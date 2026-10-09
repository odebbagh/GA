Class extends Entity


local Function get revisionDate()->$revisionDate : Date
	$revisionDate:=This:C1470.stmpRevisionDate=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpRevisionDate; True:C214)
	
local Function set revisionDate($revisionDate : Date)
	// Purpose: Date widgets echo the calendar day on load; stmp.build(date) would stamp the current time of day and mark the record dirty.
	// modified by 4D/PS [2026-october-05]
	$stmp:=This:C1470._stampIfDateChanged(This:C1470.stmpRevisionDate; $revisionDate)
	If (This:C1470.stmpRevisionDate#$stmp)
		This:C1470.stmpRevisionDate:=$stmp
	End if
	
local Function get reviewDate()->$reviewDate : Date
	$reviewDate:=This:C1470.stmpReviewDate=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpReviewDate; True:C214)
	
local Function set reviewDate($reviewDate : Date)
	$stmp:=This:C1470._stampIfDateChanged(This:C1470.stmpReviewDate; $reviewDate)
	If (This:C1470.stmpReviewDate#$stmp)
		This:C1470.stmpReviewDate:=$stmp
	End if
	
local Function get approvalDate()->$approvalDate : Date
	$approvalDate:=This:C1470.stmpApproval=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpApproval; True:C214)
	
