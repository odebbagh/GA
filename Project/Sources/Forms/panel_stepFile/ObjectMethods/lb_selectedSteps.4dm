Case of 
	: (FORM Event:C1606.code=On Selection Change:K2:29)
		cs:C1710.panel_stepFile.me.manageStepDefinitionEditor()
		cs:C1710.panel_stepFile.me.redrawAndSetVisible()
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Contextual click:C713))
			cs:C1710.panel_stepFile.me.manageReOrderBtns()
			cs:C1710.panel_stepFile.me.redrawAndSetVisible()
		End if 
	: (FORM Event:C1606.code=On Begin Drag Over:K2:44)
		Form:C1466.dragAndDrop:=New object:C1471("from"; Form:C1466.stepPos; "to"; 0)
	: (FORM Event:C1606.code=On Drop:K2:12)
		Form:C1466.dragAndDrop:=New object:C1471("from"; Form:C1466.stepPos; "to"; Drop position:C608)
		
		cs:C1710.panel_stepFile.me.btnReOrderSteps(Form:C1466.dragAndDrop.from; Form:C1466.dragAndDrop.to)
		
End case 