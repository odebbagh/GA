// ============================================
// Class: panel_lotStep
// ============================================

singleton Class constructor
	// It's a singleton class


// ----------------------------------------------
// _activate_save_cancel_button
// ----------------------------------------------
Function _activate_save_cancel_button()
	Form.current_item.UUID:=Form.current_item.UUID

// ----------------------------------------------
// formMethod
// ----------------------------------------------
Function formMethod()
	// This function manages the main logic for updating and refreshing the form
	Form.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities
	If (Form.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary to refresh
		// Add refresh logic here if needed
	End if
	If (Form.sfw.recalculationOfPanelPageNeeded())  // A page is displayed so it's time to load the data sources
		Case of
			: (FORM Get current page(*)=1)
				// add load functions for page 1
		End case
	End if
	If (Form.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visibility
		This.redrawAndSetVisible()
	End if


// ----------------------------------------------
// redrawAndSetVisible
// ----------------------------------------------
Function redrawAndSetVisible()
	// Adjusts the layout and visibility of form elements based on the current page and modification state to be implemented

