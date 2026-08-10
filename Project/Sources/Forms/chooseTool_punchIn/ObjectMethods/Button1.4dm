Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.selectedTool#Null:C1517)
			ACCEPT:C269
		Else 
			cs:C1710.sfw_dialog.me.alert("No Tool Selected !")
		End if 
End case 