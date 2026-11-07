//%attributes = {}
// Lead_createQuote
// "Create quote": the item action of the Leads entry (Lead.entryDefinition). A new quote from the
// saved lead (ga_sales.createQuoteFromLead: customer, owner, service, contacts), the lead linked to
// it, then the quote opens in its own window to be completed (lines...).
// Not in Modify: both records are saved here, and sfw owns the transaction of Modify.
#DECLARE()

var $lead : cs:C1710.LeadEntity
var $result : Object

If (Form:C1466.current_item=Null:C1517)
	return
End if
If (Form:C1466.sfw.checkIsInModification())
	cs:C1710.sfw_dialog.me.alert("Save or cancel the changes first.")
	return
End if
$lead:=ds:C1482.Lead.get(Form:C1466.current_item.UUID)  // as saved
If ($lead=Null:C1517)
	return
End if
If (cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_Customer))
	cs:C1710.sfw_dialog.me.alert("Lead "+$lead.leadCode+" has no customer: choose it first.")
	return
End if
If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_Quote))) && ($lead.quote#Null:C1517)
	If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Lead "+$lead.leadCode+" is linked to quote "+$lead.quote.code+".\rCreate a new quote? The lead will be linked to the new one."; "Create"; "Cancel")))
		return
	End if
End if

$result:=cs:C1710.ga_sales.me.createQuoteFromLead($lead)
If (Not:C34(Bool:C1537($result.success)))
	cs:C1710.sfw_dialog.me.alert($result.message)
	return
End if

// the lead on screen shows its new quote, with no change seen at the next Save
Form:C1466.current_item.reload()
If (Form:C1466.subForm#Null:C1517)  // the sfw window: the panel refreshes on its bound variable change
	Form:C1466.current_clone:=Form:C1466.current_item.clone()
	Form:C1466.subForm.refreshQuote:=True:C214
	Form:C1466.subForm:=Form:C1466.subForm
Else
	cs:C1710.panel_lead.me.drawPup_quote()
End if
cs:C1710.sfw_eventManager.me.refresh($lead.UUID; Form:C1466.sfw.entry)

Form:C1466.sfw.openInANewWindow($result.quote; "salesAndQuotes"; "quote")
