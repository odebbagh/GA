//%attributes = {}
// LT - Step Footer: bottom padding, vertical borders meet horizontal close line.
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $borderLeft : Integer
var $footerPad : Integer
var $i : Integer
var $lineItem : Object
var $objects : Collection

$footerPad:=8

$line:=ds:C1482.dfd_Line.query("name = :1"; "LT - Step Footer").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="LT - Step Footer"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.variableItems:=New object:C1471("tags"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())

$objects:=$line.objectsForm.objects

For ($i; 1; 4)
	Case of 
		: ($i=1)
			$borderLeft:=0
		: ($i=2)
			$borderLeft:=29
		: ($i=3)
			$borderLeft:=275
		Else 
			$borderLeft:=574
	End case 
	$lineItem:=New object:C1471("name"; "line_v"+String:C10($i); "order"; $i; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; 0; "left"; $borderLeft; "width"; 0; "height"; $footerPad))
	$objects.push($lineItem)
End for 

$lineItem:=New object:C1471("name"; "line_bottom"; "order"; 10; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $footerPad; "left"; 0; "width"; 574; "height"; 0))
$objects.push($lineItem)

return $line
