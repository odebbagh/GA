Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		$result:=Form:C1466.current_interaction.save()
		If ($result.success)
			cs:C1710.panel_lead.me._activate_save_cancel_button()
			
		Else 
			ALERT:C41("Error")
		End if 
		
End case 
