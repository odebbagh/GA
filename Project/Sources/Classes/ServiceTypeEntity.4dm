Class extends Entity

local Function get colorPicto()->$picto : Picture
	
	$color:=cs:C1710.sfw_htmlColor.me.getName(This:C1470.color)
	READ PICTURE FILE:C678(Folder:C1567(fk resources folder:K87:11).file("sfw/colors/"+$color+".png").platformPath; $picto)
	
	
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.name