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
	var $staff : cs:C1710.StaffEntity
	var $interaction : cs:C1710.InteractionEntity
	If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.interactionTrigger=Null:C1517)
		ds:C1482.InteractionTrigger.cacheLoad()
	End if 
	
	$items:=Storage:C1525.cache.interactionTrigger.query("code == :1"; "LEAD_CREATION")
	If ($items.length#0)
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.interactionType=Null:C1517)
			ds:C1482.InteractionType.cacheLoad()
		End if 
		$types:=Storage:C1525.cache.interactionType.query("code == :1"; "SCHEDULED")
		If ($types.length#0)
			$uuidType:=$types[0].UUID
		Else 
			$uuidType:=""
		End if 
		
		$mainContact:=This:C1470.mainContact()
		If ($mainContact#Null:C1517)
			$uuidMainContact:=$mainContact.UUID
		Else 
			$uuidMainContact:=""
		End if 
		
		$uuidTrigger:=$items[0].UUID
		$nbrDaysAfter:=Num:C11($items[0].moreData.daysAfterLeadCreation)
		
		$interaction:=ds:C1482.Interaction.new()
		$interaction.number:=ds:C1482.Interaction.sequence(This:C1470.UUID)
		$interaction.stmpCreation:=cs:C1710.sfw_stmp.me.build()
		$interaction.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Add to date:C393(Current date:C33; 0; 0; $nbrDaysAfter))
		$interaction.UUID_Staff:=This:C1470.UUID_Staff  // the lead's owner (it was the user's UUID, which is no Staff)
		$interaction.UUID_Lead:=This:C1470.UUID
		$interaction.UUID_Type:=$uuidType
		$interaction.UUID_Trigger:=$uuidTrigger
		$interaction.UUID_Contact:=$uuidMainContact
		$interaction.save()
		$interaction.notifyIfDue()  // only a follow-up due today; later ones on their day (Interaction.notifyDueFollowUps)

		
	Else 
		ALERT:C41("")
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
	
	
	
	