// Purpose: Same as v18 — checking PM not required sets Next PM to 2099-12-31.
// created by 4D/PS [2026-november-03]
If (FORM Event:C1606.code=On Clicked:K2:4)
	cs:C1710.panel_equipment.me._applyPmNotRequired()
End if
