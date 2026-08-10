//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $po : cs:C1710.PurchaseOrderEntity
var $customer : cs:C1710.CustomerEntity
var $result : Object
var $poNumber : Integer
var $created : Integer
var $updated : Integer
var $billingCountryISO : Text
var $shippingCountryISO : Text

TRUNCATE TABLE:C1051([PurchaseOrder:115])

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("purchaseOrders_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$records:=JSON Parse:C1218($file.getText())
	
	$created:=0
	$updated:=0
	
	For each ($record; $records)
		//$poNumber:=Num($record.PO_Number)
		$po:=Null:C1517
		
		//If ($poNumber>0)
		//$po:=ds.PurchaseOrder.query("poNumber = :1"; $poNumber).first()
		//End if 
		
		If ($po=Null:C1517)
			$po:=ds:C1482.PurchaseOrder.new()
			$created:=$created+1
		Else 
			$updated:=$updated+1
		End if 
		
		// Import only fields available in current PurchaseOrder schema.
		$po.customer_name:=$record.Customer
		$po.resaleNumber:=$record.Resale_Number
		$po.description:=$record.Description
		$po.poNum:=$record.PO_Number
		$po.poAmount:=$record.PO_Amount
		$po.amountBilled:=$record.AMT_Billed
		$po.log_date:=$record.Log_date
		$po.openPO:=$record.Open_PO
		$po.releaseNumber:=$record.Release_Number
		$po.forTimeBilling:=$record.For_time_billing
		$po.initials:=$record.Initials
		$po.division:=$record.Division
		$po.identifier:=$record.Identifier
		$po.ourQuote:=$record.Our_Quote
		$po.dropShipCustomer:=$record.Drop_Ship_Customer
		$po.altBillTo:=$record.Alt_bill_to
		$po.currency:=$record.Currency
		
		$billingCountryISO:=_toISO2Country($record.BillAddrCountry)
		$shippingCountryISO:=_toISO2Country($record.ShipAddrCountry)
		
		$po.address:=New object:C1471("addresses"; New collection:C1472())
		$po.address.addresses.push(New object:C1471(\
			"type"; "billing"; \
			"detail"; New object:C1471(\
			"street_1"; $record.Bill_add1; \
			"street_2"; $record.Bill_add2; \
			"city"; $record.Bill_City; \
			"state"; $record.Bill_ST; \
			"postcode"; $record.Bill_ZIP; \
			"country"; $billingCountryISO\
			)\
			))
		$po.address.addresses.push(New object:C1471(\
			"type"; "shipping"; \
			"detail"; New object:C1471(\
			"street_1"; $record.Ship_add1; \
			"street_2"; $record.Ship_add2; \
			"city"; $record.Ship_City; \
			"state"; $record.Ship_ST; \
			"postcode"; $record.Ship_ZIP; \
			"country"; $shippingCountryISO\
			)\
			))
		
		If (String:C10($record.Customer)#"")
			$customer:=ds:C1482.Customer.query("name = :1"; $record.Customer).first()
			If ($customer#Null:C1517)
				$po.UUID_Customer:=$customer.UUID
			End if 
		End if 
		
		$result:=$po.save()
		If (Not:C34($result.success))
			TRACE:C157
		End if 
	End for each 
	
	ALERT:C41("Import termine - created: "+String:C10($created)+" | updated: "+String:C10($updated))
End if 
