//%attributes = {}
// JobInvoice_action
// The accounting item actions of Invoices (JobInvoice.entryDefinition), each a one-line method:
// JobInvoice_post ("post"), JobInvoice_unpost ("unpost": back to draft), JobInvoice_void ("void").
// Not in Modify (activateIf): the saved invoice is changed with its journal entry, its PO and its
// job in one transaction (ga_invoicePosting), then the panel shows it again, as
// Quote_lifecycleAction does. Each action says what it will do and asks first.
#DECLARE($action : Text)

var $invoice : cs.JobInvoiceEntity
var $check; $result; $amounts; $income : Object
var $customer : cs.CustomerEntity
var $term : cs.PaymentTermEntity
var $date; $due : Date
var $message; $money; $poText : Text
var $entry : cs.JournalEntryEntity

If (Form.current_item=Null)
	return 
End if 
If (Form.sfw.checkIsInModification())
	cs.sfw_dialog.me.alert("Save or cancel the changes first.")
	return 
End if 
$invoice:=ds.JobInvoice.get(Form.current_item.UUID)  // as saved
If ($invoice=Null)
	return 
End if 
$money:="###,###,##0.00"
$amounts:=cs.ga_invoicePosting.me.amounts($invoice)
$poText:="the PO"
If ($invoice.job#Null)
	If ($invoice.job.purchaseOrder#Null)
		$poText:="PO "+String($invoice.job.purchaseOrder.poNumber)
	End if
End if

Case of 
	: ($action="post")
		$date:=cs.ga_invoicePosting.me.accountingDate($invoice)
		$check:=cs.ga_invoicePosting.me.checkPost($invoice; $date)
		If ($check.errors.length>0)
			cs.sfw_dialog.me.alert("Invoice "+$invoice.invoiceNumber+" cannot be posted:\r\r- "+$check.errors.join("\r- "))
			return 
		End if 
		$customer:=cs.ga_invoicePosting.me.customerOf($invoice)
		$term:=cs.ga_invoicePosting.me.termOf($customer)
		$due:=($term=Null) ? Add to date($date; 0; 0; 30) : $term.dueDate($date)
		$income:=cs.ga_invoicePosting.me.incomeAccount($invoice.job)
		$message:="Post invoice "+$invoice.invoiceNumber+" to the books?\r\r"
		$message+=$customer.name+" will owe "+String($amounts.total; $money)+", due "+String($due)+" ("+(($term=Null) ? "30 days, no term" : $term.label)+").\r\r"
		$message+="Entry dated "+String($date)+":\r"
		$message+="  Accounts receivable  debit "+String($amounts.total; $money)+"\r"
		$message+="  "+(($income.create) ? $income.name+" (new account)" : $income.account.label)+"  credit "+String($amounts.income; $money)+"\r"
		If ($amounts.freight#0)
			$message+="  Freight billed  credit "+String($amounts.freight; $money)+"\r"
		End if 
		If ($amounts.tax#0)
			$message+="  Sales tax payable  credit "+String($amounts.tax; $money)+"\r"
		End if 
		$message+="\rThe job is marked invoiced and "+$poText+" billed +"+String($amounts.total; $money)+"."
		If ($check.warnings.length>0)
			$message+="\r\rWarning:\r- "+$check.warnings.join("\r- ")
		End if 
		If (Not(cs.sfw_dialog.me.confirm($message; "Post"; "Cancel")))
			return 
		End if 
		$result:=cs.ga_invoicePosting.me.post($invoice; $date)
		If ($result.success)
			$message:="Invoice "+$invoice.invoiceNumber+" posted: journal entry #"+String($result.entryNumber)+"."
		End if 
		
	: ($action="unpost")
		$entry:=cs.ga_ledger.me.entriesOf("JobInvoice"; $invoice.UUID).query("isVoid = :1"; False).first()
		$message:="Put invoice "+$invoice.invoiceNumber+" back to draft?\r\r"
		$message+="Its journal entry"+(($entry=Null) ? "" : " #"+String($entry.number))+" is voided, the customer no longer owes "+String($invoice.postedTotal; $money)+", "+$poText+" gets "+String($invoice.postedTotal; $money)+" back and the job is no longer marked invoiced."
		If (Not(cs.sfw_dialog.me.confirm($message; "Back to draft"; "Cancel")))
			return 
		End if 
		$result:=cs.ga_invoicePosting.me.unpost($invoice; "Draft")
		$message:="Invoice "+$invoice.invoiceNumber+" is a draft again."
		
	: ($action="void")
		If (cs.ga_invoicePosting.me.isPosted($invoice))
			$message:="Void invoice "+$invoice.invoiceNumber+"?\r\rIts journal entry is voided, the customer no longer owes "+String($invoice.postedTotal; $money)+" and "+$poText+" gets it back. "
		Else 
			$message:="Void draft invoice "+$invoice.invoiceNumber+"? It is not in the books, so nothing else changes. "
		End if 
		$message+="The invoice stays in the list (view Void invoices) with its number and cannot be posted any more. This cannot be undone."
		If (Not(cs.sfw_dialog.me.confirm($message; "Void"; "Cancel")))
			return 
		End if 
		$result:=cs.ga_invoicePosting.me.unpost($invoice; "Void")
		$message:="Invoice "+$invoice.invoiceNumber+" is void."
		
	Else 
		return 
End case 

If (Not(Bool($result.success)))
	cs.sfw_dialog.me.alert("Nothing was changed:\r\r- "+$result.errors.join("\r- "))
	return 
End if 

// the invoice on screen again, and no change seen at the next Save
Form.current_item.reload()
Form.current_clone:=Form.current_item.clone()
If (Form.subForm#Null)  // called from the item actions (the sfw window): the panel refreshes on its bound variable change
	Form.subForm.previousItemUUID:=""
	Form.subForm:=Form.subForm
Else   // called from the panel itself (status pop-up)
	Form.previousItemUUID:=""
	cs.panel_jobInvoice.me.formMethod()
End if
If ($result.warnings#Null) && ($result.warnings.length>0)
	$message+="\r\r"+$result.warnings.join("\r")
End if 
cs.sfw_dialog.me.info($message)
