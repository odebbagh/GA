
singleton Class constructor
	// It's a singleton class
	
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
	
Function formMethod()
	// This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities
	If (Form:C1466.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary to refresh
		This:C1470.loadInventories()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  // A page is displayed so it's time to load the data sources
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadInventories()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visibility
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	This:C1470.drawPup_binLocationPath()

	// isEmpty is computed from linked inventory stock and cannot be set manually
	OBJECT SET ENABLED:C1123(*; "entryField_isEmpty"; False:C215)

	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	Case of
			//________________________________________
		: (FORM Get current page:C276(*)=1)

			OBJECT GET COORDINATES:C663(*; "lb_inventories"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_inventories"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)

			// keep the Actions button pinned to the bottom-left of the panel
			$offset_bA:=10
			OBJECT GET COORDINATES:C663(*; "bActionInventory"; $left_bA; $top_bA; $right_bA; $bottom_bA)
			$height_bA:=$bottom_bA-$top_bA
			OBJECT SET COORDINATES:C1248(*; "bActionInventory"; $left_bA; $heightSubform-$offset_bA-$height_bA; $right_bA; $heightSubform-$offset_bA)

	End case
	
	
Function drawPup_binLocationPath()
	If (Form:C1466.current_item#Null:C1517)
		cs:C1710.Util_binLocationPicker.me.draw("pup_binLocationPath"; Form:C1466.current_item.binLocationPath)
	End if 
	
Function loadInventories()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_inventories:=Form:C1466.current_item.inventories.orderBy("inventoryID asc")
		OBJECT SET VISIBLE:C603(*; "lbl_noInventory"; Form:C1466.lb_inventories.length=0)
		OBJECT SET VISIBLE:C603(*; "lb_inventories"; Form:C1466.lb_inventories.length>0)
		OBJECT SET VISIBLE:C603(*; "bActionInventory"; Not:C34(Form:C1466.current_item.isEmpty))
	End if
	
	
Function bActionInventory()
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Open in new window"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "openInWindow")
	
	If (Form:C1466.selectedInventory=Null:C1517) | (Undefined:C82(Form:C1466.selectedInventory))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
		: ($choice="openInWindow")
			$entity:=Form:C1466.current_item.inventories.query("UUID=:1"; Form:C1466.selectedInventory.UUID).first()
			Form:C1466.sfw.openInANewWindow($entity; "customerService"; "inventories")
	End case 
	
	
Function pup_binLocationPath()
	If (Form:C1466.sfw.checkIsInModification())
		
		$newPath:=cs:C1710.Util_binLocationPicker.me.pickWithCreate("pup_binLocationPath"; Form:C1466.current_item.binLocationPath; "")
		If ($newPath#"")
			Form:C1466.current_item.binLocationPath:=$newPath
			cs:C1710.panel_bin.me._activate_save_cancel_button()
		End if 
		This:C1470.drawPup_binLocationPath()
		
		
	End if 
	
	
	
	