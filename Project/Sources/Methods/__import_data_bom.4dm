//%attributes = {}
TRUNCATE TABLE:C1051([BOM:96])
TRUNCATE TABLE:C1051([BomItem:97])

If (True:C214)
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/bom.json")
	
	$records:=JSON Parse:C1218($file.getText())
	For each ($record; $records)
		$Division:=ds:C1482.Division.query("name == :1"; $record.Division).first()
		$Customer:=ds:C1482.Customer.query("name == :1"; $record.Customer).first()
		
		$bom:=ds:C1482.BOM.new()
		$bom.Bom_Part_Num:=$record.Bom_Part_Num
		$bom.Inv_Status_Date:=$record.Inv_Status_Date
		$bom.Inv_Status_Time:=$record.Inv_Status_Time
		$bom.CreatedBy:=$record.CreatedBy
		$bom.CreationDateTimeStamp:=$record.CreationDateTimeStamp
		$bom.Rev:=$record.Rev
		$bom.RevDate:=$record.RevDate
		$bom.RevHistory:=$record.RevHistory
		$bom.ReasonForLastChange:=$record.ReasonForLastChange
		$bom.DateTimeStamp:=$record.DateTimeStamp
		$bom.PhaseOut:=$record.PhaseOut
		$bom.Void:=$record.Void
		$bom.UUID_Division:=$Division.UUID
		$bom.UUID_Customer:=$Customer.UUID
		
		$info:=$bom.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	End for each 
	
	
	$file2:=Folder:C1567(fk data folder:K87:12).file("DataJson/bomItems.json")
	
	$records2:=JSON Parse:C1218($file2.getText())
	For each ($record2; $records2)
		//$Supplier:=ds.Supplier.query("name == :1"; $record2.Supplier).first()
		//$Customer2:=ds.Customer.query("name == :1"; $record2.Customer).first()
		$Division:=ds:C1482.Division.query("name == :1"; "GAC").first()
		
		$bom:=ds:C1482.BomItem.new()
		$bom.Bom_Part_Num:=$record2.Bom_Part_Num
		$bom.SupplierPartNum:=$record2.Supplier_partnum
		$bom.TimesFactor:=$record2.Times_factor
		$bom.InternalPartNum:=$record2.Internal_partnum
		$bom.DispensedByTool:=$record2.DispensedByTool
		$bom.BomQty:=$record2.Bom_Qty
		$bom.QtyInInventory:=$record2.Qty_in_inventory
		$bom.BOnumber:=$record2.BO_number
		$bom.BOlineItemNum:=$record2.Void
		$bom.UnitPrice:=$record2.unit_price
		$bom.PartDescription:=$record2.Part_Description
		$bom.Units:=$record2.Units
		$bom.MinAbsoluteQty:=$record2.MinAbsoluteQty
		$bom.BuyUnitsDivFactor:=$record2.BuyUnitsDivFactor
		$bom.DateTimeStamp:=$record2.DateTimeStamp
		$bom.SequenceID:=$record2.SequenceID
		$bom.CreationDateTimeStamp:=$record2.CreationDateTimeStamp
		$bom.Supplier:=$record2.Supplier
		$bom.UUID_Division:=$Division.UUID
		
		$info:=$bom.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	End for each 
End if 
ALERT:C41("BOMs done importing")