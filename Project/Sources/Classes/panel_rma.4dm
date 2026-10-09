singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Form:C1466.sfw.redrawButtons()
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET ENTERABLE:C238(*; "Field_rmaNumber"; False:C215)
	End if 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				// add load functions
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	cs:C1710.Util.me.lockDateInputs() 
	
Function btnCar()
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.current_item.qcar=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No CAR is linked to this RMA.")
		return 
	End if 
	Form:C1466.sfw.openInANewWindow(Form:C1466.current_item.qcar; "qualityAssurance"; "qcar") 
	
Function _enableLinkedForwards()
	var $hasCar; $hasTraveler; $hasCustomer : Boolean
	
	$hasCar:=False:C215
	$hasTraveler:=False:C215
	$hasCustomer:=False:C215
	If (Form:C1466.current_item#Null:C1517)
		$hasCar:=(Form:C1466.current_item.qcar#Null:C1517)
		$hasTraveler:=(String:C10(Form:C1466.current_item.travelerNumber)#"")
		$hasCustomer:=$hasCar && (Form:C1466.current_item.qcar.customer#Null:C1517)
	End if 
	OBJECT SET ENABLED:C1123(*; "btnForward1"; $hasCar)
	OBJECT SET ENABLED:C1123(*; "btnForward2"; $hasTraveler)
	OBJECT SET ENABLED:C1123(*; "btnForward3"; $hasCustomer)
	
	
Function btnOpenCustomer()
	// Purpose: RMA customer comes from the linked CAR; open the Customer entry.
	// created by 4D/PS [2026-october-09]
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.current_item.qcar=Null:C1517) || (Form:C1466.current_item.qcar.customer=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No customer is linked to this RMA.")
		return 
	End if 
	Form:C1466.sfw.openInANewWindow(Form:C1466.current_item.qcar.customer; "customerService"; "customer")
	
	
Function btnTraveler()
	var $es : Object
	
	If (Form:C1466.current_item=Null:C1517) || (String:C10(Form:C1466.current_item.travelerNumber)="")
		cs:C1710.sfw_dialog.me.alert("No traveler is linked to this RMA.")
		return 
	End if 
	$es:=ds:C1482.Lot.query("lotNumber = :1"; Form:C1466.current_item.travelerNumber)
	If ($es.length=0)
		cs:C1710.sfw_dialog.me.alert("No traveler is linked to this RMA.")
		return 
	End if 
	Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "planning") 
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	var $inModification : Boolean
	
	$inModification:=Form:C1466.sfw.checkIsInModification()
	
	// Purpose: SFW makes @entryField@ enterable. Field_* stay display-only (RMA #, customer, dates via calendar).
	// modified by 4D/PS [2026-june-08]
	// modified by 4D/PS [2026-october-05]
	OBJECT SET ENABLED:C1123(*; "Field@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "pup_@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "btnDatePicker@"; $inModification)
	OBJECT SET ENTERABLE:C238(*; "Field_rmaNumber"; False:C215)
	OBJECT SET ENABLED:C1123(*; "Field_rmaNumber"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "Field_customer"; False:C215)
	cs:C1710.Util.me.lockDateInputs()
	
	This:C1470.hideDatePickers()
	This:C1470.drawPup_car()
	This:C1470.drawPup_CustomerPO()
	This:C1470.drawPup_traveler()
	This:C1470._enableLinkedForwards()
	
	If ($inModification)
		
		// Purpose: QA edit gate uses _ga_qaEditProfiles (qs, qi, qm) — aligned with Staff entry.
		// modified by 4D/PS [2026-may-21]
		$approverProfile:=_ga_qaEditProfiles
		$hasAuthorizedProfile:=False:C215
		If (cs:C1710.sfw_userManager.me.authorizedProfiles#Null:C1517)
			$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		End if
		
		OBJECT SET ENTERABLE:C238(*; "entryField_qaQc"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_qaQc"; $hasAuthorizedProfile)
		
	End if 
	
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	
Function drawPup_car()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_car"; "")
		$number:=Form:C1466.current_item.qcar#Null:C1517 ? String:C10(Form:C1466.current_item.qcar.qcarNumber) : ""
		Form:C1466.sfw.drawButtonPup("pup_car"; $number; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.qcar=Null:C1517))
	End if 
	
Function selectQcar( ...  : Collection)
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item#Null:C1517)
		$param:=${1}
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				If (Not:C34(Undefined:C82($param)))
					$dataCollection:=$param
				Else 
					$dataCollection:=ds:C1482.Qcar.all()
				End if 
				$item:=cs:C1710.Util.me.openSelectNto1("pup_car"; "qcarNumber"; $dataCollection; "Qcar"; "There are no CARs to choose from.")
				If ($item#Null:C1517)
					Form:C1466.current_item.UUID_Qcar:=$item.UUID
					If ($item.lot#Null:C1517)
						This:C1470.applyLotSelection($item.lot)
					End if 
				End if 
		End case 
	End if 
	This:C1470.drawPup_car()
	
Function drawPup_CustomerPO()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_customerPO"; "")
		$number:=String:C10(Form:C1466.current_item.customerPo)
		Form:C1466.sfw.drawButtonPup("pup_customerPO"; $number; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item=Null:C1517))
	End if 
	
Function selectCustomerPO()
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item#Null:C1517)
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				$dataCollection:=New collection:C1472()
				$emptyMessage:="There are no purchase orders to choose from."
				If (Form:C1466.current_item.qcar=Null:C1517)
					$emptyMessage:="Select a CAR first."
				Else 
					If (Form:C1466.current_item.qcar.customer#Null:C1517)
						$dataCollection:=Form:C1466.current_item.qcar.customer.purchaseOrders
					End if 
				End if 
				$item:=cs:C1710.Util.me.openSelectNto1("pup_customerPO"; "poNumber"; $dataCollection; "PurchaseOrder"; $emptyMessage)
				If ($item#Null:C1517)
					Form:C1466.current_item.customerPo:=$item.poNumber
					This:C1470._activate_save_cancel_button()
				End if 
		End case 
	End if 
	This:C1470.drawPup_CustomerPO()
	
Function drawPup_traveler()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_traveler"; "")
		$number:=String:C10(Form:C1466.current_item.travelerNumber)
		Form:C1466.sfw.drawButtonPup("pup_traveler"; $number; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item=Null:C1517))
		
	End if 
	
Function selectTraveler()
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item#Null:C1517)
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				// Purpose: List every lot — a traveler can be chosen before lots are linked to CARs.
				// modified by 4D/PS [2026-october-05]
				$dataCollection:=ds:C1482.Lot.all().orderBy("lotNumber")
				$item:=cs:C1710.Util.me.openSelectNto1("pup_traveler"; "lotNumber"; $dataCollection; "Lot"; "There are no travelers to choose from.")
				If ($item#Null:C1517)
					This:C1470.applyLotSelection($item)
					$qcars:=$item.qcars
					If (($qcars#Null:C1517) && ($qcars.length>1))
						This:C1470.selectQcar($qcars.toCollection())
					End if 
				End if 
		End case 
	End if 
	This:C1470.drawPup_traveler()
	
	
	// Purpose: Fill RMA header from a selected lot — travelerNumber (original traveler), PO, and linked CAR when unambiguous.
	// Parameters: $lot_e : cs.LotEntity — lot chosen from the traveler picker
	// modified by 4D/PS [2026-june-08]
	// modified by 4D/PS [2026-october-05]
Function applyLotSelection($lot_e : cs:C1710.LotEntity)
	
	If ($lot_e=Null:C1517) | (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	Form:C1466.current_item.travelerNumber:=$lot_e.lotNumber
	If (String:C10($lot_e.poNumber)#"")
		Form:C1466.current_item.customerPo:=$lot_e.poNumber
	End if 
	$qcars:=$lot_e.qcars
	If (($qcars#Null:C1517) && ($qcars.length=1))
		Form:C1466.current_item.UUID_Qcar:=$qcars[0].UUID
	End if 
	This:C1470._activate_save_cancel_button()
	
	
Function btnDatePicker($object; $attribut)
	If (Form:C1466.sfw.checkIsInModification())
		If ($object=Null:C1517) | ($attribut="")
			return 
		End if 
		$form:=New object:C1471
		$form.date:=$object[$attribut]
		
		OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
		CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
		Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
		DIALOG:C40("_ga_calendar"; $form)
		
		If (OK=1) && ($form.calendar#Null:C1517) && ($form.calendar.display#Null:C1517)
			$object[$attribut]:=$form.calendar.display.date
			This:C1470._activate_save_cancel_button()
		End if 
	End if 
	