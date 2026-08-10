Case of
	: (FORM Event:C1606.code=On Selection Change:K2:29)
		If (Form:C1466.consumedPartsRow#Null:C1517)
			cs:C1710.panel_punch_in.me.displayConsumedPartsDF()
		Else
			cs:C1710.panel_punch_in.me.hideConsumedPartsDF()
		End if
End case
