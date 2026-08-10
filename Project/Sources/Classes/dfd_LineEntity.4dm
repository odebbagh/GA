Class extends Entity


local Function duplicateRecord()
	// This callback is called to create a duplication of the current item.
	Form:C1466.current_item.name+=" (copy)"
	
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=This:C1470.name