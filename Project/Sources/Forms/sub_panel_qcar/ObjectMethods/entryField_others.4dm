If (FORM Event:C1606.code=On Load:K2:1) | (FORM Event:C1606.code=On Clicked:K2:4)
	If (Form:C1466#Null:C1517)
		OBJECT SET VISIBLE:C603(*; "entryField_othersText"; Form:C1466.correctiveActionReport.others)
		OBJECT SET ENTERABLE:C238(*; "entryField_othersText"; Form:C1466.correctiveActionReport.others)
		
		If (Not:C34(Form:C1466.correctiveActionReport.others))
			Form:C1466.correctiveActionReport.othersText:=""
		End if 
	End if 
End if 