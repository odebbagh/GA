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
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
Function btnCar()
	If (Form:C1466.current_item.qcar#Null:C1517)
		var $es : Object
		$es:=ds:C1482.Qcar.query("qcarNumber = :1"; Form:C1466.current_item.qcar.qcarNumber)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "qualityAssurance"; "qcar")
		End if 
	End if 
	
Function btnTraveler()
	If (Form:C1466.current_item#Null:C1517)
		var $es : Object
		$es:=ds:C1482.Lot.query("lotNumber = :1"; Form:C1466.current_item.travelerNumber)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "lots")
		End if 
	End if 
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	var $inModification : Boolean
	
	$inModification:=Form:C1466.sfw.checkIsInModification()
	
	// Purpose: Header widgets use Field_* names (not entryField_*) — enable them explicitly in modification mode.
	// modified by 4D/PS [2026-june-08]
	OBJECT SET ENTERABLE:C238(*; "Field@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "Field@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "pup_@"; $inModification)
	OBJECT SET ENABLED:C1123(*; "btnDatePicker@"; $inModification)
	
	This:C1470.hideDatePickers()
	This:C1470.drawPup_car()
	This:C1470.drawPup_CustomerPO()
	This:C1470.drawPup_traveler()
	
	If ($inModification)
		
		// Purpose: QA edit gate uses _ga_qaEditProfiles (qs, qi, qm) — aligned with Staff entry.
		// modified by 4D/PS [2026-may-21]
		$approverProfile:=_ga_qaEditProfiles
		
		$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		
		OBJECT SET ENABLED:C1123(*; "entryField_qaQc"; $hasAuthorizedProfile)
		
	End if 
	
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	
Function drawPup_car()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_car"; "")
		$number:=Form:C1466.current_item.qcar#Null:C1517 ? String:C10(Form:C1466.current_item.qcar.qcarNumber) : ""
		Form:C1466.sfw.drawButtonPup("pup_car"; $number; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.qcar=Null:C1517))
	End if 
	
Function selectQcar( ...  : Collection)
	If (Form:C1466.sfw.checkIsInModification())
		$param:=${1}
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "pup_car"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				//$dataCollection:=New collection()
				//If (Split string(Form.current_item.travelerNumber; "\r"; sk trim spaces).join("\r")="")
				//$dataCollection:=ds.Qcar.all()
				
				//Else 
				
				//$dataCollection:=ds.Lot.query("lotNumber =:1"; Form.current_item.travelerNumber).qcars
				
				//End if 
				
				//If ($dataCollection.length=0)
				If (Not:C34(Undefined:C82($param)))
					$dataCollection:=$param
				Else 
					$dataCollection:=ds:C1482.Qcar.all()
				End if 
				
				
				//End if 
				
				$form:=New object:C1471(\
					"colName"; "qcarNumber"; \
					"lb_items"; $dataCollection; \
					"allData"; $dataCollection; \
					"dataclass"; "Qcar"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Qcar:=$form.item.UUID
					If ($form.item.lot#Null:C1517)
						This:C1470.applyLotSelection($form.item.lot)
					End if 
				End if 
		End case 
	End if 
	This:C1470.drawPup_car()
	
Function drawPup_CustomerPO()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_customerPO"; "")
		$number:=Form:C1466.current_item.customerPo
		Form:C1466.sfw.drawButtonPup("pup_customerPO"; $number; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item=Null:C1517))
	End if 
	
Function selectCustomerPO()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "pup_customerPO"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				
				$dataCollection:=New collection:C1472()
				If (Form:C1466.current_item.qcar#Null:C1517)
					If (Form:C1466.current_item.qcar.customer#Null:C1517)
						$dataCollection:=Form:C1466.current_item.qcar.customer.purchaseOrders
					End if 
				End if 
				
				$form:=New object:C1471(\
					"colName"; "poNumber"; \
					"lb_items"; $dataCollection; \
					"allData"; $dataCollection; \
					"dataclass"; "PurchaseOrder"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.customerPo:=$form.item.poNumber
					This:C1470._activate_save_cancel_button()
				End if 
		End case 
	End if 
	This:C1470.drawPup_CustomerPO()
	
Function drawPup_traveler()
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_traveler"; "")
		$number:=Form:C1466.current_item.travelerNumber
		Form:C1466.sfw.drawButtonPup("pup_traveler"; $number; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item=Null:C1517))
		
	End if 
	
Function selectTraveler()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "pup_traveler"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				//If (Form.current_item.qcar#Null)
				
				$dataCollection:=New collection:C1472()
				$dataCollection:=ds:C1482.Lot.all().query(Formula:C1597(This:C1470.qcars.length>0)).orderBy("lotNumber")
				
				//Else 
				
				$form:=New object:C1471(\
					"colName"; "lotNumber"; \
					"lb_items"; $dataCollection; \
					"allData"; $dataCollection; \
					"dataclass"; "Lot"\
					)
				//End if 
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					This:C1470.applyLotSelection($form.item)
					If ($form.item.qcars.length>1)
						This:C1470.selectQcar($form.item.qcars.toCollection())
					End if 
				End if 
		End case 
	End if 
	This:C1470.drawPup_traveler()
	
	
	// Purpose: Fill RMA header from a selected lot — travelerNumber (original traveler), PO, and linked CAR when unambiguous.
	// Parameters: $lot_e : cs.LotEntity — lot chosen from the traveler picker
	// modified by 4D/PS [2026-june-08]
Function applyLotSelection($lot_e : cs:C1710.LotEntity)
	
	If ($lot_e=Null:C1517)
		return 
	End if 
	
	Form:C1466.current_item.travelerNumber:=$lot_e.lotNumber
	If ($lot_e.poNumber#"")
		Form:C1466.current_item.customerPo:=$lot_e.poNumber
	End if 
	If ($lot_e.qcars.length=1)
		Form:C1466.current_item.UUID_Qcar:=$lot_e.qcars[0].UUID
	End if 
	This:C1470._activate_save_cancel_button()
	
	
Function btnDatePicker($object; $attribut)
	If (Form:C1466.sfw.checkIsInModification())
		$form:=New object:C1471
		$form.date:=$object[$attribut]
		
		OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
		CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
		Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
		DIALOG:C40("_ga_calendar"; $form)
		
		If (OK=1)
			$object[$attribut]:=$form.calendar.display.date
			This:C1470._activate_save_cancel_button()
		End if 
	End if 
	