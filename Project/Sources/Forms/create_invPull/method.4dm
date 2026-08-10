Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		If (Undefined:C82(Form:C1466.onlyPull))
			If (Not:C34(Form:C1466.invPull.isPull))
				FORM GOTO PAGE:C247(2)
			End if 
		Else 
			OBJECT SET ENABLED:C1123(*; "btn_putBack"; False:C215)
		End if 
End case 