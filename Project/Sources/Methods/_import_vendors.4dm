//%attributes = {}

// Imports project/imports/vendors_and_contacts_export.json into [Customer]
// with vendor=true. Vendors are matched to existing customers by normalized
// name (case, spaces, dots, commas, dashes, underscores and apostrophes
// ignored). Addresses go into contactDetails.addresses using the framework
// default display format: billing (vendor address), shipping and remit.
// Contacts are created as [Contact] entities linked through UUID_Company.

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $vendorContact : Object
var $customer : cs:C1710.CustomerEntity
var $eContact : cs:C1710.ContactEntity
var $existingCustomers : Object
var $result : Object
var $contactDetails : Object
var $addresses : Collection
var $address : Object
var $comm : Object
var $shippingLines : Collection
var $normalizedName : Text
var $contactName : Text
var $key : Text
var $created : Integer
var $updated : Integer
var $contactsCreated : Integer
var $contactsExisting : Integer

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("vendors_and_contacts_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else
	$records:=JSON Parse:C1218($file.getText())

	$created:=0
	$updated:=0
	$contactsCreated:=0
	$contactsExisting:=0

	// Map every existing customer by normalized name so vendors that are
	// already customers (even with a slightly different spelling) are reused.
	$existingCustomers:=New object:C1471()

	For each ($customer; ds:C1482.Customer.all())
		$normalizedName:=Lowercase:C14($customer.name)
		$normalizedName:=Replace string:C233($normalizedName; " "; "")
		$normalizedName:=Replace string:C233($normalizedName; "."; "")
		$normalizedName:=Replace string:C233($normalizedName; ","; "")
		$normalizedName:=Replace string:C233($normalizedName; "-"; "")
		$normalizedName:=Replace string:C233($normalizedName; "_"; "")
		$normalizedName:=Replace string:C233($normalizedName; "'"; "")

		If ($normalizedName#"")
			$existingCustomers[$normalizedName]:=$customer.UUID
		End if
	End for each

	For each ($record; $records)

		$normalizedName:=Lowercase:C14(String:C10($record.vendor_name))
		$normalizedName:=Replace string:C233($normalizedName; " "; "")
		$normalizedName:=Replace string:C233($normalizedName; "."; "")
		$normalizedName:=Replace string:C233($normalizedName; ","; "")
		$normalizedName:=Replace string:C233($normalizedName; "-"; "")
		$normalizedName:=Replace string:C233($normalizedName; "_"; "")
		$normalizedName:=Replace string:C233($normalizedName; "'"; "")

		If ($normalizedName#"")

			$customer:=Null:C1517

			If ($existingCustomers[$normalizedName]#Null:C1517)
				$customer:=ds:C1482.Customer.query("UUID = :1"; $existingCustomers[$normalizedName]).first()
			End if

			If ($customer=Null:C1517)
				$customer:=ds:C1482.Customer.new()
				$customer.name:=$record.vendor_name
				$customer.codeNumber:=ds:C1482.Customer.all().max("codeNumber")+1
				$customer.enabled:=True:C214
				$created:=$created+1
			Else
				$updated:=$updated+1
			End if

			$customer.vendor:=True:C214
			// QA approval status comes from the source (kept in sync on every import)
			$customer.approved:=Bool:C1537($record.approved_by_qa)

			// Build contactDetails in a local object and assign it to the
			// entity ONCE before save: mutating through the attribute getter
			// ($customer.contactDetails.addresses.push(...)) is not reliably
			// persisted by ORDA.
			$contactDetails:=$customer.contactDetails || New object:C1471()
			$addresses:=$contactDetails.addresses || New collection:C1472()

			// Vendor address -> billing (framework default display type)
			If (String:C10($record.vendor_address.address_1)#"") | (String:C10($record.vendor_address.city)#"")
				$addresses:=$addresses.query("type # :1"; "billing")

				$address:=New object:C1471()
				$address.type:="billing"
				$address.detail:=New object:C1471()
				$address.detail.street_1:=String:C10($record.vendor_address.address_1)
				$address.detail.street_2:=String:C10($record.vendor_address.address_2)
				$address.detail.city:=String:C10($record.vendor_address.city)
				$address.detail.state:=String:C10($record.vendor_address.state)
				$address.detail.postcode:=String:C10($record.vendor_address.zip_code)
				$address.detail.country:=_toISO2Country(String:C10($record.vendor_address.country))
				$address.detail.iso_code_2:=$address.detail.country
				$addresses.push($address)
			End if

			// Shipping address comes as one text block -> first line as street_1,
			// the rest as street_2
			If (String:C10($record.shipping_address)#"")
				$addresses:=$addresses.query("type # :1"; "shipping")

				$shippingLines:=Split string:C1554(Replace string:C233(String:C10($record.shipping_address); "\r\n"; "\r"); "\r"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)

				$address:=New object:C1471()
				$address.type:="shipping"
				$address.detail:=New object:C1471()
				$address.detail.street_1:=($shippingLines.length>0) ? $shippingLines[0] : ""
				$address.detail.street_2:=($shippingLines.length>1) ? $shippingLines.slice(1).join(", ") : ""
				$address.detail.city:=""
				$address.detail.state:=""
				$address.detail.postcode:=""
				$address.detail.country:="US"
				$address.detail.iso_code_2:="US"
				$addresses.push($address)
			End if

			// Remit to address -> remit (type used by invoice printing)
			If (String:C10($record.remit_to_address.address_1)#"") | (String:C10($record.remit_to_address.city)#"")
				$addresses:=$addresses.query("type # :1"; "remit")

				$address:=New object:C1471()
				$address.type:="remit"
				$address.detail:=New object:C1471()
				$address.detail.street_1:=String:C10($record.remit_to_address.address_1)
				$address.detail.street_2:=String:C10($record.remit_to_address.address_2)
				$address.detail.city:=String:C10($record.remit_to_address.city)
				$address.detail.state:=String:C10($record.remit_to_address.state)
				$address.detail.postcode:=String:C10($record.remit_to_address.zip_code)
				$address.detail.country:=_toISO2Country(String:C10($record.remit_to_address.country))
				$address.detail.iso_code_2:=$address.detail.country
				$addresses.push($address)
			End if

			$contactDetails.addresses:=$addresses
			$customer.contactDetails:=$contactDetails

			$result:=$customer.save()

			If (Not:C34($result.success))
				TRACE:C157
			Else

				// Contacts
				If ($record.contacts#Null:C1517)
					For each ($vendorContact; $record.contacts)
						$contactName:=String:C10($vendorContact.name)

						If ($contactName#"")
							$eContact:=ds:C1482.Contact.query("UUID_Company = :1 and firstName = :2"; $customer.UUID; $contactName).first()

							If ($eContact#Null:C1517)
								$contactsExisting:=$contactsExisting+1
							Else
								$eContact:=ds:C1482.Contact.new()
								$eContact.UUID_Company:=$customer.UUID
								$eContact.firstName:=$contactName
								$eContact.lastName:=""

								// Same as the customer addresses: build the
								// object locally and assign it once
								$contactDetails:=New object:C1471()
								$contactDetails.addresses:=New collection:C1472()
								$contactDetails.communications:=New collection:C1472()

								If (String:C10($vendorContact.phone)#"")
									$comm:=New object:C1471()
									$comm.type:="phone"
									$comm.comment:=""
									$comm.contact:=$vendorContact.phone
									$contactDetails.communications.push($comm)
								End if

								If (String:C10($vendorContact.fax)#"")
									$comm:=New object:C1471()
									$comm.type:="fax"
									$comm.comment:=""
									$comm.contact:=$vendorContact.fax
									$contactDetails.communications.push($comm)
								End if

								If (String:C10($vendorContact.email)#"")
									$comm:=New object:C1471()
									$comm.type:="email"
									$comm.comment:=""
									$comm.contact:=$vendorContact.email
									$contactDetails.communications.push($comm)
								End if

								$eContact.contactDetails:=$contactDetails

								$result:=$eContact.save()

								If ($result.success)
									$contactsCreated:=$contactsCreated+1
								Else
									TRACE:C157
								End if
							End if
						End if
					End for each
				End if

				// Register the customer so a duplicate vendor row later in the
				// file reuses this entity instead of creating another one.
				$existingCustomers[$normalizedName]:=$customer.UUID
			End if
		End if
	End for each

	ALERT:C41("Import termine - vendors created: "+String:C10($created)+" | existing customers flagged as vendor: "+String:C10($updated)+" | contacts created: "+String:C10($contactsCreated)+" | contacts existing: "+String:C10($contactsExisting))
End if
