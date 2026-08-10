
Form:C1466.currentPath:=cs:C1710.Util_binLocationPicker.me.pickReadOnly("pup_binLocation"; Form:C1466.currentPath; Form:C1466.inventory_e.UUID_Lot)
If (Form:C1466.currentPath#"")
	
	Form:C1466.selectedBins:=Storage:C1525.cache.bins.query("binLocationPath = :1"; Form:C1466.currentPath)
	If (Form:C1466.selectedBins#Null:C1517)
		If (Form:C1466.selectedBins.length>0)
			// Link inventory to the selected Bin record.
			Form:C1466.inventory_e.UUID_Location:=Form:C1466.selectedBins.first().UUID
			Form:C1466.inventory_e.location:=Form:C1466.selectedBins.first().binLocationPath
		End if 
	End if 
	OBJECT SET TITLE:C194(*; "pup_binLocation"; Form:C1466.currentPath)
	
	//cs.Util_binLocationPicker.me.draw("pup_binLocation"; Form.currentPath)
End if 

