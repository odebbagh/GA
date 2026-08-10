//%attributes = {}
/*
_ga_searchByBarcodeScanning
*/

Form:C1466.sfw.searchbox:=cs:C1710.Util_ScannerManager.me.communicateWithScanner()  //Old versiono _ga_communicateWithScanner() //return the value scanned
If (OK=1)
	Form:C1466.sfw.lb_items_search()  // search
	
	//Mimic a click on the first element of the list box
	If (Form:C1466.sfw.searchbox#"")
		OBJECT GET COORDINATES:C663(*; "lb_items"; $g; $h; $d; $b)
		CONVERT COORDINATES:C1365($g; $h; XY Current form:K27:5; XY Screen:K27:7)
		
		$xClick:=$g+20
		$yClick:=$h+33
		
		POST CLICK:C466($xClick; $YClick; Current process:C322; *)
	End if 
End if 
