//%attributes = {}
// _fix_inventoryNameKeys($list) -> {key: {UUID; name}} for _fix_inventoryNameFind: a list table
// (InventoryClassification / InventoryUnits) by its name lowercased and trimmed.
#DECLARE($list : 4D:C1709.EntitySelection)->$keys : Object

var $e : 4D:C1709.Entity
var $key : Text

$keys:=New object:C1471
For each ($e; $list)
	$key:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace(String:C10($e.name)))
	If ($key#"") && ($keys[$key]=Null:C1517)
		$keys[$key]:=New object:C1471("UUID"; $e.UUID; "name"; $e.name)
	End if
End for each
