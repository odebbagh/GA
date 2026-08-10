
singleton Class constructor
	// It's a singleton class
	
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
	
Function formMethod()
	// This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities
	If (Form:C1466.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary to refresh
		This:C1470.loadLine()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  // A page is displayed so it's time to load the data sources
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadLine()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visibility
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function loadLine()
	// Prepares the two data sources the panel needs beyond current_item itself:
	// the jobs offered by the Shipping Job picker, and the address subform.
	//If (Form.current_item=Null)
	//return 
	//End if 
	
	//// Jobs attached to this line's purchase order: same list the createPoLine
	//// dialog offers, so the picker cannot point at a job of another PO.
	//Form.poJobs:=New collection()
	//If (Form.current_item.purchaseOrder#Null)
	//Form.poJobs:=ds.Job.query("UUID_PurchaseOrder = :1"; Form.current_item.purchaseOrder.UUID).orderBy("jobNumber")
	//End if 
	
	// Shipping address of the line, edited in place through the address subform:
	// Form.subFormAddress.address IS the object held by current_item.address, so
	// the edits land on the line and are saved with it (same wiring as createPoLine).
	
Function initShippingAddress()
	
	var $address : Object
	
	$address:=Form:C1466.current_item.address
	If ($address=Null:C1517)
		$address:=New object:C1471()
	End if 
	
	If ($address.detail=Null:C1517)
		// nothing stored on the line yet -> start from the purchase order's shipping address
		If (Form:C1466.current_item.purchaseOrder#Null:C1517)
			If (Form:C1466.current_item.purchaseOrder.address#Null:C1517)
				If (Form:C1466.current_item.purchaseOrder.address.addresses#Null:C1517)
					$poShipping:=Form:C1466.current_item.purchaseOrder.address.addresses.query("type = :1"; "shipping").first()
					If ($poShipping#Null:C1517)
						// deep copy, so editing the line never touches the PO record
						$address:=OB Copy:C1225($poShipping)
					End if 
				End if 
			End if 
		End if 
		If ($address.detail=Null:C1517)
			$address.detail:=New object:C1471()
		End if 
	End if 
	
	$address.type:="shipping"
	Form:C1466.current_item.address:=$address
	
	Form:C1466.subFormAddress:=New object:C1471(\
		"address"; Form:C1466.current_item.address; \
		"situation"; New object:C1471("mode"; "modify")\
		)
	
	
Function redrawAndSetVisible()
	// Header (page 0) values are read from the parent record or calculated by
	// applyLineTotal: none of them is keyed in here. Field_poNum is the exception: it is
	// not enterable either, but it is clickable because it picks the parent purchase
	// order, so it must stay enabled.
	//OBJECT SET ENABLED(*; "entryField_customer"; False)
	//OBJECT SET ENABLED(*; "entryField_total"; False)
	//OBJECT SET ENABLED(*; "entryField_saleTax"; False)
	
	//// The Shipping Job picker is only usable when the PO has jobs attached
	//var $hasPoJobs : Boolean
	//$hasPoJobs:=False
	//If (Form.poJobs#Null)
	//$hasPoJobs:=(Form.poJobs.length>0)
	//End if 
	//OBJECT SET ENABLED(*; "Field_shipJob"; $hasPoJobs)
	
	//// the PO selection arrow is only offered while the record is being edited
	//var $isInModification : Boolean
	//$isInModification:=Form.sfw.checkIsInModification()
	//OBJECT SET VISIBLE(*; "btnSelectPO"; $isInModification)
	//OBJECT SET ENABLED(*; "btnSelectPO"; $isInModification)
	
	//OBJECT GET SUBFORM CONTAINER SIZE($widthSubform; $heightSubform)
	//$offset:=4
	//Case of 
	////________________________________________
	//: (FORM Get current page(*)=1)
	
	//// The address section is the last one: let it follow the panel width and
	//// take the height left below the sections above it. Floored at its design
	//// height so a short panel cannot collapse (or invert) the subform.
	//var $minHeight : Integer
	//$minHeight:=175
	
	//OBJECT GET COORDINATES(*; "subFormAddress"; $left_sf; $top_sf; $right_sf; $bottom_sf)
	
	//$newBottom:=$heightSubform-$offset-1
	//If ($newBottom<($top_sf+$minHeight))
	//$newBottom:=$top_sf+$minHeight
	//End if 
	
	//$newRight:=$widthSubform-$offset
	//If ($newRight<($left_sf+100))
	//$newRight:=$left_sf+100
	//End if 
	
	//OBJECT SET COORDINATES(*; "subFormAddress"; $left_sf; $top_sf; $newRight; $newBottom)
	
	// the section bands stop at the same right edge as the subform
	//For each ($bandName; New collection("item_bkgd"; "item_header"; "pricing_bkgd"; "pricing_header"; "dates_bkgd"; "dates_header"; "fulfilment_bkgd"; "fulfilment_header"; "address_header"))
	//OBJECT GET COORDINATES(*; $bandName; $left_b; $top_b; $right_b; $bottom_b)
	//OBJECT SET COORDINATES(*; $bandName; $left_b; $top_b; $newRight; $bottom_b)
	//End for each 
	
	//End case 
	
	
Function applyLineTotal()
	// A line's stored total is quantity x unit price, plus sales tax when the line is
	// taxable and the parent purchase order applies tax. Identical rule to
	// panel_purchaseOrder.applyPoLineTotal, kept here so a line edited from this
	// panel stores the same figures as one created from the PO panel.
	var $base : Real
	var $tax : Real
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	$base:=Num:C11(Form:C1466.current_item.qtyOrdered)*Num:C11(Form:C1466.current_item.unitPrice)
	
	$tax:=0
	If (Bool:C1537(Form:C1466.current_item.taxable))
		If (Form:C1466.current_item.purchaseOrder#Null:C1517)
			If (Bool:C1537(Form:C1466.current_item.purchaseOrder.taxApplied))
				$tax:=$base*(Num:C11(Form:C1466.current_item.purchaseOrder.taxPercentage)/100)
			End if 
		End if 
	End if 
	
	Form:C1466.current_item.saleTax:=$tax
	Form:C1466.current_item.total:=$base+$tax
	
	
Function recalcPoAmount()
	// PO Amount is a read-only calculated value: the sum of its line totals. This
	// line is still unsaved while the panel is in modification, so sum the sibling
	// lines from the datastore and add this line's in-memory total, instead of
	// re-querying a value that is not written yet.
	var $sum : Real
	var $po : 4D:C1709.Entity
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	$po:=Form:C1466.current_item.purchaseOrder
	If ($po=Null:C1517)
		return 
	End if 
	
	$sum:=ds:C1482.PurchaseOrderLine.query("UUID_PurchaseOrder = :1 and UUID # :2"; $po.UUID; Form:C1466.current_item.UUID).sum("total")
	$sum:=$sum+Num:C11(Form:C1466.current_item.total)
	
	If ($po.poAmount#$sum)
		$po.poAmount:=$sum
		$po.save()
	End if 
	
	
Function lineAmountChanged()
	// Called by the quantity / unit price fields: recompute the line then keep the
	// parent purchase order amount in sync, as the PO panel does on every line save.
	This:C1470.applyLineTotal()
	This:C1470.recalcPoAmount()
	cs:C1710.panel_poLines.me._activate_save_cancel_button()
	
	
Function btnDatePicker_dateOrdered()
	If (Form:C1466.sfw.checkIsInModification())
		cs:C1710.Util.me.btnDatePicker(Form:C1466.current_item; "dateOrdered")
		cs:C1710.panel_poLines.me._activate_save_cancel_button()
	End if 
	
	
Function btnDatePicker_customerRequestedDate()
	If (Form:C1466.sfw.checkIsInModification())
		cs:C1710.Util.me.btnDatePicker(Form:C1466.current_item; "customerRequestedDate")
		cs:C1710.panel_poLines.me._activate_save_cancel_button()
	End if 
	
	
Function selectPurchaseOrder()
	// Purchase order of the line, picked from the standard selectNto1 list (searched and
	// displayed on poNum, the text PO number used by the PO list and searchbox).
	var $form : Object
	var $winRef : Integer
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	
	OBJECT GET COORDINATES:C663(*; "Field_poNum"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	
	$form:=New object:C1471(\
		"colName"; "poNum"; \
		"allData"; ds:C1482.PurchaseOrder.all().orderBy("poNum"); \
		"dataclass"; "PurchaseOrder"\
		)
	
	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		Form:C1466.current_item.UUID_PurchaseOrder:=$form.item.UUID
		// the Shipping Job list and the default shipping address both depend on the PO
		This:C1470.initShippingAddress()
		//calculate item number
		Form:C1466.current_item.itemNum:=This:C1470.getNewPOItemNumber($form.item.UUID)
		cs:C1710.panel_poLines.me._activate_save_cancel_button()
	End if 
	
Function getNewPOItemNumber($UUIDPO : Text)->$itemNumber : Integer
	$test:=ds:C1482.PurchaseOrderLine.all()
	$poItems:=ds:C1482.PurchaseOrderLine.query("UUID_PurchaseOrder = :1"; $UUIDPO).orderBy("itemNum desc")
	
	If ($poItems.length=0)
		$itemNumber:=1
	Else 
		$itemNumber:=$poItems[0].itemNum+1
	End if 
	
Function selectShipJob()
	// Shipping Job is picked from the jobs attached to this line's purchase order,
	// through the standard selectNto1 list (same pattern as the other job pickers).
	If (Form:C1466.poJobs=Null:C1517)
		return 
	End if 
	If (Form:C1466.poJobs.length=0)
		return 
	End if 
	
	var $form : Object
	var $winRef : Integer
	
	OBJECT GET COORDINATES:C663(*; "Field_shipJob"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	
	$form:=New object:C1471(\
		"colName"; "jobNumber"; \
		"allData"; Form:C1466.poJobs; \
		"dataclass"; "Job"\
		)
	
	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		Form:C1466.current_item.shipJobNumber:=$form.item.jobNumber
		cs:C1710.panel_poLines.me._activate_save_cancel_button()
	End if 
	