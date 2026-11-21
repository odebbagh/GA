//%attributes = {}
// _import_openReceivables($options)
// Phase 1f: the invoices customers still owe in legacy, as invoices of the new application.
// Reads openReceivables from Project/imports/openingBalances_export.json (legacy
// _export_openingBalances, [Receivables] not settled).
//
// For someone new to accounting: the opening entry already put the TOTAL customers owe on the
// accounts receivable account (1030-0). This import brings the DETAIL behind that total - which
// customer owes which invoice, since when, how much is left - so payments received from now on
// can be applied to them (Phase 1b). Nothing is written to the books here: the amount is
// already in the opening balance (counting it again would double it).
//
// Each legacy invoice (R_type "") becomes, or updates, a JobInvoice:
//   status "Posted", isLegacy (read-only, "Posted in legacy"), number = the legacy invoice number
//   job      the job of that number when it was imported (open jobs only: legacy archives a job
//            once invoiced, so most have none - the invoice then stands on its own)
//   customer by name, else by code
//   date / due   Idate, + the customer's term (else the default term)
//   total    TotalInv; moreData.legacyAR keeps every legacy amount and openBalance = NetDue
//            (legacy's own amount due), with the partial payments (the "PY" rows) listed
// An invoice imported before and no longer open in the file gets openBalance 0 (paid since).
// The report (Project/imports/open_receivables.txt) compares, per customer, what the invoices
// say with the accounts receivable balance of the opening entry: the difference is what the
// accountant has to explain before payments are applied.
// Re-runnable. Step of _import_accounting / _import_all, after _import_customerAR and
// _import_openingBalances. $options (optional): {unattended: True}.
#DECLARE($options : Object)

var $file : 4D.File
var $data; $row; $p; $byCustomer; $legacy : Object
var $rows; $payments; $report; $seen; $problems; $keys : Collection
var $invoice : cs.JobInvoiceEntity
var $job : cs.JobEntity
var $customer : cs.CustomerEntity
var $term : cs.PaymentTermEntity
var $ar : cs.GLAccountEntity
var $date; $periodEnd : Date
var $key : Text
var $created; $updated; $closed; $noCustomer; $withJob; $differs : Integer
var $openTotal; $arBalance : Real
var $existing : cs.JobInvoiceSelection
var $save : Object

$file:=Folder(fk database folder).folder("Project/imports").file("openingBalances_export.json")
If (Not($file.exists))
	_import_notify($options; "Import file not found: "+$file.platformPath+"\r\rRun _export_openingBalances (or _export_accounting) in the legacy application and copy the file here.")
	return
End if
$data:=JSON Parse($file.getText())
$periodEnd:=Date(Substring(String($data.periodEnd); 1; 10))
$rows:=($data.openReceivables=Null) ? [] : $data.openReceivables
$problems:=[]
$seen:=[]
$byCustomer:={}

