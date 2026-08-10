If (SVG Find element ID by coordinates(*;"banner_lockedRecord";mouseX;mouseY)="locked")
	
	GET WINDOW RECT($gf;$hf;$df;$bf)
	OBJECT GET COORDINATES(*;"banner_lockedRecord";$gb;$hb;$db;$bb)
	
	$ref:=Open window($gf+$gb+mouseX-500;$hf+$hb+mouseY-330;$gf+$gb+mouseX;$hf+$hb+mouseY;Modal dialog box:K34:2)
	DIALOG("explo_locked_records")
	CLOSE WINDOW($ref)
	
End if 