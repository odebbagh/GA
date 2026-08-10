Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		OBJECT GET COORDINATES:C663(*; "entryField_classification"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "name"; \
			"lb_items"; ds:C1482.Classification.all(); \
			"allData"; ds:C1482.Classification.all(); \
			"dataclass"; "Classification"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			If ($form.item#Null:C1517)
				Form:C1466.current_item.classification:=$form.item.name
				cs:C1710.panel_inventory.me._activate_save_cancel_button()
			End if 
		End if 
		
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469(9000)
End case 