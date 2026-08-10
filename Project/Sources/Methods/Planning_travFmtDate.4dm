//%attributes = {}
#DECLARE($date : Date)->$formatted : Text

If ($date=!00-00-00!)
	$formatted:=""
Else 
	$formatted:=String:C10($date; Internal date short:K1:7)
End if 

$formatted:=Planning_travSanitizeText($formatted)
