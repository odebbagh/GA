//%attributes = {}
// Quote_lifecycleAction
// The lifecycle item actions of the Quotes entry (Quote.entryDefinition), each a one-line method:
// Quote_markAsSent ("sent"), Quote_closeWon ("won"), Quote_closeLost ("lost"), Quote_reopen
// ("reopen"), Quote_voidRestore ("void": voids, or restores a voided quote).
// Not in Modify (activateIf): the saved quote is changed here with its lead and follow-ups, in one
// transaction (QuoteEntity.markAsSent / close / reopen / setVoided), then the panel shows it again,
// as Quote_newRevision does.
#DECLARE($action : Text)

var $quote : cs:C1710.QuoteEntity
var $answer; $result : Object
var $message : Text

If (Form:C1466.current_item=Null:C1517)
	return
End if
If (Form:C1466.sfw.checkIsInModification())
	cs:C1710.sfw_dialog.me.alert("Save or cancel the changes first.")
	return
End if
$quote:=ds:C1482.Quote.get(Form:C1466.current_item.UUID)  // as saved
If ($quote=Null:C1517)
	return
End if

Case of
	: ($action="sent")
		If ($quote.stmpSent>0)
			If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Quote "+$quote.code+" was marked as sent on "+String:C10($quote.sentDate)+".\rMark it as sent again today?"; "Mark as sent"; "Cancel")))
				return
			End if
		End if
		$result:=$quote.markAsSent()
		
	: ($action="won") || ($action="lost")
		$answer:=cs:C1710.sfw_dialog.me.request("Quote "+$quote.code+" "+$action+". Reason (also written on its lead):"; ""; Choose:C955($action="won"; "Close as won"; "Close as lost"); "Cancel"; "trimSpace")
		If (Not:C34(Bool:C1537($answer.ok)))
			return
		End if
		$result:=$quote.close($action="won"; String:C10($answer.answer))
		
	: ($action="reopen")
		If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Reopen quote "+$quote.code+"?\rIts lead keeps its stage: change it on the lead if needed."; "Reopen"; "Cancel")))
			return
		End if
		$result:=$quote.reopen()
		
	: ($action="void")
		If ($quote.voided)
			If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Restore quote "+$quote.code+"?"; "Restore"; "Cancel")))
				return
			End if
			$result:=$quote.setVoided(False:C215; "")
		Else
			$answer:=cs:C1710.sfw_dialog.me.request("Void quote "+$quote.code+"? It stays in the list, greyed, and can no longer be changed. Note (why):"; ""; "Void"; "Cancel"; "trimSpace")
			If (Not:C34(Bool:C1537($answer.ok)))
				return
			End if
			$result:=$quote.setVoided(True:C214; String:C10($answer.answer))
		End if
		
	Else
		return
End case

If (Not:C34(Bool:C1537($result.success)))
	cs:C1710.sfw_dialog.me.alert($result.message)
	return
End if

// the quote on screen, and no change seen at the next Save
Form:C1466.current_item.reload()
If (Form:C1466.subForm#Null:C1517)  // the sfw window: the panel refreshes on its bound variable change
	Form:C1466.current_clone:=Form:C1466.current_item.clone()
	Form:C1466.subForm.refreshLifecycle:=True:C214
	Form:C1466.subForm:=Form:C1466.subForm
Else
	cs:C1710.panel_quote.me.refreshAfterLifecycle()
End if
cs:C1710.sfw_eventManager.me.refresh($quote.UUID; Form:C1466.sfw.entry)

// what else happened
$message:=""
If ($result.followUp#Null:C1517)
	$message+="A follow-up is scheduled on "+String:C10($result.followUp.followUPDate)+".\r"
End if
If (Num:C11($result.cancelledFollowUps)>0)
	$message+=String:C10($result.cancelledFollowUps)+" pending follow-up(s) cancelled.\r"
End if
If ($result.problems#Null:C1517) && ($result.problems.length>0)
	$message+=$result.problems.join("\r")
End if
If ($message#"")
	cs:C1710.sfw_dialog.me.info($message)
End if
