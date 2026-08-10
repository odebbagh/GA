Case of 
	: (Form event code:C388=On Clicked:K2:4)
		OBJECT GET COORDINATES:C663(*; "pup_inventory"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "code"; \
			"allData"; Form:C1466.inventoryItems; \
			"dataclass"; "Inventory"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.selectedInventory:=$form.item
			Form:C1466.maxQty:=InventoryPullForm_netPulled($form.item.UUID)
			Form:C1466.inventoryDisplay:=$form.item.code+" — Out: "+String:C10(Form:C1466.maxQty)
			Form:C1466.qtyToPutBack:=0
			OBJECT SET ENABLED:C1123(*; "inp_qtyToPutBack"; True:C214)
		End if 
End case 
