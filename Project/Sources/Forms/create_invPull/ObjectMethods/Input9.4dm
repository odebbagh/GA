Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.invPull.qtyToPull>Form:C1466.invPull.currentQty)
			Form:C1466.invPull.qtyToPull:=Form:C1466.invPull.currentQty
		End if 
End case 