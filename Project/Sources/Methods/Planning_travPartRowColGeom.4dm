//%attributes = {}
// Lot Traveller PDF — column geometry for CRS partRows (sync with __seed_planLotTraveller)
#DECLARE($row : Object; $colNum : Integer)->$geom : Object

var $colCount; $colLeft; $colWidth; $colW; $j; $pageContentW; $partTableLeft : Integer
var $visible : Boolean

$geom:=New object:C1471("left"; 0; "width"; 0; "textLeft"; 0; "textWidth"; 0; "active"; False:C215)

If ($row=Null:C1517) || ($colNum<1) || ($colNum>5)
	return $geom
End if 

$pageContentW:=812
$partTableLeft:=Round:C94(318*($pageContentW/1000); 0)
If ($row.partTableLeft#Null:C1517) && (Num:C11($row.partTableLeft)>0)
	$partTableLeft:=Num:C11($row.partTableLeft)
End if 

$colCount:=0
If ($row.partColCount#Null:C1517) && (Num:C11($row.partColCount)>0)
	$colCount:=Num:C11($row.partColCount)
End if 

If ($colCount=0)
	For ($j; 1; 5)
		$visible:=False:C215
		If ($row["visibleCol"+String:C10($j)]#Null:C1517)
			$visible:=Bool:C1537($row["visibleCol"+String:C10($j)])
		Else 
			If ($row["showCol"+String:C10($j)]#Null:C1517)
				$visible:=Bool:C1537($row["showCol"+String:C10($j)])
			End if 
		End if 
		If (Not:C34($visible)) && ($row["col_"+String:C10($j)]#Null:C1517) && (String:C10($row["col_"+String:C10($j)])#"")
			$visible:=True:C214
		End if 
		If ($visible)
			$colCount:=$j
		End if 
	End for 
End if 

If ($colCount=0) || ($colNum>$colCount)
	return $geom
End if 

$colW:=Round:C94(($pageContentW-$partTableLeft)/$colCount; 0)
$colLeft:=$partTableLeft+(($colNum-1)*$colW)
If ($colNum=$colCount)
	$colWidth:=$pageContentW-$colLeft
Else 
	$colWidth:=$colW
End if 

$geom.left:=$colLeft
$geom.width:=$colWidth
$geom.textLeft:=$colLeft+2
$geom.textWidth:=$colWidth-4
$geom.active:=True:C214
