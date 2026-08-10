//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$stepTemplate : cs:C1710.StepTemplateEntity

var $stepDef : cs:C1710.StepEntity

$stepTemplate:=Null:C1517

If ($step=Null:C1517)
	return $stepTemplate
End if 

If ($step.step#Null:C1517)
	$stepTemplate:=$step.step.stepTemplate
End if 

If ($stepTemplate=Null:C1517) && (String:C10($step.UUID_Step)#"")
	$stepDef:=ds:C1482.Step.get($step.UUID_Step)
	If ($stepDef#Null:C1517)
		$stepTemplate:=$stepDef.stepTemplate
		If ($stepTemplate=Null:C1517) && (String:C10($stepDef.UUID_StepTemplate)#"")
			$stepTemplate:=ds:C1482.StepTemplate.get($stepDef.UUID_StepTemplate)
		End if 
	End if 
End if 

return $stepTemplate
