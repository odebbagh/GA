//%attributes = {}
#DECLARE($step : 4D:C1709.Entity; $table : Object; $stepOrder : Text; $stepDesc : Text)

var $qtyIn; $qtyOut; $rejects; $dateTimeIn; $dateTimeOut; $oper : Text
var $toolsText; $hp1; $lp1; $waferThickness; $glassivated; $probed; $inked; $silicon; $others : Text
var $dataTable : Object
var $headers : Collection
var $header : Text
var $nbRows; $i : Integer
var $rowValues : Collection
var $tool : Object
var $toolParts : Collection
var $toolDate : Text
var $tab : Text
var $procText; $partText : Text
var $row : Object

$tab:=Char:C90(Tab:K15:37)

$qtyIn:=String:C10($step.qtyIn)
$qtyOut:=String:C10($step.qtyOut)
$rejects:=String:C10($step.rejects)
If ($rejects="0") && ($step.qtyRejects#0)
	$rejects:=String:C10($step.qtyRejects)
End if 

$dateTimeIn:=Planning_travFmtDateTime($step.dateIn; $step.timeIn)
$dateTimeOut:=Planning_travFmtDateTime($step.dateOut; $step.timeOut)

$oper:=String:C10($step.outOperator)
If ($oper="")
	$oper:=String:C10($step.inOperator)
End if 

$toolParts:=New collection:C1472()
If ($step.tools#Null:C1517) && ($step.tools.items#Null:C1517)
	For each ($tool; $step.tools.items)
		If (String:C10($tool.toolName)#"")
			$toolDate:=Planning_travFmtDate($tool.toolDate)
			If ($toolDate="")
				$toolParts.push(String:C10($tool.toolName))
			Else 
				$toolParts.push(String:C10($tool.toolName)+" *"+$toolDate)
			End if 
		End if 
	End for each 
End if 
$toolsText:=$toolParts.join("  ")

$hp1:=Planning_travGetParam($step; "Hp-1")
$lp1:=Planning_travGetParam($step; "LP-1")
$waferThickness:=Planning_travGetParam($step; "Wafer Thickness")
$glassivated:=Planning_travGetParam($step; "Glassivated")
$probed:=Planning_travGetParam($step; "Probed")
$inked:=Planning_travGetParam($step; "Inked")
$silicon:=Planning_travGetParam($step; "Silicon")
$others:=Planning_travGetParam($step; "Others")

If ($waferThickness="N/A")
	$waferThickness:=""
End if 
If ($glassivated="N/A")
	$glassivated:=""
End if 
If ($probed="N/A")
	$probed:=""
End if 
If ($inked="N/A")
	$inked:=""
End if 
If ($silicon="N/A")
	$silicon:=""
End if 
If ($others="N/A")
	$others:=""
End if 

WP Table append row:C1474($table; $stepOrder; $stepDesc; "")

$procText:="qty in"+$tab+"date/time in"+$tab+"rejects"+$tab+"qty out"+$tab+"date/time out"+$tab+"oper"
$procText:=$procText+Char:C90(Carriage return:K15:38)
$procText:=$procText+$qtyIn+$tab+$dateTimeIn+$tab+$rejects+$tab+$qtyOut+$tab+$dateTimeOut+$tab+$oper
$row:=WP Table append row:C1474($table; ""; ""; $procText)
WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font size:K81:66; 7)

$row:=WP Table append row:C1474($table; ""; ""; "Tools *Cal Due Date: "+$toolsText)
WP SET ATTRIBUTES:C1342($row; wk font size:K81:66; 7)

$row:=WP Table append row:C1474($table; ""; ""; "Hp-1 *"+$hp1+"    LP-1 *"+$lp1)
WP SET ATTRIBUTES:C1342($row; wk font size:K81:66; 7)

$row:=WP Table append row:C1474($table; ""; ""; "Wafer Thickness in Mils: "+$waferThickness+" Glassivated: "+$glassivated+" Probed: "+$probed+" Inked: "+$inked)
WP SET ATTRIBUTES:C1342($row; wk font size:K81:66; 7)

$row:=WP Table append row:C1474($table; ""; ""; "Silicon: "+$silicon+" Others: "+$others)
WP SET ATTRIBUTES:C1342($row; wk font size:K81:66; 7)

$dataTable:=$step.dataTable
If ($dataTable#Null:C1517) && (Not:C34(OB Is empty:C1297($dataTable)))
	$headers:=OB Keys:C1719($dataTable)
	If ($headers.length>0)
		$partText:=""
		For each ($header; $headers)
			If ($partText="")
				$partText:=String:C10($header)
			Else 
				$partText:=$partText+$tab+String:C10($header)
			End if 
		End for each 
		$row:=WP Table append row:C1474($table; ""; ""; $partText)
		WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font bold:K81:68; True:C214; wk font size:K81:66; 7)
		
		$nbRows:=$dataTable[$headers[0]].length
		If ($nbRows=0)
			$rowValues:=New collection:C1472()
			For each ($header; $headers)
				$rowValues.push("")
			End for each 
			$partText:=$rowValues.join($tab)
			$row:=WP Table append row:C1474($table; ""; ""; $partText)
			WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font size:K81:66; 7)
		Else 
			For ($i; 0; $nbRows-1)
				$rowValues:=New collection:C1472()
				For each ($header; $headers)
					$rowValues.push(String:C10($dataTable[$header][$i]))
				End for each 
				$partText:=$rowValues.join($tab)
				$row:=WP Table append row:C1474($table; ""; ""; $partText)
				WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font size:K81:66; 7)
			End for 
		End if 
	Else 
		$row:=WP Table append row:C1474($table; ""; ""; "Part Number"+$tab+"Lot Number"+$tab+"Wafer Number"+$tab+"Quantity"+$tab+"Comments")
		WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font bold:K81:68; True:C214; wk font size:K81:66; 7)
		$row:=WP Table append row:C1474($table; ""; ""; $tab+$tab+$tab+$tab)
		WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font size:K81:66; 7)
	End if 
Else 
	$row:=WP Table append row:C1474($table; ""; ""; "Part Number"+$tab+"Lot Number"+$tab+"Wafer Number"+$tab+"Quantity"+$tab+"Comments")
	WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font bold:K81:68; True:C214; wk font size:K81:66; 7)
	$row:=WP Table append row:C1474($table; ""; ""; $tab+$tab+$tab+$tab)
	WP SET ATTRIBUTES:C1342($row; wk font family:K81:65; "Courier New"; wk font size:K81:66; 7)
End if 

$row:=WP Table append row:C1474($table; ""; ""; "")
WP SET ATTRIBUTES:C1342($row; wk font size:K81:66; 4)
