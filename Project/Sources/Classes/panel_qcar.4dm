singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Form:C1466.sfw.redrawButtons()
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	OBJECT SET ENTERABLE:C238(*; "Field_qcarNumber"; False:C215) 
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
	cs:C1710.Util.me.lockDateInputs() 
	
	
	/* Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
	
Function pup_XXX()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
	End if 
	This:C1470.drawPup_XXX()
	*/
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	var $inModification : Boolean
	
	$inModification:=Form:C1466.sfw.checkIsInModification()
	OBJECT SET ENABLED:C1123(*; "entryField_rb_@"; $inModification)
	
	// Purpose: Main tab uses Field_* / EntryField_* / pup_* widgets — enable them explicitly in modification mode.
	// modified by 4D/PS [2026-june-08]
	OBJECT SET ENTERABLE:C238(*; "Field@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "Field@"; $inModification)
	OBJECT SET ENTERABLE:C238(*; "EntryField@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "EntryField@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "pup_@"; $inModification)
	OBJECT SET ENTERABLE:C238(*; "Field_qcarNumber"; False:C215)
	OBJECT SET ENABLED:C1123(*; "Field_qcarNumber"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "Field_customer"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "Field_device"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "Field_lot.poNumber"; False:C215)
	cs:C1710.Util.me.lockDateInputs()
	
	This:C1470.qcarManage()
	This:C1470.hideDatePickers()
	This:C1470.manageExternal()
	This:C1470.drawPup_traveler()
	This:C1470.drawPup_customer()
	This:C1470.drawPup_rejectCategory()
	This:C1470.drawPup_origin()
	This:C1470.manageOriginAndTraveler()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	Case of 
		: (FORM Get current page:C276(*)=2)
			OBJECT GET COORDINATES:C663(*; "subform_qcar"; $left; $top; $right; $bottom)
			
			$offset:=4
			
			OBJECT SET COORDINATES:C1248(*; "subform_qcar"; $left; $top; $right; $heightSubform-$offset)
	End case 
	
	If (Form:C1466.sfw.checkIsInModification())
		
		// Purpose: QA edit gate uses _ga_qaEditProfiles (qs, qi, qm) — aligned with Staff entry.
		// modified by 4D/PS [2026-may-21]
		$approverProfile:=_ga_qaEditProfiles
		
		$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		
		OBJECT SET ENTERABLE:C238(*; "entryField_issuedTo"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_issuedTo"; $hasAuthorizedProfile)
		OBJECT SET ENTERABLE:C238(*; "EntryField_issuedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "EntryField_issuedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_issuedDate"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verifiedDate"; $hasAuthorizedProfile)
		OBJECT SET ENTERABLE:C238(*; "entryField_verifiedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verifiedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verified"; $hasAuthorizedProfile)
		
		OBJECT SET VISIBLE:C603(*; "btnDatePickerVerified"; $hasAuthorizedProfile)
		OBJECT SET VISIBLE:C603(*; "btnDatePickerIssued"; $hasAuthorizedProfile)
		
	End if 
	
	
Function btnTraveler()
	// Purpose: Lot entry ident is planning (the old lots entry is commented out).
	// modified by 4D/PS [2026-october-09]
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.current_item.lot=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No traveler is linked to this CAR.")
		return 
	End if 
	Form:C1466.sfw.openInANewWindow(Form:C1466.current_item.lot; "customerService"; "planning")
	
Function btnPO()
	var $po : cs:C1710.PurchaseOrderEntity
	var $poText : Text
	
	// Purpose: PurchaseOrder.poNumber is numeric; traveler PO# is text (oldPoNumber / poNum).
	// modified by 4D/PS [2026-october-09]
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.current_item.lot=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No purchase order is linked to this CAR.")
		return 
	End if 
	$poText:=String:C10(Form:C1466.current_item.lot.poNumber)
	$po:=This:C1470._findPurchaseOrder($poText)
	If ($po=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No purchase order is linked to this traveler.")
		return 
	End if 
	Form:C1466.sfw.openInANewWindow($po; "customerService"; "purchaseOrders")
	
	
Function btnOpenCustomer()
	// Purpose: Open the linked Customer entry from CAR (same bForward pattern as traveler / PO).
	// created by 4D/PS [2026-october-09]
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.current_item.customer=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No customer is linked to this CAR.")
		return 
	End if 
	Form:C1466.sfw.openInANewWindow(Form:C1466.current_item.customer; "customerService"; "customer")
	
	
Function _findPurchaseOrder($poText : Text)->$po : cs:C1710.PurchaseOrderEntity
	$poText:=String:C10($poText)
	If ($poText="")
		$po:=Null:C1517
		return 
	End if 
	$po:=ds:C1482.PurchaseOrder.query("oldPoNumber = :1 OR poNum = :1"; $poText).first()
	If ($po=Null:C1517) && (Num:C11($poText)#0)
		$po:=ds:C1482.PurchaseOrder.query("poNumber = :1"; Num:C11($poText)).first()
	End if 
	
	
Function qcarManage()
	If (Form:C1466.current_item#Null:C1517)
		// Purpose: 8D report is initialized once in QcarEntity.loadAfterCreation — do not reset on every redraw in add mode.
		// modified by 4D/PS [2026-june-08]
		
		Form:C1466.subForm_qcar:=New object:C1471()
		Form:C1466.subForm_qcar.correctiveActionReport:=Form:C1466.current_item.correctiveActionReport
		Form:C1466.subForm_qcar.situation:=Form:C1466.situation
	End if 
	
Function selectCustomer()
	// Purpose: Independent customer pick when Origin is not product/lot related (Karla C — Origin Customer).
	// modified by 4D/PS [2026-october-09]
	If (Form:C1466.sfw.checkIsInModification()) && (This:C1470.originAllowsCustomerPick())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "pup_customer"; $l; $t; $r; $b)
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
					cs:C1710.panel_qcar.me._activate_save_cancel_button()
				End if 
		End case 
	End if 
	This:C1470.drawPup_customer() 
	
Function drawPup_traveler()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_traveler"; "")
		$lot:=ds:C1482.Lot.query("UUID =:1"; Form:C1466.current_item.UUID_Lot)
		$lotNumber:=$lot.length>0 ? $lot.first().lotNumber : ""
		Form:C1466.sfw.drawButtonPup("pup_traveler"; $lotNumber; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($lot=Null:C1517))
		
	End if 
	
Function selectTraveler()
	If (Form:C1466.sfw.checkIsInModification()) && (This:C1470.originAllowsTraveler())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "pup_traveler"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$dataCollection:=New collection:C1472()
				$dataCollection:=ds:C1482.Lot.all()
				
				$form:=New object:C1471(\
					"colName"; "lotNumber"; \
					"lb_items"; $dataCollection; \
					"allData"; $dataCollection; \
					"dataclass"; "Lot"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					
					Form:C1466.current_item.UUID_Lot:=$form.item.UUID
					Form:C1466.current_item.device:=String:C10($form.item.device)
					$customer:=ds:C1482.Customer.query("name =:1"; Split string:C1554($form.item.customer; "\r"; sk trim spaces:K86:2).join("\r"))
					If ($customer.length>0)
						Form:C1466.current_item.UUID_Customer:=$customer[0].UUID
					End if 
					cs:C1710.panel_qcar.me._activate_save_cancel_button()
				End if 
		End case 
	End if 
	This:C1470.drawPup_traveler()
	This:C1470.drawPup_customer()
	
Function subFormEvent()
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.subForm_qcar=Null:C1517)
		return 
	End if 
	If (Form:C1466.subForm_qcar.correctiveActionReport#Null:C1517)
		// Reassign a copy so ORDA persists in-place object edits (team, 8D text, dates).
		Form:C1466.current_item.correctiveActionReport:=OB Copy:C1225(Form:C1466.subForm_qcar.correctiveActionReport)
		Form:C1466.subForm_qcar.correctiveActionReport:=Form:C1466.current_item.correctiveActionReport
	End if 
	This:C1470._activate_save_cancel_button()
	// CALL SUBFORM CONTAINER does not run the panel form method, so the toolbar must be refreshed here.
	Form:C1466.sfw.redrawButtons()
	
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	
Function verifyQcar()
	If (Form:C1466.sfw.checkIsInModification())
		If (Form:C1466.current_item.verified)
			Form:C1466.current_item.verifiedBy:=cs:C1710.sfw_userManager.me.info.name
			Form:C1466.current_item.verifiedDate:=Current date:C33()
		Else 
			Form:C1466.current_item.verifiedBy:=""
			Form:C1466.current_item.verifiedDate:=!00-00-00!
		End if 
		This:C1470._activate_save_cancel_button()
	End if 
	
	
	/* Purpose: Staff picker for Issued By / Verified By — unused; those fields are free text like GoldenAltos.
	   created by 4D/PS [2026-october-05]
	Function pickStaffAttribute($attribute : Text)
	var $l; $t; $r; $b : Integer
	var $name : Text
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.current_item=Null:C1517) || ($attribute="")
		return 
	End if 
	If (FORM Event:C1606.code#On Clicked:K2:4) && (FORM Event:C1606.code#On Getting Focus:K2:7)
		return 
	End if 
	
	OBJECT GET COORDINATES:C663(*; FORM Event:C1606.objectName; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	$name:=_ga_pickStaffName($l; $b; String:C10(Form:C1466.current_item[$attribute]))
	If (OK=1)
		Form:C1466.current_item[$attribute]:=$name
		This:C1470._activate_save_cancel_button()
	End if */
	
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
			This:C1470.viewSelectedObjectiveEvidence() 
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
	
	
Function lb_documents()
	If (FORM Event:C1606.code=On Double Clicked:K2:5)
		This:C1470.viewSelectedObjectiveEvidence()
	End if 
	
	
Function viewSelectedObjectiveEvidence()
	If (Form:C1466.selectedDocument=Null:C1517)
		return 
	End if 
	If (BLOB size:C605(Form:C1466.selectedDocument.blob)>0)
		$path:=Temporary folder:C486+Form:C1466.selectedDocument.name+Form:C1466.selectedDocument.extension
		BLOB TO DOCUMENT:C526($path; Form:C1466.selectedDocument.blob)
		OPEN URL:C673($path)
	End if 
	
	
	// Purpose: Draws the reject-criteria pop-up button. Label is the item name when a sub-level is selected,
	// otherwise the root category name. Picto colored from the selected entity's `color` (item first, else category).
	// modified by 4D/PS [2026-may-19]
Function drawPup_rejectCategory()
	If (Form:C1466.current_item#Null:C1517)
		
		OBJECT SET TITLE:C194(*; "pup_rejectCategory"; "")
		$label:=""
		$colorName:=""
		
		If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_RejectCriteriaItem)=False:C215)
			$item:=Form:C1466.current_item.rejectCriteriaItem
			If ($item#Null:C1517)
				$label:=String:C10($item.name)
				$colorName:=cs:C1710.sfw_htmlColor.me.getName($item.color) || ""
			End if 
		Else 
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_RejectCriteriaCategory)=False:C215)
				$category:=Form:C1466.current_item.rejectCriteriaCategory
				If ($category#Null:C1517)
					$label:=String:C10($category.name)
					$colorName:=cs:C1710.sfw_htmlColor.me.getName($category.color) || ""
				End if 
			End if 
		End if 
		
		If ($colorName#"")
			$picto:="sfw/colors/"+$colorName+"-circle.png"
		Else 
			$picto:="sfw/image/skin/rainbow/icon/spacer-1x24.png"
		End if 
		
		Form:C1466.sfw.drawButtonPup("pup_rejectCategory"; $label; $picto; ($label=""))
	End if 
	
	
	
	
	// Purpose: Opens a hierarchical pop-up listing every RejectCriteriaCategory; categories with sub-items expose them as a sub-menu.
	// Selecting a category-only entry resets UUID_RejectCriteriaItem; selecting an item sets both UUIDs.
	// created by 4D/PS [2026-may-19]
Function pup_rejectCategory()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.rejectCriteriaCategory=Null:C1517)
			ds:C1482.RejectCriteriaCategory.cacheLoad()
		End if 
		
		$mainMenu:=Create menu:C408
		$menusToRelease:=New collection:C1472($mainMenu)
		
		$currentCategoryUUID:=Form:C1466.current_item.UUID_RejectCriteriaCategory
		$currentItemUUID:=Form:C1466.current_item.UUID_RejectCriteriaItem
		
		For each ($category; Storage:C1525.cache.rejectCriteriaCategory)
			$items:=ds:C1482.RejectCriteriaItem.query("UUID_RejectCriteriaCategory = :1"; $category.UUID).orderBy("levelID")
			
			Case of 
				: ($items.length=0)
					// Category has no sub-items — flat entry that selects the category only.
					APPEND MENU ITEM:C411($mainMenu; $category.name; *)
					SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "cat:"+$category.UUID)
					If ($category.UUID=$currentCategoryUUID) && (cs:C1710.sfw_string.me.isAnEmptyUUID($currentItemUUID))
						SET MENU ITEM MARK:C208($mainMenu; -1; Char:C90(18))
					End if 
					
				Else 
					// Category with sub-items — submenu listing items; first entry selects the category alone.
					$subMenu:=Create menu:C408
					$menusToRelease.push($subMenu)
					
					APPEND MENU ITEM:C411($subMenu; "(any) "+$category.name; *)
					SET MENU ITEM PARAMETER:C1004($subMenu; -1; "cat:"+$category.UUID)
					If ($category.UUID=$currentCategoryUUID) && (cs:C1710.sfw_string.me.isAnEmptyUUID($currentItemUUID))
						SET MENU ITEM MARK:C208($subMenu; -1; Char:C90(18))
					End if 
					
					APPEND MENU ITEM:C411($subMenu; "-")
					
					For each ($item; $items)
						APPEND MENU ITEM:C411($subMenu; $item.name; *)
						SET MENU ITEM PARAMETER:C1004($subMenu; -1; "item:"+$category.UUID+":"+$item.UUID)
						If ($item.UUID=$currentItemUUID)
							SET MENU ITEM MARK:C208($subMenu; -1; Char:C90(18))
						End if 
					End for each 
					
					APPEND MENU ITEM:C411($mainMenu; $category.name; $subMenu; *)
			End case 
		End for each 
		
		OBJECT GET COORDINATES:C663(*; "pup_rejectCategory"; $left; $top; $right; $bottom)
		CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Current window:K27:6)
		$choose:=Dynamic pop up menu:C1006($mainMenu; ""; $left; $bottom)
		
		For each ($refMenu; $menusToRelease)
			RELEASE MENU:C978($refMenu)
		End for each 
		
		Case of 
			: ($choose="")
				// nothing — user cancelled
			: (Substring:C12($choose; 1; 4)="cat:")
				Form:C1466.current_item.UUID_RejectCriteriaCategory:=Substring:C12($choose; 5)
				Form:C1466.current_item.UUID_RejectCriteriaItem:=16*"00"
				This:C1470._activate_save_cancel_button()
			: (Substring:C12($choose; 1; 5)="item:")
				$parts:=Split string:C1554(Substring:C12($choose; 6); ":")
				If ($parts.length>=2)
					Form:C1466.current_item.UUID_RejectCriteriaCategory:=$parts[0]
					Form:C1466.current_item.UUID_RejectCriteriaItem:=$parts[1]
					This:C1470._activate_save_cancel_button()
				End if 
		End case 
		
		This:C1470.drawPup_rejectCategory()
		
	End if 
	
	
	// Purpose: Origin checkbox + dropdown (Karla C). Traveler stays enabled only when origin is unchecked
	// or the selected origin has usesTraveler (Product by default; editable in Administration / CAR origins).
	// created by 4D/PS [2026-oct-02]
Function originAllowsTraveler()->$allow : Boolean
	$allow:=True:C214
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Bool:C1537(Form:C1466.current_item.otherOriginChecked))
		$origin:=Form:C1466.current_item.qcarOrigin
		If ($origin=Null:C1517) || (Not:C34(Bool:C1537($origin.usesTraveler)))
			$allow:=False:C215
		End if 
	End if 
	
	
	// Purpose: When the CAR is not product/lot related, Customer is chosen on its own (Origin Customer).
	// created by 4D/PS [2026-october-09]
Function originAllowsCustomerPick()->$allow : Boolean
	$allow:=Not:C34(This:C1470.originAllowsTraveler())
	
	
Function drawPup_customer()
	var $name : Text
	
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_customer"; "")
		$name:=String:C10(Form:C1466.current_item.customerDisplay)
		Form:C1466.sfw.drawButtonPup("pup_customer"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($name=""))
	End if 
	
	
Function manageOriginAndTraveler()
	var $inModification; $originOn; $allowTraveler; $allowCustomer; $hasLot; $hasCustomer; $hasPo : Boolean
	
	$inModification:=Form:C1466.sfw.checkIsInModification()
	$originOn:=(Form:C1466.current_item#Null:C1517) && (Bool:C1537(Form:C1466.current_item.otherOriginChecked))
	$allowTraveler:=This:C1470.originAllowsTraveler()
	$allowCustomer:=This:C1470.originAllowsCustomerPick()
	$hasLot:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lot#Null:C1517)
	$hasCustomer:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.customer#Null:C1517)
	$hasPo:=$hasLot && (This:C1470._findPurchaseOrder(String:C10(Form:C1466.current_item.lot.poNumber))#Null:C1517)
	
	OBJECT SET ENABLED:C1123(*; "entryField_otherOriginChecked"; $inModification)
	OBJECT SET VISIBLE:C603(*; "pup_origin"; $originOn)
	OBJECT SET ENABLED:C1123(*; "pup_origin"; $inModification && $originOn)
	OBJECT SET ENABLED:C1123(*; "pup_traveler"; $inModification && $allowTraveler)
	OBJECT SET ENABLED:C1123(*; "pup_customer"; $inModification && $allowCustomer)
	OBJECT SET ENABLED:C1123(*; "btnForward2"; $hasLot)
	OBJECT SET ENABLED:C1123(*; "btnForward1"; $hasPo)
	OBJECT SET ENABLED:C1123(*; "btnForward3"; $hasCustomer)
	
	
Function checkboxOrigin()
	If (Form:C1466.sfw.checkIsInModification())
		If (Not:C34(Bool:C1537(Form:C1466.current_item.otherOriginChecked)))
			Form:C1466.current_item.UUID_QcarOrigin:=16*"00"
		End if 
		This:C1470._syncLotWithOrigin()
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_origin()
		This:C1470.drawPup_traveler()
		This:C1470.drawPup_customer()
		This:C1470.manageOriginAndTraveler()
	End if
	
	
	// Purpose: Karla C — Audit / Certification audit / Customer are not product-related: drop traveler so PO# and Traveler go empty.
	// created by 4D/PS [2026-october-09]
Function _syncLotWithOrigin()
	var $origin : cs:C1710.QcarOriginEntity
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Not:C34(Bool:C1537(Form:C1466.current_item.otherOriginChecked)))
		return 
	End if 
	$origin:=Form:C1466.current_item.qcarOrigin
	If ($origin=Null:C1517)
		return 
	End if 
	If (Bool:C1537($origin.usesTraveler))
		return 
	End if 
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Lot)=False:C215)
		Form:C1466.current_item.UUID_Lot:=16*"00"
	End if 
	
	
