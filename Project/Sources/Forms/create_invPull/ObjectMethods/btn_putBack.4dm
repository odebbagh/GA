Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		Form:C1466.invPull.isPull:=False:C215
		FORM GOTO PAGE:C247(2)
		
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469((OBJECT Get enabled:C1079(Self:C308->)) ? 9000 : 9019)
End case 