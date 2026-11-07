// Purpose: Shared click handler for the Shift 1 / Shift 2 radio group.
// Writes "1" or "2" into Form.current_item.shift based on which radio raised the click,
// then activates the save/cancel buttons via the panel singleton.
// created by 4D/PS [2026-may-21]
// modified by 4D/PS [2026-october-09]

Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			Form:C1466.shift1:=(Form:C1466.current_item.shift="1")
			return 
		End if 
		Form:C1466.current_item.shift:=(FORM Event:C1606.objectName="entryField_shift1") ? "1" : "2"
		cs:C1710.panel_staff.me._activate_save_cancel_button()
End case 