ds.startTransaction()
For each ($row; $rows.query("R_type = :1"; ""))
	$customer:=_import_openReceivablesCust($row)
	If ($customer=Null)
		$noCustomer+=1
		$problems.push("Invoice "+String($row.Invoice)+": customer \""+String($row.Customer)+"\" ("+String($row.custid)+") not found - not imported")
		continue
	End if

	// the invoice imported before, else the one of its job, else a new one
	$invoice:=ds.JobInvoice.query("isLegacy = :1 AND moreData.legacyAR.invoice = :2"; True; Num($row.Invoice)).first()
	$job:=ds.Job.query("jobNumber = :1"; Num($row.Invoice)).first()
	If ($invoice=Null) && ($job#Null)
		$invoice:=$job.invoices.query("status # :1"; "Void").first()
	End if
	If ($invoice=Null)
		$invoice:=ds.JobInvoice.new()
		$invoice.invoiceNumber:=String($row.Invoice)
		$invoice.UUID_Job:=($job=Null) ? ("0"*32) : $job.UUID
		$created+=1
	Else
		$updated+=1
	End if
	$withJob+=Num($job#Null)

	$payments:=$rows.query("R_type = :1 AND Invoice = :2"; "PY"; $row.Invoice)
	$date:=Date(String($row.Idate))
	$term:=cs.ga_invoicePosting.me.termOf($customer)
	$invoice.UUID_Customer:=$customer.UUID
	$invoice.UUID_PaymentTerm:=($term=Null) ? ("0"*32) : $term.UUID
	$invoice.invoiceDate:=$date
	$invoice.dueStmp:=cs.sfw_stmp.me.build(($term=Null) ? Add to date($date; 0; 0; 30) : $term.dueDate($date); ?00:00:00?)
	$invoice.status:="Posted"
	$invoice.isLegacy:=True
	$invoice.total:=Num($row.TotalInv)
	$invoice.postedTotal:=Num($row.TotalInv)
	$invoice.moreData:=$invoice.moreData || {}
	$invoice.moreData.legacyAR:={\
		invoice: Num($row.Invoice); \
		custid: String($row.custid); \
		customer: String($row.Customer); \
		date: String($row.Idate); \
		saleAmount: Num($row.Saleamt); \
		salesTax: Num($row.SalesTax); \
		freight: Num($row.Freight); \
		totalInv: Num($row.TotalInv); \
		amountPaid: Num($row.Amt_Paid); \
		netDue: Num($row.NetDue); \
		openBalance: Round(Num($row.NetDue); 2); \
		depositSlip: Num($row.D_slip); \
		poNumber: String($row.POnum); \
		doubtful: Bool($row.Doubtful); \
		currency: String($row.Currency); \
		division: String($row.Division); \
		payments: $payments; \
		periodEnd: String($data.periodEnd); \
		importedAt: cs.sfw_stmp.me.now()}
	If (Round(Num($row.TotalInv)-Num($row.Amt_Paid); 2)#Round(Num($row.NetDue); 2))
		$differs+=1
		$problems.push("Invoice "+String($row.Invoice)+" ("+$customer.name+"): legacy net due "+String(Num($row.NetDue); "###,###,##0.00")+" but total - paid = "+String(Num($row.TotalInv)-Num($row.Amt_Paid); "###,###,##0.00")+" - net due kept")
	End if
	$save:=$invoice.save()
	If (Not($save.success))
		$problems.push("Invoice "+String($row.Invoice)+" could not be saved: "+String($save.statusText))
		continue
	End if
	$seen.push($invoice.UUID)
	$key:=$customer.name
	$byCustomer[$key]:=Round(Num($byCustomer[$key])+$invoice.moreData.legacyAR.openBalance; 2)
	$openTotal+=$invoice.moreData.legacyAR.openBalance
End for each

// imported before, no longer open in legacy: paid since
$existing:=ds.JobInvoice.query("isLegacy = :1 AND moreData.legacyAR.openBalance # :2"; True; 0)
For each ($invoice; $existing)
	If ($seen.indexOf($invoice.UUID)=-1)
		$invoice.moreData.legacyAR.openBalance:=0
		$invoice.moreData.legacyAR.closedByImportAt:=cs.sfw_stmp.me.now()
		$invoice.save()
		$closed+=1
	End if
End for each
ds.validateTransaction()

// the reconciliation with the books
$ar:=cs.ga_ledger.me.defaultAccount("DefaultA/R"; "")
$arBalance:=($ar=Null) ? 0 : cs.ga_ledger.me.accountBalance($ar; $periodEnd; "")
$report:=[]
$report.push("OPEN RECEIVABLES (legacy invoices still owed) - "+String(Current date)+" "+String(Current time; HH MM))
$report.push("File: "+$file.platformPath+" - balances at the end of "+String($periodEnd))
$report.push("Invoices: "+String($created+$updated)+" ("+String($created)+" created, "+String($updated)+" updated, "+String($withJob)+" linked to an imported job) - customer not found: "+String($noCustomer)+" - no longer open: "+String($closed))
$report.push("Open in the invoices: "+String($openTotal; "###,###,##0.00")+" - accounts receivable in the books ("+(($ar=Null) ? "no A/R account" : $ar.label)+") at "+String($periodEnd)+": "+String($arBalance; "###,###,##0.00"))
$report.push("Difference to explain: "+String(Round($arBalance-$openTotal; 2); "###,###,##0.00;-###,###,##0.00;0.00")+" - invoices whose net due and total - paid differ: "+String($differs))
$report.push("")
$report.push("PER CUSTOMER (open amount)")
$keys:=OB Keys($byCustomer).orderBy(ck ascending)
For each ($key; $keys)
	$report.push("  "+Substring($key+(" "*45); 1; 45)+String($byCustomer[$key]; "###,###,##0.00"))
End for each
If ($problems.length>0)
	$report.push("")
	$report.push("TO CHECK")
	For each ($key; $problems)
		$report.push("  "+$key)
	End for each
End if
$file.parent.file("open_receivables.txt").setText($report.join("\r\n"))
_import_notify($options; $report.slice(2; 5).join("\r")+"\rReport: Project/imports/open_receivables.txt")
