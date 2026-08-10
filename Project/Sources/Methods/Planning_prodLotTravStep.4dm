//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$stepData : Object

var $description : Text
var $orderDisplay : Text
var $stepDef : cs:C1710.StepEntity

$orderDisplay:=String:C10($step.order; "##0.00")
$description:=String:C10($step.description)

If ($description="") && (String:C10($step.UUID_Step)#"")
	$stepDef:=ds:C1482.Step.get($step.UUID_Step)
	If ($stepDef#Null:C1517)
		$description:=String:C10($stepDef.description)
		If ($description="")
			$description:=String:C10($stepDef.operationCode)
		End if 
		If ($description="")
			$description:=String:C10($stepDef.areas)
		End if 
	End if 
End if 

If ($description="")
	$description:=String:C10($step.area)
End if 

$stepData:=New object:C1471
$stepData.order:=Planning_travSanitizeText($orderDisplay)
$stepData.description:=Planning_travSanitizeText($description)
$stepData.alert:=Planning_travSanitizeText(String:C10($step.alert))
$stepData.qtyIn:=Planning_travSanitizeText(String:C10($step.qtyIn))
$stepData.operIn:=Planning_travSanitizeText(String:C10($step.inOperator))
$stepData.trayIn:=""
$stepData.qtyOut:=Planning_travSanitizeText(String:C10($step.qtyOut))
$stepData.operOut:=Planning_travSanitizeText(String:C10($step.outOperator))
$stepData.trayOut:=""

return $stepData
