//%attributes = {}
// LT - Binning Header: static "Binning" section title.
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $lineItem : Object
var $objects : Collection

$line:=ds:C1482.dfd_Line.query("name = :1"; "LT - Binning Header").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="LT - Binning Header"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.variableItems:=New object:C1471("tags"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())

$objects:=$line.objectsForm.objects
$lineItem:=New object:C1471("name"; "text_1"; "order"; 1; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 4; "left"; 300; "width"; 100; "height"; 15; "text"; "Binning"; "fontFamily"; "Helvetica"; "fontSize"; 9; "textDecoration"; "underline"))
$objects.push($lineItem)

$lineItem:=New object:C1471("name"; "line_2"; "order"; 10; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; 0; "width"; 0; "height"; 27))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_1"; "order"; 11; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; 29; "width"; 0; "height"; 27))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_3"; "order"; 13; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; 275; "width"; 0; "height"; 27))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_4"; "order"; 14; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; 574; "width"; 0; "height"; 27))
$objects.push($lineItem)

return $line
