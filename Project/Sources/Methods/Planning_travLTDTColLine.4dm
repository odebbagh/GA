//%attributes = {}
#DECLARE($colCount : Integer; $isHeader : Boolean)->$line : cs:C1710.dfd_LineEntity

var $borderHeight : Integer
var $borderLeft : Integer
var $cellFontSize : Integer
var $colLeft : Integer
var $colWidth : Integer
var $colWidths : Collection
var $dataLeft : Integer
var $dataRight : Integer
var $dataWidth : Integer
var $headerHeight : Integer
var $i : Integer
var $lineItem : Object
var $lineName : Text
var $nextOrder : Integer
var $objects : Collection
var $remaining : Integer
var $rowHeight : Integer
var $tags : Collection
var $textLeft : Integer
var $textTop : Integer
var $textWidth : Integer

If ($colCount<1) || ($colCount>6)
	return Null:C1517
End if 

$dataLeft:=280
$dataRight:=574
$dataWidth:=$dataRight-$dataLeft
$rowHeight:=20
$headerHeight:=42

Case of 
	: ($colCount<=3)
		$cellFontSize:=9
	: ($colCount=4)
		$cellFontSize:=8
	: ($colCount=5)
		$cellFontSize:=7
	Else 
		$cellFontSize:=6
End case 

$lineName:="LT - DT"+String:C10($colCount)+"Col"
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

$colWidths:=New collection:C1472()
$remaining:=$dataWidth
For ($i; 1; $colCount)
	If ($i=$colCount)
		$colWidths.push($remaining)
	Else 
		$colWidth:=Int:C8($dataWidth/$colCount)
		$colWidths.push($colWidth)
		$remaining:=$remaining-$colWidth
	End if 
End for 

If ($isHeader)
	$lineItem:=New object:C1471("name"; "text_label"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 0; "left"; $dataLeft; "width"; 100; "height"; 15; "text"; "Data Table"; "fontFamily"; "Helvetica"; "fontSize"; 9; "textDecoration"; "underline"))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	
	$colLeft:=$dataLeft
	For ($i; 1; $colCount)
		$colWidth:=$colWidths[$i-1]
		$textLeft:=$colLeft+2
		$textWidth:=$colWidth-4
		$textTop:=22
		
		$lineItem:=New object:C1471("name"; "rectangle_"+String:C10($i); "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 20; "left"; $colLeft; "width"; $colWidth; "height"; $rowHeight; "fill"; "lightgray"))
		$objects.push($lineItem)
		$nextOrder:=$nextOrder+1
		
		$lineItem:=New object:C1471("name"; "text_"+String:C10($i); "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $textLeft; "width"; $textWidth; "height"; 16; "text"; "##this.col"+String:C10($i)+"##"; "fontFamily"; "Helvetica"; "fontSize"; $cellFontSize; "textAlign"; "center"))
		$objects.push($lineItem)
		$nextOrder:=$nextOrder+1
		$tags.push(New object:C1471("tag"; "this.col"+String:C10($i); "objects"; New collection:C1472("text_"+String:C10($i))))
		
		$colLeft:=$colLeft+$colWidth
	End for 
Else 
	$colLeft:=$dataLeft
	For ($i; 1; $colCount)
		$colWidth:=$colWidths[$i-1]
		$textLeft:=$colLeft+2
		$textWidth:=$colWidth-4
		$textTop:=3
		
		$lineItem:=New object:C1471("name"; "rectangle_"+String:C10($i); "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; -2; "left"; $colLeft; "width"; $colWidth; "height"; $rowHeight))
		$objects.push($lineItem)
		$nextOrder:=$nextOrder+1
		
		$lineItem:=New object:C1471("name"; "text_"+String:C10($i); "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; $textTop; "left"; $textLeft; "width"; $textWidth; "height"; 16; "text"; "##this.col"+String:C10($i)+"##"; "fontFamily"; "Helvetica"; "fontSize"; $cellFontSize))
		$objects.push($lineItem)
		$nextOrder:=$nextOrder+1
		$tags.push(New object:C1471("tag"; "this.col"+String:C10($i); "objects"; New collection:C1472("text_"+String:C10($i))))
		
		$colLeft:=$colLeft+$colWidth
	End for 
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
			$borderLeft:=$dataRight
	End case 
	$borderHeight:=Choose:C955($isHeader; $headerHeight; $rowHeight+4)
	$lineItem:=New object:C1471("name"; "line_"+String:C10($i); "order"; $nextOrder; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; -2; "left"; $borderLeft; "width"; 0; "height"; $borderHeight))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
End for 

$line.variableItems:=New object:C1471("tags"; $tags)

return $line
