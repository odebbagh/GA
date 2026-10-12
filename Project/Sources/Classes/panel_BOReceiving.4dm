// Receiving - Buy Orders panel: one [BuyingOrderLine] being received.
//
// The form was rebuilt from scratch on panel_boItem's conventions. What it replaced was
// a copy of panel_buyingOrder: object names like Field_customerName2..6 bound to units,
// unit price and tax, six display fields that opened a CUSTOMER picker when clicked, a
// dead "Received By" field wired to the order's requestor, 20 orphan object methods for
// controls the form no longer had, and a redraw that addressed two objects which did not
// exist at all. None of that survives here.
//
// Layout, following panel_boItem:
//   page 0  identity strip - order, item, vendor, division, and the three quantities
//           that matter while receiving (ordered / received / still open)
//   page 1  "What was ordered" on the left, read-only, because receiving must not edit
//           the purchase; "Receipt" and "Back-order" on the right, which is the only
//           part a receiver touches
//   page 2  the vendor lots: pending until the receipt is saved, then their stock records
//
// The legacy flow this implements is Ack_order -> recv_mrp -> NewRecvOrderedPart:
//   - a line is receivable only when its order is approved, not on hold and not closed,
//     and the line has an item number, a quantity and no date in yet
//     (BuyingOrderLineEntity.receivingBlockedReason)
//   - a receiver is required, legacy [BUY_ITEMS]Recd_by, now UUID_Staff
//   - an inventory line is received as vendor lots (Lot# / Qty, legacy's scan loop): one
//     part can arrive in several manufacturer batches. Saving makes one [Inventory] record
//     per lot (BuyingOrderLineEntity.afterSave), as Update_inventoryNew +
//     CreateSplitStocks did, linked by Inventory.UUID_BuyingOrderLine - the FK that
//     replaces the legacy StockGroup string - with BuyingOrderLine.UUID_Inventory on the
//     first lot
//   - non-inventory lines take a typed quantity, as legacy did for consumable/expense
//     and fixed-asset items
//   - a partial receipt can be split onto a back-order line, legacy
//     create_backordered_buyitem, now a parent link instead of Item+0.1
singleton Class constructor
	//It's a singleton class

Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID

Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities

	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded
		This:C1470.LoadAllTabs()
	End if

	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed, load its data
		If (FORM Get current page:C276(*)=2)
			This:C1470.loadLots()
		End if
	End if

	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //time to resize and set visible
		This:C1470.redrawAndSetVisible()
	End if

