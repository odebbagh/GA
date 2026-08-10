//%attributes = {}
// InventoryPullForm_loadForLot
// Returns pull/put back history for a lot. Includes pulls of the lot's own
// inventory as well as pulls/put backs of the job's buying-order inventory that
// were performed against this lot (matched on the lot number stamped at pull time).

#DECLARE($lot : 4D:C1709.Entity)->$pulls : 4D:C1709.EntitySelection

var $lotPulls; $boPulls : 4D:C1709.EntitySelection
var $boInv : 4D:C1709.EntitySelection
var $jobUUID; $lotKey : Text

If ($lot=Null:C1517)
	$pulls:=ds:C1482.InventoryPull.newSelection()
	return
End if

// pulls of the inventory that belongs to the lot (original behaviour)
$lotPulls:=ds:C1482.Inventory.query("UUID_Lot = :1"; $lot.UUID).pulls.query("(type = :1) | (type = :2)"; "Pull"; "Put Back")

$jobUUID:=($lot.job#Null:C1517) ? $lot.job.UUID : ""

If ($jobUUID#"")
	// job buying-order inventory: its pulls carry the lot number they were made for
	$lotKey:=($lot.lotNumber#"") ? $lot.lotNumber : String:C10($lot.number)
	$boInv:=ds:C1482.Inventory.query("buyingOrderLine.UUID_Job = :1 AND buyingOrderLine.inventory = :2"; $jobUUID; True:C214)
	$boPulls:=ds:C1482.InventoryPull.query(\
		"(UUID_Inventory in :1) AND ((type = :2) | (type = :3)) AND (lotNumber = :4)"; \
		$boInv.UUID; "Pull"; "Put Back"; $lotKey)
	$pulls:=$lotPulls.or($boPulls).orderBy("date desc")
Else
	$pulls:=$lotPulls.orderBy("date desc")
End if
