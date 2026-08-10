

Case of 
		
	: (Form event code:C388=On Load:K2:1)
		
		Form:C1466.displayData:=False:C215
		
		OBJECT SET VISIBLE:C603(*; "fieldInputGroup"; False:C215)
		OBJECT SET VISIBLE:C603(*; "pup_fields"; Form:C1466.displayData)
		OBJECT SET VISIBLE:C603(*; "label"; Form:C1466.displayData)
		OBJECT SET VISIBLE:C603(*; "header_bkgd1"; Form:C1466.displayData)
		
		
		Form:C1466.pup_fields:=New object:C1471
		Form:C1466.pup_fields.values:=New collection:C1472
		Form:C1466.pup_fields.values:=Form:C1466.fieldsNames
		Form:C1466.pup_fields.index:=-1
		Form:C1466.pup_fields.currentValue:=""  //Form.pup_fields.values[0]
		
	Else 
		
End case 