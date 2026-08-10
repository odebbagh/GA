Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.sfw.checkIsInModification())
			cs:C1710.panel_stepTemplate.me._activate_save_cancel_button()
		End if 
End case 
