$uuid:=cs:C1710.panel_lead.me.pup_interaction("method"; String:C10(Form:C1466.current_interaction.UUID_Method))
If ($uuid#"")
	Form:C1466.current_interaction.UUID_Method:=$uuid
	Form:C1466.current_interaction.save()
	cs:C1710.panel_lead.me._activate_save_cancel_button()
End if 


