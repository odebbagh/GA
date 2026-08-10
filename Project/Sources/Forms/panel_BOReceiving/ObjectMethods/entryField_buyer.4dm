Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		cs:C1710.panel_BOReceiving.me.selectBuyerStaff()
		
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		If (Form:C1466.sfw.checkIsInModification())
			SET CURSOR:C469(9000)
		End if 
End case 
