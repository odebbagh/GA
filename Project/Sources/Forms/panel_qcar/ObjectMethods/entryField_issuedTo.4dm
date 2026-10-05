// Purpose: Issued To is a free-text addressee (legacy [QCARS]Issued_to), not a staff name.
// created by 4D/PS [2026-october-05]
If (FORM Event:C1606.code=On Data Change:K2:15)
	cs:C1710.panel_qcar.me._activate_save_cancel_button()
End if