Function LoadAllTabs()
	This:C1470.loadLots()

Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	var $widthSubform; $heightSubform; $g; $h; $d; $b; $offset; $lotCount : Integer
	var $isInModification; $isInventoryItem; $canBackorder; $hasStock : Boolean
	var $line : cs:C1710.BuyingOrderLineEntity

	$isInModification:=Form:C1466.sfw.checkIsInModification()
	$line:=Form:C1466.current_item

	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4

	If (FORM Get current page:C276(*)=2)
		// vendor-lots page: action rail + list stretch with the window
		OBJECT GET COORDINATES:C663(*; "rec_bkgd_lots"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "rec_bkgd_lots"; $g; $h; $d; $heightSubform-$offset)

		OBJECT GET COORDINATES:C663(*; "bActionLots"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "bActionLots"; $g; $heightSubform-$offset-27; $d; $heightSubform-$offset-6)

		OBJECT GET COORDINATES:C663(*; "lb_lots"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "lb_lots"; $g; $h; $widthSubform-$offset; $heightSubform-$offset)
	End if 

	$isInventoryItem:=($line#Null:C1517) && Bool:C1537($line.inventory)
	$canBackorder:=($line#Null:C1517) && $line.canBackorder

	// the scanner beside the receiver picker only makes sense while editing
	OBJECT SET VISIBLE:C603(*; "btnScanReceiver"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "btnScanReceiver"; $isInModification)

	// Non-inventory line: quantity and date typed here. Inventory line: the quantity is
	// the total of the vendor lots (Lot# / Qty), as legacy locked Qtyin, and saving makes
	// one stock record per lot (BuyingOrderLineEntity.afterSave). Once the stock exists
	// the date and the lots belong to those records - delete them from the Inventories
	// tab to receive again.
	$hasStock:=$isInventoryItem && $line.hasReceiptInventory
	OBJECT SET ENTERABLE:C238(*; "entryField_qtyReceived"; $isInModification & Not:C34($isInventoryItem))
	OBJECT SET ENTERABLE:C238(*; "entryField_dateIn"; $isInModification & Not:C34($hasStock))
	OBJECT SET VISIBLE:C603(*; "btnDatePicker_dateIn"; $isInModification & Not:C34($hasStock))
	OBJECT SET ENABLED:C1123(*; "btnDatePicker_dateIn"; $isInModification & Not:C34($hasStock))
	OBJECT SET VISIBLE:C603(*; "@_receiveLots"; $isInventoryItem)
	OBJECT SET ENABLED:C1123(*; "btnReceiveLots"; $isInModification & Not:C34($hasStock))
	OBJECT SET VISIBLE:C603(*; "lbl_inventoryHint"; $isInventoryItem)
	OBJECT SET TITLE:C194(*; "lbl_inventoryHint"; $hasStock ? "stock records created - see Inventories" : "total of the vendor lots")

	// Same gate as the item action, so the button cannot offer something
	// _ga_backorderBuyLine would only refuse.
	OBJECT SET ENABLED:C1123(*; "btnBackorder"; $isInModification & $canBackorder)
	// Part # / Vendor Part #: hidden when the line has neither, which is most
	// non-inventory lines. Same rule as the Buy Items panel.
	var $objectName : Text
	var $showsPart : Boolean
	$showsPart:=($line#Null:C1517) && $line.showsPartNumber
	For each ($objectName; New collection:C1472("label_partNum"; "Field_partNum"; "label_vendorPartNum"; "Field_vendorPartNum"))
		OBJECT SET VISIBLE:C603(*; $objectName; $showsPart)
	End for each

	// record count in the Lots tab label, as in the other panels
	$lotCount:=(Form:C1466.lb_lots#Null:C1517) ? Form:C1466.lb_lots.length : 0

	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Inventories ("+String:C10($lotCount)+")"
	End use 

	Form:C1466.sfw.drawHTab()

	// The button on the Receipt page. Same code path as the "Back-order remaining
	// quantity" item action - one implementation, two ways in.
	// Date-picker beside Date Received. The object is addressed by NAME rather than
	// through Self->, matching panel_boItem._pickDateInto.
	//
	// Disabled by redrawAndSetVisible once an inventory line has its stock record: the
	// date then belongs to that record.
Function pickDateReceived()
	var $l; $t; $r; $b : Integer
	var $date : Date

	If (FORM Event:C1606.code#On Clicked:K2:4)
		return
	End if
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	If (Bool:C1537(Form:C1466.current_item.inventory)) && (Form:C1466.current_item.hasReceiptInventory)
		return
	End if


	$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.current_item.dateIn; "btnDatePicker_dateIn")  // the app's calendar

	If ($date#!00-00-00!)
		Form:C1466.current_item.dateIn:=$date
		This:C1470._activate_save_cancel_button()
	End if
Function receiveLots()
	// The Lot# / Qty button on the Receiving page.
	If (FORM Event:C1606.code#On Clicked:K2:4)
		return
	End if
	This:C1470._enterReceiptLots()

Function _enterReceiptLots()
	// Legacy NewRecvOrderedPart "Highlight Button1": asks for a vendor lot # and its
	// quantity, again and again, until the receiver enters no lot, a zero quantity, or
	// cancels - so box after box can be scanned without leaving the dialog. Both prompts
	// take a barcode scanner, which types into them like a keyboard.
	//
	// Nothing is created here. The lots wait on the line (BuyingOrderLineEntity.receiptLots)
	// and become [Inventory] records when the receipt is saved; until then they can be
	// removed from the Inventories tab. Over-receiving is allowed with a warning, as legacy
	// allowed it.
	var $line : cs:C1710.BuyingOrderLineEntity
	var $reason; $lotNumber; $qtyText : Text
	var $qty : Real
	var $done : Boolean

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$line:=Form:C1466.current_item
	If ($line=Null:C1517)
		return
	End if
	If (Not:C34(Bool:C1537($line.inventory)))
		cs:C1710.sfw_dialog.me.alert("This is not an inventory line: enter the quantity received directly.")
		return
	End if
	If ($line.hasReceiptInventory)
		cs:C1710.sfw_dialog.me.alert("The stock for this line has already been received. To change it, delete its inventory records on the Inventories tab.")
		return
	End if
	$reason:=$line.receivingOrderBlockedReason
	If ($reason#"")
		cs:C1710.sfw_dialog.me.alert($reason)
		return
	End if

	$done:=False:C215
	Repeat
		$lotNumber:=Request:C163("Vendor lot # - scan or type it."+Char:C90(Carriage return:K15:38)\
			+"Received so far: "+String:C10($line.receiptLotsTotal)+" of "+String:C10($line.qtyOrderedEffective)+" ordered."; ""; "Next"; "Done")
		$lotNumber:=Replace string:C233($lotNumber; Char:C90(Carriage return:K15:38); "")
		If (OK=0) | ($lotNumber="")
			$done:=True:C214
		Else
			$qtyText:=Request:C163("Quantity in vendor lot "+$lotNumber+":"; ""; "Add"; "Cancel")
			$qty:=Num:C11($qtyText)
			Case of
				: (OK=0) | ($qty=0)
					$done:=True:C214
				: ($qty<0)
					cs:C1710.sfw_dialog.me.alert("A negative quantity is not accepted. Lot "+$lotNumber+" was not added.")
				Else
					$line.addReceiptLot($lotNumber; $qty)
					If ($line.receiptLotsTotal>$line.qtyOrderedEffective)
						cs:C1710.sfw_dialog.me.alert("Warning: the vendor lots now total "+String:C10($line.receiptLotsTotal)+", more than the "+String:C10($line.qtyOrderedEffective)+" ordered.")
					End if
			End case
		End if
	Until ($done)

	This:C1470.loadLots()
	This:C1470._activate_save_cancel_button()
	This:C1470.redrawAndSetVisible()

Function _pendingLotRows($line : cs:C1710.BuyingOrderLineEntity)->$rows : Collection
	// The pending vendor lots shaped like the [Inventory] records they will become, so
	// the Inventories tab shows them in the same columns before the save.
	var $lots : Collection
	var $i : Integer

	$rows:=New collection:C1472
	$lots:=$line.receiptLots
	For ($i; 0; $lots.length-1)
		$rows.push(New object:C1471(\
			"pending"; True:C214; \
			"index"; $i; \
			"partLotNumber"; String:C10($lots[$i].lotNumber); \
			"initialQty"; Num:C11($lots[$i].qty); \
			"qtyInStock"; Num:C11($lots[$i].qty); \
			"code"; "on save"; \
			"stockNum"; ""; \
			"dateIn"; $line.dateIn))
	End for

Function _removePendingLot()
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	If (Form:C1466.selectedLot=Null:C1517) | Undefined:C82(Form:C1466.selectedLot)
		return
	End if
	Form:C1466.current_item.removeReceiptLot(Num:C11(Form:C1466.selectedLot.index))
	This:C1470.loadLots()
	This:C1470._activate_save_cancel_button()
	This:C1470.redrawAndSetVisible()

Function backorderRemaining()
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	_ga_backorderBuyLine
	This:C1470.loadLots()
	This:C1470._activate_save_cancel_button()
Function loadLots()
	// The vendor lots of this buy line. Before the receipt is saved they are the pending
	// lots entered with Lot# / Qty; afterwards the [Inventory] records they became (the
	// FK Inventory.UUID_BuyingOrderLine backs the "inventories" relation). The dataclass
	// is queried directly rather than through current_item.inventories: a relation
	// attribute is cached on the entity the first time it is read, so records created on
	// save would not show until current_item is reloaded.
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.lb_lots:=ds:C1482.Inventory.newSelection()
		return
	End if

	If (Bool:C1537(Form:C1466.current_item.inventory)) && (Not:C34(Form:C1466.current_item.hasReceiptInventory))
		Form:C1466.lb_lots:=This:C1470._pendingLotRows(Form:C1466.current_item)
		return
	End if

	Form:C1466.lb_lots:=ds:C1482.Inventory.query("UUID_BuyingOrderLine = :1"; Form:C1466.current_item.UUID).orderBy("inventoryID")

Function bActionLots()
	var $line : cs:C1710.BuyingOrderLineEntity
	var $canAdd : Boolean

	$line:=Form:C1466.current_item
	$canAdd:=Form:C1466.sfw.checkIsInModification() && ($line#Null:C1517) && Bool:C1537($line.inventory) && Not:C34($line.hasReceiptInventory)

	$refMenu:=Create menu:C408

	APPEND MENU ITEM:C411($refMenu; "Add Vendor Lots"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--add")
	If (Not:C34($canAdd))
		DISABLE MENU ITEM:C150($refMenu; 1)
	End if

	APPEND MENU ITEM:C411($refMenu; "Delete"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--delete")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) | (Form:C1466.selectedLot=Null:C1517) | Undefined:C82(Form:C1466.selectedLot)
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if

	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)

	Case of
		: ($choice="--add")
			This:C1470._enterReceiptLots()
		: ($choice="--delete")
			//---a pending lot is only a row on the line; a saved one is a stock record
			If (Bool:C1537(Form:C1466.selectedLot.pending))
				This:C1470._removePendingLot()
			Else
				This:C1470.deleteLot()
			End if
	End case

Function _applyReceiptToLine()
	// Keeps the buy line in step with the stock received against it. Called after one of
	// its inventory records is deleted.
	//
	// dateIn is stamped ONLY once the ordered quantity is fully covered. Legacy stamped
	// it on any receipt, but only because it immediately split the remainder onto a
	// backorder line. That split now exists as the "Back-order remaining quantity" item
	// action (_ga_backorderBuyLine), and it is the receiver's decision rather than an
	// automatic one - so until they take it, a partially received line has to stay in
	// the receivable list or the remainder would simply be lost. Once they do take it,
	// the parent's qtyOrdered shrinks to what arrived and this stamps it closed.

	$line:=Form:C1466.current_item
	If ($line=Null:C1517)
		return
	End if

	//---initialQty, not qtyInStock: what arrived, which does not change as the stock
	//   is later consumed
	$received:=ds:C1482.Inventory.query("UUID_BuyingOrderLine = :1"; $line.UUID).sum("initialQty")

	$line.qtyReceived:=$received
	$line.dateIn:=(($received>0) && ($received>=$line.qtyOrderedEffective)) ? Current date:C33(*) : !00-00-00!
	$line.actualDeliveryDate:=$line.dateIn

	//---UUID_Inventory follows the first lot still standing, as it was set on save
	$firstLot:=ds:C1482.Inventory.query("UUID_BuyingOrderLine = :1"; $line.UUID).orderBy("inventoryID").first()
	$line.UUID_Inventory:=($firstLot#Null:C1517) ? $firstLot.UUID : ""

	// saved here rather than left to the panel's own save: the [Inventory] record is
	// already committed at this point, so the line must not be able to stay behind it.
	// $line is the same entity instance the panel holds, so its stamp stays in step.
	$res:=$line.save()

Function deleteLot()
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	If (Form:C1466.selectedLot=Null:C1517) | Undefined:C82(Form:C1466.selectedLot)
		return
	End if

	If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this lot and its inventory record?"; "Delete"; "CANCEL")))
		return
	End if

	START TRANSACTION:C239
	$inv:=ds:C1482.Inventory.query("UUID = :1"; Form:C1466.selectedLot.UUID).first()
	If ($inv=Null:C1517)
		CANCEL TRANSACTION:C241
		return
	End if

	//---refuse once the stock has been drawn on: anything beyond the Initial Stock pull
	//   written by InventoryEntity.afterCreation means this lot is already in use.
	$pulls:=ds:C1482.InventoryPull.query("UUID_Inventory = :1"; $inv.UUID)
	If ($pulls.query("type # :1"; "Initial Stock").length>0) | (Num:C11($inv.availableQty)#Num:C11($inv.initialQty))
		cs:C1710.sfw_dialog.me.alert("This lot has already been pulled from and cannot be deleted.")
		CANCEL TRANSACTION:C241
		return
	End if

	//---drop the Initial Stock pull with it, otherwise it is orphaned
	$dropped:=$pulls.drop()
	If ($dropped.length>0)
		CANCEL TRANSACTION:C241
		return
	End if

	$droppedUUID:=String:C10($inv.UUID)
	$res:=$inv.drop()
	If ($res.success)
		//---the line no longer has a stock record, so it can be received again
		If (String:C10(Form:C1466.current_item.UUID_Inventory)=$droppedUUID)
			Form:C1466.current_item.UUID_Inventory:=""
		End if
		VALIDATE TRANSACTION:C240
		This:C1470._applyReceiptToLine()
		This:C1470.loadLots()
		This:C1470._activate_save_cancel_button()
	Else
		CANCEL TRANSACTION:C241
	End if

Function setReceiverStaff($eStaff : cs:C1710.StaffEntity)
	// The receiver of a buy LINE - legacy [BUY_ITEMS]Recd_by, now the UUID_Staff FK
	// behind the "receiver" relation. This is the one staff link that genuinely
	// belongs to the line; the order's buyer, requestor and approvers are edited in
	// the Buying vision.
	If ($eStaff#Null:C1517)
		Form:C1466.current_item.UUID_Staff:=$eStaff.UUID
	End if 
	This:C1470._activate_save_cancel_button()

Function receiverProfile()->$ident : Text
	// Who may receive: the Receiving profile. _import_userProfiles defines it as
	//     {"ident": "rc"; "name": "Receiving"; "legacy": "ship&recv"}
	// One place to change it, as panel_buyingOrder.buyerProfile is for buyers.
	$ident:="rc"

Function selectReceiverStaff()
	// Received By: scan the receiver's badge or type their user code, then accept them
	// only if they are in the Receiving profile. Field_receivedBy and btnScanReceiver
	// both call this, so clicking either one does the same thing.
	var $result : Object
	var $eStaff : cs:C1710.StaffEntity

	//---both objects send more than On Clicked (mouse move on the field, mouse
	//   enter/leave on the button); only a click may open the scan window
	Case of 
		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			If (Form:C1466.sfw.checkIsInModification())
				SET CURSOR:C469(9000)
			End if 
			return 
		: (FORM Event:C1606.code#On Clicked:K2:4)
			return 
	End case 

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 

	$result:=cs:C1710.Util_ScannerManager.me.resolveStaffFromScanOrRequest()

	If ($result.cancelled)
		return 
	End if 

	If (Not:C34($result.success))
		Case of 
			: ($result.failureReason="codeNotFound")
				cs:C1710.sfw_dialog.me.alert("The user code entered does not correspond to any existing user.")
			: ($result.failureReason="barcodeNotFound")
				cs:C1710.sfw_dialog.me.alert("The scanned barcode does not correspond to any existing user.")
			: ($result.failureReason="noUserAccount")
				cs:C1710.sfw_dialog.me.alert("This employee does not have an application user account.")
			Else 
				cs:C1710.sfw_dialog.me.alert("Unable to identify the user.")
		End case 
		return 
	End if 

	$eStaff:=$result.staff

	//---Membership goes through Util_Authorizer.isInAnyProfile, the same test the buyer
	//   and approver pickers use: it folds case, which matters because this application
	//   spells profile idents inconsistently.
	If (Not:C34(cs:C1710.Util_Authorizer.me.isInAnyProfile($eStaff.user; New collection:C1472(This:C1470.receiverProfile()))))
		cs:C1710.sfw_dialog.me.alert(String:C10($eStaff.fullName)+" ("+String:C10($eStaff.code)+") is not in the Receiving profile and cannot be recorded as the receiver.")
		return 
	End if 

	This:C1470.setReceiverStaff($eStaff)
