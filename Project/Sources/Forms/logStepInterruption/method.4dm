
If (Form event code:C388=On Load:K2:1)
	If (String:C10(Form:C1466.start_time)="")
		Form:C1466.start_time:="00:00"
	End if
	If (String:C10(Form:C1466.end_time)="")
		Form:C1466.end_time:="00:00"
	End if
End if
