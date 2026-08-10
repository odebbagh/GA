Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.sfw.checkIsInModification())
			cs:C1710.panel_poLines.me._activate_save_cancel_button()
		End if
End case
