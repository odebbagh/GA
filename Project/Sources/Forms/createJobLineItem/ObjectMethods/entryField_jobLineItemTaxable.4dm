Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		
		Form:C1466.lineItem.lineTotal:=(Form:C1466.lineItem.quantity*Form:C1466.lineItem.unitPrice)+((Form:C1466.lineItem.quantity*Form:C1466.lineItem.unitPrice)*\
			(Form:C1466.jobTaxRate/100)*Num:C11(Form:C1466.lineItem.taxable))
		
		
	Else 
		
		
End case 