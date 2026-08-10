
If ((FORM Event:C1606.code=On Data Change:K2:15) | (FORM Event:C1606.code=On Losing Focus:K2:8))
	If (Form:C1466.stepInterruptionRow=Null:C1517)
		return 
	End if 
	
	Form:C1466.stepInterruptionStartTimeDisplay:=cs:C1710.panel_punch_in.me.formatInterruptionTimeOnLosingFocus(Form:C1466.stepInterruptionStartTimeDisplay)
	Form:C1466.stepInterruptionRow.start_time:=Time:C179(Form:C1466.stepInterruptionStartTimeDisplay)
End if 
