Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.selectedProperty#Null:C1517)
			// SNA / SNF ticked or unticked: the step gets or loses the lot's serial numbers
			If (New collection:C1472("SNA"; "SNF").indexOf(String:C10(Form:C1466.selectedProperty.name))#-1)
				cs:C1710.ga_serialization.me.syncStep(Form:C1466.current_item; Form:C1466.stepRow)
			End if 
			Form:C1466.stepRow.save()
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
		End if 
End case 