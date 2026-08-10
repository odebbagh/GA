//cs.panel_lead.me.btnDatePickerCreate(Form.current_interaction; "stmpFollowUp"; True; 1)

//Form.current_interaction.save()
//Form.current_interaction.reload()
cs:C1710.panel_lead.me._activate_save_cancel_button()


If (Form:C1466.sfw.checkIsInModification())
	cs:C1710.panel_lead.me.btnDatePicker(Form:C1466.current_interaction; "followUPDate")
	cs:C1710.panel_lead.me._activate_save_cancel_button()
End if 
