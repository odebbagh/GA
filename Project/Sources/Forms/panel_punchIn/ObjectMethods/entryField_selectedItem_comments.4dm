$res:=Form:C1466.currentStep.save()

If ($res.success)
	cs:C1710.panel_punchIn.me._activate_save_cancel_button()
End if 
