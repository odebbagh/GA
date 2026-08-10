Case of 
	: (FORM Event:C1606.code=On After Keystroke:K2:26)
		Form:C1466.lb_values:=Form:C1466.copy.lb_values.query("description = :1"; "@"+Get edited text:C655+"@")
End case 