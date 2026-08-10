// PO Number is picked from the PurchaseOrder table through the standard selectNto1
// list. The field itself is never keyed in: it displays purchaseOrder.poNum.
Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.sfw.checkIsInModification())
			cs:C1710.panel_poLines.me.selectPurchaseOrder()
		End if

	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		// the field is bound to an expression, not a variable, so Self-> is not usable:
		// address the object by name instead
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "Field_poNum"); 9000; 9019))

	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case
