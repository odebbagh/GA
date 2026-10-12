//%attributes = {}
// LT - Serial Header: the serial-number section title under an SN step (##this.snHeader##).
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $i : Integer
var $borderLeft : Integer
var $lineItem : Object
var $objects : Collection

$line:=ds:C1482.dfd_Line.query("name = :1"; "LT - Serial Header").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if

$line.name:="LT - Serial Header"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.variableItems:=New object:C1471("tags"; New collection:C1472(New object:C1471("tag"; "this.snHeader"; "objects"; New collection:C1472("text_1"))))
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())

$objects:=$line.objectsForm.objects
$lineItem:=New object:C1471("name"; "text_1"; "order"; 1; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 4; "left"; 280; "width"; 290; "height"; 15; "text"; "##this.snHeader##"; "fontFamily"; "Helvetica"; "fontSize"; 9; "textDecoration"; "underline"))
$objects.push($lineItem)

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
	$lineItem:=New object:C1471("name"; "line_"+String:C10($i); "order"; 9+$i; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; $borderLeft; "width"; 0; "height"; 27))
	$objects.push($lineItem)
End for

return $line
