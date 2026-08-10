

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.allItems:=Form:C1466.lb_items
		
	: (FORM Event:C1606.code=On Timer:K2:25)
		If (String:C10(Form:C1466.search)#"")
			Form:C1466.lb_items:=Form:C1466.allItems.query("value == :1"; "@"+Form:C1466.search+"@")
		Else 
			Form:C1466.lb_items:=Form:C1466.allItems
		End if 
		
		SET TIMER:C645(0)
End case 
