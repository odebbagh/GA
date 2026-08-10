Case of 
	: (FORM Event:C1606.code=-2000)
		//TRACE
		OBJECT SET VISIBLE:C603(*; "sf_quotesSearch"; False:C215)
		
		If (Form:C1466.sf_quotesSearch.selectedItem#Null:C1517)
			Form:C1466.searchQuoteLine:=Form:C1466.sf_quotesSearch.selectedItem.description
			Form:C1466.poLine.description:=Form:C1466.sf_quotesSearch.selectedItem.description
			Form:C1466.poLine.qtyOrdered:=Form:C1466.sf_quotesSearch.selectedItem.quantity
			Form:C1466.poLine.unitPrice:=Form:C1466.sf_quotesSearch.selectedItem.unitPrice
		End if 
		
	: (FORM Event:C1606.code=-3000)
		OBJECT SET VISIBLE:C603(*; "sf_quotesSearch"; False:C215)
		OBJECT SET SUBFORM:C1138(*; "sf_quotesSearch"; "")
End case 