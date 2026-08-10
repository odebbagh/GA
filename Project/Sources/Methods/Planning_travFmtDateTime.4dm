//%attributes = {}
#DECLARE($date : Date; $time : Time)->$formatted : Text

If ($date=!00-00-00!)
	$formatted:=""
Else 
	// Dash format avoids Print form treating slashes as division in input dataSource.
	$formatted:=String:C10($date; Internal date short:K1:7)
	If ($time#?00:00:00?)
		$formatted:=$formatted+" "+String:C10($time; HH MM:K7:2)
	End if 
End if 

$formatted:=Planning_travSanitizeText($formatted)
