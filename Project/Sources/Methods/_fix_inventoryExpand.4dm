//%attributes = {}
// _fix_inventoryExpand($counts) -> the values of {value: count} repeated count times, so that
// _diag_inventoryTop can sort them. For the report of _fix_inventoryLegacy.
#DECLARE($counts : Object)->$values : Collection

var $key : Text
var $i : Integer

$values:=New collection:C1472
For each ($key; OB Keys:C1719($counts))
	For ($i; 1; Num:C11($counts[$key]))
		$values.push($key)
	End for
End for each
