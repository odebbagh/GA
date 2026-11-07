// panel_priceListItem: a row of the master price list (PriceListItem).
// Form.lb_flowPrices: the rows of flowPrices (the prices of the flows that differ from the base one),
// edited in place; every change gives the entity a new flowPrices object so that sfw sees it.
singleton Class constructor
	// It's a singleton class


Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadFlowPrices()
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadFlowPrices()
		End case
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if


Function redrawAndSetVisible()
	var $modify : Boolean
	var $warnings : Collection

	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$modify:=Form:C1466.sfw.checkIsInModification()
	This:C1470.drawPup_process()
	This:C1470.drawPup_customer()
	This:C1470.drawPup_unit()
	OBJECT SET VISIBLE:C603(*; "btnDatePickerFrom"; $modify)
	OBJECT SET VISIBLE:C603(*; "btnDatePickerTo"; $modify)
	OBJECT SET VISIBLE:C603(*; "bAddFlow"; $modify)
	OBJECT SET VISIBLE:C603(*; "bRemoveFlow"; $modify)
	OBJECT SET ENTERABLE:C238(*; "Column_flowPrice"; $modify)
	OBJECT SET ENTERABLE:C238(*; "Column_flowCost"; $modify)

	$warnings:=Form:C1466.current_item.warnings
	Form:C1466.priceWarnings:=$warnings.join("\r")
	OBJECT SET VISIBLE:C603(*; "txt_warnings"; $warnings.length>0)


Function loadFlowPrices()
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.lb_flowPrices:=New collection:C1472
		return
	End if
	If (Form:C1466.current_item.flowPrices=Null:C1517) || (Value type:C1509(Form:C1466.current_item.flowPrices.rows)#Is collection:K8:32)
		Form:C1466.lb_flowPrices:=New collection:C1472
	Else
		Form:C1466.lb_flowPrices:=Form:C1466.current_item.flowPrices.rows
	End if

	// a new flowPrices object on the entity (an object changed in place is not seen as a change)
Function _setFlowRows($rows : Collection)
	Form:C1466.current_item.flowPrices:=New object:C1471("rows"; $rows.orderBy("flowCode asc"))
	Form:C1466.lb_flowPrices:=Form:C1466.current_item.flowPrices.rows
	This:C1470._activate_save_cancel_button()
	This:C1470.redrawAndSetVisible()


	//Mark:- Process, customer, unit
Function pup_process()
	var $menu; $choice : Text
	var $process : cs:C1710.StepProcessEntity

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "(none: not an operation process)"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "0"*32)
	APPEND MENU ITEM:C411($menu; "-")
	For each ($process; ds:C1482.StepProcess.all().orderBy("name asc"))
		APPEND MENU ITEM:C411($menu; $process.name; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $process.UUID)
		If ($process.UUID=Form:C1466.current_item.UUID_StepProcess)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.UUID_StepProcess)
		Form:C1466.current_item.UUID_StepProcess:=$choice
		If (Form:C1466.current_item.description="") && (Form:C1466.current_item.stepProcess#Null:C1517)
			Form:C1466.current_item.description:=Form:C1466.current_item.stepProcess.name
		End if
		This:C1470._activate_save_cancel_button()
		This:C1470.redrawAndSetVisible()
	End if

Function drawPup_process()
	var $title : Text
	$title:=(Form:C1466.current_item.stepProcess=Null:C1517) ? "(not a process)" : Form:C1466.current_item.stepProcess.name
	Form:C1466.sfw.drawButtonPup("pup_process"; $title; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

	// the general price (every customer), or one customer's own price: found by a part of its name
Function pup_customer()
	var $menu; $choice : Text
	var $answer : Object
	var $customers : cs:C1710.CustomerSelection
	var $customer : cs:C1710.CustomerEntity

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "All customers (general price)"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "0"*32)
	APPEND MENU ITEM:C411($menu; "One customer..."; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "search")
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	If ($choice="search")
		$choice:=""
		$answer:=cs:C1710.sfw_dialog.me.request("Customer name or code (a part is enough):"; ""; "Search"; "Cancel"; "trimSpace"; "notEmpty")
		If (Bool:C1537($answer.ok)) && (String:C10($answer.answer)#"")
			$customers:=ds:C1482.Customer.query("name = :1 or code = :1"; "@"+$answer.answer+"@").orderBy("name asc").slice(0; 60)
			Case of
				: ($customers.length=0)
					cs:C1710.sfw_dialog.me.alert("No customer matches \""+$answer.answer+"\".")
				: ($customers.length=1)
					$choice:=$customers.first().UUID
				Else
					$menu:=Create menu:C408
					For each ($customer; $customers)
						APPEND MENU ITEM:C411($menu; $customer.name+" ("+$customer.code+")"; *)
						SET MENU ITEM PARAMETER:C1004($menu; -1; $customer.UUID)
					End for each
					$choice:=Dynamic pop up menu:C1006($menu)
					RELEASE MENU:C978($menu)
			End case
		End if
	End if
	If ($choice#"") && ($choice#Form:C1466.current_item.UUID_Customer)
		Form:C1466.current_item.UUID_Customer:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.redrawAndSetVisible()
	End if

Function drawPup_customer()
	var $title : Text
	$title:=(Form:C1466.current_item.customer=Null:C1517) ? "All customers" : Form:C1466.current_item.customer.name
	Form:C1466.sfw.drawButtonPup("pup_customer"; $title; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

	// what the price is for: unit (x quantity), lot, hour, each (a flat charge)
Function pup_unit()
	var $menu; $choice; $unit : Text

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$menu:=Create menu:C408
	For each ($unit; New collection:C1472("unit"; "lot"; "hour"; "each"))
		APPEND MENU ITEM:C411($menu; $unit; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $unit)
		If ($unit=Form:C1466.current_item.unit)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.unit)
		Form:C1466.current_item.unit:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.redrawAndSetVisible()
	End if

Function drawPup_unit()
	Form:C1466.sfw.drawButtonPup("pup_unit"; "per "+Form:C1466.current_item.unit; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)


	//Mark:- Fields
Function entryField_number()
	// prices, cost, minimum lot charge
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470._activate_save_cancel_button()
		This:C1470.redrawAndSetVisible()  // the warnings may come or go
	End if

Function entryField_unitPrice()
	This:C1470.entryField_number()

Function entryField_unitCost()
	This:C1470.entryField_number()

Function entryField_minLotCharge()
	This:C1470.entryField_number()

Function entryField_effectiveFrom()
	This:C1470.entryField_number()

Function entryField_effectiveTo()
	This:C1470.entryField_number()

Function entryField_active()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470._activate_save_cancel_button()
		This:C1470.redrawAndSetVisible()
	End if

Function btnDatePickerFrom()
	If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.sfw.checkIsInModification())
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_item; "effectiveFrom"))
			This:C1470._activate_save_cancel_button()
			This:C1470.redrawAndSetVisible()
		End if
	End if

