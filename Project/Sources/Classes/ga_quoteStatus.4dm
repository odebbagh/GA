// ga_quoteStatus
// The automatic status changes of a quote (the client, October 2026: a quote that became an order
// must not stay Active in the reports). An event of the quote's life (a customer PO entered on it,
// a new revision...) runs the rules of rules(). The actions reuse the quote lifecycle
// (QuoteEntity.close / markAsSent), which saves the quote with its lead and follow-ups in one
// transaction and writes the history line.
// Called by PurchaseOrderEntity (afterCreation, afterSave, beforeDelete), QuoteEntity.newRevision,
// _fix_quoteStatusFromPOs and ga_demoCheck. Nothing here depends on the sfw callbacks: code that
// saves a PO itself calls onPurchaseOrderSaved.
// To add a rule: one line in rules() and, for a new event, a call to apply() where it happens.

singleton Class constructor


	//Mark:-Rules
	// event: what happened; action: "won" / "lost" (QuoteEntity.close), "sent"
	// (QuoteEntity.markAsSent) or "status:<code>" (the status only, e.g. "status:RFU"); enabled:
	// False keeps a rule written but inactive; label: shown in the messages and the history
Function rules()->$rules : Collection
	$rules:=New collection:C1472(\
		New object:C1471("event"; "poLinked"; "action"; "won"; "enabled"; True:C214; "label"; "Customer PO entered on the quote"); \
		New object:C1471("event"; "revisionSaved"; "action"; "sent"; "enabled"; False:C215; "label"; "New revision saved"))  // to confirm with the client

	// runs the enabled rules of $event on $quote (as saved). $context: {origin: what caused it, for
	// the history ("customer PO 1234"); reason: the W/L reason of "won" / "lost"}. Only an open
	// quote changes; a lost or voided one gets a message. Returns {changed; messages}
