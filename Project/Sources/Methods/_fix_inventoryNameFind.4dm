//%attributes = {}
// _fix_inventoryNameFind($keys; $text) -> {UUID; name} or Null: the list entry a legacy text stands
// for, case and spaces aside, singular or plural ("Wafers" -> Wafer, "UNITS" -> Units,
// "OTHER" -> Others). For _fix_inventoryLegacy.
#DECLARE($keys : Object; $text : Text)->$found : Object

var $key : Text

$found:=Null:C1517
$key:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace($text))
If ($key="")
	return
End if
Case of
	: ($keys[$key]#Null:C1517)
		$found:=$keys[$key]
	: ($key="@s") && ($keys[Substring:C12($key; 1; Length:C16($key)-1)]#Null:C1517)
		$found:=$keys[Substring:C12($key; 1; Length:C16($key)-1)]
	: ($keys[$key+"s"]#Null:C1517)
		$found:=$keys[$key+"s"]
End case
