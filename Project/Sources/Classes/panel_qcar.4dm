singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				// add load functions
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadObjectiveEvidences()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
	
Function pup_XXX()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
	End if 
	This:C1470.drawPup_XXX()
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	OBJECT SET ENABLED:C1123(*; "entryField_rb_@"; Form:C1466.sfw.checkIsInModification())
	
	This:C1470.qcarManage()
	This:C1470.hideDatePickers()
	This:C1470.manageExternal()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	Case of 
		: (FORM Get current page:C276(*)=2)
			OBJECT GET COORDINATES:C663(*; "subform_qcar"; $left; $top; $right; $bottom)
			
			$offset:=4
			
			OBJECT SET COORDINATES:C1248(*; "subform_qcar"; $left; $top; $right; $heightSubform-$offset)
	End case 
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$approverProfile:=New collection:C1472("qs"; "qm")  // only QC Team allowed to modify
		
		$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		
		OBJECT SET ENABLED:C1123(*; "entryField_issuedTo"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "EntryField_issuedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_issuedDate"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verifiedDate"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verifiedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verified"; $hasAuthorizedProfile)
		
		OBJECT SET VISIBLE:C603(*; "dp_verifiedDate"; $hasAuthorizedProfile)
		OBJECT SET VISIBLE:C603(*; "dp_issuedDate"; $hasAuthorizedProfile)
		
		
		
	End if 
	
	
Function qcarManage()
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.situation.mode="add")
			Form:C1466.current_item._initCorrectiveActionReport()
		End if 
		
		Form:C1466.subForm_qcar:=New object:C1471()
		Form:C1466.subForm_qcar.correctiveActionReport:=Form:C1466.current_item.correctiveActionReport
		Form:C1466.subForm_qcar.situation:=Form:C1466.situation
	End if 
	
Function selectCustomer()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_customerName"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Screen:K27:7)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"lb_items"; ds:C1482.Customer.all()\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
			If (ok=1)
				Form:C1466.current_item.UUID_Customer:=$form.item.UUID
				// Apr 22, 2026 4DFix: was calling panel_purchaseOrder singleton instead of panel_qcar
				cs:C1710.panel_qcar.me._activate_save_cancel_button()
			End if 
	End case 
	End if 
	
Function selectLot()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				// Apr 22, 2026 4DFix: was using "Field_customerName" coordinates for the lot popup — corrected to "Field_lotNumber"
				OBJECT GET COORDINATES:C663(*; "Field_lotNumber"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Screen:K27:7)
				
				$form:=New object:C1471(\
					"colName"; "lotNumber"; \
					"lb_items"; ds:C1482.Lot.all()\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
			If (ok=1)
				Form:C1466.current_item.UUID_Lot:=$form.item.UUID
				// Apr 22, 2026 4DFix: was calling panel_purchaseOrder singleton instead of panel_qcar
				cs:C1710.panel_qcar.me._activate_save_cancel_button()
			End if 
		End case 
	End if 
	
Function subFormEvent()
	Form:C1466.current_item.correctiveActionReport:=Form:C1466.subForm_qcar.correctiveActionReport
	This:C1470._activate_save_cancel_button()
	
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	
Function loadXXX()
	//Loads and initializes a list
	
Function bActionXXX()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	
Function verifyQcar()
	If (Form:C1466.sfw.checkIsInModification())
		If (Form:C1466.current_item.verified)
			Form:C1466.current_item.verifiedBy:=cs:C1710.sfw_userManager.me.info.name
			Form:C1466.current_item.verifiedDate:=Current date:C33()
		End if 
	End if 
	
Function manageExternal()
	OBJECT SET VISIBLE:C603(*; "label_externalParty"; Not:C34(Form:C1466.current_item.internal))
	OBJECT SET VISIBLE:C603(*; "EntryField_externalParty"; Not:C34(Form:C1466.current_item.internal))
	
Function loadObjectiveEvidences()
	Form:C1466.lb_documents:=ds:C1482.ObjectiveEvidence.query("UUID_Qcar = :1"; Form:C1466.current_item.UUID)
	
Function bActionManageDocuments()
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Add Document")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "View Document")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--view")
	If (Form:C1466.selectedDocument=Null:C1517)
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Delete Document")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()) | (Form:C1466.selectedDocument=Null:C1517))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--add")
			$doc:=Select document:C905(""; "*"; "Select Documet: "; Allow alias files:K24:10)
			
			If (OK=1)
				$document_o:=Path to object:C1547(Document)
				DOCUMENT TO BLOB:C525(Document; $blob)
				
				$oe_e:=ds:C1482.ObjectiveEvidence.new()
				
				$oe_e.name:=$document_o.name
				$oe_e.extension:=$document_o.extension
				$oe_e.blob:=$blob
				
				$oe_e.UUID_Qcar:=Form:C1466.current_item.UUID
				
				$res:=$oe_e.save()
				
				If ($res.success)
					This:C1470.loadObjectiveEvidences()
					This:C1470._activate_save_cancel_button()
				End if 
				
			End if 
		: ($choose="--view")
			If (BLOB size:C605(Form:C1466.selectedDocument.blob)>0)
				$path:=Temporary folder:C486+Form:C1466.selectedDocument.name+Form:C1466.selectedDocument.extension
				
				BLOB TO DOCUMENT:C526($path; Form:C1466.selectedDocument.blob)
				
				OPEN URL:C673($path)
			End if 
		: ($choose="--delete")
			$ok:=cs:C1710.sfw_dialog.me.confirm("Are you sure ?")
			If ($ok)
				$res:=Form:C1466.selectedDocument.drop()
				
				If ($res.success)
					This:C1470.loadObjectiveEvidences()
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
	End case 