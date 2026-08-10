Case of
	: (Form event code:C388=On Data Change:K2:15)
		// keep the quantity in sync with the SN selection
		Form:C1466.quantity:=Form:C1466.snItems.query("selected = :1"; True:C214).length
End case
