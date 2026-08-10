//%attributes = {}

var $records : Collection
var $record : Object
var $inventories : 4D.EntitySelection
var $inventory : 4D.Entity
var $inventoryDataClass : 4D.DataClass
var $lotinfoDataClass : 4D.DataClass
var $lotinfo : 4D.Entity
var $travellerLot : Text
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection:C1472()

$inventoryDataClass:=ds["Inventory"]
$lotinfoDataClass:=ds["Lotinfo"]

If ($inventoryDataClass=Null:C1517)
	ALERT:C41("DataClass Inventory not found.")
Else 
	$inventories:=$inventoryDataClass.all()
	
	For each ($inventory; $inventories)
		$travellerLot:=""
		If ($lotinfoDataClass#Null:C1517)
			$lotinfo:=$lotinfoDataClass.query("UniqueID = :1"; $inventory.StockGroup).first()
			If ($lotinfo#Null:C1517)
				$travellerLot:=String:C10($lotinfo.Lotnum)
			End if 
		End if 
		
		$record:=New object:C1471(\
			"Part_Number"; $inventory.Part_Number; \
			"Vendor"; $inventory.Vendor; \
			"Description"; $inventory.Description; \
			"Qty_in_Stock"; $inventory.Qty_in_Stock; \
			"Units"; $inventory.Units; \
			"Unit_Cost"; $inventory.Unit_Cost; \
			"Division"; $inventory.Division; \
			"Stock_Num"; $inventory.Stock_Num; \
			"Date_in"; $inventory.Date_in; \
			"Expiration_Date"; $inventory.Expiration_Date; \
			"Recd_by"; $inventory.Recd_by; \
			"Bin_Location"; $inventory.Bin_Location; \
			"Current_Actual_Value"; $inventory.Current_Actual_Value; \
			"Original_Qty"; $inventory.Original_Qty; \
			"Inactive"; $inventory.Inactive; \
			"LotNumber"; $inventory.LotNumber; \
			"IQAPass"; $inventory.IQAPass; \
			"IQADATE"; $inventory.IQADATE; \
			"IQADoneBY"; $inventory.IQADoneBY; \
			"IQADone"; $inventory.IQADone; \
			"Transformed"; $inventory.Transformed; \
			"DateTimeStamp"; $inventory.DateTimeStamp; \
			"Classification"; $inventory.Classification; \
			"CreationDateTimeStamp"; $inventory.CreationDateTimeStamp; \
			"Currency"; $inventory.Currency; \
			"AvailableQty"; $inventory.AvailableQty; \
			"UniqueID"; $inventory.UniqueID; \
			"StockGroup"; $inventory.StockGroup; \
			"DocumentsinDocserver"; $inventory.DocumentsinDocserver; \
			"IQA_Number"; $inventory.IQA_Number; \
			"CustomerSpecific"; $inventory.CustomerSpecific; \
			"travellerLot"; $travellerLot\
			)
		
		$records.push($record)
	End for each 
	
	$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
	$exportsFolder:=$resourcesFolder.folder("exports")
	
	If (Not:C34($exportsFolder.exists))
		$exportsFolder.create()
	End if 
	
	$file:=$exportsFolder.file("inventory_export.json")
	
	If (Not:C34($file.exists))
		$file.create()
	End if 
	
	$file.setText(JSON Stringify:C1217($records))
	
	ALERT:C41("Export termine: "+$file.platformPath)
End if 
