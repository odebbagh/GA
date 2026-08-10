//%attributes = {}
WINDOW LIST:C442($_refWindows; *)
If (cs:C1710.sfw_eventManager.me.window=0) || (Find in array:C230($_refWindows; This:C1470.window)<0)
	$ref:=Open form window:C675("sfw_eventPalette"; Palette form window:K39:9; On the right:K39:3; At the bottom:K39:6)
	cs:C1710.sfw_eventManager.me.setWindow($ref)
	DIALOG:C40("sfw_eventPalette"; *)
End if 

