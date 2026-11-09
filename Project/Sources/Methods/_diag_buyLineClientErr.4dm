//%attributes = {}
// _diag_buyLineClientErr($errors) -> "OK" or the last error's message
// Used by _diag_buyLineClient right after a Try(): pass it Last errors.

#DECLARE($errors : Collection)->$msg : Text

If ($errors=Null:C1517) || ($errors.length=0)
	$msg:="OK"
Else
	$msg:=String:C10($errors[$errors.length-1].errCode)+" "+String:C10($errors[$errors.length-1].message)
End if
