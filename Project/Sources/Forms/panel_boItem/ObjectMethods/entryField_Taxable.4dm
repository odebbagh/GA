Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.sfw.checkIsInModification())
			// taxable decides whether tax is added at all, and in VAT mode the entity
			// forces it back on - so it recalculates through the same path
			cs:C1710.panel_boItem.me.lineAmountChanged()
		End if
End case
