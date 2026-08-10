Case of 
	: (Form event code:C388=On Load:K2:1)
		OBJECT SET RGB COLORS:C628(*; "bManualEntry"; Black:K11:16; Grey:K11:15)
		
	: (Form event code:C388=On Clicked:K2:4)
		Form:C1466.manualEntry:=True:C214
		ACCEPT:C269
		ON EVENT CALL:C190("")
End case 
