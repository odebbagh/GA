Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.leadCode
	
	
Function get amountText()->$amount : Text
	
	$amount:="$"+String:C10(This:C1470.amount; "###,###,###,#00.00")
	
	
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
local Function beforeSaveCreation()
	This:C1470.leadCode:=This:C1470.calculateCode()
	
	
	
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
		$interaction.number:=ds:C1482.Interaction.sequence()
		$interaction.stmpCreation:=cs:C1710.sfw_stmp.me.build()
		$interaction.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Add to date:C393(Current date:C33; 0; 0; $nbrDaysAfter))
		$interaction.UUID_Staff:=cs:C1710.sfw_userManager.me.info.UUID
		$interaction.UUID_Lead:=This:C1470.UUID
		$interaction.UUID_Type:=$uuidType
		$interaction.UUID_Trigger:=$uuidTrigger
		$interaction.UUID_Contact:=$uuidMainContact
		$interaction.save()
		
		$context:=New object:C1471
		$context.target:=Form:C1466.current_item.UUID
		$context.targetDataclass:="Lead"
		$context.Followupdate:=$interaction.followUPDate
		$context.Contact:=$interaction.contact.fullName
		$context.Trigger:=$interaction.trigger.name
		
		$staff:=ds:C1482.Staff.query("UUID_User = :1"; cs:C1710.sfw_userManager.me.info.UUID).first()
		If ($staff#Null:C1517)
			$users:=New collection:C1472($staff.user.UUID)
			cs:C1710.sfw_notificationManager.me._notify("InteractionScheduled"; $users; $context)
		End if 
		
		
	Else 
		ALERT:C41("")
	End if 
	This:C1470._initContacts()
	
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
	
	
	
	$updatedInteractions:=Form:C1466.current_clone.interactions.minus(Form:C1466.current_item.interactions)
	If ($updatedInteractions.length>0)
		For each ($interaction; $updatedInteractions)
			$context:=New object:C1471
			$context.target:=Form:C1466.current_item.UUID
			$context.targetDataclass:="Lead"
			$context.Followupdate:=$followUPDate
			$context.Contact:=$interaction.contact.fullName || ""
			$context.Trigger:=$interaction.trigger.name || ""
			
			$staff:=ds:C1482.Staff.query("UUID_User = :1"; cs:C1710.sfw_userManager.me.info.UUID).first()
			$users:=New collection:C1472($staff.user.UUID)
			cs:C1710.sfw_notificationManager.me.notify("InteractionScheduled"; $users; $context)
			
		End for each 
	End if 
	
	
	
	