//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $customer : cs:C1710.CustomerEntity
var $result : Object
var $name : Text
var $code : Text
var $created : Integer
var $updated : Integer
var $carrierName : Text
var $carrierNotFound : Integer
var $customerCarrier : cs:C1710.CustomerCarrierEntity
var $note : Text
var $eComment : cs:C1710.sfw_CommentEntity
var $isVoid : Boolean
var $billingCountryISO : Text
var $shippingCountryISO : Text
var $apContact : cs:C1710.ContactEntity
var $statusContact : cs:C1710.ContactEntity
var $comm : Object
var $apEmail : Text
var $statusTel : Text
var $statusEmail : Text
var $statusContactName : Text
var $isNewCustomer : Boolean
var $customerCreateEventType : cs:C1710.sfw_EventTypeEntity
var $customerEvent : cs:C1710.CustomerEventEntity
var $eventStmp : Integer
var $eventUserUUID : Text

// CustomerCarrier is not touched here: it has its own import (_import_customerCarriers),
// which must be run first so the customers below can be linked to the carriers.
TRUNCATE TABLE:C1051([Contact:1])
TRUNCATE TABLE:C1051([Customer:114])

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("customers_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$records:=JSON Parse:C1218($file.getText())
	
	$created:=0
	$updated:=0
	$carrierNotFound:=0
	$customerCreateEventType:=ds:C1482.sfw_EventType.query("ident = :1"; "createRecord").first()
	$eventUserUUID:=cs:C1710.sfw_userManager.me.info.UUID
	If ($eventUserUUID="")
		$eventUserUUID:="00"*16
	End if

	For each ($record; $records)
		$name:=String:C10($record.Customer)
		$code:=String:C10($record.Cust_Code)
		
		$customer:=Null:C1517
		
		// First try by customer code, then fallback to name.
		If ($code#"")
			$customer:=ds:C1482.Customer.query("code = :1"; $code).first()
		End if 
		
		If ($customer=Null:C1517)
			If ($name#"")
				$customer:=ds:C1482.Customer.query("name = :1"; $name).first()
			End if 
		End if 
		
		If ($customer=Null:C1517)
			$customer:=ds:C1482.Customer.new()
			$created:=$created+1
			$isNewCustomer:=True:C214
		Else 
			$updated:=$updated+1
			$isNewCustomer:=False:C215
		End if 
		
		$customer.name:=$name
		$customer.code:=$code
		$customer.accountNumber:=$record.Account_num
		$customer.resaleLicenseNumber:=$record.ResaleLicenseNumber
		$customer.ftp:=$customer.ftp || New object:C1471()
		$customer.ftp.domain:=$record.FTPRepositoryDomain
		$customer.ftp.user:=$record.FTPRepositoryUser
		$customer.ftp.password:=$record.FTPRepositoryPass
		
		$billingCountryISO:=_toISO2Country($record.BillAddressCountry)
		$shippingCountryISO:=_toISO2Country($record.ShipAddressCountry)
		
		// Import addresses in built-in contactDetails.addresses format.
		$customer.contactDetails:=$customer.contactDetails || New object:C1471()
		$customer.contactDetails.addresses:=New collection:C1472()
		$customer.contactDetails.addresses.push(New object:C1471(\
			"type"; "billing"; \
			"detail"; New object:C1471(\
			"street_1"; $record.Bill_Address1; \
			"street_2"; $record.Bill_Address2; \
			"city"; $record.Bill_add_city; \
			"state"; $record.Bill_addr_ST; \
			"postcode"; $record.Bill_addr_zip; \
			"country"; $billingCountryISO\
			)\
			))
		$customer.contactDetails.addresses.push(New object:C1471(\
			"type"; "shipping"; \
			"detail"; New object:C1471(\
			"street_1"; $record.Ship_Address1; \
			"street_2"; $record.Ship_Address2; \
			"city"; $record.Ship_addr_city; \
			"state"; $record.Ship_addr_ST; \
			"postcode"; $record.Ship_Addr_zip; \
			"country"; $shippingCountryISO\
			)\
			))
		
		$isVoid:=$record.void
		$customer.enabled:=Not:C34($isVoid)
		
		// Link only: the carriers themselves come from _import_customerCarriers
		$carrierName:=String:C10($record.Carrier)
		If ($carrierName#"")
			$customerCarrier:=ds:C1482.CustomerCarrier.query("name = :1"; $carrierName).first()
			If ($customerCarrier#Null:C1517)
				$customer.UUID_CustomerCarrier:=$customerCarrier.UUID
			Else
				$carrierNotFound:=$carrierNotFound+1
			End if
		End if
		
		$result:=$customer.save()
		If (Not:C34($result.success))
			TRACE:C157
		Else 
			// Add a creation event for newly imported customers using legacy DateTimeStamp.
			If ($isNewCustomer) && ($customerCreateEventType#Null:C1517)
				$customerEvent:=ds:C1482.CustomerEvent.new()
				$customerEvent.UUID_Customer:=$customer.UUID
				$customerEvent.UUID_EventType:=$customerCreateEventType.UUID
				$customerEvent.UUID_User:=$eventUserUUID
				$eventStmp:=Num:C11(String:C10($record.DateTimeStamp))
				If ($eventStmp=0)
					$eventStmp:=cs:C1710.sfw_stmp.me.now()
				End if 
				$customerEvent.stmp:=$eventStmp
				$customerEvent.moreData:=New object:C1471()
				$result:=$customerEvent.save()
				If (Not:C34($result.success))
					TRACE:C157
				End if 
			End if 
			
			// AP contact (as contact type)
			$apEmail:=String:C10($record.AP_email)
			If ($apEmail#"")
				$apContact:=ds:C1482.Contact.query("UUID_Company = :1 and title = :2"; $customer.UUID; "AP").first()
				If ($apContact=Null:C1517)
					$apContact:=ds:C1482.Contact.new()
					$apContact.UUID_Company:=$customer.UUID
					$apContact.title:="AP"
				End if 
				$apContact.contactDetails:=$apContact.contactDetails || New object:C1471()
				$apContact.contactDetails.addresses:=$apContact.contactDetails.addresses || New collection:C1472()
				$apContact.contactDetails.communications:=New collection:C1472()
				$comm:=New object:C1471(\
					"type"; "email"; \
					"contact"; $apEmail; \
					"comment"; ""\
					)
				$apContact.contactDetails.communications.push($comm)
				$result:=$apContact.save()
				If (Not:C34($result.success))
					TRACE:C157
				End if 
			End if 
			
			// Status contact (as contact type)
			$statusTel:=String:C10($record.Status_Tel)
			$statusEmail:=String:C10($record.StatusEmailAddresses)
			$statusContactName:=String:C10($record.Status_Contact)
			If ($statusEmail#"")
				$statusContact:=ds:C1482.Contact.query("UUID_Company = :1 and title = :2"; $customer.UUID; "Status").first()
				If ($statusContact=Null:C1517)
					$statusContact:=ds:C1482.Contact.new()
					$statusContact.UUID_Company:=$customer.UUID
					$statusContact.title:="Status"
				End if 
				$statusContact.firstName:=$statusContactName
				$statusContact.lastName:=""
				$statusContact.contactDetails:=$statusContact.contactDetails || New object:C1471()
				$statusContact.contactDetails.addresses:=$statusContact.contactDetails.addresses || New collection:C1472()
				$statusContact.contactDetails.communications:=New collection:C1472()
				If ($statusTel#"")
					$comm:=New object:C1471(\
						"type"; "phone"; \
						"contact"; $statusTel; \
						"comment"; ""\
						)
					$statusContact.contactDetails.communications.push($comm)
				End if 
				$comm:=New object:C1471(\
					"type"; "email"; \
					"contact"; $statusEmail; \
					"comment"; ""\
					)
				$statusContact.contactDetails.communications.push($comm)
				$result:=$statusContact.save()
				If (Not:C34($result.success))
					TRACE:C157
				End if 
			End if 
			
			// Import legacy customer notes into the built-in entry notes feature.
			$note:=$record.Notes
			If ($note#"")
				$eComment:=ds:C1482.sfw_Comment.new()
				$eComment.UUID:=Generate UUID:C1066
				$eComment.UUID_target:=$customer.UUID
				$eComment.stmp:=cs:C1710.sfw_stmp.me.now()
				$eComment.ID_level:=1
				$eComment.comment:=$note
				$eComment.save()
			End if 
		End if 
	End for each 
	
	ALERT:C41("Import termine - created: "+String:C10($created)+" | updated: "+String:C10($updated)+" | carrier not found: "+String:C10($carrierNotFound))
End if 
