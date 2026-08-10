Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			Form:C1466.current_item.onHold:=Not:C34(Form:C1466.current_item.onHold)  // revert
			return 
		End if 
		// Revert the checkbox — the dialog will set the real value
		Form:C1466.current_item.onHold:=Not:C34(Form:C1466.current_item.onHold)
		cs:C1710.panel_planning.me.holdLotAction(Choose:C955(Form:C1466.current_item.onHold; "off"; "on"))
End case 
