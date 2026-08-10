//%attributes = {}
// Returns elapsed hours between punch in and punch out (simple case, no interruption adjustments).
#DECLARE($lotStep : 4D:C1709.Entity)->$hours : Real

var $seconds : Real
var $stmpIn : Integer
var $stmpOut : Integer
var $precision : Integer

$hours:=0

If ($lotStep=Null:C1517)
	return $hours
End if 

If ($lotStep.dateIn=!00-00-00!) || ($lotStep.dateOut=!00-00-00!)
	return $hours
End if 

$stmpIn:=cs:C1710.sfw_stmp.me.build($lotStep.dateIn; $lotStep.timeIn)
$stmpOut:=cs:C1710.sfw_stmp.me.build($lotStep.dateOut; $lotStep.timeOut)

If ($stmpOut<=$stmpIn)
	return $hours
End if 

$precision:=Storage:C1525.stmp.precisionSeconds
If ($precision=0)
	$precision:=1
End if 

$seconds:=($stmpOut-$stmpIn)*$precision
$hours:=Round:C94($seconds/3600; 2)

return $hours
