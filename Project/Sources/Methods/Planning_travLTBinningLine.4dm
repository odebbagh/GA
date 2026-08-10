//%attributes = {}
// LT - Binning row line with taller rows for defect labels.
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $borderHeight : Integer
var $borderLeft : Integer
var $i : Integer
var $lineItem : Object
var $objects : Collection
var $rowHeight : Integer
var $tags : Collection
var $textTop : Integer

$rowHeight:=28
$borderHeight:=$rowHeight+4
$textTop:=6

$line:=ds:C1482.dfd_Line.query("name = :1"; "LT - Binning").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="LT - Binning"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects
$tags:=New collection:C1472()

$lineItem:=New object:C1471("name"; "text_1"; "order"; 1; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; 300; "width"; 45; "height"; 20; "text"; "##this.leftBinTitle##"; "fontFamily"; "Helvetica"; "fontSize"; 8))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.leftBinTitle"; "objects"; New collection:C1472("text_1")))

$lineItem:=New object:C1471("name"; "rectangle_1"; "order"; 2; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 345; "width"; 35; "height"; $rowHeight))
$objects.push($lineItem)

$lineItem:=New object:C1471("name"; "text_2"; "order"; 3; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; 350; "width"; 30; "height"; 20; "text"; "##this.leftBinValue##"; "fontFamily"; "Helvetica"; "fontSize"; 9; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.leftBinValue"; "objects"; New collection:C1472("text_2")))

$lineItem:=New object:C1471("name"; "text_3"; "order"; 4; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; 390; "width"; 45; "height"; 20; "text"; "##this.centerBinTitle##"; "fontFamily"; "Helvetica"; "fontSize"; 8))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.centerBinTitle"; "objects"; New collection:C1472("text_3")))

$lineItem:=New object:C1471("name"; "rectangle_2"; "order"; 5; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 435; "width"; 35; "height"; $rowHeight))
$objects.push($lineItem)

$lineItem:=New object:C1471("name"; "text_4"; "order"; 6; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; 440; "width"; 30; "height"; 20; "text"; "##this.centerBinValue##"; "fontFamily"; "Helvetica"; "fontSize"; 9; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.centerBinValue"; "objects"; New collection:C1472("text_4")))

$lineItem:=New object:C1471("name"; "text_5"; "order"; 7; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; 480; "width"; 45; "height"; 20; "text"; "##this.rightBinTitle##"; "fontFamily"; "Helvetica"; "fontSize"; 8))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.rightBinTitle"; "objects"; New collection:C1472("text_5")))

$lineItem:=New object:C1471("name"; "rectangle_3"; "order"; 8; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 525; "width"; 35; "height"; $rowHeight))
$objects.push($lineItem)

$lineItem:=New object:C1471("name"; "text_6"; "order"; 9; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; 530; "width"; 30; "height"; 20; "text"; "##this.rightBinValue##"; "fontFamily"; "Helvetica"; "fontSize"; 9; "textAlign"; "center"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "this.rightBinValue"; "objects"; New collection:C1472("text_6")))

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
	$lineItem:=New object:C1471("name"; "line_"+String:C10($i); "order"; 9+$i; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; $borderLeft; "width"; 0; "height"; $borderHeight))
	$objects.push($lineItem)
End for 

$line.variableItems:=New object:C1471("tags"; $tags)

return $line
