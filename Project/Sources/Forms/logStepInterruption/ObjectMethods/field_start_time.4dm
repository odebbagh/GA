
If (FORM Event:C1606.code=On Losing Focus:K2:8)
	$raw:=Form:C1466.start_time
	// Strip everything except digits
	$digits:=""
	For ($i; 1; Length:C16($raw))
		$ch:=Substring:C12($raw; $i; 1)
		If ($ch>="0") & ($ch<="9")
			$digits:=$digits+$ch
		End if 
	End for 
	// Pad to 4 digits: left-pad hours, right-pad minutes
	Case of 
		: (Length:C16($digits)=0)
			$hh:="00"
			$mm:="00"
		: (Length:C16($digits)=1)
			$hh:="0"+$digits
			$mm:="00"
		: (Length:C16($digits)=2)
			$hh:=$digits
			$mm:="00"
		: (Length:C16($digits)=3)
			$hh:=Substring:C12($digits; 1; 2)
			$mm:=Substring:C12($digits; 3; 1)+"0"
		Else 
			$hh:=Substring:C12($digits; 1; 2)
			$mm:=Substring:C12($digits; 3; 2)
	End case 
	Form:C1466.start_time:=$hh+":"+$mm
End if 
