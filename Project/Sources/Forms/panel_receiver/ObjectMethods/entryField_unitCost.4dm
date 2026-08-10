
Case of 
	: (Form event code:C388=On Data Change:K2:15)
		If (Form:C1466.current_item.unitCost#0) & (Form:C1466.current_item.ourCount#0)
			Form:C1466.current_item.totalCharge:=Form:C1466.current_item.unitCost*Form:C1466.current_item.progressive
		Else 
			Form:C1466.current_item.totalCharge:=Form:C1466.current_item.unitCost*Form:C1466.current_item.ourCount
		End if 
		cs:C1710.panel_lot.me._activate_save_cancel_button()
End case 