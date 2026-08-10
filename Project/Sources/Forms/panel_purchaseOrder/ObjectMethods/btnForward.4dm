Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		cs:C1710.panel_purchaseOrder.me.btnOpenCustomer()
		
	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(Self:C308->); 9000; 9019))
		
	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case 