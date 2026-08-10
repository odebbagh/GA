//%attributes = {}
// Gets a saved hold form object for a specific hold ON event.
#DECLARE($lot : 4D:C1709.Entity; $formFieldName : Text; $holdOn : Object)->$form : Object

var $container : Object
var $items : Collection
var $item : Object
var $holdUUID : Text

$form:=Null:C1517

If ($lot=Null:C1517) || ($holdOn=Null:C1517)
	return $form
End if 

LotHoldForm_ensureHoldUUID($lot; $holdOn)
LotHoldForm_ensureFormContainer($lot; $formFieldName; $holdOn)

Case of 
	: ($formFieldName="NCMN")
		$container:=$lot.NCMN
	: ($formFieldName="ISSNF")
		$container:=$lot.ISSNF
	Else 
		return $form
End case 

If ($container=Null:C1517) || ($container.items=Null:C1517)
	return $form
End if 

$items:=$container.items
$holdUUID:=String:C10($holdOn.UUID)

If ($holdUUID#"")
	$item:=$items.query("hold_UUID = :1"; $holdUUID).first()
End if 

If ($item#Null:C1517)
	$form:=LotHoldForm_cloneObject($item)
End if 
