Class extends DataClass

	// the next interaction number of a lead: interactions are numbered per lead (1, 2, ...), as
	// shown in the lead's Interactions list. It was the highest number of all leads + 1, so the
	// first interaction of a new lead could be #4. A quote without a lead numbers its own
	// follow-ups ($uuidQuote, ga_followUps)
Function sequence($uuidLead : Text; $uuidQuote : Text)->$sequence : Integer
	var $es : cs:C1710.InteractionSelection

	If (cs:C1710.sfw_string.me.isAnEmptyUUID($uuidLead)) && (Count parameters:C259>=2) && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($uuidQuote)))
		$es:=This:C1470.query("UUID_Quote = :1"; $uuidQuote).orderBy("number desc")
	Else
		$es:=This:C1470.query("UUID_Lead = :1"; $uuidLead).orderBy("number desc")
	End if
	If ($es.length#0)
		$sequence:=$es[0].number+1
	Else 
		$sequence:=1
	End if
	
	// the follow-ups due today or earlier, still SCHEDULED and not yet notified for their date:
	// each sends its "Interaction Scheduled" notification (InteractionEntity.notifyIfDue). Run
	// every day by _ga_dateRelatedNotifications (4D Server) and at each login (onStartup), so
	// today's calls are waiting in the morning, also in single-user mode
Function notifyDueFollowUps()->$nbSent : Integer
	var $scheduled : cs:C1710.InteractionTypeEntity
	var $interaction : cs:C1710.InteractionEntity
	var $endOfToday : Integer
	
	$scheduled:=ds:C1482.InteractionType.query("code == :1"; "SCHEDULED").first()
	If ($scheduled#Null:C1517)
		$endOfToday:=cs:C1710.sfw_stmp.me.build(Current date:C33; ?23:59:59?)
		For each ($interaction; This:C1470.query("UUID_Type = :1 and stmpFollowUp > 0 and stmpFollowUp <= :2"; $scheduled.UUID; $endOfToday))
			If ($interaction.notifyIfDue())
				$nbSent+=1
			End if 
		End for each 
	End if 
