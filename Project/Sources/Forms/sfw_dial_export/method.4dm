Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		OBJECT SET TITLE:C194(*; "pup_folder"; Form:C1466.folderToExport.name)
		
End case 


If (Form:C1466.bPasteboard=1)
	Form:C1466.bTTR:=1
	Form:C1466.bCSV:=0
	Form:C1466.bXLS:=0
End if 
OBJECT SET ENABLED:C1123(*; "bTTR"; (Form:C1466.bPasteboard=0))
OBJECT SET ENABLED:C1123(*; "bCSV"; (Form:C1466.bPasteboard=0))
OBJECT SET ENABLED:C1123(*; "bCSV"; (Form:C1466.bPasteboard=0))
OBJECT SET ENABLED:C1123(*; "bOpen"; (Form:C1466.bPasteboard=0))
OBJECT SET ENABLED:C1123(*; "bShow"; (Form:C1466.bPasteboard=0))
OBJECT SET ENTERABLE:C238(*; "fileName"; (Form:C1466.bPasteboard=0))
OBJECT SET ENABLED:C1123(*; "pup_folder"; (Form:C1466.bPasteboard=0))


OBJECT SET ENABLED:C1123(*; "bXLS"; False:C215)
