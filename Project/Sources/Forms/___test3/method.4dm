Case of 
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.selectedPath:=""
		Form:C1466.bins:=ds:C1482.Bin.all()
		OBJECT SET TITLE:C194(*; "pup_level1"; "Choose location")
	: (Form event code:C388=On Close Box:K2:21)
		CANCEL:C270
End case 
