// Purpose: Verified By is free text (GoldenAltos / legacy [QCARS]Verify_by), not a staff picker.
// created by 4D/PS [2026-october-05]
If (FORM Event:C1606.code=On Data Change:K2:15)
	cs:C1710.panel_qcar.me._activate_save_cancel_button()
End if
