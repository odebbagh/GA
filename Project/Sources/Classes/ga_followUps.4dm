// ga_followUps
// The follow-ups (Interaction records) of leads and quotes, shared by panel_lead (Interactions
// tab) and panel_quote (Follow-ups tab): schedule, log, complete and cancel, and the automatic
// follow-ups of the trigger rules (scheduleFromTrigger).
// An interaction belongs to a lead (UUID_Lead), a quote (UUID_Quote), or both when the quote has
// a lead: the lead's and the quote's lists then both show it (list).
// Interactions are saved at once: from a panel in Modify, inside its transaction, so Cancel
// removes them with the rest of the edit.
// The dialogs (Lead_scheduleFollowUP, Lead_AddInteraction) get the lead or the quote as
// Form.current_item: both have contacts() for the Contact menu.

singleton Class constructor


	//Mark:-Lead and quote of a follow-up
	// $holder: the Lead or the Quote entity. Returns {lead; quote}, Null when there is none: a
	// lead with its quote, a quote with its lead
Function context($holder : Object)->$context : Object
	$context:=New object:C1471("lead"; Null:C1517; "quote"; Null:C1517; "holder"; $holder)
	Case of
		: ($holder=Null:C1517)
		: (OB Instance of:C1731($holder; cs:C1710.LeadEntity))
			$context.lead:=$holder
			If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($holder.UUID_Quote)))
				$context.quote:=$holder.quote
			End if
		: (OB Instance of:C1731($holder; cs:C1710.QuoteEntity))
			$context.quote:=$holder
			$context.lead:=$holder.leads.first()
	End case

	// the follow-ups shown for $holder: its own, and those of its lead or quote
