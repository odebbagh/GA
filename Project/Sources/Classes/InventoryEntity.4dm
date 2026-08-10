Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:="INV: "+String:C10(This:C1470.inventoryID; "00000#")
	
// dateIn is a real Date field (not a stamp), the computed attribute only
// exists because the form binds dateIn_d
Function get dateIn_d()->$date : Date
	$date:=This:C1470.dateIn

Function set dateIn_d($date : Date)
	This:C1470.dateIn:=$date


local Function afterSave()
	// Bin.isEmpty is computed live from linked inventories; just invalidate the bin cache so pickers refresh
	If (This:C1470.UUID_Location#"")
		// Invalidate bin cache so the picker reflects new occupancy status immediately
		If (Storage:C1525.cache#Null:C1517)
			Use (Storage:C1525.cache)
				Storage:C1525.cache.bins:=Null:C1517
			End use
		End if
	End if


local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470.inventoryID:=ds:C1482.Inventory.all().max("inventoryID")+1
	This:C1470.code:="INV"+String:C10(This:C1470.inventoryID; "00000#")
	
local Function afterCreation()
	// This callback is called after saving the new item
	
	This:C1470.availableQty:=This:C1470.initialQty
	
	$res:=This:C1470.save()
	
	$pull:=ds:C1482.InventoryPull.new()
	
	$pull.date:=cs:C1710.sfw_stmp.me.now()
	$pull.type:="Initial Stock"
	$pull.qty:=This:C1470.initialQty
	$pull.remaining:=This:C1470.initialQty
	$pull.lotNumber:="N/A"
	$pull.statusIQA:="Pending"
	
	$pull.UUID_Inventory:=This:C1470.UUID
	
	$user_es:=ds:C1482.sfw_User.query("login = :1"; Current user:C182)
	
	$pull.performedBy:=($user_es.length>0) ? $user_es[0].fullName : ""
	
	$res:=$pull.save()
	