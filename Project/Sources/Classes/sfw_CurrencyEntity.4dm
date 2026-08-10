Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	
	$nameInWindowTitle:=This:C1470.name
	
local Function afterCreation()
	// This callback is called after saving the new item
	ds:C1482.sfw_Currency.cacheClear()
	
local Function afterSave()
	// This callback is called after saving the current item
	ds:C1482.sfw_Currency.cacheClear()
	