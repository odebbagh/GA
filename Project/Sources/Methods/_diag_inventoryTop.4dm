//%attributes = {}
// _diag_inventoryTop($values; $max) -> how many times each value appears, the $max most frequent
// first, as [{value; count}]; empty values count as "(empty)". For _diag_inventory (read only).
#DECLARE($values : Collection; $max : Integer)->$top : Collection

var $counts : Object
var $value : Variant
var $key : Text

$counts:=New object
For each ($value; $values)
	$key:=String($value)
	If ($key="")
		$key:="(empty)"
	End if
	$counts[$key]:=Num($counts[$key])+1
End for each
$top:=New collection
For each ($key; OB Keys($counts))
	$top.push(New object("value"; $key; "count"; $counts[$key]))
End for each
$top:=$top.orderBy("count desc").slice(0; $max)
