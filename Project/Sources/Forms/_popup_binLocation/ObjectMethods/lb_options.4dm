Case of 
	: (Form event code:C388=On Clicked:K2:4)
		If (Form:C1466.currentItem#Null:C1517)
			If (Form:C1466.currentItem.kind#"separator") & (Form:C1466.currentItem.kind#"divider") & (Form:C1466.currentItem.value#"")
				Form:C1466.choice:=Form:C1466.currentItem.value
				ACCEPT:C269
			End if 
		End if 
End case 
