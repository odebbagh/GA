Class extends Entity


// DISABLED [2026-sep-20] - orderDate, requiredDate and paidDate each exist TWICE:
// as a real date field on [BuyingOrderLine] (types 8, ids 23/24/28) and as the computed
// accessor below over the matching *Stmp column. Two definitions of one attribute name,
// so which one answers is not something the code makes obvious.
// Commented out so the stored date fields are unambiguously the live ones. That is also
// what _import_buyOrders writes to ($boLine.orderDate:=Date(...)); only the older
// __import_data_buyingOrders writes the *Stmp columns.
// The *Stmp columns are left in place and are now simply unread on this table.
// expectedDeliveryDate / actualDeliveryDate below are NOT touched: they have no field
// behind them, so they are genuine computed attributes.
//
//local Function get orderDate()->$date : Date
//$date:=This.orderStmp=0 ? !00-00-00! : cs.sfw_stmp.me.getDate(This.orderStmp; True)
//
//local Function set orderDate($date : Date)
//This.orderStmp:=$date=!00-00-00! ? 0 : cs.sfw_stmp.me.build($date)
//
//local Function get requiredDate()->$date : Date
//$date:=This.requiredStmp=0 ? !00-00-00! : cs.sfw_stmp.me.getDate(This.requiredStmp; True)
//
//local Function set requiredDate($date : Date)
//This.requiredStmp:=$date=!00-00-00! ? 0 : cs.sfw_stmp.me.build($date)
//
//local Function get paidDate()->$date : Date
//$date:=This.paidStmp=0 ? !00-00-00! : cs.sfw_stmp.me.getDate(This.paidStmp; True)
//
//local Function set paidDate($date : Date)
//This.paidStmp:=$date=!00-00-00! ? 0 : cs.sfw_stmp.me.build($date)

local Function get expectedDeliveryDate()->$date : Date
	$date:=This:C1470.expectedDeliveryStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.expectedDeliveryStmp; True:C214)
	
local Function set expectedDeliveryDate($date : Date)
	This:C1470.expectedDeliveryStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get actualDeliveryDate()->$date : Date
	$date:=This:C1470.actualDeliveryStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.actualDeliveryStmp; True:C214)
	
local Function set actualDeliveryDate($date : Date)
	This:C1470.actualDeliveryStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
Function get qtyDeliveredMajDelay()->$quantity : Real
	$param:=cs:C1710.goldenAltos_definition_globalParameters.new()
	If (This:C1470.actualDeliveryDate#Null:C1517) && (This:C1470.expectedDeliveryDate#!00-00-00!)
		$quantity:=(This:C1470.actualDeliveryDate>(This:C1470.expectedDeliveryDate+$param.constants.deleveryMinimunDelay)) ? This:C1470.qtyReceived : 0
	End if 
	
Function get qtyDeliveredMinDelay()->$quantity : Real
	If (This:C1470.actualDeliveryDate#Null:C1517) && (This:C1470.expectedDeliveryDate#!00-00-00!)
		$quantity:=(This:C1470.actualDeliveryDate<(This:C1470.expectedDeliveryDate+10)) && (This:C1470.actualDeliveryDate>This:C1470.expectedDeliveryDate) ? This:C1470.qtyReceived : 0
	End if

	// QTY Received shown on the panel. For inventory items it is the sum of the linked
	// lots' OPENING quantity (initialQty), not qtyInStock: qtyInStock is what is still on
	// the shelf, so once stock is consumed it falls to zero and a fully received line
	// would report 0 received. Only 90 of the 762 imported legacy receipts still hold
	// stock, so summing qtyInStock showed almost every historical line as unreceived.
	// The dataclass is queried directly so freshly added lots are reflected right away.
Function get qtyReceivedDisplay()->$result : Real
	// Once an inventory line has its stock, the quantity lives on those records: initialQty
	// summed over every vendor lot. Until then it is qtyReceived - typed on a non-inventory
	// line, and kept equal to the total of the pending vendor lots on an inventory line.
	If (Bool:C1537(This:C1470.inventory)) && (This:C1470.hasReceiptInventory)
		$result:=ds:C1482.Inventory.query("UUID_BuyingOrderLine = :1"; This:C1470.UUID).sum("initialQty")
	Else
		$result:=This:C1470.qtyReceived
	End if

Function set qtyReceivedDisplay($value : Real)
	// Typed on non-inventory lines only. On an inventory line the quantity is the total of
	// its vendor lots - legacy locked Qtyin on NewRecvOrderedPart and summed the lots.
	If (Not:C34(Bool:C1537(This:C1470.inventory)))
		This:C1470.qtyReceived:=$value
	End if

	// ---- Receipt stock records: one per vendor lot -----------------------------
	// Legacy NewRecvOrderedPart: the receiver scanned or typed each vendor lot of the
	// delivery with its quantity (the Lot#/Qty button), Qtyin was their total, and Save
	// made one [Inventory] record per lot (Update_inventoryNew + CreateSplitStocks). One
	// part number can arrive in several manufacturer batches, and stock is traced, pulled
	// and IQA'd by batch, so each lot is its own record.
	//
	// Same here:
	//   - until the save, the lots wait on the line in moreData.receiving.lots as
	//     {lotNumber; qty} - there is no Inventory record to hold them yet
	//   - afterSave turns each into an [Inventory] record linked by UUID_BuyingOrderLine,
	//     which is what the Inventories tab lists
	//   - BuyingOrderLine.UUID_Inventory points at the FIRST lot's record, as the import
	//     sets it on legacy receipts (the root lot)

Function get hasReceiptInventory()->$result : Boolean
	// Checks both links. Legacy receipts were linked by the import through
	// Inventory.UUID_BuyingOrderLine, and a lot deleted from the Inventories tab can leave
	// UUID_Inventory behind, so the back-link is what decides.
	$result:=Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(This:C1470.UUID_Inventory)))
	If (Not:C34($result))
		$result:=(ds:C1482.Inventory.query("UUID_BuyingOrderLine = :1"; This:C1470.UUID).length>0)
	End if

Function get receiptLots()->$lots : Collection
	// The vendor lots entered on this line and not saved yet, as {lotNumber; qty}.
	$lots:=New collection:C1472
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.receiving#Null:C1517)
		If (Value type:C1509(This:C1470.moreData.receiving.lots)=Is collection:K8:32)
			$lots:=This:C1470.moreData.receiving.lots
		End if
	End if

Function get receiptLotsTotal()->$total : Real
	$total:=This:C1470.receiptLots.sum("qty")

