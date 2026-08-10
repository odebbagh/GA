

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		OBJECT SET VISIBLE:C603(*; "fieldInputGroup"; Form:C1466.displayData)
		
		OBJECT SET VISIBLE:C603(*; "pup_fields"; Form:C1466.displayData)
		OBJECT SET VISIBLE:C603(*; "label"; Form:C1466.displayData)
		OBJECT SET VISIBLE:C603(*; "header_bkgd1"; Form:C1466.displayData)
		
		If (Not:C34(Form:C1466.displayData))
			Form:C1466.pup_fields.index:=-1
			Form:C1466.pup_fields.currentValue:=""
		End if 
		
End case 