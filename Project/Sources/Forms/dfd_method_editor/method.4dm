Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		If (Form:C1466.method=Null:C1517)
			Form:C1466.method:=""
		End if 
		GOTO OBJECT:C206(*; "inputMethod")
		HIGHLIGHT TEXT:C210(*; "inputMethod"; 0; 0)
End case 
