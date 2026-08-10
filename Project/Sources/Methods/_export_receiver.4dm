//%attributes = {}

var $records : Collection
var $record : Object
var $receivers : 4D.EntitySelection
var $receiver : 4D.Entity
var $receiverDataClass : 4D.DataClass
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection:C1472()

$receiverDataClass:=ds["Receiver"]

If ($receiverDataClass=Null:C1517)
	ALERT:C41("DataClass Receiver not found.")
Else 
	$receivers:=$receiverDataClass.all()
	
	For each ($receiver; $receivers)
		$record:=New object:C1471(\
			"Customer"; $receiver.Customer; \
			"Shipped"; $receiver.Shipped; \
			"POLinesTotal"; $receiver.POLinesTotal; \
			"Customer_Shipper"; $receiver.Customer_Shipper; \
			"Purchase_Order"; $receiver.Purchase_Order; \
			"Device_Number"; $receiver.Device_Number; \
			"ErpJobNumber"; $receiver.ErpJobNumber; \
			"DateCreated"; $receiver.DateCreated; \
			"Division"; $receiver.Division; \
			"Total_Charge"; $receiver.Total_Charge; \
			"SetupSheetCode"; $receiver.SetupSheetCode; \
			"Process"; $receiver.Process; \
			"Invoice_date"; $receiver.Invoice_date; \
			"Sales_Tax"; $receiver.Sales_Tax; \
			"Misc_Description"; $receiver.Misc_Description; \
			"AlternateAddress"; $receiver.AlternateAddress; \
			"Last_lot_ship_date"; $receiver.Last_lot_ship_date; \
			"Shippers"; $receiver.Shippers; \
			"PO_Rel"; $receiver.PO_Rel; \
			"ParentJobNumber"; $receiver.ParentJobNumber; \
			"Initials"; $receiver.Initials; \
			"Job_Comment"; $receiver.Job_Comment; \
			"Trav_has_Info"; $receiver.Trav_has_Info; \
			"Qty"; $receiver.Qty; \
			"QtyOnHand"; $receiver.QtyOnHand; \
			"Made_Trav"; $receiver.Made_Trav; \
			"Pr_qualifier"; $receiver.Pr_qualifier; \
			"Bill_add1"; $receiver.Bill_add1; \
			"Bill_add2"; $receiver.Bill_add2; \
			"Ship_add1"; $receiver.Ship_add1; \
			"Ship_add2"; $receiver.Ship_add2; \
			"Currency"; $receiver.Currency; \
			"UniqueID"; $receiver.UniqueID; \
			"SalesTax_Rate"; $receiver.SalesTax_Rate; \
			"NO_lots"; $receiver.NO_lots; \
			"Processing_site"; $receiver.Processing_site; \
			"Drop_Ship_Customer"; $receiver.Drop_Ship_Customer; \
			"Alt_Bill_To"; $receiver.Alt_Bill_To; \
			"Inv_Format"; $receiver.Inv_Format; \
			"Pkg_Type"; $receiver.Pkg_Type; \
			"DateTimeStamp"; $receiver.DateTimeStamp; \
			"CreationDateTimeStamp"; $receiver.CreationDateTimeStamp; \
			"Bill_addr_City"; $receiver.Bill_addr_City; \
			"Bill_addr_ST"; $receiver.Bill_addr_ST; \
			"Bill_addr_ZIP"; $receiver.Bill_addr_ZIP; \
			"Ship_addr_City"; $receiver.Ship_addr_City; \
			"Ship_addr_ST"; $receiver.Ship_addr_ST; \
			"Ship_addr_ZIP"; $receiver.Ship_addr_ZIP; \
			"GroupNumber"; $receiver.GroupNumber; \
			"ConfigurableString1"; $receiver.ConfigurableString1; \
			"ConfigurableString2"; $receiver.ConfigurableString2; \
			"ConfigurableString3"; $receiver.ConfigurableString3; \
			"ModificationHistory"; $receiver.ModificationHistory; \
			"JobSplitLevel"; $receiver.JobSplitLevel; \
			"ShipAddrCountry"; $receiver.ShipAddrCountry; \
			"BillAddrCountry"; $receiver.BillAddrCountry; \
			"SalesTaxCodeName"; $receiver.SalesTaxCodeName; \
			"UnarchiveDT"; $receiver.UnarchiveDT; \
			"ExpectedJobCompletionDate"; $receiver.ExpectedJobCompletionDate; \
			"Planner"; $receiver.Planner\
			)
		$records.push($record)
	End for each 
	
	$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
	$exportsFolder:=$resourcesFolder.folder("exports")
	
	If (Not:C34($exportsFolder.exists))
		$exportsFolder.create()
	End if 
	
	$file:=$exportsFolder.file("receiver_export.json")
	
	If (Not:C34($file.exists))
		$file.create()
	End if 
	
	$file.setText(JSON Stringify:C1217($records))
	
	ALERT:C41("Export termine: "+$file.platformPath)
End if 
