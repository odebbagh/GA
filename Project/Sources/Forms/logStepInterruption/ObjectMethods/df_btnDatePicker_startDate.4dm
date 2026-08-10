Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		OBJECT GET COORDINATES:C663(Self:C308->; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($r; $b; XY Current form:K27:5; XY Main window:K27:8)
		$date:=DatePicker Display Dialog($r-30; $b-125)
		
		If ($date#!00-00-00!)
			Form:C1466.start_date:=$date
		End if 
End case 