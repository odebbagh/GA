Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		OBJECT GET COORDINATES:C663(Self:C308->; $l; $t; $r; $b)
		$iconHeight:=$b-$t
		$pickerX:=$l+1
		$pickerY:=$t-($iconHeight*2)-11
		CONVERT COORDINATES:C1365($pickerX; $pickerY; XY Current form:K27:5; XY Main window:K27:8)
		$date:=DatePicker Display Dialog($pickerX; $pickerY)
		
		If ($date#!00-00-00!)
			Form:C1466.toolDefinition.date:=$date
		End if 
End case 
