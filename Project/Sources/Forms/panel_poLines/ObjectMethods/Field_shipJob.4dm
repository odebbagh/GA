// Shipping Job is picked from the jobs attached to this line's purchase order,
// through the standard selectNto1 list (same pattern as the other job pickers).
Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.sfw.checkIsInModification())
			cs:C1710.panel_poLines.me.selectShipJob()
		End if

	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		// the field is bound to an expression, not a variable, so Self-> is not usable:
		// address the object by name instead
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "Field_shipJob"); 9000; 9019))

	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case
