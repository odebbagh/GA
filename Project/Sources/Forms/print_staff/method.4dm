Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.order:=0
	: (FORM Event:C1606.code=On Printing Detail:K2:18)
		Form:C1466.order:=Form:C1466.order+1
End case 