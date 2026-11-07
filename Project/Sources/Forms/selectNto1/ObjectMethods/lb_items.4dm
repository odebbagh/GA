
// Purpose: Double-click on a blank listbox row must not accept a Null item.
// modified by 4D/PS [2026-october-05]

Case of 
	: (FORM Event:C1606.code=On Double Clicked:K2:5)
		If (Form:C1466.item#Null:C1517)
			ACCEPT:C269
		End if 
		
End case 
