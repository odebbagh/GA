// Start: the operator punching in (mandatory), the date and time in, and the Qty In proposed from
// the lot's progress count when it is still empty (it stays editable)
var $staff : 4D:C1709.Entity
	
Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			return 
		End if 
		If (Not:C34(cs:C1710.panel_punch_in.me.canEditPanelFields()))
			return 
		End if 
		$staff:=cs:C1710.ga_operator.me.ask()
		If ($staff=Null:C1517)
			return 
		End if 
		Form:C1466.current_item.inOperator:=$staff.code
		Form:C1466.current_item.dateIn:=Current date:C33(*)
		Form:C1466.current_item.timeIn:=Current time:C178(*)
		LotStep_updateActHours(Form:C1466.current_item)
		If (Num:C11(Form:C1466.current_item.qtyIn)=0)
			Form:C1466.current_item.qtyIn:=Form:C1466.current_item.defaultQtyIn()
			cs:C1710.panel_punch_in.me.checkSnCountAtPunchIn()
		End if 
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
End case 
