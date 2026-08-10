//%attributes = {}
// InventoryPullForm_pullList
// Inventory that can be pulled for a lot step: the lot's own inventory plus any
// inventory received against a buying-order line that is flagged inventory and
// assigned to the lot's job. Only items with available quantity are returned.

#DECLARE($lotUUID : Text; $jobUUID : Text)->$items : cs:C1710.InventorySelection

If ($lotUUID="") && ($jobUUID="")
	$items:=ds:C1482.Inventory.newSelection()
	return
End if

If ($jobUUID#"")
	$items:=ds:C1482.Inventory.query(\
		"((UUID_Lot = :1) OR (buyingOrderLine.UUID_Job = :2 AND buyingOrderLine.inventory = :3)) AND (availableQty > :4)"; \
		$lotUUID; $jobUUID; True:C214; 0).orderBy("code asc")
Else
	$items:=ds:C1482.Inventory.query("UUID_Lot = :1 AND availableQty > :2"; $lotUUID; 0).orderBy("code asc")
End if
