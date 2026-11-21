//%attributes = {}
// _import_customerAR
// Brings the customers' accounts receivable settings from legacy: reads
// Project/imports/customerAR_export.json (legacy _export_customerAR, from [Customer_Log]) and sets,
// on each customer matched by code (Cust_Code = Customer.code), else by name:
//   payment terms    InvPaymentTermsinDays -> the "Net N" term (created when missing); 0 or empty
//                    leaves the customer on the default term
//   credit limit     AbsoluteCreditAmount
//   credit hold      CREDIT_HOLD + HOLD_REASON
//   statements to    AP_email (the customer's accounts payable contact: who pays our invoices)
// Creates the usual payment terms first (PaymentTerm.seed). Report only / Apply; the report is
// written to Project/imports/customer_ar.txt. Safe to re-run: it sets the same values again.

// $options (optional): {unattended: True} - applies without asking and writes its messages
// to Project/imports/import_messages.txt (_import_accounting, _import_all).
#DECLARE($options : Object)

var $file : 4D:C1709.File
var $records; $report; $notFound : Collection
var $record : Object
var $customer : cs:C1710.CustomerEntity
var $term : cs:C1710.PaymentTermEntity
var $apply : Boolean
var $matched; $withTerm; $onHold; $withLimit; $withEmail; $failed; $days : Integer
var $byDays : Object
var $key; $summary : Text
var $save : Object

$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("customerAR_export.json")
If (Not:C34($file.exists))
	_import_notify($options; "Import file not found: "+$file.platformPath+"\r\rRun _export_customerAR in the legacy application and copy DataJson/customerAR_export.json here.")
	return
End if
$records:=JSON Parse:C1218($file.getText())

// what the file holds, before asking
$byDays:=New object:C1471
$notFound:=New collection:C1472
For each ($record; $records)
	$customer:=_import_customerAR_find($record)
	If ($customer=Null:C1517)
		If (Not:C34(Bool:C1537($record.void)))
			$notFound.push(String:C10($record.Cust_Code)+" "+String:C10($record.Customer))
		End if
		continue
	End if
	$matched:=$matched+1
	$days:=Num:C11($record.InvPaymentTermsinDays)
	If ($days>0)
		$withTerm:=$withTerm+1
		$byDays[String:C10($days)]:=Num:C11($byDays[String:C10($days)])+1
	End if
	$onHold:=$onHold+Num:C11(Bool:C1537($record.CREDIT_HOLD))
	$withLimit:=$withLimit+Num:C11(Num:C11($record.AbsoluteCreditAmount)>0)
	$withEmail:=$withEmail+Num:C11(String:C10($record.AP_email)#"")
End for each

$report:=New collection:C1472
$report.push("CUSTOMER A/R SETTINGS - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178; HH MM:K7:2))
$report.push("File: "+$file.platformPath+" ("+String:C10($records.length)+" legacy customers)")
$report.push("Matched: "+String:C10($matched)+" - not found (and not void in legacy): "+String:C10($notFound.length))
$report.push("With terms: "+String:C10($withTerm)+" - on credit hold: "+String:C10($onHold)+" - with a credit limit: "+String:C10($withLimit)+" - with a statement e-mail: "+String:C10($withEmail))
$summary:=""
For each ($key; OB Keys:C1719($byDays))
	$summary:=$summary+Choose:C955($summary=""; ""; ", ")+"Net "+$key+": "+String:C10($byDays[$key])
End for each
$report.push("Terms: "+Choose:C955($summary=""; "(none)"; $summary))
If ($notFound.length>0)
	$report.push("")
	$report.push("NOT FOUND")
	$report.combine($notFound.map(Formula:C1597($1.result:="  "+$1.value)))
End if
$file.parent.file("customer_ar.txt").setText($report.join("\r\n"))

$apply:=(($options#Null:C1517) && Bool:C1537($options.unattended)) || cs:C1710.sfw_dialog.me.confirm($report.slice(2; 5).join("\r")+"\r\rReport: Project/imports/customer_ar.txt"; "Apply"; "Report only")
If (Not:C34($apply))
	return
End if

ds:C1482.PaymentTerm.seed()
For each ($record; $records)
	$customer:=_import_customerAR_find($record)
	If ($customer=Null:C1517)
		continue
	End if
	$days:=Num:C11($record.InvPaymentTermsinDays)
	If ($days>0)
		$term:=ds:C1482.PaymentTerm.forDays($days)
		$customer.UUID_PaymentTerm:=$term.UUID
	End if
	$customer.creditLimit:=Num:C11($record.AbsoluteCreditAmount)
	$customer.creditHold:=Bool:C1537($record.CREDIT_HOLD)
	$customer.creditHoldReason:=String:C10($record.HOLD_REASON)
	$customer.statementEmail:=String:C10($record.AP_email)
	$customer.moreData:=$customer.moreData || New object:C1471
	$customer.moreData.legacyAR:=New object:C1471("importedAt"; cs:C1710.sfw_stmp.me.now(); \
		"InvPaymentTermsinDays"; $record.InvPaymentTermsinDays; "DelinquentCreditAmount"; $record.DelinquentCreditAmount; \
		"EmailARNotice"; $record.EmailARNotice)
	$save:=$customer.save()
	If (Not:C34($save.success))
		$failed:=$failed+1
	End if
End for each
_import_notify($options; "Customer A/R settings applied to "+String:C10($matched-$failed)+" customer(s)"+Choose:C955($failed=0; "."; ", "+String:C10($failed)+" could not be saved (open in Modify elsewhere?)."))
