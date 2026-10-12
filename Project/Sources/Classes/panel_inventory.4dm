singleton Class constructor
	//It's a singleton class

	// Customer Service > Inventories. Rebuilt in Oct 2026 on the legacy audits (Inventory_audit,
	// Inventory_audit2): one stock figure (availableQty) that only moves through a recorded line
	// (ga_stock.move), a bin that can hold many materials, the classification and units of their
	// own tables (InventoryClassification / InventoryUnits).

Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID

Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh
		This:C1470.loadAllTabs()
		Form:C1466.currentPath:=""
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadInventoryPulls()
		End case
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if

Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	var $modify; $isNew : Boolean

	$modify:=Form:C1466.sfw.checkIsInModification()
	$isNew:=False:C215
	If (Form:C1466.current_item#Null:C1517)
		$isNew:=Form:C1466.current_item.isNew()
	End if

	If (Form:C1466.lb_pulls#Null:C1517)
		Use (Form:C1466.sfw.entry.panel.pages)
			Form:C1466.sfw.entry.panel.pages[1].label:="Pulls & History ("+String:C10(Form:C1466.lb_pulls.length)+")"
		End use
	End if

	This:C1470.drawPup_customer()
	This:C1470.drawPup_status_IQA()
	This:C1470.drawPup_staff()
	This:C1470.drawPup_binLocation()

	// the pickers and calendars change the record: Modify only
	OBJECT SET ENABLED:C1123(*; "dp_units"; $modify)
	OBJECT SET ENABLED:C1123(*; "dp_classifications"; $modify)
	OBJECT SET ENABLED:C1123(*; "dp_dateIn_d"; $modify)
	OBJECT SET ENABLED:C1123(*; "dp_archivedDate1"; $modify)

	// the quantity received is typed once, when the material is created; after that the stock only
	// moves through Pulls & History (ga_stock)
	OBJECT SET ENTERABLE:C238(*; "entryField_initialQty"; $modify & $isNew)
	If ($isNew)
		Form:C1466.current_item.availableQty:=Form:C1466.current_item.initialQty
		cs:C1710.ga_stock.me.syncFigures(Form:C1466.current_item)
	End if

	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Case of
		: (FORM Get current page:C276(*)=2)  // pulls & history
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_pulls"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionPulls"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)

			$offset:=4
			$offset_bAc:=10

			$height_bAc:=$bottom_bAc-$top_bAc

			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_pulls"; $left_lb; $top_lb; $right_lb; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionPulls"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
	End case

	This:C1470.showOwner()

	Form:C1466.sfw.drawHTab()

Function showOwner()
	// customer material (customer specific) belongs to a customer: the customer picker; bought stock
	// comes from a supplier: the vendor text
	var $customerSpecific : Boolean

	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$customerSpecific:=Bool:C1537(Form:C1466.current_item.customerSpecific)
	OBJECT SET VISIBLE:C603(*; "pup_customer"; $customerSpecific)
	OBJECT SET VISIBLE:C603(*; "btnOpenCustomer"; $customerSpecific && (Form:C1466.current_item.customer#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnOpenCustomer"; (Form:C1466.current_item.customer#Null:C1517))
	OBJECT SET VISIBLE:C603(*; "entryField_vendor"; Not:C34($customerSpecific))
	OBJECT SET TITLE:C194(*; "label_customer"; $customerSpecific ? "Customer" : "Vendor")

Function customerSpecificChanged()
	This:C1470.showOwner()
	This:C1470._activate_save_cancel_button()

Function loadAllTabs()
	This:C1470.loadInventoryPulls()

Function loadInventoryPulls()
	Form:C1466.lb_pulls:=ds:C1482.InventoryPull.query("UUID_Inventory = :1"; Form:C1466.current_item.UUID).orderBy("date desc")

Function bActionInvPull()
	// stock corrections from this screen (the legacy adjustment list: Load Line, Variance, Scrap...):
	// Pull takes stock out, Put Back brings it in. Each is a recorded line (ga_stock.move); the stock
	// is never typed. In the legacy app all 416 put backs were made here, as corrections.
	var $form; $result : Object
	var $user_es : 4D:C1709.EntitySelection

	$refMenu:=Create menu:C408

	APPEND MENU ITEM:C411($refMenu; "Pull (take out of stock)")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--pull")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.current_item.isNew())
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if

	APPEND MENU ITEM:C411($refMenu; "Put Back (bring into stock)")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--put-back")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.current_item.isNew())
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if

	$choose:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	If ($choose="")
		return
	End if

	$form:=New object:C1471(\
		"invPull"; New object:C1471(\
		"isPull"; ($choose="--pull"); \
		"date"; Current date:C33(); \
		"currentQty"; Form:C1466.current_item.availableQty; \
		"qtyToPull"; 0; \
		"pulledBy"; ""; \
		"reason"; ""; \
		"note"; ""\
		))
	$user_es:=ds:C1482.sfw_User.query("login = :1"; Current user:C182)
	$form.invPull.pulledBy:=($user_es.length>0) ? $user_es[0].fullName : ""

	$winRef:=Open form window:C675("create_invPull"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("create_invPull"; $form)
	CLOSE WINDOW:C154($winRef)
	If (OK#1)
		return
	End if

	// the material of the panel itself, inside the panel's transaction: Cancel undoes it
	$result:=cs:C1710.ga_stock.me.move(Form:C1466.current_item; ($form.invPull.isPull) ? "Pull" : "Put Back"; Num:C11($form.invPull.qtyToPull); New object:C1471(\
		"performedBy"; $form.invPull.pulledBy; \
		"reason"; $form.invPull.reason; \
		"note"; $form.invPull.note; \
		"date"; $form.invPull.date))
	If ($result.success)
		This:C1470.loadInventoryPulls()
		This:C1470._activate_save_cancel_button()
	Else
		cs:C1710.sfw_dialog.me.alert($result.message)
	End if

Function selectCustomer()
	If (Form:C1466.sfw.checkIsInModification())
		Case of
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)

				OBJECT GET COORDINATES:C663(*; "pup_customer"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

				$form:=New object:C1471(\
					"colName"; "name"; \
					"lb_items"; ds:C1482.Customer.all().orderBy("name asc"); \
					"allData"; ds:C1482.Customer.all().orderBy("name asc"); \
					"dataclass"; "Customer"\
					)

				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)

				If (ok=1) && ($form.item#Null:C1517)
					Form:C1466.current_item.UUID_Customer:=$form.item.UUID
					Form:C1466.current_item.vendor:=String:C10($form.item.name)  // the name, as the legacy Vendor field held it
					This:C1470._activate_save_cancel_button()
				End if
		End case
	End if
	This:C1470.drawPup_customer()

Function drawPup_customer()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.customer.name || "Select Customer"
		Form:C1466.sfw.drawButtonPup("pup_customer"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.customer=Null:C1517))
	End if

Function drawPup_status_IQA()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.IQA_status || "Select Status"
		Form:C1466.sfw.drawButtonPup("pup_IQAstatus"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)
	End if

Function drawPup_staff()
	// Received By: the [Staff] link is "receiver"
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.receiver.fullName || "Select Staff"
		Form:C1466.sfw.drawButtonPup("pup_staff"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.receiver=Null:C1517))
	End if

Function manageUnit()
	// typed in the Units field: the matching unit of InventoryUnits, picked from a list
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470._pickFrom("InventoryUnits"; "entryField_units"; String:C10(Form:C1466.current_item.units); "UUID_InventoryUnits"; "units")
	End if

Function pickUnit()
	// the list button next to Units
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470._pickFrom("InventoryUnits"; "entryField_units"; ""; "UUID_InventoryUnits"; "units")
	End if

Function manageClassification()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470._pickFrom("InventoryClassification"; "entryField_classification"; String:C10(Form:C1466.current_item.classification); "UUID_InventoryClassification"; "classification")
	End if

Function pickClassification()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470._pickFrom("InventoryClassification"; "entryField_classification"; ""; "UUID_InventoryClassification"; "classification")
	End if

Function _pickFrom($dataclass : Text; $anchor : Text; $typed : Text; $linkField : Text; $textField : Text)
	// one value of a list table (InventoryClassification / InventoryUnits): typed text narrows the list
	// (one match is taken straight away), the link and the name are set together. Nothing is created
	// here: the lists are kept in Housekeeping.
	var $all; $matches : 4D:C1709.EntitySelection
	var $item : 4D:C1709.Entity
	var $form : Object

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$all:=ds:C1482[$dataclass].all().orderBy("name asc")
	$matches:=$all
	If ($typed#"")
		$matches:=$all.query("name = :1"; "@"+$typed+"@")
	End if

	$item:=Null:C1517
	If ($matches.length=1) && ($typed#"")
		$item:=$matches.first()
	Else
		If ($matches.length=0)
			$matches:=$all
		End if
		OBJECT GET COORDINATES:C663(*; $anchor; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		$form:=New object:C1471("colName"; "name"; "lb_items"; $matches; "allData"; $all; "dataclass"; $dataclass)
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		If (ok=1)
			$item:=$form.item
		End if
	End if

	If ($item#Null:C1517)
		Form:C1466.current_item[$linkField]:=$item.UUID
		Form:C1466.current_item[$textField]:=String:C10($item.name)
		This:C1470._activate_save_cancel_button()
	Else
		// nothing chosen: back to what the record holds
		$item:=(Form:C1466.current_item[$linkField]#"") ? ds:C1482[$dataclass].get(Form:C1466.current_item[$linkField]) : Null:C1517
		Form:C1466.current_item[$textField]:=($item#Null:C1517) ? String:C10($item.name) : String:C10(Form:C1466.current_item[$textField])
	End if

Function selectStatus_IQA()
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408

		APPEND MENU ITEM:C411($refMenu; " ")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--empty")

		APPEND MENU ITEM:C411($refMenu; "In Progress")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--in-progress")

		APPEND MENU ITEM:C411($refMenu; "Done")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--done")

		$choose:=Dynamic pop up menu:C1006($refMenu)

		Case of
			: ($choose="--empty")
				Form:C1466.current_item.IQA_status:=""

			: ($choose="--in-progress")
				Form:C1466.current_item.IQA_status:="In Progress"

			: ($choose="--done")
				Form:C1466.current_item.IQA_status:="Done"
		End case
		This:C1470._activate_save_cancel_button()
	End if
	This:C1470.drawPup_status_IQA()

Function selectStaff()
	If (Form:C1466.sfw.checkIsInModification())
		Case of
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)

				OBJECT GET COORDINATES:C663(*; "pup_staff"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

				$form:=New object:C1471(\
					"colName"; "fullName"; \
					"lb_items"; ds:C1482.Staff.all().orderBy("fullName asc"); \
					"allData"; ds:C1482.Staff.all().orderBy("fullName asc"); \
					"dataclass"; "Staff"\
					)

				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)

				If (ok=1) && ($form.item#Null:C1517)
					Form:C1466.current_item.UUID_Staff:=$form.item.UUID
					This:C1470._activate_save_cancel_button()
				End if
		End case
	End if
	This:C1470.drawPup_staff()

Function btnOpenCustomer()
	// also the object method of the button in dynamic rendering (Documents page): every event lands here
	Case of
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "btnOpenCustomer"); 9000; 9019))
			return
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469()
			return
		: (FORM Event:C1606.code#On Clicked:K2:4)
			return
	End case
	$entity:=Form:C1466.current_item.customer
	If ($entity#Null:C1517)
		Form:C1466.sfw.openInANewWindow($entity; "customerService"; "customer")
	End if

Function drawPup_binLocation()
	If (Form:C1466.current_item#Null:C1517)
		$locationName:=""
		If (Form:C1466.current_item.bin#Null:C1517)
			$locationName:=String:C10(Form:C1466.current_item.bin.binLocationPath)
		End if
		cs:C1710.Util_binLocationPicker.me.draw("pup_binLocation"; $locationName)
	End if

Function pup_binLocation()
	If (FORM Event:C1606.code#On Clicked:K2:4)
		return
	End if
	If (Form:C1466.sfw.checkIsInModification())

		$result:=cs:C1710.Util_binLocationPicker.me.pickReadOnly("pup_binLocation"; Form:C1466.currentPath; "")
		If ($result#"")
			Form:C1466.currentPath:=$result
			Form:C1466.selectedBins:=Storage:C1525.cache.bins.query("binLocationPath = :1"; Form:C1466.currentPath)
			If (Form:C1466.selectedBins#Null:C1517)
				If (Form:C1466.selectedBins.length>0)
					// Link inventory to the selected Bin record.
					Form:C1466.current_item.UUID_Location:=Form:C1466.selectedBins.first().UUID
					Form:C1466.current_item.location:=Form:C1466.selectedBins.first().binLocationPath
					This:C1470._activate_save_cancel_button()
				End if
			End if
			This:C1470.drawPup_binLocation()

		End if

	End if

//Mark:- Dynamic-rendering mirrors of the form object methods
// activateDocument() on this entry adds the framework Documents page, which switches the
// panel to dynamic-source rendering: every object method of the form is replaced by
// sfw_dynamicForm_script, which calls cs.panel_inventory.me[objectName]() - and does nothing, without
// an error, when there is no function of that name. Each function below is the object
// method of the object it is named after (Self replaced by the object's name). The
// ObjectMethods files are kept: CHANGE BOTH, or the panel behaves differently once the
// Documents page is removed.

Function bActionPulls()
	cs:C1710.panel_inventory.me.bActionInvPull()
	
Function dp_archivedDate1()
	// the app's calendar (ga_datePicker), opened under this button
	If (FORM Event:C1606.code=On Clicked:K2:4)
		cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_item; "expirationDate_d")  // the date view of the stamp (InventoryEntity)
	End if
	
Function dp_classifications()
	cs:C1710.panel_inventory.me.pickClassification()
	
Function dp_dateIn_d()
	// the app's calendar (ga_datePicker), opened under this button
	If (FORM Event:C1606.code=On Clicked:K2:4)
		cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_item; "dateIn")
	End if
	
Function dp_units()
	cs:C1710.panel_inventory.me.pickUnit()
	
Function entryField_classification()
	cs:C1710.panel_inventory.me.manageClassification()
	
Function entryField_customerSpecific()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		cs:C1710.panel_inventory.me.customerSpecificChanged()
	End if
	
Function entryField_units()
	cs:C1710.panel_inventory.me.manageUnit()
	
Function pup_IQAstatus()
	cs:C1710.panel_inventory.me.selectStatus_IQA()
	
Function pup_customer()
	cs:C1710.panel_inventory.me.selectCustomer()
	
Function pup_staff()
	cs:C1710.panel_inventory.me.selectStaff()
	
