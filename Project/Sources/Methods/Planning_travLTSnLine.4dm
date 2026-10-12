//%attributes = {}
// LT - Serial: one row of six serial-number boxes (##this.sn1## to ##this.sn6##), same grid as
// LT - DT6Col.
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $borderLeft : Integer
var $cellLeft : Integer
var $i : Integer
var $lineItem : Object
var $objects : Collection
var $rowHeight : Integer
var $tags : Collection

$rowHeight:=16

$line:=ds:C1482.dfd_Line.query("name = :1"; "LT - Serial").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if

$line.name:="LT - Serial"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects
$tags:=New collection:C1472()

For ($i; 1; 6)
	$cellLeft:=280+(($i-1)*49)
	$lineItem:=New object:C1471("name"; "rectangle_"+String:C10($i); "order"; ($i*2)-1; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; $cellLeft; "width"; 49; "height"; $rowHeight))
	$objects.push($lineItem)
	$lineItem:=New object:C1471("name"; "text_"+String:C10($i); "order"; $i*2; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 3; "left"; $cellLeft+2; "width"; 45; "height"; 12; "text"; "##this.sn"+String:C10($i)+"##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "textAlign"; "center"))
	$objects.push($lineItem)
	$tags.push(New object:C1471("tag"; "this.sn"+String:C10($i); "objects"; New collection:C1472("text_"+String:C10($i))))
End for

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
	$lineItem:=New object:C1471("name"; "line_"+String:C10($i); "order"; 12+$i; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; $borderLeft; "width"; 0; "height"; $rowHeight+4))
	$objects.push($lineItem)
End for

$line.variableItems:=New object:C1471("tags"; $tags)

return $line
