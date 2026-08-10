Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		cs:C1710.panel_lot.me.manageReOrderBtns()
		
	: (FORM Event:C1606.code=On Begin Drag Over:K2:44)
		Form:C1466.dragAndDrop:=New object:C1471("from"; Form:C1466.selectedLotPos; "to"; 0)
	: (FORM Event:C1606.code=On Drop:K2:12)
		Form:C1466.dragAndDrop:=New object:C1471("from"; Form:C1466.selectedLotPos; "to"; Drop position:C608)
		
		cs:C1710.panel_lot.me.btnReOrderLots(Form:C1466.dragAndDrop.from; Form:C1466.dragAndDrop.to)
		
End case 