//%attributes = {}
// Gets or prepares a hold form object for the current active hold ON event.
#DECLARE($lot : 4D:C1709.Entity; $formFieldName : Text; $defaults : Object)->$form : Object

var $hold : Object
var $container : Object
var $items : Collection
var $item : Object
var $holdUUID : Text

If ($lot=Null:C1517)
	return LotHoldForm_cloneObject($defaults)
End if 

$hold:=LotHoldForm_getCurrentHoldOn($lot)

If ($hold=Null:C1517)
	return LotHoldForm_cloneObject($defaults)
End if 

LotHoldForm_ensureHoldUUID($lot; $hold)
LotHoldForm_ensureFormContainer($lot; $formFieldName; $hold)

Case of 
	: ($formFieldName="NCMN")
		$container:=$lot.NCMN
	: ($formFieldName="ISSNF")
		$container:=$lot.ISSNF
	Else 
		return LotHoldForm_cloneObject($defaults)
End case 

$items:=$container.items
$holdUUID:=String:C10($hold.UUID)
$item:=Null:C1517

If ($holdUUID#"")
	$item:=$items.query("hold_UUID = :1"; $holdUUID).first()
End if 

If ($item#Null:C1517)
	$form:=LotHoldForm_cloneObject($item)
Else 
	$form:=LotHoldForm_cloneObject($defaults)
End if 
