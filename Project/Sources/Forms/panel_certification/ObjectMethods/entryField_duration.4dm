// Purpose: Mark certification dirty when validity duration (days) is edited.
// modified by 4D/PS [2026-june-02]
If (Form:C1466.current_item#Null:C1517)
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
End if 
