Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (String:C10(Form:C1466.staffCode)="")
			cs:C1710.sfw_dialog.me.alert("Please identify who performed the hold action.")
		Else 
			ACCEPT:C269
		End if 
End case 