local Function set approvalDate($approvalDate : Date)
	$stmp:=This:C1470._stampIfDateChanged(This:C1470.stmpApproval; $approvalDate)
	If (This:C1470.stmpApproval#$stmp)
		This:C1470.stmpApproval:=$stmp
	End if
	
local Function _stampIfDateChanged($currentStmp : Integer; $date : Date)->$stmp : Integer
	// Purpose: Persist a date stamp only when the calendar day changed; keep the stored time-of-day otherwise.
	// created by 4D/PS [2026-october-05]
	If ($date=!00-00-00!)
		$stmp:=0
	Else 
		$storedDate:=($currentStmp=0) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate($currentStmp; True:C214)
		If ($storedDate=$date)
			$stmp:=$currentStmp
		Else 
			$stmp:=cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
		End if 
	End if
	
local Function drowPup($dataClass; $queryField; $queryValue; $pupName)
	// Purpose: Popup buttons keep the last OBJECT SET FORMAT until redrawn. Always rewrite the title from This, including empty UUID after Cancel or a record with no category/department.
	// modified by 4D/PS [2026-october-05]
	$entity:=New object:C1471
	$uuid:=String:C10(This:C1470[$queryValue])
	If ($uuid#"") && ($uuid#"00000000000000000000000000000000")
		$found:=ds:C1482[$dataClass].query($queryField+" =:1"; This:C1470[$queryValue]).first()
		If ($found#Null:C1517)
			$entity:=$found
		End if 
	End if 
	
	$name:=""
	If ($entity.name#Null:C1517)
		$name:=String:C10($entity.name)
	End if 
	$pathIcon:="sfw/image/skin/rainbow/icon/spacer-1x24.png"
	If (Not:C34(Undefined:C82($entity.color))) && ($entity.color#Null:C1517) && (String:C10($entity.color)#"")
		$color:=cs:C1710.sfw_htmlColor.me.getName($entity.color)
		If ($color#"")
			$pathIcon:="sfw/colors/"+$color+"-circle.png"
		End if 
	End if 
	If (Form:C1466.sfw#Null:C1517)
		// Purpose: Same visual as CAR Traveler — empty popup stays normal, not red. Selection and save logic unchanged.
		// modified by 4D/PS [2026-october-06]
		Form:C1466.sfw.drawButtonPup($pupName; $name; $pathIcon; False:C215)
	End if 
	OBJECT SET TITLE:C194(*; $pupName; $name)
	
	
local Function pup($cacheCollection; $dataClass; $queryField; $queryValue)
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheCollection]=Null:C1517)
			ds:C1482[$dataClass].cacheLoad()
		End if 
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheCollection]=Null:C1517)
			return 
		End if 
		
		For each ($eEntity; Storage:C1525.cache[$cacheCollection])
			APPEND MENU ITEM:C411($menu; $eEntity.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eEntity.UUID)
			If ($queryField="UUID")  //# TO BE REMOVED
				
				If ($eEntity[$queryField]=Form:C1466.current_item[$queryValue])
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
			Else 
				
				If (Num:C11($eEntity[$queryField])=Form:C1466.current_item[$queryValue])
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
				
			End if 
			
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				$eEntity:=ds:C1482[$dataClass].get($choose)
				Form:C1466.current_item[$queryValue]:=$eEntity[$queryField]
		End case 
		
	End if 
	
	
	
	
	
	
	//mark:-Callbacks
	
local Function afterCreation()
	
	
	
local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	// modified by 4D/PS [2026-october-05]
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	This:C1470._initReports()
	
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	
	
	
	
local Function isDeletable()->$isDeletable : Boolean
	// This callback must return false to inactivate the deletion mode for the current item.
	$isDeletable:=True:C214
	
	
local Function _initReports()
	// Purpose: Ensure the supporting-documents object exists before the panel reads it.
	// modified by 4D/PS [2026-october-05]
	If (This:C1470.documents=Null:C1517)
		This:C1470.documents:=New object:C1471
	End if 
	If (This:C1470.documents.documentsCollection=Null:C1517)
		This:C1470.documents.documentsCollection:=New collection:C1472()
	End if 
	
	
local Function beforeSave()
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_clone#Null:C1517)
		If (Form:C1466.current_item.isApproved=False:C215) & (Form:C1466.current_item.isApproved#Form:C1466.current_clone.isApproved)
			
			$context:=New object:C1471
			$context.target:=Form:C1466.current_item.UUID
			$context.targetDataclass:="Specification"
			$context.spec:=Form:C1466.current_item.spec
			
			$profiles:=New collection:C1472("qm"; "qs"; "pm"; "ps"; "vp"; "gm")
			$staff:=ds:C1482.Staff.query("user.userInscriptions.userProfile.ident in :1 | memberships.team.name =:2"; $profiles; "Facilities")
			
			$users:=$staff.extract("user").extract("UUID").distinct()
			cs:C1710.sfw_notificationManager.me.notify("SpecControlApproval"; $users; $context)
			
		End if 
	End if 
	
	// Purpose: Panel writes Form.bufferOfEvents; keep a fallback on Form.subForm for older paths.
	// A Collection-typed local cannot be assigned Null in v20.
	// modified by 4D/PS [2026-october-05]
	$bufferOfEvents:=New collection:C1472
	If (Not:C34(Undefined:C82(Form:C1466.bufferOfEvents))) && (Form:C1466.bufferOfEvents#Null:C1517) && (Form:C1466.bufferOfEvents.length>0)
		$bufferOfEvents:=Form:C1466.bufferOfEvents
	Else 
		If (Not:C34(Undefined:C82(Form:C1466.subForm))) && (Form:C1466.subForm#Null:C1517) && (Form:C1466.subForm.bufferOfEvents#Null:C1517) && (Form:C1466.subForm.bufferOfEvents.length>0)
			$bufferOfEvents:=Form:C1466.subForm.bufferOfEvents
		End if 
	End if 
	If ($bufferOfEvents.length>0)
		This:C1470._saveBufferOfEvents($bufferOfEvents)
		Form:C1466.bufferOfEvents:=New collection:C1472
		If (Not:C34(Undefined:C82(Form:C1466.subForm))) && (Form:C1466.subForm#Null:C1517)
			Form:C1466.subForm.bufferOfEvents:=New collection:C1472
		End if 
	End if 
	
	
local Function beforeSaveCreation()
	
	If (Not:C34(Undefined:C82(Form:C1466.bufferOfEvents))) && (Form:C1466.bufferOfEvents#Null:C1517)
		This:C1470._saveBufferOfEvents(Form:C1466.bufferOfEvents)
	Else 
		If (Not:C34(Undefined:C82(Form:C1466.subForm))) && (Form:C1466.subForm#Null:C1517) && (Form:C1466.subForm.bufferOfEvents#Null:C1517)
			This:C1470._saveBufferOfEvents(Form:C1466.subForm.bufferOfEvents)
		End if 
	End if 
	
	
Function _saveBufferOfEvents($bufferOfEvents : Collection)
	If ($bufferOfEvents=Null:C1517)
		return 
	End if 
	For each ($buffer; $bufferOfEvents)
		$moreData:=New object:C1471
		$moreData.comment:=$buffer.label
		cs:C1710.sfw_eventManager.me.addEvent(Form:C1466.sfw.entry; $buffer.event; This:C1470.UUID; $moreData; $buffer.stmp)
	End for each 
	
	
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.spec)
	
	
	
