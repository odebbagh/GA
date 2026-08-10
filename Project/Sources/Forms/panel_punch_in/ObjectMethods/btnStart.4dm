Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			return 
		End if 
		If (Not:C34(cs:C1710.panel_punch_in.me.canEditPanelFields()))
			return 
		End if 
		
		Form:C1466.current_item.dateIn:=Current date:C33(*)
		Form:C1466.current_item.timeIn:=Current time:C178(*)
		LotStep_updateActHours(Form:C1466.current_item)
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
End case 
