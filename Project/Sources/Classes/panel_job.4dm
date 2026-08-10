singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh
		Form:C1466.addressBilling:=1
		Form:C1466.addressShipping:=0
		Form:C1466.sfw.entry.setAllowedProfilesForCreation("nothing")
		
		This:C1470.loadAllTabs()

	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.initAddresses()
				
			: (FORM Get current page:C276(*)=2)
				
			: (FORM Get current page:C276(*)=3)  //PO -> line items
				This:C1470.loadPoLineItems()
				
			: (FORM Get current page:C276(*)=4)  //PO -> line items
				This:C1470.loadLots()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
Function loadDpAddress()
	Form:C1466.dpAddress:=New object:C1471(\
		"values"; New collection:C1472("billing"; "shipping"); \
		"index"; 0; \
		"currentValue"; "Billing Address"\
		)
	
	
Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
	
Function pup_XXX()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
	End if 
	This:C1470.drawPup_XXX()
	
	
Function redrawAndSetVisible()
	This:C1470.hideDatePickers()
	// pup_jobType, pup_tax and entryField_taxRate are no longer on the form (the Main
	// page was rebuilt). Their drawing/enabling is disabled so the redraw does not
	// address missing objects; restore these lines if the fields are put back.
	//This.drawPup_jobType()
	//This.drawPup_tax()

	// Job #, Customer and PO # are read-only display fields: they are named Field_*
	// (not entryField_*) so the framework leaves them transparent instead of painting
	// them as entry boxes it then cannot make enterable. Customer and PO # are picked
	// through the selectNto1 list on click, handled by their object methods.
	//OBJECT SET ENTERABLE(*; "entryField_taxRate"; False)
	
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[2].label:="PO Lines ("+String:C10(Form:C1466.lb_lineItems.length)+")"
		Form:C1466.sfw.entry.panel.pages[3].label:="Lots ("+String:C10(Form:C1466.lb_lots.length)+")"
	End use 
	
	//OBJECT SET ENABLED(*; "pup_jobType"; Form.situation.mode="add")
	Form:C1466.sfw.drawHTab()
	
	
	Case of 
			
		: (FORM Get current page:C276(*)=1)

			// Main page: the Job Specification block keeps its width on the left, the
			// address block grows to fill the rest of the panel.
			$offset:=2

			OBJECT GET COORDINATES:C663(*; "header_bkgd_addrMain"; $left_a; $top_a; $right_a; $bottom_a)
			OBJECT SET COORDINATES:C1248(*; "header_bkgd_addrMain"; $left_a; $top_a; $widthSubform-$offset; $heightSubform-$offset)

			OBJECT GET COORDINATES:C663(*; "subFormAddress_main"; $left_s; $top_s; $right_s; $bottom_s)
			OBJECT SET COORDINATES:C1248(*; "subFormAddress_main"; $left_s; $top_s; $widthSubform-($offset*3); $heightSubform-($offset*3))

		: (FORM Get current page:C276(*)=2)
			
			OBJECT GET COORDINATES:C663(*; "subFormAddress"; $left_l; $top_l; $right_l; $bottom_l)
			OBJECT GET COORDINATES:C663(*; "header_bkgd3"; $left_c; $top_c; $right_c; $bottom_c)
			
			$offset:=2
			
			OBJECT SET COORDINATES:C1248(*; "subFormAddress"; $left_l; $top_l; $widthSubform-30; $heightSubform-10)
			OBJECT SET COORDINATES:C1248(*; "header_bkgd3"; $left_c; $top_c; $widthSubform-$offset; $heightSubform-$offset)
			
			
		: (FORM Get current page:C276(*)=3)  // po lines
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_poLinesItems"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionLineItems"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_poLinesItems"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionLineItems"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			
		: (FORM Get current page:C276(*)=4)  // lots
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_3"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_poLinesItems"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionLineItems"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_3"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_lots"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionLots"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
	End case 
	
	// entryField_shipMemo and entryField_jobComment no longer exist on the form (the
	// Main page was rebuilt); the profile restrictions are kept here so they can be
	// re-enabled as soon as those two fields are put back on a page.
	//If (Form.sfw.checkIsInModification())
	//$authorizedProfile:=New collection("qs"; "qm")  // only QC Team allowed to modify
	//$hasAuthorizedProfile:=cs.sfw_userManager.me.authorizedProfiles.find(Formula((Value type($1.value)=Is text) && ($authorizedProfile.indexOf($1.value)#-1)))#Null
	//OBJECT SET ENTERABLE(*; "entryField_shipMemo"; $hasAuthorizedProfile)
	//$authorizedProfile:=New collection("sr")  // only Shipping and Receiving Team allowed to modify
	//$hasAuthorizedProfile:=cs.sfw_userManager.me.authorizedProfiles.find(Formula((Value type($1.value)=Is text) && ($authorizedProfile.indexOf($1.value)#-1)))#Null
	//OBJECT SET ENTERABLE(*; "entryField_jobComment"; $hasAuthorizedProfile)
	//End if
	
	
