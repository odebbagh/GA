Case of 
	: (Form event code:C388=On Load:K2:1)
		If (Form:C1466.toolDefinition=Null:C1517)
			Form:C1466.toolDefinition:=New object:C1471("name"; ""; "date"; Current date:C33())
		End if 
		If (Form:C1466.toolDefinition.date=Null:C1517)
			Form:C1466.toolDefinition.date:=Current date:C33()
		End if 
End case 
