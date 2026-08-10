//%attributes = {}
// InventoryPullForm_savePull
// Creates an inventory pull and updates available quantity.

#DECLARE($lot : 4D:C1709.Entity; $inventory_e : 4D:C1709.Entity; $qtyToPull : Real; $performedBy : Text)->$result : Object

var $pull_e : 4D:C1709.Entity
var $res : 4D:C1709.EntitySelection

$result:=New object:C1471("success"; False:C215; "message"; "")

If ($lot=Null:C1517) || ($inventory_e=Null:C1517) || ($qtyToPull<=0)
	$result.message:="Invalid pull data."
	return $result
End if 

If (String:C10($performedBy)="")
	$result.message:="Please identify who performed the pull."
	return $result
End if 

If ($qtyToPull>$inventory_e.availableQty)
	$result.message:="Quantity cannot exceed available quantity ("+String:C10($inventory_e.availableQty)+")."
	return $result
End if 

$pull_e:=ds:C1482.InventoryPull.new()
$pull_e.type:="Pull"
$pull_e.date:=cs:C1710.sfw_stmp.me.now()
$pull_e.qty:=$qtyToPull
$pull_e.remaining:=$inventory_e.availableQty-$qtyToPull
$pull_e.performedBy:=$performedBy
$pull_e.statusIQA:="N/A"
If ($inventory_e.IQA_status#"")
	$pull_e.statusIQA:=$inventory_e.IQA_status
End if 
$pull_e.lotNumber:=$lot.lotNumber
If ($pull_e.lotNumber="")
	$pull_e.lotNumber:=String:C10($lot.number)
End if 
$pull_e.UUID_Inventory:=$inventory_e.UUID
If ($lot.job#Null:C1517)
	$pull_e.jobNumber:=$lot.job.jobNumber
End if 

$res:=$pull_e.save()

If (Not:C34($res.success))
	$result.message:="Could not save inventory pull."
	return $result
End if 

$inventory_e.availableQty:=$pull_e.remaining
$res:=$inventory_e.save()

If (Not:C34($res.success))
	$result.message:="Inventory pull saved but inventory could not be updated."
	return $result
End if 

$result.success:=True:C214
