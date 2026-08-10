Class extends Entity

local Function get nextCalDate()->$nextCalDate : Date
	$nextCalDate:=This:C1470.stmpNextCal=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpNextCal; True:C214)
	
local Function set nextCalDate($nextCalDate : Date)
	This:C1470.stmpNextCal:=$nextCalDate=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($nextCalDate)
	
local Function get lastCalDate()->$lastCalDate : Date
	$lastCalDate:=This:C1470.stmpLastCal=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpLastCal; True:C214)
	
local Function set lastCalDate($lastCalDate : Date)
	This:C1470.stmpLastCal:=$lastCalDate=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($lastCalDate)
	
local Function get lastPMDate()->$lastPMDate : Date
	$lastPMDate:=This:C1470.stmpLastPM=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpLastPM; True:C214)
	
local Function set lastPMDate($lastPMDate : Date)
	This:C1470.stmpLastPM:=$lastPMDate=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($lastPMDate)
	
local Function get nextPMDate()->$nextPMDate : Date
	$nextPMDate:=This:C1470.stmpNextPM=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpNextPM; True:C214)
	
local Function set nextPMDate($nextPMDate : Date)
	This:C1470.stmpNextPM:=$nextPMDate=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($nextPMDate)
	
local Function loadAfterCreation()
	
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initReports()
	
local Function _initReports()
	
	If (This:C1470.reports.documents=Null:C1517)
		
		This:C1470.reports.documents:=New collection:C1472()
		
	End if 
	
	
	// Mark:-Callbacks
	
local Function itemLoad()
	
	// This callback is called when the item is selected in the itemList
	
local Function beforeDelete()
	KILL WORKER:C1390(Current process:C322)
	
local Function beforeSave()
	
	If (Form:C1466.current_item.down=True:C214) & (Form:C1466.current_item.down#Form:C1466.current_clone.down)
		
		$context:=New object:C1471
		$context.target:=Form:C1466.current_item.UUID
		$context.targetDataclass:="Equipment"
		$context.assignedID:=Form:C1466.current_item.assignedID
		
		$staff:=ds:C1482.Staff.query("user.userInscriptions.userProfile.ident = :1 | memberships.team.name =:2"; "pm"; "Facilities")
		
		$users:=$staff.extract("user").extract("UUID").distinct()
		cs:C1710.sfw_notificationManager.me.notify("EquipmentDown"; $users; $context)
		
	End if 
	
	
	If (Form:C1466.subForm.bufferOfEvents#Null:C1517) && (Form:C1466.subForm.bufferOfEvents.length>0)
		This:C1470._saveBufferOfEvents(Form:C1466.subForm.bufferOfEvents)
		Form:C1466.subForm.bufferOfEvents:=New collection:C1472
	End if 
	
	
local Function beforeSaveCreation()
	
	This:C1470._saveBufferOfEvents(Form:C1466.subForm.bufferOfEvents)
	
	
Function _saveBufferOfEvents($bufferOfEvents : Collection)
	For each ($buffer; $bufferOfEvents)
		$moreData:=New object:C1471
		$moreData.comment:=$buffer.label
		cs:C1710.sfw_eventManager.me.addEvent(Form:C1466.sfw.entry; $buffer.event; This:C1470.UUID; $moreData; $buffer.stmp)
	End for each 
	
	//cs.sfw_eventManager.me.addEvent(Form.sfw.entry; "modifyDocument"; Form.current_item.UUID)
	