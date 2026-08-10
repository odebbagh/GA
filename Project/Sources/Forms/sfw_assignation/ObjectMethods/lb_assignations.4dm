Case of 
	: (FORM Event:C1606.code=On Selection Change:K2:29) && (FORM Get current page:C276=1)
		
		SET TIMER:C645(-1)
		
	: (FORM Event:C1606.code=On Selection Change:K2:29) && (FORM Get current page:C276=2)
		
		LISTBOX SELECT ROW:C912(*; FORM Event:C1606.objectName; 0; lk remove from selection:K53:3)
		
End case 
