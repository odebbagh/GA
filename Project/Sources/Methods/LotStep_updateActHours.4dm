//%attributes = {}
// Recalculates and stores actualHours on the current LotStep from punch in/out times.
#DECLARE($lotStep : 4D:C1709.Entity)->$result : Object

var $hours : Real

$result:=New object:C1471("success"; False:C215; "hours"; 0)

If ($lotStep=Null:C1517)
	return $result
End if 

If ($lotStep.dateIn=!00-00-00!) || ($lotStep.dateOut=!00-00-00!)
	return $result
End if 

$hours:=LotStep_calcActualHours($lotStep)
$lotStep.actualHours:=$hours
$result.success:=True:C214
$result.hours:=$hours

return $result
