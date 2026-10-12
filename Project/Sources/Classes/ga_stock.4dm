// ga_stock
// The one place a material's stock changes. Built on how the legacy app was really used
// (Inventory_audit / Inventory_audit2, Oct 2026):
// - one stock figure: Qty_in_Stock and AvailableQty were always equal there. Here availableQty is
//   the stock left; qtyInStock is kept equal to it for the legacy screens and imports, and the
//   value (actualValue) follows it;
// - stock moves only through a recorded line ([InventoryPull]): a pull takes it out, a put back
//   brings it in. Set by hand without a record happened on 5 legacy materials in 14,718;
// - the line and the new stock are saved together: if the material cannot be saved (locked by
//   someone else), the line is not kept either.
singleton Class constructor

Function move($inventory : 4D:C1709.Entity; $type : Text; $qty : Real; $info : Object)->$result : Object
	// $type: "Pull" (out of stock) or "Put Back" (into stock)
	// $info: performedBy (text, required), reason, note, date (Date, today when absent),
	//        lot and lotStep (entities, for a production pull), reload (True: read the material
	//        again first, when it was loaded some time ago - not for the material of an open panel)
	// The material is saved: inside the panel's transaction when called from a panel in Modify,
	// so Cancel there undoes the line and the stock together.
	var $pull : 4D:C1709.Entity
	var $save : Object
	var $previous : Real

	$result:=New object:C1471("success"; False:C215; "message"; ""; "pull"; Null:C1517)
	If ($info=Null:C1517)
		$info:=New object:C1471
	End if
	Case of
		: ($inventory=Null:C1517)
			$result.message:="No material is selected."
			return
		: ($type#"Pull") && ($type#"Put Back")
			$result.message:="Unknown stock movement: "+$type
			return
		: ($qty<=0)
			$result.message:="Enter a quantity greater than zero."
			return
		: (String:C10($info.performedBy)="")
			$result.message:="Please identify who performed it."
			return
	End case
	If (Bool:C1537($info.reload))
		$inventory.reload()
	End if
	If ($type="Pull") && ($qty>$inventory.availableQty)
		$result.message:="Quantity cannot exceed the available quantity ("+String:C10($inventory.availableQty)+")."
		return
	End if

	$pull:=ds:C1482.InventoryPull.new()
	$pull.UUID_Inventory:=$inventory.UUID
	$pull.type:=$type
	$pull.date:=cs:C1710.sfw_stmp.me.now()
	If (Value type:C1509($info.date)=Is date:K8:7)
		If ($info.date#!00-00-00!) && ($info.date#Current date:C33)
			$pull.date:=cs:C1710.sfw_stmp.me.build($info.date)
		End if
	End if
	$pull.qty:=$qty
	$pull.remaining:=$inventory.availableQty+(($type="Pull") ? -$qty : $qty)
	$pull.performedBy:=String:C10($info.performedBy)
	$pull.reason:=String:C10($info.reason)
	$pull.cost:=Round:C94($qty*Num:C11($inventory.unitCost); 2)
	$pull.statusIQA:=(String:C10($inventory.IQA_status)#"") ? $inventory.IQA_status : "N/A"
	$pull.lotNumber:="N/A"
	If ($info.lot#Null:C1517)
		$pull.UUID_Lot:=$info.lot.UUID
		$pull.lotNumber:=$info.lot.displayNumber  // as people read the lot (41-1)
		If ($info.lot.job#Null:C1517)
			$pull.jobNumber:=$info.lot.job.jobNumber
		End if
	End if
	If ($info.lotStep#Null:C1517)
		$pull.UUID_LotStep:=$info.lotStep.UUID
		$pull.stepOrder:=$info.lotStep.order
	End if
	$pull.moreData:=New object:C1471("note"; String:C10($info.note))

	$previous:=$inventory.availableQty
	START TRANSACTION:C239
	$save:=$pull.save()
	If ($save.success)
		$inventory.availableQty:=$pull.remaining
		This:C1470.syncFigures($inventory)
		$save:=$inventory.save()
		If ($save.success)
			VALIDATE TRANSACTION:C240
			$result.success:=True:C214
			$result.pull:=$pull
			return
		End if
		$result.message:="The material "+String:C10($inventory.code)+" could not be updated"+((String:C10($save.statusText)#"") ? (" ("+$save.statusText+")") : "")+": it may be open by someone else. Nothing was recorded; try again."
	Else
		$result.message:="The stock line could not be saved"+((String:C10($save.statusText)#"") ? (" ("+$save.statusText+")") : "")+". Nothing was recorded."
	End if
	CANCEL TRANSACTION:C241
	$inventory.availableQty:=$previous
	This:C1470.syncFigures($inventory)

Function syncFigures($inventory : 4D:C1709.Entity)
	// qtyInStock (the legacy field) and the value follow the stock left; does not save
	If ($inventory=Null:C1517)
		return
	End if
	$inventory.qtyInStock:=$inventory.availableQty
	$inventory.actualValue:=Round:C94($inventory.availableQty*Num:C11($inventory.unitCost); 2)

Function pulledForLot($inventoryUUID : Text; $lotUUID : Text)->$net : Real
	// what a lot took out of a material and has not brought back: the most it can put back
	var $lines : 4D:C1709.EntitySelection

	$net:=0
	If ($inventoryUUID="") || ($lotUUID="")
		return
	End if
	$lines:=ds:C1482.InventoryPull.query("UUID_Inventory = :1 AND UUID_Lot = :2"; $inventoryUUID; $lotUUID)
	$net:=$lines.query("type = :1"; "Pull").sum("qty")-$lines.query("type = :1"; "Put Back").sum("qty")
