Class extends Entity

// Purpose: ControllingDepartment lookup row (Administration → Controlling departments).
// created by 4D/PS [2026-october-09]
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.name
	
	
local Function get colorPicto()->$picto : Picture
	$color:=cs:C1710.sfw_htmlColor.me.getName(This:C1470.color)
	If ($color#"")
		READ PICTURE FILE:C678(Folder:C1567(fk resources folder:K87:11).file("sfw/colors/"+$color+".png").platformPath; $picto)
	End if 
	
	
local Function loadAfterCreation()
	cs:C1710.Util.me.initListRow(This:C1470; "ControllingDepartment")
