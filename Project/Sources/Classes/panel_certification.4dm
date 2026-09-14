
singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	
	var $inModification : Boolean
	
	$inModification:=Form:C1466.sfw.checkIsInModification()
	OBJECT SET ENABLED:C1123(*; "entryField_ref"; $inModification)
	OBJECT SET ENABLED:C1123(*; "entryField_name"; $inModification)
	// Purpose: Duration is assignment validity in days (editable); independent of re-training frequency checkboxes.
	// modified by 4D/PS [2026-june-02]
	OBJECT SET ENABLED:C1123(*; "entryField_duration"; $inModification && Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENABLED:C1123(*; "cb_freqQuarterly"; $inModification && Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENABLED:C1123(*; "cb_freqHalfYear"; $inModification && Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENABLED:C1123(*; "cb_freqAnnually"; $inModification && Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENTERABLE:C238(*; "cb_freqQuarterly"; $inModification && Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENTERABLE:C238(*; "cb_freqHalfYear"; $inModification && Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENTERABLE:C238(*; "cb_freqAnnually"; $inModification && Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENABLED:C1123(*; "entryField_oneTime"; $inModification)
	OBJECT SET ENTERABLE:C238(*; "entryField_oneTime"; $inModification)
	
	
// Purpose: One time clears frequencies; selecting a frequency clears one time (Karla 2.f).
// modified by 4D/PS [2026-june-02]
Function cb_oneTime()
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	Form:C1466.current_item.applyOneTimeRule(Form:C1466.current_item.oneTime)
	This:C1470.redrawAndSetVisible()
	This:C1470._activate_save_cancel_button()
	
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	