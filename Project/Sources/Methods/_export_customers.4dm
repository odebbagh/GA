//%attributes = {}

var $records : Collection
var $record : Object
var $customers : cs.Customer_LogSelection
var $customer : cs.Customer_LogEntity
var $customerLogDataClass : 4D.DataClass
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection:C1472()

$customerLogDataClass:=ds["Customer_Log"]

If ($customerLogDataClass=Null:C1517)
	ALERT:C41("DataClass Customer_Log not found.")
Else 
	$customers:=$customerLogDataClass.all()

	For each ($customer; $customers)
		$record:=New object:C1471(\
			"Customer"; $customer.Customer; \
			"Status_Contact"; $customer.Status_Contact; \
			"Bill_Address1"; $customer.Bill_Address1; \
			"Bill_Address2"; $customer.Bill_Address2; \
			"Ship_Address1"; $customer.Ship_Address1; \
			"Ship_Address2"; $customer.Ship_Address2; \
			"Cust_Code"; $customer.Cust_Code; \
			"Status_Tel"; $customer.Status_Tel; \
			"Carrier"; $customer.Carrier; \
			"Account_num"; $customer.Account_num; \
			"Notes"; $customer.Notes; \
			"StatusEmailAddresses"; $customer.StatusEmailAddresses; \
			"emp_code"; $customer.emp_code; \
			"AP_email"; $customer.AP_email; \
			"Ship_addr_city"; $customer.Ship_addr_city; \
			"Bill_add_city"; $customer.Bill_add_city; \
			"Ship_addr_ST"; $customer.Ship_addr_ST; \
			"Bill_addr_ST"; $customer.Bill_addr_ST; \
			"Ship_Addr_zip"; $customer.Ship_Addr_zip; \
			"Bill_addr_zip"; $customer.Bill_addr_zip; \
			"void"; $customer.void; \
			"UniqueID"; $customer.UniqueID; \
			"DateTimeStamp"; $customer.DateTimeStamp; \
			"CreationDateTimeStamp"; $customer.CreationDateTimeStamp; \
			"BillAddressCountry"; $customer.BillAddressCountry; \
			"ShipAddressCountry"; $customer.ShipAddressCountry; \
			"FTPRepositoryDomain"; $customer.FTPRepositoryDomain; \
			"FTPRepositoryUser"; $customer.FTPRepositoryUser; \
			"FTPRepositoryPass"; $customer.FTPRepositoryPass; \
			"ResaleLicenseNumber"; $customer.ResaleLicenseNumber\
			)
		
		$records.push($record)
	End for each 

	$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
	$exportsFolder:=$resourcesFolder.folder("exports")

	If (Not:C34($exportsFolder.exists))
		$exportsFolder.create()
	End if 

	$file:=$exportsFolder.file("customers_export.json")

	If (Not:C34($file.exists))
		$file.create()
	End if 

	$file.setText(JSON Stringify:C1217($records))

	ALERT:C41("Export termine: "+$file.platformPath)
End if 
