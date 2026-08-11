// Purpose: Normalize Certification.duration on import — legacy and CSV often store 0; default validity is 365 days.
// Parameters:
// $rawDuration : Integer — duration from source file (0 when missing or unset)
// $oneTime : Boolean — when True, catalog validity is cleared (returns 0)
// Returns: Integer — value to store in Certification.duration
// created by 4D/PS [2026-june-08]
#DECLARE($rawDuration : Integer; $oneTime : Boolean) -> $days : Integer

If ($oneTime)
	$days:=0
Else If ($rawDuration>0)
	$days:=$rawDuration
Else 
	$days:=365
End if 
