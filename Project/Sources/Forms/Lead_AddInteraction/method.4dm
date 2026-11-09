If (Form event code:C388=On Load:K2:1)
	cs:C1710.ga_followUps.me.drawDialog()  // filled by "Complete follow up": the pop-ups show their values
End if 
OBJECT SET ENABLED:C1123(*; "pup_contact"; Form:C1466.current_item.contacts().length>0)
