Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.step#Null:C1517)
			cs:C1710.panel_stepFile.me.syncStepSpecificationScalarsFromRow(Form:C1466.step)
			cs:C1710.panel_stepFile.me.drawSfSpecification()
			cs:C1710.panel_stepFile.me.refreshDerivedStepColumnsForCurrentStep()
		End if 
End case 
