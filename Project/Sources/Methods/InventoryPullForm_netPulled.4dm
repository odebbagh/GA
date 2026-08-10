//%attributes = {}
// InventoryPullForm_netPulled
// Net quantity pulled but not yet put back for an inventory item.

#DECLARE($inventoryUUID : Text)->$netPulled : Real

var $pulled : Real
var $returned : Real

If ($inventoryUUID="")
	$netPulled:=0
Else 
	$pulled:=ds:C1482.InventoryPull.query("UUID_Inventory = :1 AND type = :2"; $inventoryUUID; "Pull").sum("qty")
	$returned:=ds:C1482.InventoryPull.query("UUID_Inventory = :1 AND type = :2"; $inventoryUUID; "Put Back").sum("qty")
	$netPulled:=$pulled-$returned
End if 
