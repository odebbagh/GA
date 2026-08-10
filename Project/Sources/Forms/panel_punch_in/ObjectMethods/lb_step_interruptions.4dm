Case of 
	: (FORM Event:C1606.code=On Selection Change:K2:29)
		If (Form:C1466.stepInterruptionRow#Null:C1517)
			cs:C1710.panel_punch_in.me.displayDetailForm()
		Else 
			cs:C1710.panel_punch_in.me.hideDetailForm()
		End if 
End case 