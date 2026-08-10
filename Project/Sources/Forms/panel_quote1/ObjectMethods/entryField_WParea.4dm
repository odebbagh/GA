WP UpdateWidget("WPtoolbar"; "WParea")

Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		cs:C1710.panel_quote.me._activate_save_cancel_button()
End case 
