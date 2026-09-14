// Purpose: Mark certification dirty when annual retrain checkbox is edited; clear oneTime when a frequency is enabled.
// modified by 4D/PS [2026-june-08]
If (Form:C1466.current_item#Null:C1517)
	If (Form:C1466.current_item.retrainAnnually) && (Form:C1466.current_item.oneTime)
		Form:C1466.current_item.oneTime:=False:C215
	End if 
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
End if 
