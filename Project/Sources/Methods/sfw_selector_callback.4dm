//%attributes = {}
#DECLARE($expression : Text; $key : Text)
var $formula : 4D:C1709.Function

$formula:=Formula from string:C1601($expression)
$formula.call(Null:C1517; $key)
