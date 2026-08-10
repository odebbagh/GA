Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.searchItem:=""
		Form:C1466.copy:=New object:C1471("lb_values"; Form:C1466.lb_values)
		
		If (Not:C34(Undefined:C82(Form:C1466.windowTitle)))
			SET WINDOW TITLE:C213(Form:C1466.windowTitle)
		End if 
		
		If (Not:C34(Undefined:C82(Form:C1466.inputPlaceholder)))
			OBJECT SET PLACEHOLDER:C1295(*; "input_searchBox"; Form:C1466.inputPlaceholder)
		End if 
End case 