//%attributes = {}
// InventoryPullForm_putBackList
// Returns inventory items that still have net pulled quantity for a lot: the
// lot's own inventory plus any inventory received against a buying-order line
// flagged inventory and assigned to the lot's job.

#DECLARE($lotUUID : Text; $jobUUID : Text)->$items : Collection

var $inv : 4D:C1709.Entity
var $candidates : 4D:C1709.EntitySelection

$items:=New collection:C1472()

If ($lotUUID="") && ($jobUUID="")
	return $items
End if

If ($jobUUID#"")
	$candidates:=ds:C1482.Inventory.query(\
		"(UUID_Lot = :1) OR (buyingOrderLine.UUID_Job = :2 AND buyingOrderLine.inventory = :3)"; \
		$lotUUID; $jobUUID; True:C214).orderBy("code asc")
Else
	$candidates:=ds:C1482.Inventory.query("UUID_Lot = :1"; $lotUUID).orderBy("code asc")
End if

For each ($inv; $candidates)
	If (InventoryPullForm_netPulled($inv.UUID)>0)
		$items.push($inv)
	End if
End for each
