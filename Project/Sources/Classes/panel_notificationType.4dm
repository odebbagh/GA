singleton Class constructor
	
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()
	
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
	
Function redrawAndSetVisible()
	OBJECT SET ENABLED:C1123(*; "cb_notificationActive"; sfw_checkIsInModification)