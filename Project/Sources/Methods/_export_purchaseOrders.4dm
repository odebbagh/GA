//%attributes = {}

var $records : Collection
var $record : Object
var $poLogs : 4D.EntitySelection
var $poLog : 4D.Entity
var $poLogDataClass : 4D.DataClass
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection:C1472()

$poLogDataClass:=ds["PO_LOG"]

If ($poLogDataClass=Null:C1517)
	ALERT:C41("DataClass PO_LOG not found.")
Else 
	$poLogs:=$poLogDataClass.all()
	
	For each ($poLog; $poLogs)
		$record:=New object:C1471(\
			"Customer"; $poLog.Customer; \
			"Resale_Number"; $poLog.Resale_Number; \
			"Description"; $poLog.Description; \
			"PO_Number"; $poLog.PO_Number; \
			"PO_Amount"; $poLog.PO_Amount; \
			"AMT_Billed"; $poLog.AMT_Billed; \
			"SessionTemp"; $poLog.SessionTemp; \
			"Log_date"; $poLog.Log_date; \
			"Open_PO"; $poLog.Open_PO; \
			"Release_Number"; $poLog.Release_Number; \
			"For_time_billing"; $poLog.For_time_billing; \
			"DocumentsinDocServer"; $poLog.DocumentsinDocServer; \
			"Remove"; $poLog.Remove; \
			"Initials"; $poLog.Initials; \
			"Ninvoices"; $poLog.Ninvoices; \
			"Division"; $poLog.Division; \
			"Identifier"; $poLog.Identifier; \
			"Bill_add1"; $poLog.Bill_add1; \
			"Bill_add2"; $poLog.Bill_add2; \
			"Ship_add1"; $poLog.Ship_add1; \
			"Ship_add2"; $poLog.Ship_add2; \
			"Our_Quote"; $poLog.Our_Quote; \
			"Drop_Ship_Customer"; $poLog.Drop_Ship_Customer; \
			"Alt_bill_to"; $poLog.Alt_bill_to; \
			"Currency"; $poLog.Currency; \
			"DateTimeStamp"; $poLog.DateTimeStamp; \
			"CreationDateTimeStamp"; $poLog.CreationDateTimeStamp; \
			"UniqueID"; $poLog.UniqueID; \
			"Bill_City"; $poLog.Bill_City; \
			"Bill_ST"; $poLog.Bill_ST; \
			"Bill_ZIP"; $poLog.Bill_ZIP; \
			"Ship_City"; $poLog.Ship_City; \
			"Ship_ST"; $poLog.Ship_ST; \
			"Ship_ZIP"; $poLog.Ship_ZIP; \
			"BillAddrCountry"; $poLog.BillAddrCountry; \
			"ShipAddrCountry"; $poLog.ShipAddrCountry\
			)
		
		$records.push($record)
	End for each 
	
	$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
	$exportsFolder:=$resourcesFolder.folder("exports")
	
	If (Not:C34($exportsFolder.exists))
		$exportsFolder.create()
	End if 
	
	$file:=$exportsFolder.file("purchaseOrders_export.json")
	
	If (Not:C34($file.exists))
		$file.create()
	End if 
	
	$file.setText(JSON Stringify:C1217($records))
	
	ALERT:C41("Export termine: "+$file.platformPath)
End if 
