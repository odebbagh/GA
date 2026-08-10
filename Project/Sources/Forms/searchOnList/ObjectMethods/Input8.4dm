Case of 
	: (FORM Event:C1606.code=On After Keystroke:K2:26)
		Form:C1466.lb_values:=Form:C1466.copy.lb_values.query(Form:C1466.colName+" = :1"; "@"+Get edited text:C655+"@").orderBy(Form:C1466.colName+" asc")
End case 