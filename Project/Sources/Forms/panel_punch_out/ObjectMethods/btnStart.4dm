// Start: the operator punching out (mandatory) and the date and time out
var $staff : 4D:C1709.Entity
	
Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			return 
		End if 
		If (Not:C34(cs:C1710.panel_punch_out.me.canEditPanelFields()))
			return 
		End if 
		$staff:=cs:C1710.ga_operator.me.ask()
		If ($staff=Null:C1517)
			return 
		End if 
		Form:C1466.current_item.outOperator:=$staff.code
		Form:C1466.current_item.dateOut:=Current date:C33(*)
		Form:C1466.current_item.timeOut:=Current time:C178(*)
		LotStep_updateActHours(Form:C1466.current_item)
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
End case 
