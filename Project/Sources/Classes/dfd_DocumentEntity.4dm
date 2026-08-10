Class extends Entity


Function get date()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmp || 0)
	
local Function duplicateRecord()
	// This callback is called to create a duplication of the current item.
	Form:C1466.current_item.name+=" (copy)"
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	// With this callback you return the name to displayed in the title of the window for the current item
	$nameInWindowTitle:=This:C1470.name
	
	
local Function beforeSaveCreation()
	// This callback is called before saving the new item
	If (cs:C1710.sfw_userManager.me.info.UUID#Null:C1517)
		This:C1470.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
	End if 
	This:C1470.stmp:=cs:C1710.sfw_stmp.me.now()
	