Function btnDatePickerTo()
	If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.sfw.checkIsInModification())
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_item; "effectiveTo"))
			This:C1470._activate_save_cancel_button()
			This:C1470.redrawAndSetVisible()
		End if
	End if


	//Mark:- Prices by flow
Function lb_flowPrices()
	var $rows : Collection
	If (FORM Event:C1606.code=On Data Change:K2:15)
		$rows:=OB Copy:C1225(Form:C1466.lb_flowPrices)
		This:C1470._setFlowRows($rows)
	End if

	// a price for one of the flows that has none yet
Function bAddFlow()
	var $menu; $choice : Text
	var $flow : cs:C1710.PriceFlowEntity
	var $rows : Collection

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$rows:=OB Copy:C1225(Form:C1466.lb_flowPrices || New collection:C1472)
	$menu:=Create menu:C408
	For each ($flow; ds:C1482.PriceFlow.all().orderBy("levelID asc"))
		If ($rows.query("UUID_PriceFlow = :1"; $flow.UUID).length=0)
			APPEND MENU ITEM:C411($menu; $flow.code+" - "+$flow.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $flow.UUID)
		End if
	End for each
	If (Count menu items:C405($menu)=0)
		RELEASE MENU:C978($menu)
		cs:C1710.sfw_dialog.me.alert("Every flow already has its price here. The flows are defined in Administration > Price flows.")
		return
	End if
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"")
		$flow:=ds:C1482.PriceFlow.get($choice)
		$rows.push(New object:C1471("UUID_PriceFlow"; $flow.UUID; "flowCode"; $flow.code; "unitPrice"; Form:C1466.current_item.unitPrice; "unitCost"; Form:C1466.current_item.unitCost))
		This:C1470._setFlowRows($rows)
	End if

Function bRemoveFlow()
	var $rows : Collection

	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.selectedFlowPrice=Null:C1517)
		return
	End if
	$rows:=OB Copy:C1225(Form:C1466.lb_flowPrices).query("UUID_PriceFlow # :1"; Form:C1466.selectedFlowPrice.UUID_PriceFlow)
	This:C1470._setFlowRows($rows)
