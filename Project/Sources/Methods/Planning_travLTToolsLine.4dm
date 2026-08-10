//%attributes = {}
#DECLARE($isHeader : Boolean)->$line : cs:C1710.dfd_LineEntity

var $borderLeft : Integer
var $i : Integer
var $lineItem : Object
var $lineName : Text
var $nextOrder : Integer
var $objects : Collection
var $tags : Collection
var $textLeft : Integer
var $textTop : Integer
var $textWidth : Integer

$textLeft:=279
$textWidth:=295
$textTop:=2

$lineName:="LT - Tools"
If ($isHeader)
	$lineName:=$lineName+" Header"
End if 

$line:=ds:C1482.dfd_Line.query("name = :1"; $lineName).first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:=$lineName
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects
$tags:=New collection:C1472()
$nextOrder:=1

If ($isHeader)
	$lineItem:=New object:C1471("name"; "text_label"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $textLeft; "width"; $textWidth; "height"; 15; "text"; "##this.toolsHeader##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	$tags.push(New object:C1471("tag"; "this.toolsHeader"; "objects"; New collection:C1472("text_label")))
Else 
	$lineItem:=New object:C1471("name"; "text_value"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $textLeft; "width"; $textWidth; "height"; 15; "text"; "##this.toolText##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	$tags.push(New object:C1471("tag"; "this.toolText"; "objects"; New collection:C1472("text_value")))
End if 

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
	$lineItem:=New object:C1471("name"; "line_"+String:C10($i); "order"; $nextOrder; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; 0; "left"; $borderLeft; "width"; 0; "height"; 25))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
End for 

$line.variableItems:=New object:C1471("tags"; $tags)

return $line
