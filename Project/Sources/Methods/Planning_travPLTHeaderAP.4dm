//%attributes = {}
// PLT - Header All Pages: logos + column header for continuation pages.
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $colHdrLine : cs:C1710.dfd_LineEntity
var $hdrObj : Object
var $hdrOrder : Integer
var $lineItem : Object
var $name : Text
var $objects : Collection
var $order : Integer

$line:=ds:C1482.dfd_Line.query("name = :1"; "PLT - Header All Pages").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="PLT - Header All Pages"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.variableItems:=New object:C1471("tags"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects
$order:=1

$lineItem:=New object:C1471("name"; "picture_ga"; "order"; $order; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 10; "left"; 10; "width"; 120; "height"; 60; "pictureFormat"; "scaled"; "picture"; "/RESOURCES/image/modeles/GA_logo.png"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "picture_itar"; "order"; $order; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 10; "left"; 300; "width"; 120; "height"; 60; "pictureFormat"; "scaled"; "picture"; "/RESOURCES/image/modeles/itar.png"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "picture_esd"; "order"; $order; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 15; "left"; 520; "width"; 45; "height"; 50; "pictureFormat"; "scaled"; "picture"; "/RESOURCES/image/modeles/esd.png"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "line_top"; "order"; $order; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; 80; "left"; 0; "width"; 574; "height"; 0))
$objects.push($lineItem)
$order:=$order+1

$colHdrLine:=Planning_travPLTColHdr(88)
For each ($hdrObj; $colHdrLine.objectsForm.objects)
	$hdrOrder:=$hdrObj.order+$order
	$name:=$hdrObj.name
	$lineItem:=New object:C1471("name"; $name; "order"; $hdrOrder; "properties"; OB Copy:C1225($hdrObj.properties))
	$objects.push($lineItem)
End for each 

return $line
