//%attributes = {}
// _import_customerCredits($options)
// Phase 1b: the customer credits still open in legacy at the start date (money paid in advance,
// or paid too much, not applied to an invoice yet), as payments of the new application, so they
// can be used on invoices (Receive payment, method "Apply credit").
// Reads Project/imports/customerCredits_export.json (legacy _export_customerCredits: per customer,
// credits - debits on the Customer advances account "CusAdv", role DefaultCustomerAdvance).
//
// For someone new to accounting: the opening entry already put the TOTAL of these credits on the
// Customer advances account (a liability: we owe that money back, in work or in cash). This
// import brings the DETAIL - which customer has how much - and writes nothing to the books
// (counting it again would double it).
//
// Each credit becomes, or updates, a CustomerPayment: isLegacy (read-only, "From legacy"), status
// Posted, dated the start date, amount = unappliedAmount = the credit, method "Legacy", deposit
// account = the Customer advances account. A legacy credit imported before and no longer in the
// file gets amount 0 (used since). Credits of a customer not found, or negative, are reported,
// not imported.
// The report (Project/imports/customer_credits.txt) compares the total with the Customer advances
// balance of the opening entry.
// Re-runnable. Step of _import_accounting / _import_all, after _import_openingBalances and
// _import_customerAR. $options (optional): {unattended: True}.
#DECLARE($options : Object)

var $file : 4D.File
var $data; $row : Object
var $rows; $report; $problems; $seen : Collection
var $payment : cs.CustomerPaymentEntity
var $customer : cs.CustomerEntity
var $adv; $account : cs.GLAccountEntity
var $periodEnd : Date
var $key; $line : Text
var $created; $updated; $closed; $skipped : Integer
var $total; $advBalance : Real
var $save : Object

$file:=Folder(fk database folder).folder("Project/imports").file("customerCredits_export.json")
If (Not($file.exists))
	_import_notify($options; "Import file not found: "+$file.platformPath+"\r\rRun _export_customerCredits (or _export_accounting) in the legacy application and copy the file here.")
	return
End if
$data:=JSON Parse($file.getText())
$periodEnd:=Date(Substring(String($data.periodEnd); 1; 10))
$rows:=($data.credits=Null) ? [] : $data.credits
$problems:=[]
$seen:=[]
$adv:=cs.ga_ledger.me.defaultAccount("DefaultCustomerAdvance"; "")

ds.startTransaction()
For each ($row; $rows)
	$customer:=_import_openReceivablesCust({Customer: String($row.customer); custid: ""})
	Case of
		: ($customer=Null)
			$skipped+=1
			$problems.push("Credit of "+String(Num($row.credit); "###,###,##0.00")+": customer \""+String($row.customer)+"\" not found - not imported")
			continue
		: (Num($row.credit)<0)
			$skipped+=1
			$problems.push($customer.name+": the Customer advances account shows "+String(-Num($row.credit); "###,###,##0.00")+" OWED by the customer (more used than paid) - not imported, check it in legacy")
			continue
	End case

	$key:=$customer.UUID+"|"+String($row.glac)
	$payment:=ds.CustomerPayment.query("isLegacy = :1 AND moreData.legacyCredit.key = :2"; True; $key).first()
	If ($payment=Null)
		$payment:=ds.CustomerPayment.new()
		$payment.number:=ds.sfw_Counter.getNextValue("CustomerPayment")
		$payment.UUID_PostedBy:="0"*32
		$payment.UUID_Division:="0"*32
		$created+=1
	Else
		$updated+=1
	End if
	$account:=cs.ga_ledger.me.accountByGlac(String($row.glac))
	If ($account=Null)
		$account:=$adv
	End if
	$payment.UUID_Customer:=$customer.UUID
	$payment.paymentDate:=$periodEnd
	$payment.amount:=Round(Num($row.credit); 2)
	// what was used of it here since the last run stays used
	$payment.unappliedAmount:=Round(Num($row.credit); 2)
	$payment.method:="Legacy"
	$payment.reference:="legacy"
	$payment.memo:="Credit in legacy on "+String($periodEnd)+" (account "+String($row.glac)+")"
	$payment.UUID_DepositAccount:=($account=Null) ? ("0"*32) : $account.UUID
	$payment.status:="Posted"
	$payment.isLegacy:=True
	$payment.postedStmp:=cs.sfw_stmp.me.now()
	$payment.moreData:=$payment.moreData || {}
	$payment.moreData.legacyCredit:={\
		key: $key; \
		customer: String($row.customer); \
		credit: Num($row.credit); \
		totalCredits: Num($row.totalCredits); \
		totalDebits: Num($row.totalDebits); \
		lines: Num($row.lines); \
		lastDate: String($row.lastDate); \
		glac: String($row.glac); \
		division: String($row.division); \
		periodEnd: String($data.periodEnd); \
		importedAt: cs.sfw_stmp.me.now()}
	$save:=$payment.save()
	If (Not($save.success))
		$problems.push($customer.name+": the credit could not be saved: "+String($save.statusText))
		continue
	End if
	$seen.push($payment.UUID)
	$total+=$payment.amount
End for each

// imported before, no longer in the file: used in legacy since
For each ($payment; ds.CustomerPayment.query("isLegacy = :1 AND amount # :2"; True; 0))
	If ($seen.indexOf($payment.UUID)=-1)
		$payment.amount:=0
		$payment.unappliedAmount:=0
		$payment.moreData.legacyCredit.closedByImportAt:=cs.sfw_stmp.me.now()
		$payment.save()
		$closed+=1
	End if
End for each
ds.validateTransaction()

// the reconciliation with the books (a liability: a positive balance is what we owe customers)
$advBalance:=($adv=Null) ? 0 : cs.ga_ledger.me.accountBalance($adv; $periodEnd; "")
$report:=[]
$report.push("CUSTOMER CREDITS (legacy money received, not applied yet) - "+String(Current date)+" "+String(Current time; HH MM))
$report.push("File: "+$file.platformPath+" - credits at the end of "+String($periodEnd))
$report.push("Credits: "+String($created+$updated)+" ("+String($created)+" created, "+String($updated)+" updated) - not imported: "+String($skipped)+" - no longer open: "+String($closed))
$report.push("Total imported: "+String($total; "###,###,##0.00")+" - Customer advances in the books ("+(($adv=Null) ? "no account with the role Customer advances" : $adv.label)+") at "+String($periodEnd)+": "+String($advBalance; "###,###,##0.00"))
$report.push("Difference to explain: "+String(Round($advBalance-$total; 2); "###,###,##0.00;-###,###,##0.00;0.00"))
If ($data.accounts#Null)
	$report.push("")
	$report.push("LEGACY ACCOUNTS (balance in the export)")
	For each ($row; $data.accounts)
		$report.push("  "+String($row.glac)+" "+String($row.description)+" ("+String($row.division)+"): "+String(Num($row.balance); "###,###,##0.00"))
	End for each
End if
$report.push("")
$report.push("PER CUSTOMER")
For each ($payment; ds.CustomerPayment.query("isLegacy = :1 AND amount # :2"; True; 0).orderBy("customer.name asc"))
	$report.push("  "+Substring($payment.customer.name+(" "*45); 1; 45)+String($payment.amount; "###,###,##0.00"))
End for each
If ($problems.length>0)
	$report.push("")
	$report.push("TO CHECK")
	For each ($line; $problems)
		$report.push("  "+$line)
	End for each
End if
$file.parent.file("customer_credits.txt").setText($report.join("\r\n"))
_import_notify($options; $report.slice(2; 5).join("\r")+"\rReport: Project/imports/customer_credits.txt")
