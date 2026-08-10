//%attributes = {}


If (cs:C1710.sfw_commentManager.me.window=0)
	$ref:=Open form window:C675("sfw_commentPalette"; Palette form window:K39:9; On the right:K39:3; At the top:K39:5)
	cs:C1710.sfw_commentManager.me.setWindow($ref)
	DIALOG:C40("sfw_commentPalette"; *)
End if 