Class extends Entity

Function get creationDate()->$creationDate : Date
	$creationDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation)
	
Function get followUPDate()->$followUPDate : Date
	$followUPDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpFollowUp)
	
	
Function set creationDate($creationDate : Date)
	This:C1470.stmpCreation:=cs:C1710.sfw_stmp.me.build($creationDate)
	
Function set followUPDate($followUPDate : Date)
	This:C1470.stmpFollowUp:=cs:C1710.sfw_stmp.me.build($followUPDate)

	// the columns of the quote's Follow-ups list (panel_quote, page 7)
Function get creationDateText()->$text : Text
	$text:=(This:C1470.stmpCreation=0) ? "" : String:C10(This:C1470.creationDate)

Function get followUpText()->$text : Text
	$text:=(This:C1470.stmpFollowUp=0) ? "" : String:C10(This:C1470.followUPDate)

Function get typeName()->$text : Text
	$text:=(This:C1470.type=Null:C1517) ? "" : String:C10(This:C1470.type.name)

Function get triggerName()->$text : Text
	$text:=(This:C1470.trigger=Null:C1517) ? "" : String:C10(This:C1470.trigger.name)

Function get contactName()->$text : Text
	$text:=(This:C1470.contact=Null:C1517) ? "" : String:C10(This:C1470.contact.fullName)

Function get staffName()->$text : Text
	$text:=(This:C1470.staff=Null:C1517) ? "" : String:C10(This:C1470.staff.fullName)

	// "L00012", "Q3041" or "L00012 / Q3041": what the follow-up belongs to
Function get fromText()->$text : Text
	var $parts : Collection
	$parts:=New collection:C1472
	If (This:C1470.lead#Null:C1517)
		$parts.push(This:C1470.lead.leadCode)
	End if
	If (This:C1470.quote#Null:C1517)
		$parts.push(This:C1470.quote.code)
	End if
	$text:=$parts.join(" / ")
	
	
	
	
	
	
	// the "Interaction Scheduled" notification, sent on the follow-up date and not before: the bell
	// lists every notification at once, so it can only be created on the day. Called when a
	// follow-up is scheduled or its lead saved (sends at once if due today), and every day by
	// Interaction.notifyDueFollowUps (_ga_dateRelatedNotifications, onStartup). Sent once per
	// date: moreData.notifiedFor keeps the follow-up stamp it went out for, so a follow-up moved
	// to another day notifies again on that day. To the interaction's Sales person, else the
	// lead's owner, else the quote's owner. _notify, not notify: from the lead panel it is saved in the lead's
	// transaction, so Cancel removes it with the interaction
Function notifyIfDue()->$sent : Boolean
	var $context; $moreData : Object
	var $scheduled : cs:C1710.InteractionTypeEntity
	var $userUUID : Text

	$scheduled:=ds:C1482.InteractionType.query("code == :1"; "SCHEDULED").first()
	Case of
		: ($scheduled=Null:C1517) || (This:C1470.UUID_Type#$scheduled.UUID)  // logged or cancelled: no call to make
		: (This:C1470.stmpFollowUp<=0) || (This:C1470.followUPDate>Current date:C33)  // not due yet
		: (This:C1470.moreData#Null:C1517) && (Num:C11(This:C1470.moreData.notifiedFor)=This:C1470.stmpFollowUp)  // already sent for this date
		Else
			Case of
				: (This:C1470.staff#Null:C1517) && (This:C1470.staff.user#Null:C1517)
					$userUUID:=This:C1470.staff.user.UUID
				: (This:C1470.lead#Null:C1517) && (This:C1470.lead.staff#Null:C1517) && (This:C1470.lead.staff.user#Null:C1517)
					$userUUID:=This:C1470.lead.staff.user.UUID
				: (This:C1470.quote#Null:C1517) && (This:C1470.quote.staff#Null:C1517) && (This:C1470.quote.staff.user#Null:C1517)
					$userUUID:=This:C1470.quote.staff.user.UUID  // a quote's follow-up without a lead
			End case
			If ($userUUID#"")
				$context:=New object:C1471
				// opens the lead, or the quote when the follow-up has no lead (ga_followUps)
				If (This:C1470.lead#Null:C1517) || (This:C1470.quote=Null:C1517)
					$context.target:=This:C1470.UUID_Lead
					$context.targetDataclass:="Lead"
				Else
					$context.target:=This:C1470.UUID_Quote
					$context.targetDataclass:="Quote"
				End if
				$context.Followupdate:=String:C10(This:C1470.followUPDate)  // a placeholder given Null stays "##...##"
				$context.Contact:=(This:C1470.contact#Null:C1517) ? String:C10(This:C1470.contact.fullName) : "no contact"
				$context.Trigger:=(This:C1470.trigger#Null:C1517) ? String:C10(This:C1470.trigger.name) : "a follow-up"
				cs:C1710.sfw_notificationManager.me._notify("InteractionScheduled"; New collection:C1472($userUUID); $context)
				$sent:=True:C214
			End if
			// recorded even with nobody to tell, so the daily run does not try it again every day
			$moreData:=(This:C1470.moreData#Null:C1517) ? OB Copy:C1225(This:C1470.moreData) : New object:C1471
			$moreData.notifiedFor:=This:C1470.stmpFollowUp
			This:C1470.moreData:=$moreData
			This:C1470.save()
	End case