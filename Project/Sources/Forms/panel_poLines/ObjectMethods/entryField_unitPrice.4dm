Case of
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.sfw.checkIsInModification())
			// quantity x unit price feeds saleTax/total, and the total feeds the
			// purchase order amount: recompute both from one place
			cs:C1710.panel_poLines.me.lineAmountChanged()
		End if
End case
