//%attributes = {}
// JobInvoice_receivePayment: "Receive payment..." of the invoice panel (Status pop-up) and of
// the Invoices item actions. The quick way for the usual case, one check for one invoice: asks
// the amount (the balance due by default), records a payment dated today into Undeposited
// funds, applied to this invoice, then opens it (Receive payment) to change anything there
// (date, method, check number, other invoices of the customer...).

var $invoice : cs.JobInvoiceEntity
var $payment : cs.CustomerPaymentEntity
var $account : cs.GLAccountEntity
var $answer; $check; $result : Object
var $rows : Collection
var $row : Object
var $amount; $due : Real
var $money : Text

If (Form.current_item=Null)
	return
End if
If (Form.sfw.checkIsInModification())
	cs.sfw_dialog.me.alert("Save or cancel the changes first.")
	return
End if
$invoice:=ds.JobInvoice.get(Form.current_item.UUID)
If ($invoice=Null)
	return
End if
If (Not($invoice.canReceivePayment))
	cs.sfw_dialog.me.alert("Invoice "+$invoice.invoiceNumber+" has nothing to pay: it must be posted, with a customer and a balance due.")
	return
End if
$money:="###,###,##0.00"
$due:=$invoice.balanceDue
$answer:=cs.sfw_dialog.me.request("Payment received for invoice "+$invoice.invoiceNumber+" ("+$invoice.customer.name+"), balance due "+String($due; $money)+".\r\rAmount received today:"; String($due; "#########0.00"); "Next"; "Cancel"; "trimSpace"; "notEmpty")
If (Not(Bool($answer.ok)))
	return
End if
$amount:=Round(Num(Replace string(String($answer.answer); ","; "")); 2)
If ($amount<=0)
	cs.sfw_dialog.me.alert("The amount must be more than 0.")
	return
End if

$payment:=ds.CustomerPayment.new()
$payment.loadAfterCreation()
$payment.UUID_Customer:=$invoice.UUID_Customer
$payment.amount:=$amount
$account:=cs.ga_ledger.me.defaultAccount("UndepositedFunds"; "")
If ($account=Null)
	cs.sfw_dialog.me.alert("No account has the role Undeposited funds (Chart of Accounts): open Receive payment and choose the bank account the money went to.")
	return
End if
$rows:=cs.ga_receivables.me.rowsForPayment($payment; True)
$row:=$rows.query("UUID_JobInvoice = :1"; $invoice.UUID).first()
$row.apply:=($amount>$row.open) ? $row.open : $amount
$check:=cs.ga_receivables.me.checkPayment($payment; $rows)
If (Not($check.success))
	cs.sfw_dialog.me.alert("The payment cannot be recorded:\r\r- "+$check.errors.join("\r- "))
	return
End if
If (Not(cs.sfw_dialog.me.confirm("Record a payment of "+String($amount; $money)+" from "+$invoice.customer.name+", dated today, into "+$account.label+"?\r\r"+\
"Invoice "+$invoice.invoiceNumber+" gets "+String($row.apply; $money)+(($check.warnings.length=0) ? "." : ".\r"+$check.warnings.join("\r"))+\
"\r\rThe payment opens next: change the method, the check number or the date there if needed."; "Record"; "Cancel")))
	return
End if

ds.startTransaction()
$result:=cs.ga_receivables.me.writePayment($payment; $rows)
If (Not($result.success))
	ds.cancelTransaction()
	cs.sfw_dialog.me.alert("Nothing was recorded:\r\r- "+$result.errors.join("\r- "))
	return
End if
ds.validateTransaction()

Form.current_item.reload()
Form.current_clone:=Form.current_item.clone()
If (Form.subForm#Null)
	Form.subForm.previousItemUUID:=""
	Form.subForm:=Form.subForm
Else
	Form.previousItemUUID:=""
	cs.panel_jobInvoice.me.formMethod()
End if
Form.sfw.openInANewWindow($payment; "accounting"; "receivePayment")
