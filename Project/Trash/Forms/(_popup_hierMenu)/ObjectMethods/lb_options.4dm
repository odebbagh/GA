Case of 
	: (Form event code:C388=On Clicked:K2:4)
		If (Form.currentItem#Null:C1517)
			If (Form.currentItem.kind#"separator")
				Form.choice:=Form.currentItem.value
				ACCEPT:C269
			End if 
		End if 
End case 