Function list($holder : Object)->$interactions : cs:C1710.InteractionSelection
	var $context : Object
	$context:=This:C1470.context($holder)
	Case of
		: ($context.lead#Null:C1517) && ($context.quote#Null:C1517)
			$interactions:=ds:C1482.Interaction.query("UUID_Lead = :1 or UUID_Quote = :2"; $context.lead.UUID; $context.quote.UUID)
		: ($context.lead#Null:C1517)
			$interactions:=ds:C1482.Interaction.query("UUID_Lead = :1"; $context.lead.UUID)
		: ($context.quote#Null:C1517)
			$interactions:=ds:C1482.Interaction.query("UUID_Quote = :1"; $context.quote.UUID)
		Else
			$interactions:=ds:C1482.Interaction.newSelection()
	End case

Function typeUUID($code : Text)->$uuid : Text
	var $type : cs:C1710.InteractionTypeEntity
	$type:=ds:C1482.InteractionType.query("code == :1"; $code).first()
	$uuid:=($type=Null:C1517) ? ("0"*32) : $type.UUID

Function isScheduled($interaction : cs:C1710.InteractionEntity)->$is : Boolean
	$is:=($interaction#Null:C1517) && ($interaction.UUID_Type=This:C1470.typeUUID("SCHEDULED"))


	//Mark:-Actions (Interactions / Follow-ups menu)
	// the action menu of panel_lead (Interactions) and panel_quote (Follow-ups): $current is the
	// selected interaction, $editable the panel in Modify. True when something was saved
Function actionMenu($holder : Object; $current : cs:C1710.InteractionEntity; $editable : Boolean)->$changed : Boolean
	var $menu; $choice : Text
	var $scheduled : Boolean

	$scheduled:=This:C1470.isScheduled($current)
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Complete follow up"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--complete")
	If (Not:C34($editable)) || (Not:C34($scheduled))
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "Cancel interaction"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--cancel")
	If (Not:C34($editable)) || (Not:C34($scheduled))
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "(-")
	APPEND MENU ITEM:C411($menu; "Schedule follow up"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--schedule")
	If (Not:C34($editable))
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "Log interaction"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--log")
	If (Not:C34($editable))
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choice="--complete")
			$changed:=(This:C1470.complete($current; $holder).length>0)
		: ($choice="--cancel")
			This:C1470.cancel($current)
			$changed:=True:C214
		: ($choice="--schedule")
			$changed:=(This:C1470.schedule($holder)#Null:C1517)
		: ($choice="--log")
			$changed:=(This:C1470.log($holder).length>0)
	End case

	// "Schedule follow up": Lead_scheduleFollowUP. Returns the interaction created, or Null
Function schedule($holder : Object)->$interaction : cs:C1710.InteractionEntity
	var $context; $form : Object
	var $ref : Integer

	$context:=This:C1470.context($holder)
	$form:=New object:C1471
	$form.current_item:=$holder
	$form.creationDate:=Current date:C33()
	$form.number:=This:C1470._sequence($context)
	$form.followUPDate:=Add to date:C393(Current date:C33; 0; 0; 1)

	$ref:=Open form window:C675("Lead_scheduleFollowUP"; Sheet form window:K39:12)
	DIALOG:C40("Lead_scheduleFollowUP"; $form)
	CLOSE WINDOW:C154($ref)

	If (OK=1)
		$interaction:=This:C1470._new($context; "SCHEDULED")
		This:C1470._fill($interaction; $form)
		$interaction.save()
		$interaction.notifyIfDue()  // today: now; a later date: on that day (Interaction.notifyDueFollowUps)
	End if

	// "Log interaction": Lead_AddInteraction, a COMPLETED interaction, and the next follow-up when
	// "Next follow-up?" is ticked. Returns the interactions created
Function log($holder : Object)->$created : Collection
	var $context; $form : Object
	var $interaction : cs:C1710.InteractionEntity
	var $ref : Integer

	$created:=New collection:C1472
	$context:=This:C1470.context($holder)
	$form:=New object:C1471
	$form.current_item:=$holder
	$form.creationDate:=Current date:C33()
	$form.number:=This:C1470._sequence($context)
	$form.nextFollowUp:=False:C215
	$form.followUPDate:=Add to date:C393(Current date:C33; 0; 0; 1)

	$ref:=Open form window:C675("Lead_AddInteraction"; Sheet form window:K39:12)
	DIALOG:C40("Lead_AddInteraction"; $form)
	CLOSE WINDOW:C154($ref)

	If (OK=1)
		$interaction:=This:C1470._new($context; "COMPLETED")
		This:C1470._fill($interaction; $form)
		$interaction.save()
		$created.push($interaction)
		If (Bool:C1537($form.nextFollowUp))
			$created.push(This:C1470._next($context; $interaction; $form))
		End if
	End if

	// "Complete follow up": the scheduled follow-up becomes the call that was made (COMPLETED), with
	// its notes and outcome, dated the day of the call; the date it was planned for stays in
	// stmpFollowUp, the day it was scheduled in moreData.scheduledOn. "Next follow-up?" schedules
	// the next one. A completed follow-up is no longer notified (InteractionEntity.notifyIfDue).
	// Returns the interactions changed or created
Function complete($interaction : cs:C1710.InteractionEntity; $holder : Object)->$changed : Collection
	var $context; $form; $moreData : Object
	var $ref; $followUp : Integer

	$changed:=New collection:C1472
	If (Not:C34(This:C1470.isScheduled($interaction)))
		return
	End if
	$context:=This:C1470.context($holder)
	$form:=New object:C1471
	$form.current_item:=$holder
	$form.dialogTitle:="Complete follow-up"
	$form.creationDate:=Current date:C33()
	$form.number:=$interaction.number
	$form.notes:=$interaction.notes
	$form.UUID_Staff:=$interaction.UUID_Staff
	$form.UUID_Contact:=$interaction.UUID_Contact
	$form.UUID_Method:=$interaction.UUID_Method
	$form.UUID_Outcome:=$interaction.UUID_Outcome
	$form.UUID_Trigger:=$interaction.UUID_Trigger
	$form.nextFollowUp:=False:C215
	$form.followUPDate:=Add to date:C393(Current date:C33; 0; 0; 7)

	$ref:=Open form window:C675("Lead_AddInteraction"; Sheet form window:K39:12)
	DIALOG:C40("Lead_AddInteraction"; $form)
	CLOSE WINDOW:C154($ref)

	If (OK=1)
		$moreData:=($interaction.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($interaction.moreData)
		$moreData.scheduledOn:=$interaction.stmpCreation
		$interaction.moreData:=$moreData
		$followUp:=$interaction.stmpFollowUp
		This:C1470._fill($interaction; $form)
		$interaction.stmpFollowUp:=$followUp  // the date it was planned for, not the next one
		$interaction.UUID_Type:=This:C1470.typeUUID("COMPLETED")
		$interaction.save()
		$changed.push($interaction)
		If (Bool:C1537($form.nextFollowUp))
			$changed.push(This:C1470._next($context; $interaction; $form))
		End if
	End if

Function cancel($interaction : cs:C1710.InteractionEntity)
	If (This:C1470.isScheduled($interaction))
		$interaction.UUID_Type:=This:C1470.typeUUID("CANCELED")
		$interaction.save()
	End if


	// the SCHEDULED ones of $interactions become CANCELED (a quote won, lost or voided). Returns how many
Function cancelPending($interactions : cs:C1710.InteractionSelection)->$nb : Integer
	var $interaction : cs:C1710.InteractionEntity
	If ($interactions=Null:C1517)
		return
	End if
	For each ($interaction; $interactions.query("UUID_Type = :1"; This:C1470.typeUUID("SCHEDULED")))
		This:C1470.cancel($interaction)
		$nb+=1
	End for each


	//Mark:-Trigger rules
	// the automatic follow-up of an event: the trigger $code (InteractionTrigger) gives the number of
	// days after $baseDate (moreData.daysAfterLeadCreation, "Days until the follow-up" in
	// Lead Parameters > Interaction triggers; the name is the one of the first rule). A trigger
	// without a number of days has no rule: nothing is scheduled. Events wired so far:
	// LEAD_CREATION (LeadEntity.afterCreation), PROPOSAL_SENT (quote "Mark as sent",
	// QuoteEntity.markAsSent). To the owner of $holder, with its main contact
Function scheduleFromTrigger($code : Text; $holder : Object; $baseDate : Date)->$interaction : cs:C1710.InteractionEntity
	var $trigger : cs:C1710.InteractionTriggerEntity
	var $context : Object

	$trigger:=ds:C1482.InteractionTrigger.query("code == :1"; $code).first()
	Case of
		: ($trigger=Null:C1517) || ($holder=Null:C1517)
		: ($trigger.moreData=Null:C1517) || (String:C10($trigger.moreData.daysAfterLeadCreation)="")
		Else
			$context:=This:C1470.context($holder)
			$interaction:=This:C1470._new($context; "SCHEDULED")
			$interaction.stmpCreation:=cs:C1710.sfw_stmp.me.build()
			$interaction.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Add to date:C393($baseDate; 0; 0; Num:C11($trigger.moreData.daysAfterLeadCreation)))
			$interaction.UUID_Trigger:=$trigger.UUID
			$interaction.UUID_Staff:=$holder.UUID_Staff  // the lead's or the quote's owner
			If ($holder.moreData#Null:C1517) && ($holder.moreData.mainContact#Null:C1517)
				$interaction.UUID_Contact:=String:C10($holder.moreData.mainContact.UUID)
			End if
			$interaction.save()
			$interaction.notifyIfDue()  // only a follow-up due today; later ones on their day
	End case


	//Mark:-Dialog
	// Lead_AddInteraction opened filled (Complete follow up): the pop-ups show their values
Function drawDialog()
	If (Form:C1466.dialogTitle#Null:C1517)
		OBJECT SET TITLE:C194(*; "Text"; Form:C1466.dialogTitle)
	End if
	This:C1470._drawDialogPup("pup_contact"; "Contact"; "fullName"; Form:C1466.UUID_Contact)
	This:C1470._drawDialogPup("pup_sales"; "Staff"; "fullName"; Form:C1466.UUID_Staff)
	This:C1470._drawDialogPup("pup_method"; "InteractionMethod"; "name"; Form:C1466.UUID_Method)
	This:C1470._drawDialogPup("pup_outcome"; "InteractionOutcome"; "name"; Form:C1466.UUID_Outcome)
	This:C1470._drawDialogPup("pup_trigger"; "InteractionTrigger"; "name"; Form:C1466.UUID_Trigger)

Function _drawDialogPup($object : Text; $dataclass : Text; $attribute : Text; $uuid : Variant)
	var $entity : Object
	If (Value type:C1509($uuid)=Is text:K8:3) && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($uuid)))
		$entity:=ds:C1482[$dataclass].get($uuid)
		If ($entity#Null:C1517)
			OBJECT SET TITLE:C194(*; $object; String:C10($entity[$attribute]))
		End if
	End if


	//Mark:-Private
Function _sequence($context : Object)->$number : Integer
	$number:=ds:C1482.Interaction.sequence(($context.lead#Null:C1517) ? $context.lead.UUID : ""; ($context.quote#Null:C1517) ? $context.quote.UUID : "")

Function _new($context : Object; $typeCode : Text)->$interaction : cs:C1710.InteractionEntity
	$interaction:=ds:C1482.Interaction.new()
	$interaction.UUID_Lead:=($context.lead#Null:C1517) ? $context.lead.UUID : ("0"*32)
	$interaction.UUID_Quote:=($context.quote#Null:C1517) ? $context.quote.UUID : ("0"*32)
	$interaction.number:=This:C1470._sequence($context)
	$interaction.UUID_Type:=This:C1470.typeUUID($typeCode)

	// the dialog's values ($form) into $interaction
Function _fill($interaction : cs:C1710.InteractionEntity; $form : Object)
	var $attribute : Text
	$interaction.stmpCreation:=cs:C1710.sfw_stmp.me.build($form.creationDate)
	$interaction.stmpFollowUp:=cs:C1710.sfw_stmp.me.build($form.followUPDate)
	$interaction.notes:=String:C10($form.notes)
	For each ($attribute; New collection:C1472("UUID_Staff"; "UUID_Contact"; "UUID_Method"; "UUID_Outcome"; "UUID_Trigger"))
		If (Value type:C1509($form[$attribute])=Is text:K8:3) && ($form[$attribute]#"")
			$interaction[$attribute]:=$form[$attribute]
		End if
	End for each

	// the follow-up scheduled from the "Next follow-up?" box of a logged or completed interaction
Function _next($context : Object; $previous : cs:C1710.InteractionEntity; $form : Object)->$interaction : cs:C1710.InteractionEntity
	$interaction:=This:C1470._new($context; "SCHEDULED")
	This:C1470._fill($interaction; $form)
	$interaction.notes:=""
	$interaction.UUID_Outcome:="0"*32
	$interaction.UUID_Interaction:=$previous.UUID
	$interaction.save()
	$interaction.notifyIfDue()  // today: now; a later date: on that day

