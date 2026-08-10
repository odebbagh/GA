Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.selectedProperty#Null:C1517)
			Form:C1466.stepRow.save()
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
		End if 
End case 