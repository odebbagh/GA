Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.leadCode
	
	
Function get amountText()->$amount : Text
	
	$amount:=_ga_usdText(This:C1470.amount)  // "$1,234.56" whatever the Windows region
	
	
Function get dateCreation()->$createDate : Date
	$createDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation; True:C214)
	
Function set dateCreation($createDate : Date)
	This:C1470.stmpCreation:=cs:C1710.sfw_stmp.me.build($createDate)
	
Function get dateClose()->$closeDate : Date
	$closeDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpClose; True:C214)
	
Function set dateClose($closeDate : Date)
	This:C1470.stmpClose:=cs:C1710.sfw_stmp.me.build($closeDate)
	
Function get customerName()->$name : Text
	$name:=This:C1470.customer.name
	
Function get dealType()->$name : Text
	If (This:C1470.deal)
		$name:="Existing customer"
	Else 
		$name:="New customer"
	End if 
	
Function get numCode()->$num : Integer
	$num:=Num:C11(This:C1470.leadCode)
	
	
	
Function get stage()->$stage : Text
	var $eLeadStage : cs:C1710.LeadStageEntity
	$eLeadStage:=ds:C1482.LeadStage.query("stageID = :1"; Num:C11(This:C1470.currentStageID)).first()
	$stage:=$eLeadStage.name || "-"

	//Mark:-List columns (Lead.entryDefinition)
	// The follow-ups still to make: the lead's interactions of type SCHEDULED (a logged one becomes
	// COMPLETED, a cancelled one CANCELED)
Function openFollowUps()->$interactions : cs:C1710.InteractionSelection
	$interactions:=This:C1470.interactions.query("UUID_Type = :1"; ds:C1482.Lead.scheduledTypeUUID())

Function get openInteractions()->$count : Integer
	$count:=This:C1470.openFollowUps().length

	// the earliest follow-up still to make, overdue ones included (shown in red in the list);
	// 00-00-00 when there is none
Function get nextFollowUp()->$date : Date
	var $stmp : Real
	$stmp:=Num:C11(This:C1470.openFollowUps().query("stmpFollowUp > 0").min("stmpFollowUp"))
	If ($stmp>0)
		$date:=cs:C1710.sfw_stmp.me.getDate($stmp)
	End if

Function get nextFollowUpText()->$text : Text
	var $date : Date
	$date:=This:C1470.nextFollowUp
	$text:=($date=!00-00-00!) ? "" : String:C10($date)

	// what the column sorts on: yyyymmdd, the leads without a follow-up last
Function get nextFollowUpKey()->$key : Integer
	var $date : Date
	$date:=This:C1470.nextFollowUp
	$key:=($date=!00-00-00!) ? 99999999 : (Year of:C25($date)*10000)+(Month of:C24($date)*100)+Day of:C23($date)

	// the weighted value: amount x probability (probabilityPC is a percentage)
Function get pipelineValue()->$value : Real
	$value:=Round:C94(Num:C11(This:C1470.amount)*Num:C11(This:C1470.probabilityPC)/100; 2)

Function get pipelineValueText()->$text : Text
	$text:=_ga_usdText(This:C1470.pipelineValue)

	// won or lost (LeadStage.outcomeOf): out of the open leads and of the pipeline
