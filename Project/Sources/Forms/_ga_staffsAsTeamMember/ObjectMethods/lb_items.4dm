
var $col; $row : Integer

Case of 
	: (Form event code:C388=On Clicked:K2:4)
		// Toggle by clicking the name/title columns. The checkbox column already writes This.selected.
		If (Form:C1466.currentStaff#Null:C1517)
			LISTBOX GET CELL POSITION:C971(*; "lb_items"; $col; $row)
			If ($col>1)
				Form:C1466.currentStaff.selected:=Not:C34(Bool:C1537(Form:C1466.currentStaff.selected))
			End if 
		End if 
		
End case 
