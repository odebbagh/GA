cs:C1710.panel_punch_in.me.formMethod()

If (Form event code:C388=On Load:K2:1)
	If (String:C10(Form:C1466.stepInterruptionStartTimeDisplay)="")
		Form:C1466.stepInterruptionStartTimeDisplay:="00:00"
	End if 
	If (String:C10(Form:C1466.stepInterruptionEndTimeDisplay)="")
		Form:C1466.stepInterruptionEndTimeDisplay:="00:00"
	End if 
	cs:C1710.panel_punch_in.me.initStepInterruptionRowTimes()
End if 
