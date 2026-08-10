Case of 
	: (Form event code:C388=On Data Change:K2:15)
		If (This:C1470.snAtPunchIn=This:C1470.snAtPunchOut) & (This:C1470.snAtPunchIn) & (This:C1470.snAtPunchOut)
			This:C1470.snAtPunchOut:=Not:C34(This:C1470.snAtPunchOut)
		End if 
End case 