Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lot#Null:C1517)
			LotStepForm_saveLotPackageType(Form:C1466.current_item.lot)
		End if 
End case 
