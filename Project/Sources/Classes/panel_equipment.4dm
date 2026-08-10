singleton Class constructor
	
	// It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	
	// This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities
	
	If (Form:C1466.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary ti refresh
		
		This:C1470.LoadAllTabs()
		//If (Undefined(Form.subForm))
		//Form.subForm:=New object()
		//End if 
		If (Undefined:C82(Form:C1466.bufferOfEvents))
			Form:C1466.bufferOfEvents:=New collection:C1472()
		End if 
	End if 
	
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  // a page is displayed so it's time to load the sources of data to display
		
		Case of 
				
				//________________________________________
			: (FORM Get current page:C276(*)=1)
				
				//________________________________________
			: (FORM Get current page:C276(*)=2)
				
				This:C1470.loadRepairLog()
				
				//________________________________________
			: (FORM Get current page:C276(*)=3)
				
				This:C1470.loadDocuments()
				OBJECT SET ENTERABLE:C238(*; "lb_documents"; False:C215)
				
				//________________________________________
		End case 
	End if 
	
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visible
		
		This:C1470.redrawAndSetVisible()
		
	End if 
	
Function drawPup_XXX()
	
	// This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
Function pup_XXX()
	
	// Create pop up menu
	
Function redrawAndSetVisible()
	
	// Adjusts the layout and visibility of form elements based on the current page and modification state
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	
	Case of 
			
			//________________________________________
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "entryField_statusHistory"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_statusHistory"; $g; $h; $widthSubform-25; $heightSubform-15)
			
			//________________________________________
		: (FORM Get current page:C276(*)=2)
			
			OBJECT GET COORDINATES:C663(*; "lb_repairLog"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_repairLog"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
			//________________________________________
		: (FORM Get current page:C276(*)=3)
			
			OBJECT GET COORDINATES:C663(*; "lb_documents"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_documents"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
			//________________________________________
	End case 
	
	Use (Form:C1466.sfw.entry.panel.pages)
		
		Form:C1466.sfw.entry.panel.pages[1].label:="Repair Log ("+String:C10(Form:C1466.lb_repairLog.length)+")"
		Form:C1466.sfw.entry.panel.pages[2].label:="Documents ("+String:C10(Form:C1466.lb_documents.length)+")"
		
	End use 
	
	This:C1470.drawPup_EquipmentType()
	This:C1470.drawPup_EquipmentLocation()
	This:C1470.drawPup_Division()
	
	If (Form:C1466.current_item.calibrationNotRequired=False:C215) & (Form:C1466.current_item.notAtSite=False:C215) & (Form:C1466.current_item.nextCalDate<=Current date:C33(*))
		Form:C1466.current_item.outOfCalibration:=True:C214
	End if 
	
	OBJECT SET ENTERABLE:C238(*; "entryField_outOfCalibration"; False:C215)
	
	OBJECT SET ENTERABLE:C238(*; "entryField_statusHistory"; False:C215)
	
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	
	Form:C1466.sfw.drawHTab()
	
Function drawPup_EquipmentType()
	
	If (Form:C1466.current_item#Null:C1517)
		
		$equipmentType:=ds:C1482.ToolType.query("UUID= :1"; Form:C1466.current_item.UUID_ToolType).first() || New object:C1471()
		$typeName:=$equipmentType.name
		
		If ($typeName=Null:C1517)
			
			$typeName:=""
			
		End if 
		
		$color:=""  //cs.sfw_htmlColor.me.getName($equipmentType.color)
		$pathIcon:=(Length:C16($color)#0) ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_equipmentType"; $typeName; $pathIcon; ($equipmentType=Null:C1517))
		
	End if 
	
Function pup_type()
	
	// Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_equipmentType"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "name"; \
			"allData"; ds:C1482.ToolType.all(); \
			"dataclass"; "ToolType"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			
			Form:C1466.current_item.UUID_ToolType:=$form.item.UUID
			//cs.panel_equipment.me._activate_save_cancel_button()
			
		End if 
	End if 
	
	This:C1470.drawPup_EquipmentType()
	
Function drawPup_EquipmentLocation()
	
	If (Form:C1466.current_item#Null:C1517)
		
		$equipmentLocation:=ds:C1482.EquipmentLocation.query("UUID= :1"; Form:C1466.current_item.UUID_EquipmentLocation).first() || New object:C1471()
		$locationName:=$equipmentLocation.name
		
		If ($locationName=Null:C1517)
			
			$locationName:=""
			
		End if 
		
		$color:=""
		$pathIcon:=(Length:C16($color)#0) ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_equipmentLocation"; $locationName; $pathIcon; ($equipmentLocation=Null:C1517))
		
	End if 
	
Function pup_location()
	
	// Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		
		$menu:=Create menu:C408
		
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.equipmentLocations=Null:C1517)
			
			ds:C1482.EquipmentLocation.cacheLoad()
			
		End if 
		
		For each ($equipmentLocation; Storage:C1525.cache.equipmentLocations)
			
			APPEND MENU ITEM:C411($menu; $equipmentLocation.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $equipmentLocation.UUID)
			
			If ($equipmentLocation.UUID=Form:C1466.current_item.UUID_EquipmentLocation)
				
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				
				If (Is Windows:C1573)
					
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					
				End if 
			End if 
		End for each 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
				
				//________________________________________
			: (Length:C16($choose)#0)
				
				$equipmentLocation:=ds:C1482.EquipmentLocation.get($choose)
				Form:C1466.current_item.UUID_EquipmentLocation:=$equipmentLocation.UUID
				
				//________________________________________
		End case 
	End if 
	
	This:C1470.drawPup_EquipmentLocation()
	
Function drawPup_Division()
	
	If (Form:C1466.current_item#Null:C1517)
		
		$equipmentDivision:=ds:C1482.Division.query("UUID= :1"; Form:C1466.current_item.UUID_Division).first() || New object:C1471(\
			)
		$divisionName:=$equipmentDivision.name
		
		If ($divisionName=Null:C1517)
			
			$divisionName:=""
			
		End if 
		
		$color:=""
		$pathIcon:=(Length:C16($color)#0) ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_equipmentDivision"; $divisionName; $pathIcon; ($equipmentDivision=Null:C1517))
		
	End if 
	
Function pup_division()
	
	// Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		
		$menu:=Create menu:C408
		
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.divisions=Null:C1517)
			
			ds:C1482.Division.cacheLoad()
			
		End if 
		
		For each ($equipmentDivision; Storage:C1525.cache.divisions)
			
			APPEND MENU ITEM:C411($menu; $equipmentDivision.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $equipmentDivision.UUID)
			
			If ($equipmentDivision.UUID=Form:C1466.current_item.UUID_Division)
				
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				
				If (Is Windows:C1573)
					
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					
				End if 
			End if 
		End for each 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
				
				//________________________________________
			: (Length:C16($choose)#0)
				
				$equipmentDivision:=ds:C1482.Division.get($choose)
				Form:C1466.current_item.UUID_Division:=$equipmentDivision.UUID
				
				//________________________________________
		End case 
	End if 
	
	This:C1470.drawPup_Division()
	
Function loadRepairLog()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_repairLog:=Form:C1466.current_item.repairLogs
		
	End if 
	
Function loadDocuments()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_documents:=Form:C1466.current_item.reports.documents.map(Formula:C1597(_ga_getDateTime))
		
	End if 
	
Function LoadAllTabs()
	This:C1470.loadRepairLog()
	This:C1470.loadDocuments()
	
Function linkOpenLot($entity : 4D:C1709.Entity; $visionIdent : Text; $entryIdent : Text)
	
	If ($entity#Null:C1517)
		
		$formData:=New object:C1471(\
			)
		$formData.sfw:=cs:C1710.sfw_item.new()
		$formData.window:=New object:C1471
		GET WINDOW RECT:C443($left; $top; $right; $bottom)
		$formData.window.left:=$left+50
		$formData.window.top:=$top+50
		$formData.sfw.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; $visionIdent).first()
		$formData.sfw.entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; $entryIdent).first()
		$formData.current_item:=$entity
		$formData.sfw.openForm($formData)
		
	End if 
	
Function bActionRepairLog()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Open in new window"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "openInWindow")
	
	If (Form:C1466.selectedRepaiLog=Null:C1517)\
		 | (Undefined:C82(Form:C1466.selectedRepaiLog))
		
		DISABLE MENU ITEM:C150($refMenu; -1)
		
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
			
			//________________________________________
		: ($choice="openInWindow")
			
			Form:C1466.sfw.openInANewWindow(Form:C1466.current_item.repairLogs.query("UUID=:1"; Form:C1466.selectedRepaiLog.UUID).first(); "qualityAssurance"; "repairLog")
			
			//________________________________________
	End case 
	
Function bActionDocument()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "View report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--view")
	
	If (Form:C1466.selectedDocument=Null:C1517)\
		 | (Undefined:C82(Form:C1466.selectedDocument))
		
		DISABLE MENU ITEM:C150($refMenu; 1)
		
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "add report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--add")
	
	If (sfw_checkIsInModification=False:C215)
		
		DISABLE MENU ITEM:C150($refMenu; 2)
		
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "modify report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 3; "--modify")
	
	If (sfw_checkIsInModification=False:C215)\
		 | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		
		DISABLE MENU ITEM:C150($refMenu; 3)
		
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "delete report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 4; "--delete")
	
	If (sfw_checkIsInModification=False:C215)\
		 | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		
		DISABLE MENU ITEM:C150($refMenu; 4)
		
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
			
			//________________________________________
		: ($choice="--view")
			
			$LocalFile:=Temporary folder:C486+Folder separator:K24:12+Form:C1466.selectedDocument.sourcePath
			BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.selectedDocument.blob)
			OPEN URL:C673($LocalFile; *)
			
			//________________________________________
		: ($choice="--add")
			
			$details:=New object:C1471
			OB SET:C1220($details; "code"; ""; \
				"dateTimeStamp"; cs:C1710.sfw_stmp.me.now(); \
				"creationDateTimeStamp"; cs:C1710.sfw_stmp.me.now(); \
				"documentPath"; ""; \
				"sourcePath"; ""; \
				"description"; ""; \
				"approvalDate"; Date:C102(!00-00-00!); \
				"approvedBy"; ""; \
				"isApproved"; False:C215)
			
			$form:=New object:C1471(\
				"details"; $details)  // Form.selectedDocument)
			$form.approverProfile:=New collection:C1472("qs")
			$form.approverTeam:=New collection:C1472("Facilities")
			$form.displayApprovalFields:=False:C215
			
			
			$winRef:=Open form window:C675("_ga_document"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_document"; $form)
			
			If (OK=1)
				
				//Form.lb_documents.push($form.details) 
				
				$buffer:=New object:C1471()
				$buffer.event:="addDocument"
				$buffer.label:="Document "+$form.details.sourcePath+" added"
				$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
				Form:C1466.bufferOfEvents.push($buffer)
				
				Form:C1466.current_item.reports.documents.push($form.details)
				cs:C1710.panel_equipment.me._activate_save_cancel_button()
				
			End if 
			
			//________________________________________
		: ($choice="--modify")
			
			$form:=New object:C1471(\
				"details"; OB Copy:C1225(Form:C1466.current_item.reports.documents[Form:C1466.selectedDocumentPos-1]))  // Form.selectedDocument)
			$form.approverProfile:=New collection:C1472("qs")
			$form.approverTeam:=New collection:C1472("Facilities")
			$form.displayApprovalFields:=False:C215
			$form.bufferOfEvents:=Form:C1466.bufferOfEvents
			
			$winRef:=Open form window:C675("_ga_document"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_document"; $form)
			
			If (OK=1)
				
				//Form.selectedDocument:=$form.details
				If ($form.modified) | ($form.documentHasChanged)
					Form:C1466.current_item.reports.documents[Form:C1466.selectedDocumentPos-1]:=$form.details
					cs:C1710.panel_equipment.me._activate_save_cancel_button()
				End if 
				
			End if 
			
			//________________________________________
		: ($choice="--delete")
			
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this document? "; "Delete"; "CANCEL")
			
			If ($ok)
				
				//Form.lb_documents.remove(Form.selectedDocumentPos-1)
				
				$buffer:=New object:C1471()
				$buffer.event:="deleteDocument"
				$buffer.label:="Document "+Form:C1466.current_item.reports.documents[Form:C1466.selectedDocumentPos-1].sourcePath+" deleted"
				$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
				Form:C1466.bufferOfEvents.push($buffer)
				
				Form:C1466.current_item.reports.documents.remove(Form:C1466.selectedDocumentPos-1)
				cs:C1710.panel_equipment.me._activate_save_cancel_button()
				
			End if 
			
			//________________________________________
	End case 
	
	This:C1470.loadDocuments()
	
	
	
	