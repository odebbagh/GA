Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		If (Form:C1466.readOnly=Null:C1517)
			Form:C1466.readOnly:=False:C215
		End if 
		LotHoldForm_applyReadOnlyMode
End case 
