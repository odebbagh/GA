Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.current_item.customerSpecific)
			OBJECT SET VISIBLE:C603(*; "entryField_vendor"; True:C214)
			OBJECT SET VISIBLE:C603(*; "pup_customer"; False:C215)
		Else 
			OBJECT SET VISIBLE:C603(*; "pup_customer"; True:C214)
			OBJECT SET VISIBLE:C603(*; "entryField_vendor"; False:C215)
		End if 
End case 