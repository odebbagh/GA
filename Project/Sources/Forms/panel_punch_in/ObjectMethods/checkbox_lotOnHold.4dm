Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			Form:C1466.current_item.lot.onHold:=Not:C34(Form:C1466.current_item.lot.onHold)  // revert
			return 
		End if 
		// Revert the checkbox — the dialog will set the real value
		Form:C1466.current_item.lot.onHold:=Not:C34(Form:C1466.current_item.lot.onHold)
		cs:C1710.panel_punch_in.me.holdLotAction(Choose:C955(Form:C1466.current_item.lot.onHold; "off"; "on"))
End case 
