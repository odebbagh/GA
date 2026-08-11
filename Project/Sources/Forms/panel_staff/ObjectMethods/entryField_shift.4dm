// Purpose: Shared click handler for the Shift 1 / Shift 2 radio group.
// Writes "1" or "2" into Form.current_item.shift based on which radio raised the click,
// then activates the save/cancel buttons via the panel singleton.
// created by 4D/PS [2026-may-21]

Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		Form:C1466.current_item.shift:=(FORM Event:C1606.objectName="entryField_shift1") ? "1" : "2"
		cs:C1710.panel_staff.me._activate_save_cancel_button()
End case 
