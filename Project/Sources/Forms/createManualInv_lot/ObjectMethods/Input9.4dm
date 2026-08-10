Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		OBJECT GET COORDINATES:C663(*; "Input9"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "name"; \
			"lb_items"; ds:C1482.InventoryUnits.all().orderBy("name asc"); \
			"allData"; ds:C1482.InventoryUnits.all().orderBy("name asc"); \
			"dataclass"; "InventoryUnits"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (OK=1)
			If ($form.item#Null:C1517)
				Form:C1466.inventory_e.UUID_InventoryUnits:=$form.item.UUID
				Form:C1466.inventory_e.units:=$form.item.name
			End if 
		End if 
End case 

