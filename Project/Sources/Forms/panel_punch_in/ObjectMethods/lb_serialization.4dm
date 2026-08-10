Case of 
	: ((FORM Event:C1606.code=On Clicked:K2:4) | (FORM Event:C1606.code=On Selection Change:K2:29))
		If (Form:C1466.snItem#Null:C1517)
			cs:C1710.panel_punch_in.me.displaySerializationDetailForm()
		Else 
			cs:C1710.panel_punch_in.me.hideSerializationDetailForm()
		End if 
End case 