Function loadAllTabs()
	This:C1470.loadPoLineItems()
	This:C1470.loadLots()
	
	
Function initAddresses()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.address:=Form:C1466.current_item.rebuildAddress()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
	End if

Function jobHasAddress()->$hasAddress : Boolean
	// True as soon as the job already holds at least one non-empty address, so we know
	// whether replacing them would discard something the user entered.
	var $address : Object

	$hasAddress:=False:C215
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	If (Form:C1466.current_item.address=Null:C1517)
		return
	End if
	If (Form:C1466.current_item.address.addresses=Null:C1517)
		return
	End if

	For each ($address; Form:C1466.current_item.address.addresses)
		If (Address_toSingleLine($address)#"")
			$hasAddress:=True:C214
			return
		End if
	End for each

Function applyAddressesFrom($addresses : Collection; $sourceLabel : Text)
	// Copy billing/shipping addresses onto the job. When the job already has addresses
	// the user is asked first, so an existing address is never overwritten silently.
	If ($addresses=Null:C1517)
		return
	End if
	If ($addresses.length=0)
		return
	End if
	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	If (This:C1470.jobHasAddress())
		If (Not:C34(cs:C1710.sfw_dialog.me.confirm(\
			"This job already has addresses.\rReplace them with the addresses of the selected "+$sourceLabel+"?"; \
			"Use "+$sourceLabel+" addresses"; \
			"Keep current addresses")))
			return
		End if
	End if

	If (Form:C1466.current_item.address=Null:C1517)
		Form:C1466.current_item.address:=New object:C1471()
	End if

	// deep copy: the job keeps its own version, editable without touching the source
	Form:C1466.current_item.address.addresses:=$addresses.copy()
	Form:C1466.current_item.address:=Form:C1466.current_item.address

	This:C1470.initAddresses()


Function loadPoLineItems()
	Form:C1466.lb_lineItems:=ds:C1482.PurchaseOrderLine.query("UUID_Job = :1"; Form:C1466.current_item.UUID)
	
Function loadLots()
	Form:C1466.lb_lots:=ds:C1482.Lot.query("UUID_Job = :1"; Form:C1466.current_item.UUID)
	
Function bActionAttachPoLine()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "Attach a PO Line")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "(Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--create")
				$form:=New object:C1471("UUID_Job"; Form:C1466.current_item.UUID)
				
				$winRef:=Open form window:C675("createPoLine_job"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createPoLine_job"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (OK=1)
					This:C1470.loadPoLineItems()
				End if 
				
			: ($choose="--delete")
				
		End case 
	Else 
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "(Attach a PO Line")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "(Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
	End if 
