//%attributes = {}
//BackgroundColor lb_bins baesd on bin type
//"Good"; "Rejects"; "Mechanical Rejects"; "Missing or Excluded"

Case of 
		
	: (This:C1470.type="Good")
		$0:="#CDEFE2"
	: (This:C1470.type="Rejects")
		$0:="#FBD6D1"
	: (This:C1470.type="Mechanical Rejects")
		$0:="#FBD6D1"
	: (This:C1470.type="Missing or Excluded")
		$0:="#FFE4BF"
	Else 
		$0:="transparent"
End case 
