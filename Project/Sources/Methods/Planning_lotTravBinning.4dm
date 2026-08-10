//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$result : Object

var $binItems : Collection
var $bins : Collection
var $centerBin : Object
var $i : Integer
var $leftBin : Object
var $rightBin : Object
var $row : Object
var $stepTemplate : cs:C1710.StepTemplateEntity

$result:=New object:C1471(\
"hasBinning"; False:C215; \
"binningH"; New collection:C1472(); \
"bins"; New collection:C1472()\
)

If ($step=Null:C1517)
	return $result
End if 

// Same condition as punch-in Binning tab: disabled when step.stepTemplate.binning=False.
$stepTemplate:=Planning_travGetStepTemplate($step)
If ($stepTemplate=Null:C1517) || ($stepTemplate.binning=False:C215)
	return $result
End if 

If ($step.bins=Null:C1517) || ($step.bins.items=Null:C1517) || ($step.bins.items.length=0)
	return $result
End if 

$binItems:=$step.bins.items
$result.hasBinning:=True:C214
$result.binningH.push(New object:C1471("binningHeader"; "Binning"))

$bins:=New collection:C1472()
For ($i; 0; $binItems.length-1; 3)
	$row:=New object:C1471()
	$leftBin:=$binItems[$i]
	$row.leftBinTitle:=Planning_travSanitizeText(String:C10($leftBin.definition))
	If ($row.leftBinTitle="")
		$row.leftBinTitle:=Planning_travSanitizeText("Bin "+String:C10($leftBin.num))
	End if 
	$row.leftBinValue:=Planning_travSanitizeText(String:C10($leftBin.quantity))
	
	If ($i+1<$binItems.length)
		$centerBin:=$binItems[$i+1]
		$row.centerBinTitle:=Planning_travSanitizeText(String:C10($centerBin.definition))
		If ($row.centerBinTitle="")
			$row.centerBinTitle:=Planning_travSanitizeText("Bin "+String:C10($centerBin.num))
		End if 
		$row.centerBinValue:=Planning_travSanitizeText(String:C10($centerBin.quantity))
	Else 
		$row.centerBinTitle:=""
		$row.centerBinValue:=""
	End if 
	
	If ($i+2<$binItems.length)
		$rightBin:=$binItems[$i+2]
		$row.rightBinTitle:=Planning_travSanitizeText(String:C10($rightBin.definition))
		If ($row.rightBinTitle="")
			$row.rightBinTitle:=Planning_travSanitizeText("Bin "+String:C10($rightBin.num))
		End if 
		$row.rightBinValue:=Planning_travSanitizeText(String:C10($rightBin.quantity))
	Else 
		$row.rightBinTitle:=""
		$row.rightBinValue:=""
	End if 
	
	$bins.push($row)
End for 

$result.bins:=$bins