Function bActionAttachLot()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "Attach a Lot")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "(Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		APPEND MENU ITEM:C411($refMenu; "-")
		
		APPEND MENU ITEM:C411($refMenu; "Split Lot")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--split-lot")
		
		If (Form:C1466.selectedLot=Null:C1517)
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--create")
				$form:=New object:C1471("UUID_Job"; Form:C1466.current_item.UUID)
				
				$winRef:=Open form window:C675("createLot_job"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createLot_job"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (OK=1)
					This:C1470.loadLots()
				End if 
				
			: ($choose="--split-lot")
				$answer:=cs:C1710.sfw_dialog.me.request("Would you like to split the Lot into : ")
				If ($answer.ok) & ($answer.answer#"")
					$subLots:=Num:C11($answer.answer)
				End if 
				
				If ($subLots>0)
					If (Undefined:C82(Form:C1466.selectedLot.lotParent))
						
						$dataclassObject:=ds:C1482.Lot
						
						For ($i; 1; $subLots)
							$newLot:=ds:C1482.Lot.new()
							
							$id:=Form:C1466.selectedLot.subLots.length+$i
							
							$newLotNumber:=Form:C1466.selectedLot.lotNumber+"-"+String:C10($id)
							
							$lot_es:=ds:C1482.Lot.query("lotNumber = :1"; $newLotNumber)
							
							While ($lot_es.length>0)
								$id:=$id+1
								
								$newLotNumber:=(Form:C1466.selectedLot.lotNumber)+"-"+String:C10($id)
								
								$lot_es:=ds:C1482.Lot.query("lotNumber = :1"; $newLotNumber)
							End while 
							
							For each ($attributeName; $dataclassObject)
								$attribute:=$dataclassObject[$attributeName]
								
								If ($attribute.kind="storage")
									Case of 
										: ($attributeName="UUID") & ($attribute.type="string")
											$newLot[$attributeName]:=Generate UUID:C1066
										: ($attributeName="UUID_LotParent") & ($attribute.type="string")
											$newLot.UUID_LotParent:=Form:C1466.selectedLot.UUID
										: ($attributeName="lotNumber")
											$newLot.lotNumber:=$newLotNumber
										: ($attributeName="original")
											$newLot.original:=0
										: ($attributeName="ourCount")
											$newLot.ourCount:=0
										Else 
											$newLot[$attributeName]:=Form:C1466.selectedLot[$attributeName]
									End case 
								End if 
							End for each 
							
							$res:=$newLot.save()
							
							If ($res.success)
								//cs.panel_lot.me._activate_save_cancel_button()
								Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
							End if 
						End for 
						
						This:C1470.loadLots()
						
					Else 
						//Sub Lot
						ALERT:C41("sub lot")
					End if 
				End if 
				
		End case 
	Else 
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "(Attach a Lot")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "(Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "Split Lot")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--split-lot")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
	End if 
	
