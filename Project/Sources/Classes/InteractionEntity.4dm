Class extends Entity

Function get creationDate()->$creationDate : Date
	$creationDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation)
	
Function get followUPDate()->$followUPDate : Date
	$followUPDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpFollowUp)
	
	
Function set creationDate($creationDate : Date)
	This:C1470.stmpCreation:=cs:C1710.sfw_stmp.me.build($creationDate)
	
Function set followUPDate($followUPDate : Date)
	This:C1470.stmpFollowUp:=cs:C1710.sfw_stmp.me.build($followUPDate)
	
	
	
	
	
	
	// the "Interaction Scheduled" notification, sent on the follow-up date and not before: the bell
	// lists every notification at once, so it can only be created on the day. Called when a
	// follow-up is scheduled or its lead saved (sends at once if due today), and every day by
	// Interaction.notifyDueFollowUps (_ga_dateRelatedNotifications, onStartup). Sent once per
	// date: moreData.notifiedFor keeps the follow-up stamp it went out for, so a follow-up moved
	// to another day notifies again on that day. To the interaction's Sales person, else the
	// lead's owner. _notify, not notify: from the lead panel it is saved in the lead's
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
			End case
			If ($userUUID#"")
				$context:=New object:C1471
				$context.target:=This:C1470.UUID_Lead
				$context.targetDataclass:="Lead"
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