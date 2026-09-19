singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	//Touching the primary key marks the entity as touched so sfw enables Save/Cancel
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				//nothing to load: the Write Pro zone is bound straight to current_item.content
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	//The Write Pro zone and its toolbar follow the panel through sizingX/sizingY "grow"
	
Function wpContent()
	//Keeps the Write Pro widget toolbar in sync with the zone and flags the record as modified
	WP UpdateWidget("WPtoolbar"; "entryField_wpContent")
	
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			This:C1470._activate_save_cancel_button()
	End case 
