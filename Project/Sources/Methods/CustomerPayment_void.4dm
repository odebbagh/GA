//%attributes = {}
// CustomerPayment_void: item action "Void the payment..." of Receive payment
// (CustomerPayment.entryDefinition). Outside Modify: the payment, its entry and the invoices it
// paid change together in one transaction (ga_receivables.voidPayment). Asks first.

var $payment : cs.CustomerPaymentEntity
var $errors : Collection
var $result : Object
var $message; $money : Text

If (Form.current_item=Null)
	return
End if
If (Form.sfw.checkIsInModification())
	cs.sfw_dialog.me.alert("Save or cancel the changes first.")
	return
End if
$payment:=ds.CustomerPayment.get(Form.current_item.UUID)  // as saved
If ($payment=Null)
	return
End if
$money:="###,###,##0.00"
$errors:=cs.ga_receivables.me.checkVoid($payment)
If ($errors.length>0)
	cs.sfw_dialog.me.alert("Payment #"+String($payment.number)+" cannot be voided:\r\r- "+$errors.join("\r- "))
	return
End if
$message:="Void payment #"+String($payment.number)+" of "+String($payment.amount; $money)+" from "+(($payment.customer=Null) ? "?" : $payment.customer.name)+"?\r\r"
$message+="Its journal entry is voided: the invoices it paid ("+$payment.lines.extract("invoice.invoiceNumber").join(", ")+") are open again"
If ($payment.unappliedAmount>0)
	$message+=" and the customer loses the credit of "+String($payment.unappliedAmount; $money)
End if
$message+=". Do this for a check that bounced or a payment typed by mistake. The payment stays in the list (view Void payments) with its number. This cannot be undone."
If (Not(cs.sfw_dialog.me.confirm($message; "Void"; "Cancel")))
	return
End if
$result:=cs.ga_receivables.me.voidPayment($payment)
If (Not($result.success))
	cs.sfw_dialog.me.alert("Nothing was changed:\r\r- "+$result.errors.join("\r- "))
	return
End if

Form.current_item.reload()
Form.current_clone:=Form.current_item.clone()
If (Form.subForm#Null)
	Form.subForm.previousItemUUID:=""
	Form.subForm:=Form.subForm
End if
cs.sfw_dialog.me.info("Payment #"+String($payment.number)+" is void.")