Function drawPup_origin()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_origin"; "")
		$label:=""
		If (Bool:C1537(Form:C1466.current_item.otherOriginChecked))
			$origin:=Form:C1466.current_item.qcarOrigin
			If ($origin#Null:C1517)
				$label:=String:C10($origin.name)
			End if 
		End if 
		Form:C1466.sfw.drawButtonPup("pup_origin"; $label; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($label=""))
	End if 
	
	
Function pup_origin()
	
	If (Form:C1466.sfw.checkIsInModification()) && (Bool:C1537(Form:C1466.current_item.otherOriginChecked))
		
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.qcarOrigin=Null:C1517)
			ds:C1482.QcarOrigin.cacheLoad()
		End if 
		
		$menu:=Create menu:C408
		$currentUUID:=Form:C1466.current_item.UUID_QcarOrigin
		
		If (Storage:C1525.cache#Null:C1517) && (Storage:C1525.cache.qcarOrigin#Null:C1517)
			For each ($item; Storage:C1525.cache.qcarOrigin)
				APPEND MENU ITEM:C411($menu; $item.name; *)
				SET MENU ITEM PARAMETER:C1004($menu; -1; $item.UUID)
				If ($item.UUID=$currentUUID)
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
			End for each 
		End if 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		If ($choose#"")
			Form:C1466.current_item.UUID_QcarOrigin:=$choose
			This:C1470._syncLotWithOrigin()
			This:C1470._activate_save_cancel_button()
		End if 
		
		This:C1470.drawPup_origin()
		This:C1470.drawPup_traveler()
		This:C1470.drawPup_customer()
		This:C1470.manageOriginAndTraveler()
		
	End if 
	