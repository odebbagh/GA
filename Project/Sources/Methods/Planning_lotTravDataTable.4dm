//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$result : Object

var $colCount : Integer
var $dataTable : Object
var $header : Text
var $headerObj : Object
var $headers : Collection
var $i : Integer
var $j : Integer
var $nbRows : Integer
var $row : Object
var $rows : Collection

$result:=New object:C1471(\
"colCount"; 0; \
"rowsKey"; ""; \
"headerKey"; ""; \
"rows"; New collection:C1472(); \
"header"; New collection:C1472()\
)

If ($step=Null:C1517)
	return $result
End if 

$headers:=$step.getDataTableColumnKeys()
If ($headers.length=0)
	return $result
End if 

$colCount:=$headers.length
If ($colCount>6)
	$colCount:=6
End if 

$dataTable:=$step.ensureDataTable()
If ($dataTable=Null:C1517)
	return $result
End if 

$headerObj:=New object:C1471("dataTableLabel"; "Data Table")
For ($j; 1; $colCount)
	$header:=String:C10($headers[$j-1])
	$headerObj["col"+String:C10($j)]:=Planning_travSanitizeText($header)
End for 

$rows:=New collection:C1472()
$nbRows:=0
If ($dataTable[$headers[0]]#Null:C1517)
	$nbRows:=$dataTable[$headers[0]].length
End if 

For ($i; 0; $nbRows-1)
	$row:=New object:C1471()
	For ($j; 1; $colCount)
		$header:=$headers[$j-1]
		If ($dataTable[$header]#Null:C1517) && ($i<$dataTable[$header].length)
			$row["col"+String:C10($j)]:=Planning_travSanitizeText(String:C10($dataTable[$header][$i]))
		Else 
			$row["col"+String:C10($j)]:=""
		End if 
	End for 
	$rows.push($row)
End for 

If ($rows.length=0)
	return $result
End if 

$result.colCount:=$colCount
$result.rowsKey:="dt"+String:C10($colCount)+"col"
$result.headerKey:="dt"+String:C10($colCount)+"colH"
$result.rows:=$rows
$result.header.push($headerObj)