Function addReceiptLot($lotNumber : Text; $qty : Real)
	This:C1470._setReceiptLots(This:C1470.receiptLots.copy().push(New object:C1471("lotNumber"; $lotNumber; "qty"; $qty)))

Function removeReceiptLot($index : Integer)
	var $lots : Collection

	$lots:=This:C1470.receiptLots.copy()
	If ($index>=0) && ($index<$lots.length)
		$lots.remove($index)
		This:C1470._setReceiptLots($lots)
	End if

local Function _setReceiptLots($lots : Collection)
	// Stores the pending lots and keeps qtyReceived equal to their total. qtyReceived
	// changing is also what makes the save ask the back-order question (beforeSave).
	var $moreData : Object

	$moreData:=(This:C1470.moreData=Null:C1517) ? New object:C1471 : This:C1470.moreData
	If ($lots.length=0)
		OB REMOVE:C1226($moreData; "receiving")
	Else
		$moreData.receiving:=New object:C1471("lots"; $lots)
	End if
	//---reassigned so the line is marked as modified
	This:C1470.moreData:=$moreData
	This:C1470.qtyReceived:=$lots.sum("qty")

local Function afterSave()
	// Called by the framework once the panel has saved this line, still inside the
	// entry's transaction: the stock records and the line are validated together.
	// Receiving and Buy Items both edit [BuyingOrderLine], so this runs from either;
	// nothing happens unless an inventory line has pending vendor lots and no stock yet.
	var $result : Object

	If (Not:C34(Bool:C1537(This:C1470.inventory))) || (This:C1470.receiptLots.length=0) || (This:C1470.hasReceiptInventory)
		return
	End if

	$result:=This:C1470.createReceiptInventories()
	If (Not:C34($result.success))
		cs:C1710.sfw_dialog.me.alert("The receipt was saved, but no inventory record was created:\r"+$result.message)
	End if

