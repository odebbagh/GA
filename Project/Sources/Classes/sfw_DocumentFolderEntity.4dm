Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=This:C1470.name
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	
local Function itemReload()
	// This callback is executed when the current_item is reloaded. (click on buttons reload, cancel and save or after changing the mode)
	