
Case of 
	: (Form event code:C388=On Load:K2:1)
		OBJECT SET ENABLED:C1123(*; "inp_qtyToPutBack"; False:C215)
		If (Form:C1466.inventoryDisplay=Null:C1517)
			Form:C1466.inventoryDisplay:=""
		End if 
		If (Form:C1466.qtyToPutBack=Null:C1517)
			Form:C1466.qtyToPutBack:=0
		End if 
		If (Form:C1466.performedBy=Null:C1517)
			Form:C1466.performedBy:=""
		End if 
End case 
