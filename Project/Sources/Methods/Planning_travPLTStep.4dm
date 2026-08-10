//%attributes = {}
// PLT - Step: production lot traveller table row.
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $geom : Object
var $lineItem : Object
var $minH : Integer
var $objects : Collection
var $tags : Collection
var $textTop : Integer

$geom:=Planning_travPLTColGeom()
$minH:=18
$textTop:=3

$line:=ds:C1482.dfd_Line.query("name = :1"; "PLT - Step").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="PLT - Step"
$line.calculs:=New object:C1471("rules"; New collection:C1472(\
New object:C1471("rule"; "line_v0.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v1.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v2.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v3.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v4.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v5.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v6.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v7.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v8.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_v9.bottom:=description.bottom+3"); \
New object:C1471("rule"; "line_bottom.top:=description.bottom+3")\
))
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects
$tags:=New collection:C1472()

$lineItem:=New object:C1471("name"; "text_order"; "order"; 1; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; 2; "width"; $geom.wOrder-4; "height"; 14; "text"; "##this.order##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.order"; "objects"; New collection:C1472("text_order")))

$lineItem:=New object:C1471("name"; "description"; "order"; 2; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colDesc+2; "width"; $geom.wDesc-4; "height"; "auto"; "text"; "##this.description##"; "fontFamily"; "Helvetica"; "fontSize"; 8))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.description"; "objects"; New collection:C1472("description")))

$lineItem:=New object:C1471("name"; "text_alert"; "order"; 3; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colAlert+2; "width"; $geom.wAlert-4; "height"; "auto"; "text"; "##this.alert##"; "fontFamily"; "Helvetica"; "fontSize"; 8))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.alert"; "objects"; New collection:C1472("text_alert")))

$lineItem:=New object:C1471("name"; "text_qtyIn"; "order"; 4; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colQtyIn+2; "width"; $geom.wData-4; "height"; 14; "text"; "##this.qtyIn##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.qtyIn"; "objects"; New collection:C1472("text_qtyIn")))

$lineItem:=New object:C1471("name"; "text_operIn"; "order"; 5; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colOperIn+2; "width"; $geom.wData-4; "height"; 14; "text"; "##this.operIn##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.operIn"; "objects"; New collection:C1472("text_operIn")))

$lineItem:=New object:C1471("name"; "text_trayIn"; "order"; 6; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colTrayIn+2; "width"; $geom.wData-4; "height"; 14; "text"; "##this.trayIn##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.trayIn"; "objects"; New collection:C1472("text_trayIn")))

$lineItem:=New object:C1471("name"; "text_qtyOut"; "order"; 7; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colQtyOut+2; "width"; $geom.wData-4; "height"; 14; "text"; "##this.qtyOut##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.qtyOut"; "objects"; New collection:C1472("text_qtyOut")))

$lineItem:=New object:C1471("name"; "text_operOut"; "order"; 8; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colOperOut+2; "width"; $geom.wData-4; "height"; 14; "text"; "##this.operOut##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.operOut"; "objects"; New collection:C1472("text_operOut")))

$lineItem:=New object:C1471("name"; "text_trayOut"; "order"; 9; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $geom.colTrayOut+2; "width"; $geom.wTrayOut-4; "height"; 14; "text"; "##this.trayOut##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.trayOut"; "objects"; New collection:C1472("text_trayOut")))

$lineItem:=New object:C1471("name"; "line_v0"; "order"; 20; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; 0; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v1"; "order"; 21; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colDesc; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v2"; "order"; 22; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colAlert; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v3"; "order"; 23; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colQtyIn; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v4"; "order"; 24; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colOperIn; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v5"; "order"; 25; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colTrayIn; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v6"; "order"; 26; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colQtyOut; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v7"; "order"; 27; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colOperOut; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v8"; "order"; 28; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colTrayOut; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_v9"; "order"; 29; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -1; "left"; $geom.colRight; "width"; 0; "height"; $minH))
$objects.push($lineItem)
$lineItem:=New object:C1471("name"; "line_bottom"; "order"; 30; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $minH; "left"; 0; "width"; $geom.pageWidth; "height"; 0))
$objects.push($lineItem)

$line.variableItems:=New object:C1471("tags"; $tags)

return $line
