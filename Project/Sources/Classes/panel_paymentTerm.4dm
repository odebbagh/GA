// panel_paymentTerm: one payment term (PaymentTerm). Plain fields only; the explanation under them
// says in a sentence what the term means.
singleton Class constructor


Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if

Function redrawAndSetVisible()
	// nothing to arrange: the explanation is a computed attribute bound in the form
