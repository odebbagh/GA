//cs.panel_lead.me.btnDatePickerClose()
//cs.panel_lead.me.btnDatePickerCreate(Form.current_item; "dateClose"; False; 1)


If (Form:C1466.sfw.checkIsInModification())
	cs:C1710.panel_lead.me.btnDatePicker(Form:C1466.current_item; "dateClose")
End if 