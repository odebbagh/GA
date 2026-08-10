//%attributes = {}
// Saves packageType on the lot linked to a LotStep panel. Reverts the field when the lot is locked.
#DECLARE($lot : 4D:C1709.Entity)->$result : Object

var $saveCheck : Object
var $freshLot : 4D:C1709.Entity

$result:=New object:C1471("success"; False:C215)

If ($lot=Null:C1517)
	return $result
End if 

$saveCheck:=LotHoldForm_trySaveLot($lot)
If (Not:C34($saveCheck.success))
	$freshLot:=ds:C1482.Lot.get($lot.UUID)
	If ($freshLot#Null:C1517)
		$lot.packageType:=$freshLot.packageType
	End if 
	cs:C1710.sfw_dialog.me.alert("The lot record is locked or could not be saved. Please free the record before changing the package type.")
	return $result
End if 

$result.success:=True:C214
return $result
