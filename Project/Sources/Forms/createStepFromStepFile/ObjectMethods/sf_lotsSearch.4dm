Case of 
	: (FORM Event:C1606.code=-2000)
		//TRACE
		OBJECT SET VISIBLE:C603(*; "sf_lotsSearch"; False:C215)
		
		If (Form:C1466.sf_lotsSearch.selectedItem#Null:C1517)
			Form:C1466.searchLine:=Form:C1466.sf_lotsSearch.selectedItem.lotNumber
		End if 
		
	: (FORM Event:C1606.code=-3000)
		OBJECT SET VISIBLE:C603(*; "sf_lotsSearch"; False:C215)
		OBJECT SET SUBFORM:C1138(*; "sf_lotsSearch"; "")
End case 