Case of 
	: (Form event code:C388=On AfterEdit:K2:28)
		If (Form:C1466.qtyToPull>Form:C1466.availableQty)
			Form:C1466.qtyToPull:=Form:C1466.availableQty
		End if 
		If (Form:C1466.qtyToPull<0)
			Form:C1466.qtyToPull:=0
		End if 
End case 
