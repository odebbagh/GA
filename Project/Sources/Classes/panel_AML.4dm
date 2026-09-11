singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		This:C1470.LoadAllTabs()
		
		If (Undefined:C82(Form:C1466.bufferOfEvents))
			Form:C1466.bufferOfEvents:=New collection:C1472()
		End if 
		
	End if 
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
			: (FORM Get current page:C276(*)=2)
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadDocuments()
				OBJECT SET ENTERABLE:C238(*; "lb_documents"; False:C215)
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[2].label:="Documents ("+String:C10(Form:C1466.lb_documents.length)+")"
	End use 
	
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "entryField_comment"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_comment"; $g; $h; $widthSubform-30; $b)
			
		: (FORM Get current page:C276(*)=2)
			
			OBJECT GET COORDINATES:C663(*; "subFormAddress"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "subFormAddress"; $g; $h; $widthSubform-10; $b)
			
		: (FORM Get current page:C276(*)=3)
			
			OBJECT GET COORDINATES:C663(*; "lb_documents"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			$offset:=4
			
			OBJECT SET COORDINATES:C1248(*; "lb_documents"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
	End case 
	
	This:C1470.supplierAddressDetails()
	This:C1470.drawPup_approvedBy()
	This:C1470.drawPup_empCode()
	This:C1470.drawPup_inventoryUnit()
	This:C1470.drawPup_procurementUnit()
	This:C1470.drawPup_division()
	This:C1470.drawPup_supplier()
	
	OBJECT SET VISIBLE:C603(*; "PopupDa@"; Form:C1466.sfw.checkIsInModification())
	
	If (Form:C1466.sfw.checkIsInModification())
		
		// Purpose: QA edit gate uses _ga_qaEditProfiles (qs, qi, qm) — aligned with Staff entry.
		// modified by 4D/PS [2026-may-21]
		$approverProfile:=_ga_qaEditProfiles
		
		$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		
		OBJECT SET ENABLED:C1123(*; "entryField_isApproved"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_approver"; False:C215)  //$hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_approvalDate"; False:C215)  //$hasAuthorizedProfile)
		OBJECT SET VISIBLE:C603(*; "PopupDate1"; False:C215)  // $hasAuthorizedProfile)
		
	End if 
	Form:C1466.sfw.drawHTab()
	
	
Function supplierAddressDetails()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.address:=Form:C1466.current_item.rebuildAddress()
		Form:C1466.subFormAddress.situation:=OB Copy:C1225(Form:C1466.situation)
		Form:C1466.subFormAddress.situation.mode:="view"
		
	End if 
	
	
Function drawPup_supplier()
	If (Form:C1466.current_item#Null:C1517)
		$supplier:=ds:C1482.Supplier.query("UUID= :1"; Form:C1466.current_item.UUID_Supplier).first() || New object:C1471()
		$supplierName:=$supplier.name
		If ($supplierName=Null:C1517)
			$supplierName:=""
		End if 
		$color:=""
		$pathIcon:=""
		Form:C1466.sfw.drawButtonPup("pup_supplier"; $supplierName; $pathIcon; ($supplier=Null:C1517))
		
	End if 
	
	
Function pup_supplier()
	//Create pop up menu
	
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_supplier"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "name"; \
			"allData"; ds:C1482.Supplier.all(); \
			"dataclass"; "Supplier"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.current_item.UUID_Supplier:=$form.item.UUID
			cs:C1710.panel_AML.me._activate_save_cancel_button()
		End if 
	End if 
	
	This:C1470.drawPup_supplier()
	
	
	
Function drawPup_approvedBy()
	If (Form:C1466.current_item#Null:C1517)
		$operator:=ds:C1482.Staff.query("code= :1"; Form:C1466.current_item.approvedBy).first() || New object:C1471()
		$operatorCode:=$operator.code
		If ($operatorCode=Null:C1517)
			$operatorCode:=""
		End if 
		$color:=""
		$pathIcon:=""
		Form:C1466.sfw.drawButtonPup("pup_approvedBy"; $operatorCode; $pathIcon; ($operator=Null:C1517))
		
	End if 
	
	
Function pup_approvedBy()
	//Create pop up menu
	
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_approvedBy"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "code"; \
			"allData"; ds:C1482.Staff.all(); \
			"dataclass"; "Staff"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.current_item.approvedBy:=$form.item.code
			cs:C1710.panel_AML.me._activate_save_cancel_button()
		End if 
	End if 
	
	This:C1470.drawPup_approvedBy()
	
	
Function drawPup_empCode()
	If (Form:C1466.current_item#Null:C1517)
		$operator:=ds:C1482.Staff.query("code= :1"; Form:C1466.current_item.enteredBy).first() || New object:C1471()
		$operatorCode:=$operator.code
		If ($operatorCode=Null:C1517)
			$operatorCode:=""
		End if 
		$color:=""
		$pathIcon:=""
		Form:C1466.sfw.drawButtonPup("pup_empCode"; $operatorCode; $pathIcon; ($operator=Null:C1517))
		
	End if 
	
	
Function pup_empCode()
	//Create pop up menu
	
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_empCode"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "code"; \
			"allData"; ds:C1482.Staff.all(); \
			"dataclass"; "Staff"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.current_item.enteredBy:=$form.item.code
			cs:C1710.panel_AML.me._activate_save_cancel_button()
		End if 
	End if 
	
	This:C1470.drawPup_empCode()
	
	
Function drawPup_inventoryUnit()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("Units"; "levelID"; "inventoryUnits"; "pup_inventoryUnit")
	End if 
	
	
Function pup_inventoryUnit()
	//Create pop up menu
	Form:C1466.current_item.pup("units"; "Units"; "levelID"; "inventoryUnits")
	This:C1470.drawPup_inventoryUnit()
	
	
Function drawPup_procurementUnit()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("Units"; "levelID"; "procurementUnits"; "pup_procurementUnit")
	End if 
	
	
Function pup_procurementUnit()
	//Create pop up menu
	Form:C1466.current_item.pup("units"; "Units"; "levelID"; "procurementUnits")
	This:C1470.drawPup_procurementUnit()
	
	
Function drawPup_division()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("Division"; "UUID"; "UUID_Division"; "pup_division")
	End if 
	
	
Function pup_division()
	//Create pop up menu
	Form:C1466.current_item.pup("divisions"; "Division"; "UUID"; "UUID_Division")
	This:C1470.drawPup_division()
	
	
Function btnOpenSupplier()
	
	$es:=ds:C1482.Supplier.query("UUID =:1"; Form:C1466.current_item.UUID_Supplier)
	
	If ($es.length>0)
		Form:C1466.sfw.openInANewWindow($es[0]; "qualityAssurance"; "Supplier")
	End if 
	
	
Function bActionDocument()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "View report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--view")
	If (Form:C1466.selectedDocument=Null:C1517) | (Undefined:C82(Form:C1466.selectedDocument))
		DISABLE MENU ITEM:C150($refMenu; 1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "add report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--add")
	If (sfw_checkIsInModification=False:C215)
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "modify report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 3; "--modify")
	If (sfw_checkIsInModification=False:C215) | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		DISABLE MENU ITEM:C150($refMenu; 3)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "delete report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 4; "--delete")
	If (sfw_checkIsInModification=False:C215) | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		DISABLE MENU ITEM:C150($refMenu; 4)
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	Case of 
		: ($choice="--view")
			
			$LocalFile:=Temporary folder:C486+Folder separator:K24:12+Form:C1466.selectedDocument.sourcePath
			BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.selectedDocument.blob)
			OPEN URL:C673($LocalFile; *)
			
			
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
			
			
			$form:=New object:C1471("details"; $details)  // Form.selectedDocument)
			$form.approverProfile:=_ga_qaEditProfiles
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
				
				Form:C1466.current_item.attachedDocuments.documents.push($form.details)
				// Apr 22, 2026 4DFix: was calling panel_supplier singleton instead of panel_AML
				cs:C1710.panel_AML.me._activate_save_cancel_button()
			End if 
			
			
		: ($choice="--modify")
			
			$form:=New object:C1471("details"; Form:C1466.current_item.attachedDocuments.documents[Form:C1466.selectedDocumentPos-1])
			$form.approverProfile:=_ga_qaEditProfiles
			$form.displayApprovalFields:=False:C215
			$form.bufferOfEvents:=Form:C1466.bufferOfEvents
			
			$winRef:=Open form window:C675("_ga_document"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_document"; $form)
			
			If (OK=1)
				If ($form.modified) | ($form.documentHasChanged)
					//Form.selectedDocument:=$form.details
					Form:C1466.current_item.attachedDocuments.documents[Form:C1466.selectedDocumentPos-1]:=$form.details
					// Apr 22, 2026 4DFix: was calling panel_supplier singleton instead of panel_AML
					cs:C1710.panel_AML.me._activate_save_cancel_button()
				End if 
			End if 
			
		: ($choice="--delete")
			
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this document? "; "Delete"; "CANCEL")
			If ($ok)
				
				//Form.lb_documents.remove(Form.selectedDocumentPos-1)
				
				$buffer:=New object:C1471()
				$buffer.event:="deleteDocument"
				$buffer.label:="Document "+Form:C1466.current_item.attachedDocuments.documents[Form:C1466.selectedDocumentPos-1].sourcePath+" deleted"
				$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
				Form:C1466.bufferOfEvents.push($buffer)
				Form:C1466.current_item.attachedDocuments.documents.remove(Form:C1466.selectedDocumentPos-1)
				// Apr 22, 2026 4DFix: was calling panel_supplier singleton instead of panel_AML
				cs:C1710.panel_AML.me._activate_save_cancel_button()
				
			End if 
			
			//This.loadDocuments()
			
	End case 
	
	This:C1470.loadDocuments()
	
Function loadDocuments()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_documents:=Form:C1466.current_item.attachedDocuments.documents.map(Formula:C1597(_ga_getDateTime))
		
	End if 
	
Function LoadAllTabs()
	
	This:C1470.loadDocuments()
	
	
Function btnOpenApprover()
	
	$es:=ds:C1482.Staff.query("code =:1"; Form:C1466.current_item.approvedBy)
	
	If ($es.length>0)
		Form:C1466.sfw.openInANewWindow($es[0]; "qualityAssurance"; "Staff")
	End if 
	
	
	
	