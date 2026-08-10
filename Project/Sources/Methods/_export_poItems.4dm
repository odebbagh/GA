//%attributes = {}

var $records : Collection
var $record : Object
var $poItems : 4D.EntitySelection
var $poItem : 4D.Entity
var $poItemsDataClass : 4D.DataClass
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection:C1472()

$poItemsDataClass:=ds["PO_Items"]

If ($poItemsDataClass=Null:C1517)
	ALERT:C41("DataClass PO_Items not found.")
Else 
	$poItems:=$poItemsDataClass.all()
	
	For each ($poItem; $poItems)
		$record:=New object:C1471(\
			"PO_number"; $poItem.PO_number; \
			"Item_num"; $poItem.Item_num; \
			"Item_Desc"; $poItem.Item_Desc; \
			"Qty_Ordered"; $poItem.Qty_Ordered; \
			"Date_Ordered"; $poItem.Date_Ordered; \
			"CustomerRequestedDate"; $poItem.CustomerRequestedDate; \
			"ShipJobNumber"; $poItem.ShipJobNumber; \
			"Unit_Price"; $poItem.Unit_Price; \
			"UnReleased"; $poItem.UnReleased; \
			"Customer"; $poItem.Customer; \
			"Division"; $poItem.Division; \
			"EnteredBy"; $poItem.EnteredBy; \
			"SeqNum"; $poItem.SeqNum; \
			"Void"; $poItem.Void; \
			"DateTimeStamp"; $poItem.DateTimeStamp; \
			"Notes"; $poItem.Notes; \
			"History"; $poItem.History; \
			"LastChangeBy"; $poItem.LastChangeBy; \
			"Currency"; $poItem.Currency; \
			"CreationDateTimeStamp"; $poItem.CreationDateTimeStamp; \
			"DataType"; $poItem.DataType; \
			"UniqueID"; $poItem.UniqueID; \
			"Closed"; $poItem.Closed; \
			"ShipTo"; $poItem.ShipTo; \
			"Ship_Add1"; $poItem.Ship_Add1; \
			"Ship_Add2"; $poItem.Ship_Add2; \
			"Ship_City"; $poItem.Ship_City; \
			"Ship_ST"; $poItem.Ship_ST; \
			"Ship_Zip"; $poItem.Ship_Zip; \
			"Ship_Country"; $poItem.Ship_Country; \
			"Bill_To"; $poItem.Bill_To; \
			"Bill_Add1"; $poItem.Bill_Add1; \
			"Bill_City"; $poItem.Bill_City; \
			"Bill_ST"; $poItem.Bill_ST; \
			"Bill_ZIP"; $poItem.Bill_ZIP; \
			"Bill_Country"; $poItem.Bill_Country; \
			"GroupNumber"; $poItem.GroupNumber; \
			"PriceEffectivityStartDate"; $poItem.PriceEffectivityStartDate; \
			"PriceEffectivityStopDate"; $poItem.PriceEffectivityStopDate; \
			"ItemTypeCode"; $poItem.ItemTypeCode; \
			"SalesSource"; $poItem.SalesSource; \
			"LineItemTotal"; $poItem.LineItemTotal; \
			"InvoiceDate"; $poItem.InvoiceDate\
			)
		
		$records.push($record)
	End for each 
	
	$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
	$exportsFolder:=$resourcesFolder.folder("exports")
	
	If (Not:C34($exportsFolder.exists))
		$exportsFolder.create()
	End if 
	
	$file:=$exportsFolder.file("poItems_export.json")
	
	If (Not:C34($file.exists))
		$file.create()
	End if 
	
	$file.setText(JSON Stringify:C1217($records))
	
	ALERT:C41("Export termine: "+$file.platformPath)
End if 
