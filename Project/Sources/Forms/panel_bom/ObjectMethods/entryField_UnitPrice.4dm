Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		$res:=Form:C1466.selectedItem.save()
		cs:C1710.panel_BOM.me._activate_save_cancel_button()
End case 