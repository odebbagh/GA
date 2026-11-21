//%attributes = {}
// _import_accountingCheck($options)
// Last step of _import_accounting: compares what is now in this application with the control
// totals legacy wrote when it exported (Project/imports/accounting_export_manifest.json, from
// _export_accounting). Each line is OK or DIFFERENT; the report is
// Project/imports/accounting_import_check.txt. Read only.
#DECLARE($options : Object)

var $file : 4D.File
var $m; $tb : Object
var $lines : Collection
var $periodEnd : Date
var $opening : cs.JournalEntryEntity
var $legacyOpen : cs.JobInvoiceSelection
var $assets : cs.AssetSelection
var $credits : cs.CustomerPaymentSelection
var $ok : Boolean
var $count : Integer
var $value; $assetsSum; $liabilities; $equity : Real
var $row : Object

$file:=Folder(fk database folder).folder("Project/imports").file("accounting_export_manifest.json")
If (Not($file.exists))
	_import_notify($options; "No control totals: "+$file.platformPath+" is missing. Run _export_accounting in legacy and copy its files here.")
	return
End if
$m:=JSON Parse($file.getText())
$periodEnd:=Date(String($m.periodEnd))
$lines:=[]
$ok:=True

// the chart of accounts
$count:=ds.GLAccount.query("glac # :1"; "").length
$ok:=$ok & _import_accountingCheckLine($lines; "GL accounts (at least)"; $m.glAccounts; $count; $count>=$m.glAccounts)
$count:=ds.GLAccount.query("defaultKey # :1 AND defaultKey # :2"; ""; "DefaultBank").length
$ok:=$ok & _import_accountingCheckLine($lines; "Accounts with a legacy role"; $m.glAccountsWithRole; $count; $count>=$m.glAccountsWithRole)

// the opening entry
$opening:=ds.JournalEntry.query("type = :1 AND isVoid = :2"; "Opening"; False).first()
If ($opening=Null)
	$lines.push("DIFFERENT  Opening entry: none")
	$ok:=False
Else
	$ok:=$ok & _import_accountingCheckLine($lines; "Opening entry date"; String($periodEnd); String($opening.date); $opening.date=$periodEnd)
	$tb:=cs.ga_ledger.me.trialBalance($periodEnd; "")
	For each ($row; $tb.rows)
		Case of
			: ($row.typeCode=1)
				$assetsSum+=$row.debit-$row.credit
			: ($row.typeCode=2)
				$liabilities+=$row.credit-$row.debit
			: ($row.typeCode=4)
				$equity+=$row.credit-$row.debit
		End case
	End for each
	$ok:=$ok & _import_accountingCheckLine($lines; "Assets at "+String($periodEnd); $m.balances.assets; Round($assetsSum; 2); Round($assetsSum-$m.balances.assets; 2)=0)
	$ok:=$ok & _import_accountingCheckLine($lines; "Liabilities"; $m.balances.liabilities; Round($liabilities; 2); Round($liabilities-$m.balances.liabilities; 2)=0)
	$ok:=$ok & _import_accountingCheckLine($lines; "Equity"; $m.balances.equity; Round($equity; 2); Round($equity-$m.balances.equity; 2)=0)
	$ok:=$ok & _import_accountingCheckLine($lines; "Trial balance balanced"; "yes"; $tb.balanced ? "yes" : "no"; $tb.balanced)
	$ok:=$ok & _import_accountingCheckLine($lines; "Books locked up to"; String($periodEnd); String(cs.ga_ledger.me.closingDate()); cs.ga_ledger.me.closingDate()>=$periodEnd)
End if

// the open invoices
// every invoice this import brought in (one may have 0 left to pay: legacy still lists it as open)
$legacyOpen:=ds.JobInvoice.query("isLegacy = :1 AND moreData.legacyAR.periodEnd = :2 AND moreData.legacyAR.closedByImportAt = null"; True; String($m.periodEnd))
$value:=Round($legacyOpen.extract("moreData.legacyAR.openBalance").sum(); 2)
$ok:=$ok & _import_accountingCheckLine($lines; "Open legacy invoices"; $m.openInvoices.count; $legacyOpen.length; $legacyOpen.length=$m.openInvoices.count)
$ok:=$ok & _import_accountingCheckLine($lines; "Their amount due"; $m.openInvoices.netDue; $value; Round($value-$m.openInvoices.netDue; 2)=0)

// the customer credits not applied yet (legacy payments, _import_customerCredits)
If ($m.customerCredits#Null)
	$credits:=ds.CustomerPayment.query("isLegacy = :1 AND moreData.legacyCredit.periodEnd = :2 AND moreData.legacyCredit.closedByImportAt = null"; True; String($m.periodEnd))
	$value:=Round($credits.sum("amount"); 2)
	$ok:=$ok & _import_accountingCheckLine($lines; "Customer credits (legacy)"; $m.customerCredits.count; $credits.length; $credits.length=$m.customerCredits.count)
	$ok:=$ok & _import_accountingCheckLine($lines; "Their amount"; $m.customerCredits.total; $value; Round($value-$m.customerCredits.total; 2)=0)
Else
	$lines.push("SKIPPED    Customer credits: the legacy export predates them (re-run _export_accounting)")
End if

// customers, banks, assets
$count:=ds.Customer.query("creditHold = :1"; True).length
$ok:=$ok & _import_accountingCheckLine($lines; "Customers on credit hold (at most)"; $m.customers.onHold; $count; $count<=$m.customers.onHold)
$count:=ds.GLAccount.query("moreData.bank # null").length
$ok:=$ok & _import_accountingCheckLine($lines; "Bank accounts on their GL account"; $m.banks; $count; $count=$m.banks)
$assets:=ds.Asset.query("moreData.legacy # null")
$ok:=$ok & _import_accountingCheckLine($lines; "Assets"; $m.assets.count; $assets.length; $assets.length=$m.assets.count)
$value:=Round($assets.sum("originalCost"); 2)
$ok:=$ok & _import_accountingCheckLine($lines; "Assets cost"; $m.assets.cost; $value; Round($value-$m.assets.cost; 2)=0)

$lines.insert(0; "ACCOUNTING IMPORT CHECK - "+String(Current date)+" "+String(Current time; HH MM))
$lines.insert(1; "Against the legacy export of "+String($m.exportedAt)+", balances at the end of "+String($periodEnd)+Choose(Bool($m.isClosedPeriod); ""; " (NOT a closed month in legacy: a test)"))
$lines.insert(2; $ok ? "ALL MATCH" : "SOME DIFFER - see the DIFFERENT lines")
$lines.insert(3; "")
$file.parent.file("accounting_import_check.txt").setText($lines.join("\r\n"))
_import_notify($options; $lines.join("\r"))
