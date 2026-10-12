Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Bool:C1537(Form:C1466.readOnly))
			return 
		End if 
		$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.problemDate; OBJECT Get name:C1087(Object current:K67:2))  // the app's calendar
		
		If ($date#!00-00-00!)
			Form:C1466.problemDate:=$date
		End if 
End case 