Function get isClosed()->$closed : Boolean
	$closed:=(ds:C1482.LeadStage.outcomeOf(Num:C11(This:C1470.currentStageID))#"")

	// the list's metaExpression: an overdue follow-up in red
local Function metaColor()->$meta : Object
	var $date : Date
	$meta:=New object:C1471("cell"; New object:C1471)
	$date:=This:C1470.nextFollowUp
	If ($date#!00-00-00!) && ($date<Current date:C33)
		If (Form:C1466.current_lb_item=Null:C1517) || (Form:C1466.current_lb_item.UUID#This:C1470.UUID)
			$meta.cell.columnFollowUp:=New object:C1471("stroke"; "#C0392B")
		End if
	End if

	//Mark:-call back functions
	// code, date and owner of a new lead: here rather than in panel_lead, which wrote them into
	// every lead it displayed. The code is taken at once so the panel shows it (like the quote
	// code); a new lead that is cancelled leaves a gap in the series
local Function loadAfterCreation()
	This:C1470.leadCode:=This:C1470.calculateCode()
	This:C1470.dateCreation:=Current date:C33()
	If (cs:C1710.sfw_userManager.me.info.UUID_Staff#Null:C1517)  // the owner: the user's staff record
		This:C1470.staff:=ds:C1482.Staff.query("UUID = :1"; cs:C1710.sfw_userManager.me.info.UUID_Staff).first()
	End if

	// a copy gets its own code and today's date, not the original's
local Function duplicateRecord()
	This:C1470.leadCode:=This:C1470.calculateCode()
	This:C1470.dateCreation:=Current date:C33()

local Function beforeSaveCreation()
	If (This:C1470.leadCode="")
		This:C1470.leadCode:=This:C1470.calculateCode()
	End if
	
	
	
Function calculateCode()->$leadCode : Text
	var $eleadCounter : cs:C1710.sfw_CounterEntity
	
	$leadCode:="L"
	$test:=ds:C1482.sfw_Counter.getNextValue("leadCode")
	
	$leadCode+=String:C10($test; "00000")
	
	
	
local Function afterCreation()
	// the first follow-up, from the LEAD_CREATION trigger rule (its number of days; none without
	// the trigger or its days), to the owner with the main contact
	cs:C1710.ga_followUps.me.scheduleFromTrigger("LEAD_CREATION"; This:C1470; Current date:C33)
	// the panel counts again for its "Interactions (n)" tab (panel_lead, on the bound variable change
	// sfw raises right after this callback): it last counted before that follow-up existed
	If (Form:C1466.subForm#Null:C1517)
		Form:C1466.subForm.refreshCounts:=True:C214
	End if
	This:C1470._initContacts()
	CALL FORM:C1391(Current form window:C827; "_ga_refreshItemsCounter")  // "2 leads", once sfw has added the lead to the list

	// "1 lead" again after a deletion (sfw removes the lead from the list after this callback)
local Function beforeDelete()
	CALL FORM:C1391(Current form window:C827; "_ga_refreshItemsCounter")

local Function _initContacts()
	If (This:C1470.moreData.secondaryContacts=Null:C1517)
		This:C1470.moreData.secondaryContacts:=New collection:C1472
	End if 
	
Function contacts()->$contacts : Collection
	var $e_mainContact : cs:C1710.ContactEntity
	var $secondaryContacts : cs:C1710.ContactSelection
	
	$contacts:=New collection:C1472()
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.mainContact#Null:C1517)
		$e_mainContact:=ds:C1482.Contact.get(This:C1470.moreData.mainContact.UUID)
		If ($e_mainContact#Null:C1517)
			$mainContact:=$e_mainContact.toObject()
			$mainContact.type:="Main"
			$contacts.push($mainContact)
		End if 
	End if 
	
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.secondaryContacts#Null:C1517)
		$secondaryContacts:=ds:C1482.Contact.query("UUID in :1"; This:C1470.moreData.secondaryContacts)
		For each ($e_contact; $secondaryContacts)
			$contact:=$e_contact.toObject()
			$contact.type:="Secondary"
			$contacts.push($contact)
		End for each 
	End if 
	
local Function mainContact()->$mainContact : cs:C1710.ContactEntity
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.mainContact#Null:C1517)
		$mainContact:=ds:C1482.Contact.get(This:C1470.moreData.mainContact.UUID)
	Else 
		$mainContact:=Null:C1517
	End if 
	
	
	
	
local Function beforeSave()
	// an existing lead without a code gets the next one when it is saved
	If (This:C1470.leadCode="")
		This:C1470.leadCode:=This:C1470.calculateCode()
	End if

	
	
	// the "Interaction Scheduled" notification is sent on the follow-up date, once
	// (InteractionEntity.notifyIfDue, see afterSave). Sending it here for every interaction added
	// during the edit doubled it, with an undefined follow-up date ("##Followupdate##")

	// a follow-up moved to today (or earlier) in the detail fields notifies with this save, not
	// only at the next daily run; the others wait for their day. Still inside the transaction
local Function afterSave()
	var $interaction : cs:C1710.InteractionEntity

	If (Bool:C1537(Form:C1466.info.success))
		For each ($interaction; This:C1470.interactions)
			$interaction.notifyIfDue()
		End for each
	End if
	
	
	
	
