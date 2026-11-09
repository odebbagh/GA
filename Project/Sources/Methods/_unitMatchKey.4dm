//%attributes = {}
// _unitMatchKey($name : Text) -> Text
// Folds a unit of measure down to a comparison key, so the spellings the legacy
// application used all land on the same [Unit] row.
//
//   "BOX" / "Box" / "box"   -> "box"
//   "GALLON" / "Gallon"     -> "gallon"
//
// Case and punctuation only. It deliberately does NOT strip a trailing "s": that would
// merge Bars/Bar, Months/Month, Days/Day and even Pcs/Pc, which are the units people
// actually wrote. Genuine variants that do not fold by case alone - Hrs, Hours, HR, PK,
// PKG, YR, YRS, Spools, Pails - are declared one by one as aliases on the row in
// _import_units, and matched through moreData.aliasKeys.
//
// Used by _import_units to seed the table, and by _import_buyOrders to resolve the
// legacy Units value of a buy line to it. Both must fold the same way, which is why
// this lives in one place.

#DECLARE($name : Text)->$key : Text

var $work : Text
var $i : Integer
var $char : Text

$key:=""
$work:=Lowercase:C14(String:C10($name))

If ($work="")
	return
End if

For ($i; 1; Length:C16($work))
	$char:=Substring:C12($work; $i; 1)
	If (Position:C15($char; "abcdefghijklmnopqrstuvwxyz0123456789")>0)
		$key:=$key+$char
	End if
End for
