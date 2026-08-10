//%attributes = {}

TRUNCATE TABLE:C1051([Job:117])

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $job : cs:C1710.JobEntity
var $purchaseOrder : cs:C1710.PurchaseOrderEntity
var $customer : cs:C1710.CustomerEntity
var $result : Object
var $created : Integer
var $failed : Integer
var $linkedPO : Integer
var $missingPO : Integer
var $linkedCustomer : Integer
var $missingCustomer : Integer
var $erpJobNumber : Integer
var $purchaseOrderNum : Text
var $stmpCreated : Integer
var $stmpInvoiced : Integer
var $stmpLastShipped : Integer
var $stmpExpected : Integer
var $stmpArchived : Integer

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("receiver_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$records:=JSON Parse:C1218($file.getText())
	
	$created:=0
	$failed:=0
	$linkedPO:=0
	$missingPO:=0
	$linkedCustomer:=0
	$missingCustomer:=0
	
	For each ($record; $records)
		$erpJobNumber:=Num:C11($record.ErpJobNumber)
		$purchaseOrderNum:=String:C10($record.Purchase_Order)
		
		If ($erpJobNumber<=0)
			$failed:=$failed+1
		Else 
			$job:=ds:C1482.Job.new()
			$created:=$created+1
			
			// Import only fields available in the current Job schema.
			$job.jobNumber:=$erpJobNumber
			$job.customerName:=String:C10($record.Customer)
			$job.shipped:=Bool:C1537($record.Shipped)
			$job.customerShipper:=String:C10($record.Customer_Shipper)
			$job.deviceNumber:=String:C10($record.Device_Number)
			$job.process:=String:C10($record.Process)
			$job.totalTax:=Num:C11($record.Sales_Tax)
			$job.totalCharge:=Num:C11($record.Total_Charge)
			$job.poRel:=Num:C11($record.PO_Rel)
			$job.parentJobNumber:=Num:C11($record.ParentJobNumber)
			$job.initials:=String:C10($record.Initials)
			$job.jobComment:=String:C10($record.Job_Comment)
			$job.qty:=Num:C11($record.Qty)
			$job.qtyOnHand:=Num:C11($record.QtyOnHand)
			$job.pr_qualifier:=String:C10($record.Pr_qualifier)
			$job.currency:=String:C10($record.Currency)
			$job.noLots:=Bool:C1537($record.NO_lots)
			$job.dropShipCustomer:=String:C10($record.Drop_Ship_Customer)
			$job.packageType:=String:C10($record.Pkg_Type)
			$job.shippers:=Num:C11($record.Shippers)
			$job.miscNote:=String:C10($record.Misc_Description)
			$job.alternateShipAddress:=Bool:C1537($record.AlternateAddress)
			
			$job.address:=New object:C1471("addresses"; New collection:C1472())
			$job.address.addresses.push(New object:C1471(\
				"type"; "billing"; \
				"detail"; New object:C1471(\
				"street_1"; $record.Bill_add1; \
				"street_2"; $record.Bill_add2; \
				"city"; $record.Bill_addr_City; \
				"state"; $record.Bill_addr_ST; \
				"postcode"; $record.Bill_addr_ZIP; \
				"country"; _toISO2Country($record.BillAddrCountry)\
				)\
				))
			$job.address.addresses.push(New object:C1471(\
				"type"; "shipping"; \
				"detail"; New object:C1471(\
				"street_1"; $record.Ship_add1; \
				"street_2"; $record.Ship_add2; \
				"city"; $record.Ship_addr_City; \
				"state"; $record.Ship_addr_ST; \
				"postcode"; $record.Ship_addr_ZIP; \
				"country"; _toISO2Country($record.ShipAddrCountry)\
				)\
				))
			
			$stmpCreated:=Num:C11($record.DateTimeStamp)
			If ($stmpCreated=0)
				$stmpCreated:=Num:C11($record.CreationDateTimeStamp)
			End if 
			If ($stmpCreated>0)
				$job.stmpCreated:=$stmpCreated
			End if 
			
			$stmpInvoiced:=Num:C11($record.Invoice_date)
			If ($stmpInvoiced>0)
				$job.stmpInvoiced:=$stmpInvoiced
			End if 
			
			$stmpLastShipped:=Num:C11($record.Last_lot_ship_date)
			If ($stmpLastShipped>0)
				$job.stmpLastShipped:=$stmpLastShipped
			End if 
			
			$stmpExpected:=Num:C11($record.ExpectedJobCompletionDate)
			If ($stmpExpected>0)
				$job.stmpExpected:=$stmpExpected
			End if 
			
			$stmpArchived:=Num:C11($record.UnarchiveDT)
			If ($stmpArchived>0)
				$job.stmpArchived:=$stmpArchived
			End if 
			
			If ($purchaseOrderNum#"")
				$purchaseOrder:=ds:C1482.PurchaseOrder.query("poNum = :1"; $purchaseOrderNum).first()
				If ($purchaseOrder#Null:C1517)
					$job.UUID_PurchaseOrder:=$purchaseOrder.UUID
					$job.poNumber:=Num:C11($purchaseOrder.poNum)
					$linkedPO:=$linkedPO+1
				Else 
					$missingPO:=$missingPO+1
					$job.poNumber:=Num:C11($purchaseOrderNum)
				End if 
			End if 
			
			If (String:C10($record.Customer)#"")
				$customer:=ds:C1482.Customer.query("name = :1"; String:C10($record.Customer)).first()
				If ($customer#Null:C1517)
					$job.UUID_Customer:=$customer.UUID
					$linkedCustomer:=$linkedCustomer+1
				Else 
					$missingCustomer:=$missingCustomer+1
				End if 
			End if 
			
			$result:=$job.save()
			If (Not:C34($result.success))
				$failed:=$failed+1
			End if 
		End if 
	End for each 
	
	ALERT:C41("Import termine - created: "+String:C10($created)+" | linked PO: "+String:C10($linkedPO)+" | missing PO: "+String:C10($missingPO)+" | linked customers: "+String:C10($linkedCustomer)+" | missing customers: "+String:C10($missingCustomer)+" | failed: "+String:C10($failed))
End if 
