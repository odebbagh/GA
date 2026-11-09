// the quantity brought back into stock: no upper limit (a correction up), never below zero
Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Num:C11(Form:C1466.invPull.qtyToPull)<0)
			Form:C1466.invPull.qtyToPull:=0
		End if 
End case 
