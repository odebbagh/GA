Class extends Entity


local Function duplicateRecord()
	// This callback is called to create a duplication of the current item.
	Form:C1466.current_item.name+=" (copy)"
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=This:C1470.name
	
	
	
local Function isDeletable()->$isDeletable : Boolean
	// This callback must return false to inactivate the deletion mode for the current item.
	If (This:C1470.documents.length=0)
		$isDeletable:=True:C214
	Else 
		$isDeletable:=False:C215
	End if 
	