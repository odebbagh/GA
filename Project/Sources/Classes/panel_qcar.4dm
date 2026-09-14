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
	OBJECT SET ENABLED:C1123(*; "btnForward@"; $inModification)
	
	This:C1470.qcarManage()
	This:C1470.hideDatePickers()
	This:C1470.manageExternal()
	This:C1470.drawPup_traveler()
	This:C1470.drawPup_rejectCategory()
	
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
		
		OBJECT SET ENABLED:C1123(*; "entryField_issuedTo"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_issuedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_issuedDate"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verifiedDate"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verifiedBy"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_verified"; $hasAuthorizedProfile)
		
		OBJECT SET VISIBLE:C603(*; "dp_verifiedDate"; $hasAuthorizedProfile)
		OBJECT SET VISIBLE:C603(*; "dp_issuedDate"; $hasAuthorizedProfile)
		
	End if 
	
	
Function btnTraveler()
	If (Form:C1466.current_item#Null:C1517)
		var $es : Object
		$es:=ds:C1482.Lot.query("lotNumber = :1"; Form:C1466.current_item.lot.lotNumber)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "lots")
		End if 
	End if 
	
Function btnPO()
	If (Form:C1466.current_item#Null:C1517)
		var $es : Object
		$es:=ds:C1482.PurchaseOrder.query("poNumber = :1"; Form:C1466.current_item.lot.poNumber)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "purchaseOrders")
		End if 
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
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "entryField_customerName"; $l; $t; $r; $b)
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
	
Function drawPup_traveler()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_traveler"; "")
		$lot:=ds:C1482.Lot.query("UUID =:1"; Form:C1466.current_item.UUID_Lot)
		$lotNumber:=$lot.length>0 ? $lot.first().lotNumber : ""
		Form:C1466.sfw.drawButtonPup("pup_traveler"; $lotNumber; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($lot=Null:C1517))
		
	End if 
	
Function selectTraveler()
	If (Form:C1466.sfw.checkIsInModification())
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
					$customer:=ds:C1482.Customer.query("name =:1"; Split string:C1554($form.item.customer; "\r"; sk trim spaces:K86:2).join("\r"))
					If ($customer.length>0)
						Form:C1466.current_item.UUID_Customer:=$customer[0].UUID
					End if 
					cs:C1710.panel_qcar.me._activate_save_cancel_button()
				End if 
		End case 
	End if 
	This:C1470.drawPup_traveler()
	
Function subFormEvent()
	Form:C1466.current_item.correctiveActionReport:=Form:C1466.subForm_qcar.correctiveActionReport
	This:C1470._activate_save_cancel_button()
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	
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
	