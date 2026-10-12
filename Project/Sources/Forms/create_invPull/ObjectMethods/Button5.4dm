// who put it back: the staff list under the "Pulled By" field (it stored the menu line number before)
Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		OBJECT GET COORDINATES:C663(*; "Input10"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "fullName"; \
			"lb_items"; ds:C1482.Staff.all().orderBy("fullName asc"); \
			"allData"; ds:C1482.Staff.all().orderBy("fullName asc"); \
			"dataclass"; "Staff"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1) && ($form.item#Null:C1517)
			Form:C1466.invPull.pulledBy:=$form.item.fullName
		End if 
		
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469(9000)
End case 
