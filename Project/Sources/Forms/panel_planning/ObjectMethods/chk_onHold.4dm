//Case of 
//: (FORM Event.code=On Clicked)
//If (Not(Form.sfw.checkIsInModification()))
//Form.current_item.onHold:=Not(Form.current_item.onHold)  // revert
//return 
//End if 
//// Revert the checkbox — the dialog will set the real value
//Form.current_item.onHold:=Not(Form.current_item.onHold)
//cs.panel_planning.me.holdLotAction(Choose(Form.current_item.onHold; "Hold OFF"; "Hold ON"))
//End case 
