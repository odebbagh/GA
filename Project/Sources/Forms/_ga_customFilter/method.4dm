// Purpose: Year / value picker list used by Util.setYearPicker.
// created by 4D/PS [2026-june-08]
// modified by 4D/PS [2026-october-05]
Case of 
	: (Form event code:C388=On Load:K2:1)
		LISTBOX SET ROWS HEIGHT:C835(*; "List Box"; 25)
		Form:C1466.selected:=New object:C1471("value"; "")
	Else 
End case
