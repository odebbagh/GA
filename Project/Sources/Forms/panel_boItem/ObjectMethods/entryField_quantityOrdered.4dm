Case of
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.sfw.checkIsInModification())
			// quantity, unit price and the tax-inclusive price all feed the same
			// two-direction recalculation on the entity
			cs:C1710.panel_boItem.me.lineAmountChanged()
		End if
End case
