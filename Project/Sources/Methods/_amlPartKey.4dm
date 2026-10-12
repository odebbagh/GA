//%attributes = {}
// _amlPartKey($partNumber : Text; $leadingCodeOnly : Boolean) -> Text
// Folds a part number down to a comparison key, so a buy line's legacy Part_num and an
// [AML] row's ourPartNum land on each other.
//
//   "LM117HRQMLV" / "lm117hrqmlv"   -> "lm117hrqmlv"
//   "CF-015" / "CF 015" / "cf015"   -> "cf015"
//
// Case and punctuation only, the same rule _unitMatchKey applies to units of measure.
// Used by _import_buyOrders on BOTH sides of the lookup, which is why it lives here
// rather than being written out twice.
//
// $leadingCodeOnly handles the "code + description" shape. 271 legacy buy lines carry a
// part number with a description glued on:
//
//   "CF-001    1.25   mil AL TANAKA"
//   "CF-015   LOCTITE ABLESTIK QMI2569"
//
// where the AML row is just "CF-001". Passing True truncates at the first run of TWO OR
// MORE spaces and folds what is left. A SINGLE space is deliberately not a separator:
// "5972-13-BURN IN" and "SEE BELOW" are whole values, not a code plus commentary.
//
// It returns "" when there is no such run - i.e. when there is no distinct leading code
// to fall back on - so the caller can tell "nothing to try" from "tried and missed".
//
// Across the 1,371 legacy lines that carry a part number this yields 64 leading codes,
// 63 of them the CF-0NN internal family and the last one "N/A", which matches no AML
// row. The fallback is counted separately in the import report so it stays auditable.

#DECLARE($partNumber : Text; $leadingCodeOnly : Boolean)->$key : Text

var $work : Text
var $position : Integer
var $i : Integer
var $char : Text

$key:=""
$work:=String:C10($partNumber)

If ($leadingCodeOnly)
	$position:=Position:C15("  "; $work)
	If ($position<=1)
		return
	End if
	$work:=Substring:C12($work; 1; $position-1)
End if

$work:=Lowercase:C14($work)

If ($work="")
	return
End if

For ($i; 1; Length:C16($work))
	$char:=Substring:C12($work; $i; 1)
	If (Position:C15($char; "abcdefghijklmnopqrstuvwxyz0123456789")>0)
		$key:=$key+$char
	End if
End for
