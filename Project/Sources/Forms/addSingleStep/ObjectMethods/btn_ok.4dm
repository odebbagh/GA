Case of 
	: (Form event code:C388=On Clicked:K2:4)
		If (Form:C1466.stepProcessUUID=Null:C1517)
			cs:C1710.sfw_dialog.me.alert("Please select a step process.")
		Else If (Form:C1466.selectedStep=Null:C1517)
			cs:C1710.sfw_dialog.me.alert("Please select a step.")
		Else 
			ACCEPT:C269
		End if 
End case 
