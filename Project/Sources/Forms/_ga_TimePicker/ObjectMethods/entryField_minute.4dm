Case of 
		
	: (Form event code:C388=On Data Change:K2:15)
		
		If (Num:C11(Form:C1466.minute)>59)
			Form:C1466.minute:="00"
		End if 
		
		
	Else 
		
		
End case 