Function createReceiptInventories()->$result : Object
	// One [Inventory] record per pending vendor lot, each built the way every other receipt
	// in this application is: initialQty / availableQty / qtyInStock set to what arrived,
	// then InventoryEntity.afterCreation, which writes the "Initial Stock" pull.
	//
	// Everything the receiver does not retype is read through a link rather than a copy on
	// the line (part <- aml, vendor <- buyingOrder.supplier, units <- unit, ...). The text
	// columns on [Inventory] are still filled, because a stock record has to keep reading
	// correctly once the buy line is edited or archived.
	//
	// All or nothing: one lot that fails to save cancels the others.
	var $inv; $first : cs:C1710.InventoryEntity
	var $lot; $save; $moreData : Object
	var $lots : Collection
	var $partNumber; $vendor; $units; $division; $currency : Text
	var $dateIn : Date
	var $qty : Real

	$result:=New object:C1471("success"; False:C215; "message"; ""; "created"; New collection:C1472)
	$lots:=This:C1470.receiptLots.copy()

	Case of
		: (Not:C34(Bool:C1537(This:C1470.inventory)))
			$result.message:="This is not an inventory line."
			return
		: (This:C1470.hasReceiptInventory)
			$result.message:="This line already has its inventory records."
			return
		: ($lots.length=0)
			$result.message:="Add the vendor lots received (Lot# / Qty) and save again."
			return
		: (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(This:C1470.UUID_Staff)))
			//---legacy refused the receipt without Recd_by ("Please enter your Employee Code")
			$result.message:="Set who received it (Received By) and save again. The vendor lots are kept."
			return
	End case

	//---what every lot of this receipt shares, resolved once
	$partNumber:=String:C10(This:C1470.description)
	If (This:C1470.aml#Null:C1517) && (String:C10(This:C1470.aml.ourPartNum)#"")
		$partNumber:=String:C10(This:C1470.aml.ourPartNum)
	End if
	$vendor:=""
	If (This:C1470.buyingOrder#Null:C1517) && (This:C1470.buyingOrder.supplier#Null:C1517)
		$vendor:=String:C10(This:C1470.buyingOrder.supplier.name)
	End if
	$units:=String:C10(This:C1470.units)
	If (This:C1470.unit#Null:C1517) && (String:C10(This:C1470.unit.name)#"")
		$units:=String:C10(This:C1470.unit.name)
	End if
	$division:=""
	If (This:C1470.division#Null:C1517)
		$division:=String:C10(This:C1470.division.name)
	End if
	If ($division="") && (This:C1470.buyingOrder#Null:C1517)
		$division:=String:C10(This:C1470.buyingOrder.division)
	End if
	$currency:=(This:C1470.buyingOrder#Null:C1517) ? String:C10(This:C1470.buyingOrder.currency) : ""
	$dateIn:=(This:C1470.dateIn=!00-00-00!) ? Current date:C33(*) : This:C1470.dateIn


	START TRANSACTION:C239

	For each ($lot; $lots)
		$qty:=Num:C11($lot.qty)

		$inv:=ds:C1482.Inventory.new()
		$inv.partNumber:=$partNumber
		$inv.description:=String:C10(This:C1470.description)
		$inv.vendor:=$vendor
		$inv.units:=$units
		$inv.division:=$division
		$inv.currency:=$currency
		$inv.partLotNumber:=String:C10($lot.lotNumber)
		$inv.dateIn:=$dateIn
		$inv.active:=True:C214

		//---valuation is a SNAPSHOT, not a link: reading unitCost back through the line
		//   would revalue stock already on the shelf every time a buyer edits the order
		$inv.unitCost:=Num:C11(This:C1470.unitPrice)
		$inv.qtyInStock:=$qty
		$inv.initialQty:=$qty
		$inv.availableQty:=$qty
		$inv.totalCost:=$qty*Num:C11($inv.unitCost)
		$inv.actualValue:=$inv.totalCost

		$inv.inventoryID:=Sequence number:C244([Inventory:126])  // the table's counter, one per inventory
		$inv.code:="INV"+String:C10($inv.inventoryID; "00000#")
		//---legacy Stock_Num was PO_NUM+"_"+Seq_Number; kept only as the label people search on
		$inv.stockGroup:="BO"+String:C10(This:C1470.orderNumber)+"-"+String:C10(This:C1470.number)
		$inv.stockNum:=$inv.stockGroup+"-"+String:C10($inv.inventoryID)

		$inv.UUID_BuyingOrderLine:=This:C1470.UUID
		$inv.UUID_Staff:=This:C1470.UUID_Staff
		$inv.UUID_Job:=String:C10(This:C1470.UUID_Job)

		$save:=$inv.save()
		If (Not:C34($save.success))
			CANCEL TRANSACTION:C241
			$result.message:="The inventory record for vendor lot "+String:C10($lot.lotNumber)+" could not be saved ("+String:C10($save.statusText)+"). No inventory was created; the vendor lots are kept."
			$result.created:=New collection:C1472
			return
		End if

		//---the Initial Stock pull, as for every other receipt
		$inv.afterCreation()

		$result.created.push($inv)
		If ($first=Null:C1517)
			$first:=$inv
		End if
	End for each

	This:C1470.UUID_Inventory:=$first.UUID
	//---the lots now live on their stock records
	$moreData:=This:C1470.moreData
	OB REMOVE:C1226($moreData; "receiving")
	This:C1470.moreData:=$moreData

	$save:=This:C1470.save()
	If (Not:C34($save.success))
		CANCEL TRANSACTION:C241
		$result.message:="The inventory records could not be linked to the line ("+String:C10($save.statusText)+"). No inventory was created."
		$result.created:=New collection:C1472
		return
	End if

	VALIDATE TRANSACTION:C240
	$result.success:=True:C214


	// ---- Price / tax recalculation ------------------------------------------
	// One implementation of the two-direction rule described in section 1e of
	// Documentation/buyItems_field_migration.md. Legacy scattered this across
	// BI_EntryF object methods; here it lives on the entity so the panel, the
	// import and anything added later all produce the same numbers.
	//
	// Verified against the 11,860 imported legacy lines:
	//   - [BuyingOrder]salesTaxRate is a FRACTION (0.0925 = 9.25%). Note this is
	//     NOT the same scale as [SalesTax]rate, which is a percentage and is
	//     divided by 100 at every use site (see panel_jobInvoice).
	//   - lineTotal is TAX-INCLUSIVE: 822 of 823 taxable lines match
	//     qty * unitPrice * (1 + salesTaxRate). The legacy formula quoted in the
	//     migration document omits the tax term; the data does not agree with it.
	//   - tax = qty * unitPrice * salesTaxRate (822 of 823).
	//   - non-taxable lines carry unitPriceWithTax = unitPrice, not 0 (9,175 of 9,261).

local Function get salesTaxRate()->$rate : Real
	If (This:C1470.buyingOrder#Null:C1517)
		$rate:=Num:C11(This:C1470.buyingOrder.salesTaxRate)
	End if 

	// Legacy [BUY_ORDERS]VATMode has no column on [BuyingOrder] in GA and is not
	// carried by the legacy export, so it is read out of the order's moreData and
	// defaults to False - i.e. every order behaves in Normal mode today. When a real
	// BuyingOrder.VATMode column is added, this accessor is the only thing to change.
local Function get vatMode()->$vatMode : Boolean
	var $moreData : Object
	If (This:C1470.buyingOrder#Null:C1517)
		$moreData:=This:C1470.buyingOrder.moreData
		$vatMode:=($moreData#Null:C1517) ? Bool:C1537($moreData.vatMode) : False:C215
	End if 

	// Normal mode: unitPrice is entered, unitPriceWithTax derived.
	// VAT mode: unitPriceWithTax is entered, unitPrice back-computed, and taxable is
	// forced true (legacy also locks the checkbox - the form does that part).
	// The document writes the VAT inversion as
	//   (unitPriceWithTax / (100 + salesTaxRate * 100)) * 100
	// which, with salesTaxRate held as a fraction, is unitPriceWithTax / (1 + rate).
Function recalcPrices()
	var $rate : Real
	$rate:=This:C1470.salesTaxRate
	If (This:C1470.vatMode)
		This:C1470.taxable:=True:C214
		This:C1470.unitPrice:=((1+$rate)=0) ? 0 : Num:C11(This:C1470.unitPriceWithTax)/(1+$rate)
	Else
		This:C1470.unitPriceWithTax:=Bool:C1537(This:C1470.taxable) ? Num:C11(This:C1470.unitPrice)*(1+$rate) : Num:C11(This:C1470.unitPrice)
	End if 
	This:C1470.recalcLineTotal()

	// tax and lineTotal always follow from the net unitPrice, in both modes.
	// Return-to-vendor and credit are deliberately absent: the vendor-returns
	// workflow does not exist in GA yet (section 3), and Credit was dropped
	// (section 4) after confirming it evaluates to 0 on every legacy record.
Function recalcLineTotal()
	var $base : Real
	// qtyOrdered is the quantity the panel edits, and is what panel_poLines.applyLineTotal
	// uses for the same calculation on a purchase-order line. qty carries the same legacy
	// QTY and is what SupplierEntity reads for receiving, so the two are kept equal here
	// rather than allowed to drift once a buyer edits the order quantity.
	This:C1470.qty:=Num:C11(This:C1470.qtyOrdered)
	$base:=Num:C11(This:C1470.qtyOrdered)*Num:C11(This:C1470.unitPrice)
	This:C1470.tax:=Bool:C1537(This:C1470.taxable) ? $base*This:C1470.salesTaxRate : 0
	This:C1470.lineTotal:=$base+This:C1470.tax

	// Row meta for the Receiving - Buy Orders list: buy items that already have
	// a date in (received) are shown on a gray background.
local Function metaColor()->$meta : Object
	$meta:=New object:C1471()
	If (This:C1470.dateIn#!00-00-00!)
		$meta.fill:="#D3D3D3"
	End if

	// TEMP: canBeReceived FILTER disabled - see goldenAltos_definition (BuyOrders
	// entry). To re-enable, back it with a stored boolean field on the buy line
	// (the framework's boolean filter cannot resolve a computed date query).
	// The getter itself is live further down; only the query/filter pair stays off.
	//Function get canBeReceived()->$result : Boolean
	//$result:=This.dateIn=!00-00-00!
	//
	//Function query canBeReceived($event : Object)->$result : cs.BuyingOrderLineSelection
	//Case of
	//: ($event.value=True) | (String($event.value)="true")
	//$result:=ds.BuyingOrderLine.query("dateIn = :1"; !00-00-00!)
	//Else
	//$result:=ds.BuyingOrderLine.query("dateIn # :1"; !00-00-00!)
	//End case
	
	
	
	
local Function loadAfterCreation()
	var $pendingOrder : Object
	var $maxNumber : Variant
	// Called by the framework after creating a new item but before displaying the
	// panel, so it fires ONLY for records created from a panel. An import that calls
	// ds.BuyingOrderLine.new() directly does not go through it.

	// NOTE: "number" is deliberately NOT set here. It is the item number WITHIN a buy
	// order, so it cannot be known until a buy order is picked - see
	// panel_boItem.selectBuyingOrder, which assigns it at that moment.

	// Buy Items (buying vision) only: start a new line on today's date. Scoped by entry
	// ident the same way LotEntity does, so the receiving "BuyOrders" entry on this same
	// table keeps the behaviour it had.
	//---Pre-fill from the buy order this line is being created for, when the Line Items
	//   tab asked for it (panel_buyingOrder --add). The entry is opened through the
	//   framework's createANewEntity, which takes no seed values and opens its own
	//   window, so the order arrives on the singleton instead of through Form.
	//
	//   The item number is assigned here for the same reason panel_boItem.selectBuyingOrder
	//   assigns it there: it is a sequence WITHIN a buy order, so it cannot be known
	//   until the order is.
	$pendingOrder:=cs:C1710.panel_buyingOrder.me.pendingBuyingOrder()

	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($pendingOrder.uuid)))
		//---the values are taken from what the panel handed over, NOT from a query: the
		//   order is inside that process's transaction and is invisible here.
		This:C1470.UUID_BuyingOrder:=$pendingOrder.uuid
		This:C1470.boNumber:=Num:C11($pendingOrder.boNumber)
		This:C1470.UUID_Supplier:=$pendingOrder.supplier

		If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($pendingOrder.glAccount)))
			This:C1470.UUID_GLAccount:=$pendingOrder.glAccount
			This:C1470.applyGLAccountRules()
		End if

		//---next item number within that order. Only committed lines are visible, which
		//   is right: a brand-new order has none, so the first line is 1.
		$maxNumber:=ds:C1482.BuyingOrderLine.query("UUID_BuyingOrder = :1"; $pendingOrder.uuid).max("number")
		This:C1470.number:=Num:C11($maxNumber)+1

		//---consumed: a line created later from the Buy Items list must not inherit it
		cs:C1710.panel_buyingOrder.me.setPendingBuyingOrder(Null:C1517)
	End if
	//---Inherit the order's GL account, as legacy SetInheritedBuyItemFields did:
	//       : (Glac="") & (BUY_ORDERS.GLAC#"")  ->  Glac := BUY_ORDERS.GLAC
	//   Only when the line has none of its own, and only the link - the account's flags
	//   are then applied by applyGLAccountRules, exactly as the legacy branch called
	//   SetBuyingFieldsBasedonGLacc straight afterwards.
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(This:C1470.UUID_GLAccount)))
		If (This:C1470.buyingOrder#Null:C1517)
			If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(This:C1470.buyingOrder.UUID_GLAccount))))
				This:C1470.UUID_GLAccount:=String:C10(This:C1470.buyingOrder.UUID_GLAccount)
				This:C1470.applyGLAccountRules()
			End if
		End if
	End if

	If (Form:C1466.sfw.entry.ident="boItems")
		This:C1470.orderDate:=Current date:C33(*)
	End if

	// ---- Receiving ------------------------------------------------------------
	// The legacy gates lived in recv_mrp (buy-order number valid, Requistion=False),
	// in NewRecvOrderedPart's On Load (Item#0) and in its save (Recd_by filled).
	// They are collected here so the Inventories tab, the Main tab and anything
	// added later all refuse for the same reasons and with the same wording.
	//
	// Gone on purpose, because links replace them: PO_NUM / SEQ_NUM matching is now
	// the UUID_BuyingOrder relation, and Seq_Number is the line's own UUID, which is
	// what Inventory.UUID_BuyingOrderLine points at. Division is not checked - there
	// is one division today and the value is reachable through the link when needed.

	// qtyOrdered is what the panel edits; qty carries the same legacy QTY and is what
	// _import_buyOrders wrote. recalcLineTotal keeps them equal, but imported lines
	// predate that, so fall back rather than read a zero.
Function get qtyOrderedEffective()->$qty : Real
	$qty:=Num:C11(This:C1470.qtyOrdered)
	If ($qty=0)
		$qty:=Num:C11(This:C1470.qty)
	End if 

Function get qtyRemaining()->$qty : Real
	$qty:=This:C1470.qtyOrderedEffective-This:C1470.qtyReceivedDisplay

Function get receivingOrderBlockedReason()->$reason : Text
	// Everything that stops a line being received EXCEPT "already received": the order's
	// approval / hold / closed state and the line's own set-up. Checked before vendor lots
	// are entered, because the receiver may already have typed Date Received, which on its
	// own reads as fully received.
	Case of
		: (This:C1470.buyingOrder=Null:C1517)
			$reason:="This buy item is not attached to a buy order."
		: (This:C1470.buyingOrder.awaitingApproval)
			$reason:="Buy order "+String:C10(This:C1470.buyingOrder.boNumber)+" has not been approved. Both approver signatures are required before it can be received."
		: (Bool:C1537(This:C1470.buyingOrder.onHold))
			$reason:="Buy order "+String:C10(This:C1470.buyingOrder.boNumber)+" is on hold."
		: (Bool:C1537(This:C1470.buyingOrder.closed))
			$reason:="Buy order "+String:C10(This:C1470.buyingOrder.boNumber)+" is closed."
		: (Num:C11(This:C1470.number)=0)
			$reason:="This line has no item number yet. Add it from the buy order before receiving."
		: (This:C1470.qtyOrderedEffective<=0)
			$reason:="This line has no quantity ordered."
	End case

Function get receivingBlockedReason()->$reason : Text
	$reason:=This:C1470.receivingOrderBlockedReason
	If ($reason="") && (This:C1470.dateIn#!00-00-00!)
		$reason:="This line was fully received on "+String:C10(This:C1470.dateIn)+"."
	End if

Function get canBeReceived()->$result : Boolean
	$result:=(This:C1470.receivingBlockedReason="")

	// ---- GL account rules -----------------------------------------------------
	// Legacy SetBuyingFieldsBasedonGLacc decided the three line type flags from the
	// account the buyer picked, and locked the checkboxes the type forbids:
	//
	//   account type              asset  inventory   consumable
	//   ------------------------  -----  ----------  ----------
	//   Expense family (code 16)  False  locked off  unlocked
	//   Fixed Asset               True   locked off  locked off
	//   Other / Other Current     True   UNLOCKED    locked off
	//     Asset
	//   anything else             False  locked off  unlocked
	//
	// So an inventory line is one whose GL account is an asset account that is NOT a
	// Fixed Asset - "inventory" was never a free checkbox. _export_glAccounts resolved
	// that per account, so the flags are read off [GLAccount] rather than recomputed.
	//
	// Resolved by UUID_GLAccount when the line carries it, falling back to matching on
	// the legacy glac text. The fallback covers lines imported before the FK existed,
	// and new lines between picking an account and saving. Neither path names the
	// relation, so renaming it in the structure editor cannot break this.

Function get glAccountRecord()->$account : Object
	var $accountClass : 4D:C1709.DataClass
	$accountClass:=ds:C1482["GLAccount"]
	If ($accountClass=Null:C1517)
		return
	End if
	If (String:C10(This:C1470.UUID_GLAccount)#"")
		$account:=$accountClass.query("UUID = :1"; String:C10(This:C1470.UUID_GLAccount)).first()
		If ($account#Null:C1517)
			return
		End if
	End if

	If (String:C10(This:C1470.glAccount)="")
		return
	End if
	$account:=$accountClass.query("glac = :1"; String:C10(This:C1470.glAccount)).first()

	// Until _import_glAccounts has been run there is no [GLAccount] to consult. These
	// default OPEN rather than closed, so an unconfigured database behaves as it does
	// today instead of locking every checkbox and blocking data entry.
Function get orderNumber()->$number : Integer
	// The BO # through the link to the order. boNumber on the line is only a copy made
	// when the line was created, and a copy that came through as 0 printed "Order # 0"
	// on the receipt; the order's own number is the one to show.
	$number:=(This:C1470.buyingOrder#Null:C1517) ? Num:C11(This:C1470.buyingOrder.boNumber) : Num:C11(This:C1470.boNumber)

Function get glAccountDisplay()->$text : Text
	// The line's GL account as Buy Items shows it, read-only - "1036-0 - INVENTORIES", the
	// same form as the order's glAccountLabel. Through glAccountRecord, so a legacy line
	// that only carries the glac text still shows it.
	var $account : Object

	$account:=This:C1470.glAccountRecord
	If ($account#Null:C1517)
		$text:=String:C10($account.glac)
		If (String:C10($account.description)#"")
			$text:=$text+" - "+String:C10($account.description)
		End if
	Else
		$text:=String:C10(This:C1470.glAccount)
	End if

Function inheritGLAccountFromOrder($order : cs:C1710.BuyingOrderEntity)
	// A buy item's GL account is its order's - legacy SetInheritedBuyItemFields. It is
	// taken when the line is attached to an order and pushed again whenever the order's
	// account changes (panel_buyingOrder._cascadeGLAccountToLines); Buy Items only shows
	// it. The legacy glac text is kept in step for the reports that still read it, then
	// the Inventory / Consumable / Asset rules of the account are applied.
	//
	// Read with GLAccount.get rather than $order.account: a relation attribute is cached
	// on the entity, and the order's account has usually just been changed.
	var $accountClass : 4D:C1709.DataClass
	var $account : 4D:C1709.Entity

	If ($order=Null:C1517)
		return
	End if
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($order.UUID_GLAccount)))
		return
	End if
	$accountClass:=ds:C1482["GLAccount"]
	If ($accountClass=Null:C1517)
		return
	End if
	$account:=$accountClass.get(String:C10($order.UUID_GLAccount))
	If ($account=Null:C1517)
		return
	End if

	This:C1470.UUID_GLAccount:=$account.UUID
	This:C1470.glAccount:=String:C10($account.glac)
	This:C1470.applyGLAccountRules()

Function get allowsInventory()->$result : Boolean
	var $account : Object
	$account:=This:C1470.glAccountRecord
	$result:=($account=Null:C1517) ? True:C214 : Bool:C1537($account.allowsInventory)

Function get allowsConsumable()->$result : Boolean
	var $account : Object
	$account:=This:C1470.glAccountRecord
	$result:=($account=Null:C1517) ? True:C214 : Bool:C1537($account.allowsConsumable)

Function get defaultAsset()->$result : Boolean
	var $account : Object
	$account:=This:C1470.glAccountRecord
	$result:=($account#Null:C1517) && Bool:C1537($account.defaultAsset)

	// Call after the buyer changes the GL account. This is the assignment half of
	// SetBuyingFieldsBasedonGLacc; the locking half belongs to the form, which reads
	// allowsInventory / allowsConsumable above.
Function applyGLAccountRules()
	var $account : Object
	$account:=This:C1470.glAccountRecord
	If ($account=Null:C1517)
		return
	End if
	This:C1470.asset:=Bool:C1537($account.defaultAsset)
	If (Not:C34(Bool:C1537($account.allowsInventory)))
		This:C1470.inventory:=False:C215
	End if
	If (Not:C34(Bool:C1537($account.allowsConsumable)))
		This:C1470.consumable:=False:C215
	End if

	// ---- Backorder splits -----------------------------------------------------
	// Legacy recorded a partial receipt by duplicating the buy line and adding 0.1 to
	// [BUY_ITEMS]Item (create_backordered_buyitem), so "1, 1.1, 1.2" was one PO line
	// split twice - not three lines. The buy order is a document already sent to the
	// vendor, so its line numbers are fixed: the remainder is still line 1.
	//
	// Here that is a link rather than a number trick, matching how [Lot] already models
	// its own splits (UUID_LotParent / splitLevel): number keeps the PO line number and
	// splitLevel counts the generation. The legacy label is still derivable for display,
	// which is what displayNumber below is for.

Function get isBackorder()->$result : Boolean
	$result:=Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(This:C1470.UUID_LineParent)))

	// "1" for an original line, "1.1" / "1.2" for its successive remainders - the same
	// label the legacy application printed, rebuilt rather than stored.
Function get displayNumber()->$display : Text
	$display:=String:C10(Num:C11(This:C1470.number))
	If (Num:C11(This:C1470.splitLevel)>0)
		$display:=$display+"."+String:C10(Num:C11(This:C1470.splitLevel))
	End if

	// The original line this one descends from, however many splits deep. Returns the
	// line itself when it is not a backorder. Guarded against a cycle in the data: a
	// self-referencing or looping parent chain would otherwise hang the panel.
Function get rootLine()->$root : cs:C1710.BuyingOrderLineEntity
	var $guard : Integer
	$root:=This:C1470
	$guard:=0
	While (($root#Null:C1517) && $root.isBackorder && ($guard<20))
		$guard:=$guard+1
		If ($root.lineParent=Null:C1517)
			return
		End if
		$root:=$root.lineParent
	End while

	// Every generation of this PO line, oldest first, including this one. Queried on the
	// dataclass rather than walked through subLines so a freshly created child shows up
	// without reloading the entity.
Function get splitChain()->$chain : cs:C1710.BuyingOrderLineSelection
	var $root : cs:C1710.BuyingOrderLineEntity
	$root:=This:C1470.rootLine
	If ($root=Null:C1517)
		$chain:=ds:C1482.BuyingOrderLine.newSelection()
		return
	End if
	$chain:=ds:C1482.BuyingOrderLine.query("UUID_BuyingOrder = :1 and number = :2"; String:C10($root.UUID_BuyingOrder); Num:C11($root.number)).orderBy("splitLevel asc")

	// True once the remainder has been moved onto a child line, which is what closes
	// this one even though less than the ordered quantity arrived against it.
Function get hasBackorder()->$result : Boolean
	$result:=(ds:C1482.BuyingOrderLine.query("UUID_LineParent = :1"; String:C10(This:C1470.UUID)).length>0)

	// Offered as an item action on the receiving entry. Something must have arrived,
	// something must still be outstanding, and the remainder must not already have been
	// moved onto a child line.
Function get canBackorder()->$result : Boolean
	$result:=(This:C1470.qtyReceivedDisplay>0) && (This:C1470.qtyRemaining>0) && Not:C34(This:C1470.hasBackorder)
	If ($result) && (This:C1470.buyingOrder#Null:C1517)
		$result:=Not:C34(Bool:C1537(This:C1470.buyingOrder.closed))
	End if 

Function get backorderBlockedReason()->$reason : Text
	// Why canBackorder is False, in the receiver's words. Empty when it is True.
	Case of
		: (This:C1470.hasBackorder)
			$reason:="The remaining quantity of this line has already been moved onto a back-order line."
		: (This:C1470.qtyReceivedDisplay<=0)
			$reason:="Nothing has been received against this line yet, so there is no partial receipt to split."
		: (This:C1470.qtyRemaining<=0)
			$reason:="This line is fully received - there is no outstanding quantity to back-order."
		: (This:C1470.buyingOrder#Null:C1517) && (Bool:C1537(This:C1470.buyingOrder.closed))
			$reason:="Buy order "+String:C10(This:C1470.buyingOrder.boNumber)+" is closed."
	End case

Function backorderRemaining()->$result : Object
	// The split itself - legacy create_backordered_buyitem. One implementation for both
	// ways in: the "Back-order remaining quantity" button / item action
	// (_ga_backorderBuyLine) and the question the receipt save asks (beforeSave below).
	//
	// Legacy duplicated the record and added 0.1 to [BUY_ITEMS]Item, so 1 -> 1.1 -> 1.2
	// was one PO line split twice. Here the number does not move - the buy order is a
	// document already sent to the vendor - so the child keeps number, carries
	// splitLevel+1 and links back through UUID_LineParent, the shape [Lot] uses for its
	// own splits. displayNumber still shows "1.1".
	//
	// What legacy did that this deliberately does not:
	//   - it wrote " PARTIAL RECEIPT" / "On back order" into [BUY_ITEMS]Comments. The
	//     parent link records the fact, so nothing is written into a text to be parsed.
	//   - it cleared Seq_Number and UniqueID so fresh ones would be assigned. Those are
	//     the legacy keys; the child simply gets a new UUID.
	var $child : cs:C1710.BuyingOrderLineEntity
	var $received; $remaining : Real
	var $save : Object

	$result:=New object:C1471("success"; False:C215; "message"; "")

	If (Not:C34(This:C1470.canBackorder))
		$result.message:=This:C1470.backorderBlockedReason
		return
	End if

	$received:=This:C1470.qtyReceivedDisplay
	$remaining:=This:C1470.qtyRemaining

	START TRANSACTION:C239

	//---the original line shrinks to what actually arrived and closes.
	//   Legacy did exactly this: QTY := Qtyin, then upd_bototals.
	This:C1470.qtyOrdered:=$received
	This:C1470.recalcLineTotal()  // also keeps qty in step with qtyOrdered
	This:C1470.qtyReceived:=$received
	This:C1470.dateIn:=Current date:C33(*)
	This:C1470.actualDeliveryDate:=This:C1470.dateIn

	$save:=This:C1470.save()
	If (Not:C34($save.success))
		CANCEL TRANSACTION:C241
		$result.message:="Could not update the original line ("+String:C10($save.statusText)+"). Nothing was changed."
		return
	End if

	//---the child carries everything that describes WHAT was ordered
	$child:=ds:C1482.BuyingOrderLine.new()
	$child.UUID:=Generate UUID:C1066
	$child.UUID_LineParent:=This:C1470.UUID
	$child.splitLevel:=Num:C11(This:C1470.splitLevel)+1
	$child.number:=Num:C11(This:C1470.number)
	$child.order:=Num:C11(This:C1470.order)

	$child.UUID_BuyingOrder:=This:C1470.UUID_BuyingOrder
	$child.boNumber:=This:C1470.orderNumber
	$child.description:=String:C10(This:C1470.description)

	$child.unitPrice:=Num:C11(This:C1470.unitPrice)
	$child.unitPriceWithTax:=Num:C11(This:C1470.unitPriceWithTax)
	$child.taxable:=Bool:C1537(This:C1470.taxable)
	$child.freight:=Num:C11(This:C1470.freight)

	$child.units:=String:C10(This:C1470.units)
	$child.UUID_Unit:=String:C10(This:C1470.UUID_Unit)

	$child.glAccount:=String:C10(This:C1470.glAccount)
	$child.UUID_GLAccount:=String:C10(This:C1470.UUID_GLAccount)
	$child.inventory:=Bool:C1537(This:C1470.inventory)
	$child.consumable:=Bool:C1537(This:C1470.consumable)
	$child.asset:=Bool:C1537(This:C1470.asset)

	$child.UUID_AML:=String:C10(This:C1470.UUID_AML)
	$child.UUID_Division:=String:C10(This:C1470.UUID_Division)
	$child.UUID_Supplier:=String:C10(This:C1470.UUID_Supplier)
	$child.UUID_Job:=String:C10(This:C1470.UUID_Job)
	$child.jobNumber:=Num:C11(This:C1470.jobNumber)
	$child.assetListNumber:=Num:C11(This:C1470.assetListNumber)
	$child.supPsNumber:=Num:C11(This:C1470.supPsNumber)
	$child.verificationRequired:=Bool:C1537(This:C1470.verificationRequired)

	$child.orderDate:=This:C1470.orderDate
	$child.requiredDate:=This:C1470.requiredDate
	$child.confirmationDate:=This:C1470.confirmationDate

	//---and nothing about the receipt or the payment of the parent. The balance is
	//   outstanding again: unreceived, unbilled, no receiver, no stock record - it gets
	//   its own when it is received (one inventory record per line).
	$child.qtyOrdered:=$remaining
	$child.recalcLineTotal()
	$child.qtyReceived:=0
	$child.dateIn:=!00-00-00!
	$child.UUID_Staff:=""
	$child.checkNumber:=0
	$child.amountPaid:=0
	$child.paidDate:=!00-00-00!

	$child.moreData:=New object:C1471(\
		"createdBy"; "backorderRemaining"; \
		"createdAt"; cs:C1710.sfw_stmp.me.now(); \
		"backorderOf"; This:C1470.UUID; \
		"qtyAtSplit"; New object:C1471("ordered"; $received+$remaining; "received"; $received; "carried"; $remaining)\
		)

	$save:=$child.save()
	If (Not:C34($save.success))
		CANCEL TRANSACTION:C241
		$result.message:="Could not create the back-order line ("+String:C10($save.statusText)+"). Nothing was changed."
		return
	End if

	VALIDATE TRANSACTION:C240

	$result.success:=True:C214
	$result.child:=$child
	$result.received:=$received
	$result.remaining:=$remaining

	//---shown straight away: appended to the list on screen, so the receiver sees the
	//   new line without searching again. It takes its sorted place on the next search.
	This:C1470._showInList($child)

local Function beforeSave()
	// Legacy asked this from the Save button of NewRecvOrderedPart whenever less than
	// the ordered quantity had arrived:
	//     CONFIRM("Do you want to back-order remaining quantity N ?"; "Back-Order"; "Save as is")
	// Asked here only when THIS save changes the received quantity, so re-saving a line
	// someone already chose to keep partial does not ask again. Receiving and Buy Items
	// both edit [BuyingOrderLine], so it is asked from either.
	var $result : Object

	If (This:C1470.touchedAttributes().indexOf("qtyReceived")=-1)
		return
	End if
	If (Not:C34(This:C1470.canBackorder))
		return
	End if

	If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Do you want to back-order the remaining quantity "+String:C10(This:C1470.qtyRemaining)+" of item "+This:C1470.displayNumber+"?"; "Back-Order"; "Save as is")))
		return
	End if

	$result:=This:C1470.backorderRemaining()
	If ($result.success)
		cs:C1710.sfw_dialog.me.info("Item "+This:C1470.displayNumber+" closed at "+String:C10($result.received)+" received."+"\r"+"Back-order line "+$result.child.displayNumber+" created for the remaining "+String:C10($result.remaining)+".")
	Else
		cs:C1710.sfw_dialog.me.alert("The receipt will be saved, but the back-order could not be created:\r"+$result.message)
	End if

local Function _showInList($line : cs:C1710.BuyingOrderLineEntity)
	If (Form:C1466=Null:C1517) || (Form:C1466.sfw=Null:C1517) || (Form:C1466.sfw.lb_items=Null:C1517)
		return
	End if
	//---through the LIST's own dataclass, not the entity handed in. The line was created
	//   by backorderRemaining, which is not a local function: under client/server it comes
	//   back from the server's datastore, and the list - the client's - refuses it with
	//   error 1600 "the entity does not belong to the dataclass".
	var $same : 4D:C1709.Entity
	$same:=Form:C1466.sfw.lb_items.getDataClass().get(String:C10($line.UUID))
	If ($same=Null:C1517)
		return
	End if
	If (Form:C1466.sfw.lb_items.contains($same))
		return
	End if
	Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.copy().add($same)
	Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items

	// ---- Part number ----------------------------------------------------------
	// There is no partNumber column on [BuyingOrderLine]: the part is the AML row the
	// line points at. But 661 legacy lines carry a [BUY_ITEMS]Part_num with no AML row
	// behind it - service work (backgrind, radiography, vibration) where the number is
	// the CUSTOMER's part being processed, not something bought from the vendor. Those
	// values live in moreData.legacy.partNumber, and reading only aml.ourPartNum made
	// them look lost.
	//
	// Of 11,860 lines: 710 inventory lines all carry a part (legacy made it mandatory
	// there via subr_lineitem_check), 661 non-inventory lines carry one anyway, and
	// 10,489 have none at all - which is why the fields are hidden rather than shown
	// permanently blank.

Function get partNumberDisplay()->$partNumber : Text
	$partNumber:=""
	If (This:C1470.aml#Null:C1517)
		$partNumber:=String:C10(This:C1470.aml.ourPartNum)
	End if
	If ($partNumber="") && (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.legacy#Null:C1517)
		$partNumber:=String:C10(This:C1470.moreData.legacy.partNumber)
	End if

Function get vendorPartNumberDisplay()->$partNumber : Text
	$partNumber:=""
	If (This:C1470.aml#Null:C1517)
		$partNumber:=String:C10(This:C1470.aml.vendorPartnum)
	End if
	If ($partNumber="") && (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.legacy#Null:C1517)
		$partNumber:=String:C10(This:C1470.moreData.legacy.vendorPartNumber)
	End if

	// Show the part fields when there is a part, or when the line is one that must have
	// one. An inventory line always shows them even while still empty - that is where
	// the buyer picks from the AML.
Function get showsPartNumber()->$result : Boolean
	$result:=Bool:C1537(This:C1470.inventory) | (This:C1470.partNumberDisplay#"") | (This:C1470.vendorPartNumberDisplay#"")

	//mark:-Line list columns
	//
	// Two of the PO Lines columns stack three values in one cell, as the legacy list did,
	// so the grid stays readable without eleven narrow date and number columns.

Function get amountHeld()->$amount : Real
	// Legacy "Amt held", [BUY_ITEMS]Amt_outstanding: what is still owed on the line.
	// Legacy stored it and refreshed it after each check run (WrapperAmt_OutStanding):
	//     Line_total - Discount + Freight - T_paid
	// Computed live here instead. There is no line discount in this application, so
	// that term drops out; amountPaid is the imported T_paid.
	$amount:=Num:C11(This:C1470.lineTotal)+Num:C11(This:C1470.freight)-Num:C11(This:C1470.amountPaid)

Function get paymentBlock()->$text : Text
	// Check# / Date Paid / Amt Paid, one per line.
	var $lines : Collection

	$lines:=New collection:C1472()

	If (Num:C11(This:C1470.checkNumber)#0)
		$lines.push(String:C10(Num:C11(This:C1470.checkNumber)))
	End if
	If (This:C1470.paidDate#!00-00-00!)
		$lines.push(String:C10(This:C1470.paidDate; System date short:K1:1))
	End if
	If (Num:C11(This:C1470.amountPaid)#0)
		$lines.push(String:C10(Num:C11(This:C1470.amountPaid); "###,##0.00"))
	End if

	$text:=$lines.join(Char:C90(Carriage return:K15:38))

Function get referenceBlock()->$text : Text
	// Job# / Asset# / Supplier PS#, one per line. supPsNumber is the subcontract packing
	// slip - it only carries a value on a line created by that workflow.
	var $lines : Collection

	$lines:=New collection:C1472()

	If (Num:C11(This:C1470.jobNumber)#0)
		$lines.push(String:C10(Num:C11(This:C1470.jobNumber)))
	End if
	If (Num:C11(This:C1470.assetListNumber)#0)
		$lines.push(String:C10(Num:C11(This:C1470.assetListNumber)))
	End if
	If (Num:C11(This:C1470.supPsNumber)#0)
		$lines.push(String:C10(Num:C11(This:C1470.supPsNumber)))
	End if

	$text:=$lines.join(Char:C90(Carriage return:K15:38))
	//mark:-Buy-items report columns
	//
	// Columns for the inventory buy-items export - legacy's BuyItemsSpreadSheet report,
	// which was a [BUY_ITEMS] report and therefore ONE ROW PER LINE. That grain is kept,
	// so a line that was never received still appears (it has no lots at all), which is
	// the whole point of the "NOT received" variant of that report.
	//
	// The consequence is that the lot columns the client asked for - available quantity,
	// IQA, vendor lot, expiration - have to be aggregated whenever a line has more than
	// one lot. lotCount is exported alongside them so a row that is an aggregate is never
	// mistaken for a single lot.
	//
	// Every one of these is a single-segment attribute on purpose: ExcelDataExporter
	// walks dotted paths by stringifying each hop, which is not safe past two levels.

Function get availableQtyTotal()->$qty : Real
	$qty:=This.inventories.sum("availableQty")

Function get lotCount()->$count : Integer
	$count:=This.inventories.length

Function get lotNumbersDisplay()->$text : Text
	$text:=This._joinLotValues("partLotNumber")

Function get expirationDatesDisplay()->$text : Text
	// Text rather than a date: a line with two lots has two expiry dates, and showing
	// only the earliest would quietly hide the second.
	//
	// [Inventory]expirationDate is a NUMERIC STAMP, not a date - the same storage as
	// expectedDeliveryStmp on this table, and what createManualInv_lot writes with
	// sfw_stmp.build. Comparing it to !00-00-00! is what raised "This operation is not
	// compatible with the two arguments".
	var $lot : cs:C1710.InventoryEntity
	var $values : Collection
	var $date : Date

	$values:=New collection()
	For each ($lot; This.inventories)
		If (Num($lot.expirationDate)#0)
			$date:=cs:C1710.sfw_stmp.me.getDate($lot.expirationDate; True)
			If ($date#!00-00-00!)
				$values.push(String($date; System date short))
			End if
		End if
	End for each

	$text:=$values.distinct().join("; ")

Function get iqaDoneDisplay()->$text : Text
	$text:=This._joinIqa("iqaDoneDisplay")

Function get iqaPassDisplay()->$text : Text
	$text:=This._joinIqa("iqaPassDisplay")

Function get iqaNumberDisplay()->$text : Text
	$text:=This._joinLotValues("iqaNumberDisplay")

Function get supplierName()->$text : Text
	$text:=(This.buyingOrder#Null) && (This.buyingOrder.supplier#Null) ? String(This.buyingOrder.supplier.name) : ""

	//mark:-Legacy accounts-payable columns
	//
	// The legacy report showed $disc, Inv#, Inv date, p/p and Disputed. This application
	// has no accounts-payable module yet, so _import_buyOrders parked those values in
	// moreData.legacy rather than inventing columns for them. They are read-only here.

Function get invoiceNumberDisplay()->$text : Text
	var $value : Variant
	$value:=This._legacy("invoiceNumber")
	$text:=($value=Null) ? "" : String($value)

Function get invoiceDateDisplay()->$text : Text
	var $value : Variant
	$value:=This._legacy("invoiceDate")
	$text:=(Value type($value)=Is date) && ($value#!00-00-00!) ? String($value; System date short) : ""

Function get disputedDisplay()->$text : Text
	$text:=Bool(This._legacy("disputedInvoice")) ? "Y" : "N"

Function get partialPaymentDisplay()->$text : Text
	// legacy Multi_chks, printed as the "p/p" column
	$text:=Bool(This._legacy("multiChecks")) ? "Y" : "N"

Function get discountDaysDisplay()->$days : Integer
	//---Null on lines created in this application, which carry no legacy data, and
	//   Num(Null) is an error rather than 0
	var $value : Variant
	$value:=This._legacy("discountDays")
	$days:=($value=Null) ? 0 : Num($value)

	//mark:-Sub functions

local Function _legacy($key : Text)->$value : Variant
	$value:=Null
	If (This.moreData#Null) && (This.moreData.legacy#Null)
		$value:=This.moreData.legacy[$key]
	End if

local Function _joinLotValues($attribute : Text)->$text : Text
	// Distinct, non-empty values across the line's lots.
	var $lot : cs:C1710.InventoryEntity
	var $values : Collection
	var $one : Text

	$values:=New collection()
	For each ($lot; This.inventories)
		$one:=String($lot[$attribute])
		If ($one#"")
			$values.push($one)
		End if
	End for each

	$text:=$values.distinct().join("; ")

local Function _joinIqa($attribute : Text)->$text : Text
	// One Y/N when the lots agree, "Partial" when they do not, "" when nothing is
	// recorded. Never a bare "Y" on a line where only one of three lots passed.
	var $values : Collection

	$values:=Split string(This._joinLotValues($attribute); "; "; sk ignore empty strings)

	Case of
		: ($values.length=0)
			$text:=""
		: ($values.length=1)
			$text:=$values[0]
		Else
			$text:="Partial"
	End case