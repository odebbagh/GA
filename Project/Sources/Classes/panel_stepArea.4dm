singleton Class constructor
	
	
Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of 
			: (FORM Get current page:C276(*)=1)
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	OBJECT SET ENTERABLE:C238(*; "entryField@"; Form:C1466.sfw.checkIsInModification())
	
