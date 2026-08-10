Case of 
	: (Form event code:C388=On Before Keystroke:K2:6)
		Form:C1466.PreviousLimit:=Form:C1466.current_item.buyOrderLimit
	: (Form event code:C388=On Data Change:K2:15)
		If (Form:C1466.PreviousLimit#0)
			cs:C1710.panel_buyingOrder.me.changeBOLimit(Form:C1466.PreviousLimit; Form:C1466.current_item.buyOrderLimit)
		End if 
End case 
