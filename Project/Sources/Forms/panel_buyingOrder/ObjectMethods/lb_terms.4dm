Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.selectedTerm#Null:C1517)
			wpArea:=Form:C1466.current_item[Form:C1466.selectedTerm.type]
		End if 
End case 