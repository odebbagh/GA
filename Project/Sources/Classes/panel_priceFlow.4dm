// panel_priceFlow: a flow of the master price list (PriceFlow)
singleton Class constructor
	// It's a singleton class


Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if


Function redrawAndSetVisible()


	// one flow only is the default: the others are unmarked when this one is saved (PriceFlowEntity)
Function entryField_isDefault()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470._activate_save_cancel_button()
	End if

Function entryField_aliasesText()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470._activate_save_cancel_button()
	End if
