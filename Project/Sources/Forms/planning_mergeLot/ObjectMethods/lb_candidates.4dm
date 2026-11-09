Case of 
	: (Form event code:C388=On Selection Change:K2:29)
		Case of 
			: (Form:C1466.selected=Null:C1517)
				Form:C1466.selectedMessage:=""
			: (Not:C34(Bool:C1537(Form:C1466.selected.allowed)))
				Form:C1466.selectedMessage:="BLOCKED: "+String:C10(Form:C1466.selected.message)
			: (String:C10(Form:C1466.selected.message)="")
				Form:C1466.selectedMessage:="OK: lot "+String:C10(Form:C1466.selected.lotNumber)+" ("+String:C10(Form:C1466.selected.ourCount)+" item(s)) can be merged."
			Else 
				Form:C1466.selectedMessage:="WARNING (you can still merge):\r"+String:C10(Form:C1466.selected.message)
		End case 
End case 
