Case of 
	: (Form event code:C388=On AfterEdit:K2:28)
		If (Form:C1466.qtyToPutBack>Form:C1466.maxQty)
			Form:C1466.qtyToPutBack:=Form:C1466.maxQty
		End if 
		If (Form:C1466.qtyToPutBack<0)
			Form:C1466.qtyToPutBack:=0
		End if 
End case 
