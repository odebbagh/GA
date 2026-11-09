// Comments of a unit on the lot's table. The steps keep their own comments (why a unit failed
// there), so this one is not copied to them. Touching the table lets Save see the change.
Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		Form:C1466.current_item.snTable:=Form:C1466.current_item.snTable
		cs:C1710.panel_planning.me._activate_save_cancel_button()
End case 
