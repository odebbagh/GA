//%attributes = {}
// PLT - Column Header: table column titles (first page only).
#DECLARE($topOffset : Integer)->$line : cs:C1710.dfd_LineEntity

var $cell : Object
var $cols : Collection
var $geom : Object
var $lineItem : Object
var $objects : Collection
var $rowH : Integer
var $textTop : Integer

If ($topOffset=0)
	$topOffset:=0
End if 

$geom:=Planning_travPLTColGeom()
$rowH:=22
$textTop:=$topOffset+5

$line:=ds:C1482.dfd_Line.query("name = :1"; "PLT - Column Header").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="PLT - Column Header"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.variableItems:=New object:C1471("tags"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects

$lineItem:=New object:C1471("name"; "hdr_bg"; "order"; 1; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; $topOffset; "left"; 0; "width"; $geom.pageWidth; "height"; $rowH; "fill"; "lightgray"))
$objects.push($lineItem)

$cols:=New collection:C1472(\
New object:C1471("name"; "order"; "left"; 0; "width"; $geom.wOrder; "text"; "#"); \
New object:C1471("name"; "desc"; "left"; $geom.colDesc; "width"; $geom.wDesc; "text"; "Step description"); \
New object:C1471("name"; "alert"; "left"; $geom.colAlert; "width"; $geom.wAlert; "text"; "Step Alert"); \
New object:C1471("name"; "qtyIn"; "left"; $geom.colQtyIn; "width"; $geom.wData; "text"; "Qty In"); \
New object:C1471("name"; "operIn"; "left"; $geom.colOperIn; "width"; $geom.wData; "text"; "Oper in"); \
New object:C1471("name"; "trayIn"; "left"; $geom.colTrayIn; "width"; $geom.wData; "text"; "Tray In"); \
New object:C1471("name"; "qtyOut"; "left"; $geom.colQtyOut; "width"; $geom.wData; "text"; "Qty Out"); \
New object:C1471("name"; "operOut"; "left"; $geom.colOperOut; "width"; $geom.wData; "text"; "Oper out"); \
New object:C1471("name"; "trayOut"; "left"; $geom.colTrayOut; "width"; $geom.wTrayOut; "text"; "Tray Out")\
)

For each ($cell; $cols)
	$lineItem:=New object:C1471("name"; "hdr_"+$cell.name; "order"; $objects.length+1; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $cell.left+2; "width"; $cell.width-4; "height"; 14; "text"; $cell.text; "fontFamily"; "Helvetica"; "fontSize"; 8; "fontWeight"; "bold"; "textAlign"; "center"))
	$objects.push($lineItem)
End for each 

$lineItem:=New object:C1471("name"; "v_left"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; 0; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_desc"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colDesc; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_alert"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colAlert; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_qtyIn"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colQtyIn; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_operIn"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colOperIn; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_trayIn"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colTrayIn; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_qtyOut"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colQtyOut; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_operOut"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colOperOut; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_trayOut"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colTrayOut; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "v_right"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; $geom.colRight; "width"; 0; "height"; $rowH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "h_top"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset; "left"; 0; "width"; $geom.pageWidth; "height"; 0))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "h_bottom"; "order"; $objects.length+1; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $topOffset+$rowH; "left"; 0; "width"; $geom.pageWidth; "height"; 0))
$objects.push($lineItem)

return $line