Function apply($event : Text; $quote : cs:C1710.QuoteEntity; $context : Object)->$result : Object
	var $rule; $res : Object

	$result:=New object:C1471("changed"; False:C215; "messages"; New collection:C1472)
	If ($quote=Null:C1517)
		return
	End if
	If ($context=Null:C1517)
		$context:=New object:C1471
	End if
	For each ($rule; This:C1470.rules().query("event = :1 and enabled = :2"; $event; True:C214))
		$quote.reload()  // as saved, also after a previous rule
		Case of
			: ($quote.voided)
				$result.messages.push("Quote "+$quote.code+" is voided: its status is not changed ("+$rule.label+").")
			: ($quote.outcome="lost")
				$result.messages.push("Quote "+$quote.code+" is closed as lost: its status is not changed ("+$rule.label+"). Reopen it if the order is confirmed.")
			: ($quote.isClosed)
				// already won or closed: nothing to do
			: ($rule.action="sent") && ($quote.stmpSent>0)
				// already sent: a later revision does not send it again
			Else
				$res:=This:C1470._run($rule; $quote; $context)
				If (Bool:C1537($res.success))
					$result.changed:=True:C214
					$result.messages.push("Quote "+$quote.code+" is now "+String:C10($quote.status.name)+" ("+$rule.label+").")
					If (Num:C11($res.cancelledFollowUps)>0)
						$result.messages.push(String:C10($res.cancelledFollowUps)+" pending follow-up(s) of the quote cancelled.")
					End if
					If ($res.followUp#Null:C1517)
						$result.messages.push("A follow-up is scheduled on "+String:C10($res.followUp.followUPDate)+".")
					End if
					If ($res.problems#Null:C1517)
						$result.messages.combine($res.problems)
					End if
				Else
					$result.messages.push(String:C10($res.message)+" Change its status by hand ("+$rule.label+").")
				End if
		End case
	End for each

	// the action of $rule on $quote: {success; message; ...} as the lifecycle functions return it
Function _run($rule : Object; $quote : cs:C1710.QuoteEntity; $context : Object)->$res : Object
	var $origin; $code; $previous : Text

	$origin:=Choose:C955(String:C10($context.origin)=""; ""; "Automatic: "+String:C10($context.origin)+".")
	Case of
		: ($rule.action="won") || ($rule.action="lost")
			$res:=$quote.close($rule.action="won"; String:C10($context.reason); $origin)

		: ($rule.action="sent")
			$res:=$quote.markAsSent($origin)

		: (Position:C15("status:"; $rule.action)=1)
			$code:=Substring:C12($rule.action; 8)
			$res:=New object:C1471("success"; False:C215; "message"; "")
			If (ds:C1482.QuoteStatus.query("code == :1"; $code).first()=Null:C1517)
				$res.message:="There is no quote status \""+$code+"\"."
				return
			End if
			$previous:=String:C10($quote.status.name)
			ds:C1482.startTransaction()
			$quote._setStatus($code)
			If ($quote._saveIn($res))
				ds:C1482.validateTransaction()
				cs:C1710.ga_events.me.addEvent("quote"; $quote.UUID; "quoteAutoStatus"; "Status changed automatically"; New collection:C1472(\
					"Status: "+$previous+" -> "+String:C10($quote.status.name)+" ("+$rule.label+")."; \
					$origin).filter(Formula:C1597($1.result:=(String:C10($1.value)#""))))
				$res.success:=True:C214
			End if

		Else
			$res:=New object:C1471("success"; False:C215; "message"; "Unknown quote status rule \""+String:C10($rule.action)+"\".")
	End case


	//Mark:-Events
	// a PO saved: when its quote link changed, the new quote gets the "poLinked" rules and the
	// previous one is checked by onPurchaseOrderRemoved. Only a change of link counts, so a quote
	// reopened on purpose is not closed again by an edit of its PO. $previousQuoteUUID: the link
	// before the save ("0"*32 for a new PO). Returns {changed; messages}
Function onPurchaseOrderSaved($po : cs:C1710.PurchaseOrderEntity; $previousQuoteUUID : Text)->$result : Object
	var $res : Object
	var $poText : Text

	$result:=New object:C1471("changed"; False:C215; "messages"; New collection:C1472)
	If ($po=Null:C1517)
		return
	End if
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($previousQuoteUUID))
		$previousQuoteUUID:="0"*32
	End if
	If ($po.UUID_Quote=$previousQuoteUUID)
		return
	End if
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($po.UUID_Quote))) && ($po.quote#Null:C1517)
		$poText:=This:C1470.poText($po)
		$res:=This:C1470.apply("poLinked"; $po.quote; New object:C1471("origin"; "customer PO "+$poText; "reason"; "Customer PO "+$poText))
		$result.changed:=$res.changed
		$result.messages.combine($res.messages)
	End if
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($previousQuoteUUID)))
		$result.messages.combine(This:C1470.onPurchaseOrderRemoved($previousQuoteUUID; $po.UUID).messages)
	End if

	// PO $poUUID no longer on quote $quoteUUID (another quote picked, or the PO deleted): nothing
	// is undone (the client, October 2026); a quote won and left without a PO gets a message.
	// Returns {changed; messages}
Function onPurchaseOrderRemoved($quoteUUID : Text; $poUUID : Text)->$result : Object
	var $quote : cs:C1710.QuoteEntity

	$result:=New object:C1471("changed"; False:C215; "messages"; New collection:C1472)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($quoteUUID))
		return
	End if
	$quote:=ds:C1482.Quote.get($quoteUUID)
	Case of
		: ($quote=Null:C1517)
		: ($quote.outcome#"won")
		: (ds:C1482.PurchaseOrder.query("UUID_Quote = :1 and UUID # :2"; $quoteUUID; $poUUID).length>0)
		Else
			$result.messages.push("Quote "+$quote.code+" has no customer PO left but stays "+String:C10($quote.status.name)+": use Reopen on the quote if the PO was entered on it by mistake.")
	End case

	// a new revision of $quote saved (QuoteEntity.newRevision); $revisionLabel: the level it is
	// frozen as. Returns {changed; messages}
Function onRevisionSaved($quote : cs:C1710.QuoteEntity; $revisionLabel : Text)->$result : Object
	$result:=This:C1470.apply("revisionSaved"; $quote; New object:C1471("origin"; "new revision "+$revisionLabel))

	// the PO number as users read it
Function poText($po : cs:C1710.PurchaseOrderEntity)->$text : Text
	$text:=Choose:C955(String:C10($po.poNum)#""; String:C10($po.poNum); String:C10($po.poNumber))

