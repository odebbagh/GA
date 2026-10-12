//%attributes = {}
// InventoryPullForm_netPulled
// What a lot pulled from a material and has not put back yet: the most it can put back
// (ga_stock.pulledForLot). Without a lot: every production pull of the material, net of its
// production put backs - corrections made on the Inventories screen are not counted.

#DECLARE($inventoryUUID : Text; $lotUUID : Text)->$netPulled : Real

var $lines : 4D:C1709.EntitySelection

$netPulled:=0
If ($inventoryUUID="")
	return
End if
If (Count parameters:C259>=2) && ($lotUUID#"")
	$netPulled:=cs:C1710.ga_stock.me.pulledForLot($inventoryUUID; $lotUUID)
Else
	$lines:=ds:C1482.InventoryPull.query("UUID_Inventory = :1 AND reason = :2"; $inventoryUUID; "Production")
	$netPulled:=$lines.query("type = :1"; "Pull").sum("qty")-$lines.query("type = :1"; "Put Back").sum("qty")
End if