Function btnOpenCustomer()
	// the customer now lives on the job itself, no longer reached through the PO
	var $customer : 4D:C1709.Entity

	$customer:=Form:C1466.current_item.customer
	If ($customer=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No customer is linked to this job.")
		return
	End if
	Form:C1466.sfw.openInANewWindow($customer; "customerService"; "customer")
Function btnOpenPurchaseOrder()
	If (Form:C1466.current_item.purchaseOrder#Null:C1517)
		var $es : Object
		$es:=ds:C1482.PurchaseOrder.query("poNumber = :1"; Form:C1466.current_item.purchaseOrder.poNumber)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "purchaseOrders")
		End if 
	End if 
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	
Function loadMaterials()
	Form:C1466.lb_materials:=ds:C1482.Inventory.query("UUID_Job = :1"; Form:C1466.current_item.UUID)
	
Function bActionCustProvMat()
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Receive Material")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--receive_material")
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--receive_material")
			$form:=New object:C1471(\
				"inventory_e"; ds:C1482.Inventory.new()\
				)
			
			$form.inventory_e.vendor:=Form:C1466.current_item.job.customerName
			$form.inventory_e.UUID_Job:=Form:C1466.current_item.UUID
			$form.inventory_e.stockNum:="man_"+String:C10(ds:C1482.Inventory.all().length)+String:C10(Milliseconds:C459)
			$form.inventory_e.inventoryID:=(ds:C1482.Inventory.all().length>0) ? ds:C1482.Inventory.all().max("inventoryID")+1 : 1
			$form.inventory_e.code:="INV"+String:C10($form.inventory_e.inventoryID; "00000#")
			
			$winRef:=Open form window:C675("createManualInv_lot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createManualInv_lot"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (ok=1)
				$form.inventory_e.initialQty:=$form.inventory_e.qtyInStock
				$form.inventory_e.availableQty:=$form.inventory_e.qtyInStock
				
				$res:=$form.inventory_e.save()
				
				If ($res.success)
					This:C1470.loadMaterials()
					$form.inventory_e.afterCreation()
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
	End case 
	
Function drawPup_jobType()
	If (Form:C1466.current_item#Null:C1517)
		$jobType:=Form:C1466.current_item || New object:C1471()
		$typeName:=$jobType.lineItem=False:C215 ? "Job Order" : "NR Job Order"
		If ($typeName=Null:C1517)
			$typeName:=""
		End if 
		$color:=""  //cs.sfw_htmlColor.me.getName($jobType.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_jobType"; $typeName; $pathIcon; ($jobType=Null:C1517))
	End if 
	
Function pup_jobType()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		$jobTypes:=New collection:C1472(New object:C1471("name"; "Job Order"; "lineItem"; False:C215); New object:C1471("name"; "NR Job Order"; "lineItem"; True:C214))
		For each ($eType; $jobTypes)
			APPEND MENU ITEM:C411($menu; $eType.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eType.name)
			If ($eType.name=Form:C1466.current_item.jobType)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				Form:C1466.current_item.lineItem:=$choose="Job Order" ? False:C215 : True:C214
		End case 
		
	End if 
	This:C1470.drawPup_jobType()
	
	
	
Function selectPO()
	// Purchase order picker (standard selectNto1 list, searched and displayed on the
	// PO number). When the job already has a customer, only that customer's purchase
	// orders are offered; with no customer yet, all of them are.
	var $pos : cs:C1710.PurchaseOrderSelection
	var $form : Object
	var $winRef : Integer
	var $customerUUID : Text

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	$customerUUID:=This:C1470.jobCustomerUUID()

	If ($customerUUID#"")
		$pos:=ds:C1482.PurchaseOrder.query("UUID_Customer = :1"; $customerUUID).orderBy("poNum")
	Else
		$pos:=ds:C1482.PurchaseOrder.all().orderBy("poNum")
	End if

	If ($pos.length=0)
		cs:C1710.sfw_dialog.me.alert("No purchase order available for this customer.")
		return
	End if

	OBJECT GET COORDINATES:C663(*; "Field_purchaseOrder"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

	$form:=New object:C1471(\
		"colName"; "poNum"; \
		"allData"; $pos; \
		"dataclass"; "PurchaseOrder"\
		)

	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)

	If (OK=1)
		Form:C1466.current_item.UUID_PurchaseOrder:=$form.item.UUID
		// a job without its own customer inherits the one of the purchase order
		This:C1470.forceCustomerFromPO()
		// and its addresses are initialised from the purchase order
		If ($form.item.address#Null:C1517)
			This:C1470.applyAddressesFrom($form.item.address.addresses; "purchase order")
		End if
		This:C1470._activate_save_cancel_button()
	End if

Function jobCustomerUUID()->$customerUUID : Text
	// The job's own customer, "" when not set yet (an empty UUID counts as not set).
	$customerUUID:=""
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$customerUUID:=String:C10(Form:C1466.current_item.UUID_Customer)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($customerUUID))
		$customerUUID:=""
	End if

Function forceCustomerFromPO()
	// No customer on the job but a purchase order is linked -> take the PO's customer.
	var $po : 4D:C1709.Entity

	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	If (This:C1470.jobCustomerUUID()#"")
		return
	End if

	$po:=ds:C1482.PurchaseOrder.query("UUID = :1"; Form:C1466.current_item.UUID_PurchaseOrder).first()
	If ($po=Null:C1517)
		return
	End if
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($po.UUID_Customer)))
		return
	End if

	Form:C1466.current_item.UUID_Customer:=$po.UUID_Customer

Function selectCustomer()
	// The customer is picked on the job itself, independently of the purchase order.
	var $form : Object
	var $winRef : Integer

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	OBJECT GET COORDINATES:C663(*; "Field_customer"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

	$form:=New object:C1471(\
		"colName"; "name"; \
		"allData"; ds:C1482.Customer.all().orderBy("name"); \
		"dataclass"; "Customer"\
		)

	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)

	If (OK=1)
		Form:C1466.current_item.UUID_Customer:=$form.item.UUID
		// the job's addresses default to the customer's
		If ($form.item.contactDetails#Null:C1517)
			This:C1470.applyAddressesFrom($form.item.contactDetails.addresses; "customer")
		End if
		This:C1470._activate_save_cancel_button()
	End if
	
	
Function drawPup_tax()
	If (Form:C1466.current_item#Null:C1517)
		
		$tax:=ds:C1482.SalesTax.query("UUID =:1"; Form:C1466.current_item.UUID_SalesTax).first() || New object:C1471()
		$taxRate:=$tax#Null:C1517 ? $tax.code : ""
		$color:=""
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_tax"; $taxRate; $pathIcon; ($tax=Null:C1517))
	End if 
	
	
Function pup_tax()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.taxes=Null:C1517)
			ds:C1482.SalesTax.cacheLoad()
		End if 
		
		For each ($eTax; Storage:C1525.cache.taxes)
			APPEND MENU ITEM:C411($menu; $eTax.code; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eTax.UUID)
			If ($eTax.UUID=Form:C1466.current_item.UUID_SalesTax)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				$eTax:=ds:C1482.SalesTax.get($choose)
				Form:C1466.current_item.UUID_SalesTax:=$eTax.UUID
		End case 
		
		
	End if 
	This:C1470.drawPup_tax()
	
