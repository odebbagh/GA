//%attributes = {}

// Imports project/imports/buyOrders_export.json into [BuyingOrder] and
// [BuyingOrderLine].
// - vendor is linked to [Customer] by normalized name (same rule as _import_vendors)
// - buyer/requestor are linked to [Staff] by code when a match exists
// - attention to is linked to the vendor's [Contact] by name
// - addresses go into BuyingOrder.contactDetails (billing/shipping/remit)
// - terms/termsCritical* are filled from the .4wp files exported next to the
//   json (templates + deduplicated per-record Buy_policy_ documents)
// - legacy fields with no direct column are kept in moreData

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $line : Object
var $bo : cs:C1710.BuyingOrderEntity
var $boLine : cs:C1710.BuyingOrderLineEntity
var $customer : cs:C1710.CustomerEntity
var $staff : cs:C1710.StaffEntity
var $eContact : cs:C1710.ContactEntity
var $existingCustomers : Object
var $existingStaff : Object
var $contactDetails : Object
var $addresses : Collection
var $address : Object
var $moreData : Object
var $shippingLines : Collection
var $result : Object
var $eComment : cs:C1710.sfw_CommentEntity
var $notes : Text
var $note : Text
var $noteItems : Collection
var $normalizedName : Text
var $customerUUID : Text
var $termsTemplate : Object
var $termsCriticalMaterials : Object
var $termsCriticalService : Object
var $policyDocs : Object
var $policyFile : 4D:C1709.File
var $templateFile : 4D:C1709.File
var $policyKey : Text
var $created : Integer
var $failed : Integer
var $linesCreated : Integer
var $notesCreated : Integer
var $linkedVendor : Integer
var $missingVendor : Integer

// drop the notes attached to the buy orders that are about to be truncated,
// so re-running the import does not leave orphaned comments behind
ds:C1482.sfw_Comment.query("UUID_target IN :1"; ds:C1482.BuyingOrder.all().UUID).drop()

TRUNCATE TABLE:C1051([BuyingOrderLine:64])
TRUNCATE TABLE:C1051([BuyingOrder:46])

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("buyOrders_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else
	$records:=JSON Parse:C1218($file.getText())

	// terms templates (.4wp files exported by export_vendors_and_contacts);
	// a missing file just means an empty document
	$termsTemplate:=WP New:C1317()
	$templateFile:=$importsFolder.file("BuyOrderTerms.4wp")
	If ($templateFile.exists)
		$termsTemplate:=WP Import document:C1318($templateFile.platformPath)
	End if

	$termsCriticalMaterials:=WP New:C1317()
	$templateFile:=$importsFolder.file("BuyOrderTerms_CriticalMaterials.4wp")
	If ($templateFile.exists)
		$termsCriticalMaterials:=WP Import document:C1318($templateFile.platformPath)
	End if

	$termsCriticalService:=WP New:C1317()
	$templateFile:=$importsFolder.file("BuyOrderTerms_CriticalService.4wp")
	If ($templateFile.exists)
		$termsCriticalService:=WP Import document:C1318($templateFile.platformPath)
	End if

	// per-record Buy_policy_ documents, deduplicated by the export:
	// imports/buyPolicyDocs/<key>.4wp, loaded once and cached by key
	$policyDocs:=New object:C1471()

	$created:=0
	$failed:=0
	$linesCreated:=0
	$notesCreated:=0
	$linkedVendor:=0
	$missingVendor:=0

	// Map vendor customers by normalized name to link the buy order's vendor
	// (only Customer records flagged as vendors are eligible)
	$existingCustomers:=New object:C1471()

	For each ($customer; ds:C1482.Customer.query("vendor = :1"; True:C214))
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

	// Map every job by its number to link the buy line to its job
	$existingJobs:=New object:C1471()

	For each ($job; ds:C1482.Job.all())
		$existingJobs[String:C10($job.jobNumber)]:=$job.UUID
	End for each

	// Map staff by normalized full name (firstName + lastName) to link the
	// requestor, which the export stores as a full name rather than a code
	$existingStaff:=New object:C1471()

	For each ($staff; ds:C1482.Staff.all())
		$staffKey:=Lowercase:C14(String:C10($staff.firstName)+String:C10($staff.lastName))
		$staffKey:=Replace string:C233($staffKey; " "; "")
		$staffKey:=Replace string:C233($staffKey; "."; "")
		$staffKey:=Replace string:C233($staffKey; ","; "")
		$staffKey:=Replace string:C233($staffKey; "-"; "")
		$staffKey:=Replace string:C233($staffKey; "_"; "")
		$staffKey:=Replace string:C233($staffKey; "'"; "")

		If ($staffKey#"")
			$existingStaff[$staffKey]:=$staff.UUID
		End if
	End for each

	For each ($record; $records)

		$bo:=ds:C1482.BuyingOrder.new()

		$bo.boNumber:=$record.boNumber
		$bo.orderDate:=Date:C102(String:C10($record.orderDate))
		$bo.buyOrderLimit:=$record.buyOrderLimit
		$bo.salesTaxRate:=$record.salesTaxRate
		$bo.currency:=String:C10($record.currency)
		$bo.discountDays:=$record.discountDays
		$bo.netDays:=$record.netDays
		$bo.fob:=String:C10($record.fob)
		$bo.shipVia:=String:C10($record.shipVia)
		$bo.division:=String:C10($record.division)
		$bo.salesTax:=$record.salesTax
		$bo.lineItemsTotal:=$record.lineItemsTotal
		$bo.shippingAddress:=String:C10($record.shipping_address)
		$bo.accountNumber:=Num:C11(String:C10($record.glac))
		$bo.closed:=Bool:C1537($record.closed)
		$bo.requisitionOnly:=Bool:C1537($record.requisition)

		// vendor -> customer link (normalized name)
		$customerUUID:=""
		$normalizedName:=Lowercase:C14(String:C10($record.vendor_name))
		$normalizedName:=Replace string:C233($normalizedName; " "; "")
		$normalizedName:=Replace string:C233($normalizedName; "."; "")
		$normalizedName:=Replace string:C233($normalizedName; ","; "")
		$normalizedName:=Replace string:C233($normalizedName; "-"; "")
		$normalizedName:=Replace string:C233($normalizedName; "_"; "")
		$normalizedName:=Replace string:C233($normalizedName; "'"; "")

		If ($normalizedName#"") && ($existingCustomers[$normalizedName]#Null:C1517)
			$customerUUID:=$existingCustomers[$normalizedName]
			$bo.UUID_Customer:=$customerUUID
			$linkedVendor:=$linkedVendor+1
		Else
			$missingVendor:=$missingVendor+1
		End if

		// buyer -> staff link by code
		If (String:C10($record.buyersCode)#"")
			$staff:=ds:C1482.Staff.query("code = :1"; String:C10($record.buyersCode)).first()
			If ($staff#Null:C1517)
				$bo.UUID_Buyer:=$staff.UUID
			End if
		End if

		// requestor -> staff link by full name (the export stores the requestor's
		// full name, not a code); matched against the normalized staff map
		$requestorKey:=Lowercase:C14(String:C10($record.requestor))
		$requestorKey:=Replace string:C233($requestorKey; " "; "")
		$requestorKey:=Replace string:C233($requestorKey; "."; "")
		$requestorKey:=Replace string:C233($requestorKey; ","; "")
		$requestorKey:=Replace string:C233($requestorKey; "-"; "")
		$requestorKey:=Replace string:C233($requestorKey; "_"; "")
		$requestorKey:=Replace string:C233($requestorKey; "'"; "")
		If ($requestorKey#"") && ($existingStaff[$requestorKey]#Null:C1517)
			$bo.UUID_Requestor:=$existingStaff[$requestorKey]
		End if

		// attention to -> contact of the vendor by name
		If ($customerUUID#"") && (String:C10($record.attention.name)#"")
			$eContact:=ds:C1482.Contact.query("UUID_Company = :1 and firstName = :2"; $customerUUID; String:C10($record.attention.name)).first()
			If ($eContact#Null:C1517)
				$bo.UUID_AttentionTo:=$eContact.UUID
			End if
		End if

		// addresses -> contactDetails (billing/shipping/remit), built locally
		// and assigned once (same rule as _import_vendors)
		$contactDetails:=New object:C1471()
		$addresses:=New collection:C1472()

		If (String:C10($record.vendor_address.address_1)#"") | (String:C10($record.vendor_address.city)#"")
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

		If (String:C10($record.shipping_address)#"")
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

		If (String:C10($record.remit_to_address.address_1)#"") | (String:C10($record.remit_to_address.city)#"")
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
		$bo.contactDetails:=$contactDetails

		// terms: the record's legacy applied policy (Buy_policy_) when it was
		// exported, otherwise the default template; the two critical variants
		// always start from the templates
		$policyKey:=String:C10($record.buyPolicyKey)

		If ($policyKey#"") && ($policyDocs[$policyKey]=Null:C1517)
			$policyFile:=$importsFolder.folder("buyPolicyDocs").file($policyKey+".4wp")
			If ($policyFile.exists)
				$policyDocs[$policyKey]:=WP Import document:C1318($policyFile.platformPath)
			End if
		End if

		If ($policyKey#"") && ($policyDocs[$policyKey]#Null:C1517)
			$bo.terms:=$policyDocs[$policyKey]
		Else
			$bo.terms:=$termsTemplate
		End if

		$bo.termsCriticalMaterials:=$termsCriticalMaterials
		$bo.termsCriticalService:=$termsCriticalService

		// no direct column in the new table -> moreData
		$moreData:=New object:C1471()
		$moreData.addTerms:=$record.addTerms
		$moreData.totalPaid:=$record.totalPaid
		$moreData.totalDue:=$record.totalDue
		$moreData.requestor:=$record.requestor
		$moreData.onHold:=Bool:C1537($record.onHold)
		$moreData.nonApproved:=Bool:C1537($record.nonApproved)
		$moreData.glac:=$record.glac
		$moreData.asset:=Bool:C1537($record.asset)
		$moreData.dateClosed:=$record.dateClosed
		$moreData.autoInc:=Bool:C1537($record.autoInc)
		$moreData.buyPolicyKey:=$record.buyPolicyKey
		$moreData.attention:=$record.attention
		$moreData.buyerName:=$record.buyer
		$moreData.legacyApprover1:=$record.approver1
		$moreData.legacyApprover2:=$record.approver2
		$moreData.legacySignature1:=$record.signature1
		$moreData.legacySignature2:=$record.signature2
		$moreData.legacyDateTimeStamp:=$record.dateTimeStamp
		$moreData.legacyCreationDateTimeStamp:=$record.creationDateTimeStamp
		$moreData.legacyUniqueID:=$record.uniqueID
		$bo.moreData:=$moreData

		$result:=$bo.save()

		If (Not:C34($result.success))
			$failed:=$failed+1
			TRACE:C157
		Else
			$created:=$created+1

			// Legacy internal notes -> built-in notes feature (sfw_Comment):
			// the legacy field holds several notes separated by \r, each one
			// becomes its own note on the buy order
			$notes:=Replace string:C233(String:C10($record.internalNotes); "\r\n"; "\r")
			$notes:=Replace string:C233($notes; "\n"; "\r")
			$noteItems:=Split string:C1554($notes; "\r"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)

			For each ($note; $noteItems)
				$eComment:=ds:C1482.sfw_Comment.new()
				$eComment.UUID:=Generate UUID:C1066
				$eComment.UUID_target:=$bo.UUID
				$eComment.stmp:=cs:C1710.sfw_stmp.me.now()
				$eComment.ID_level:=1
				$eComment.comment:=$note
				$result:=$eComment.save()
				If ($result.success)
					$notesCreated:=$notesCreated+1
				Else
					TRACE:C157
				End if
			End for each

			If ($record.lines#Null:C1517)
				$lineOrder:=0
				For each ($line; $record.lines)

					$boLine:=ds:C1482.BuyingOrderLine.new()

					$boLine.UUID_BuyingOrder:=$bo.UUID
					$boLine.boNumber:=$record.boNumber
					$lineOrder:=$lineOrder+1
					$boLine.order:=$lineOrder
					$boLine.legacySeqNum:=Num:C11($line.seqNumber)
					$boLine.description:=String:C10($line.description)
					$boLine.qty:=Num:C11($line.qty)
					$boLine.qtyOrdered:=Num:C11($line.qty)
					$boLine.units:=String:C10($line.units)
					$boLine.unitPrice:=$line.unitPrice
					$boLine.lineTotal:=$line.lineTotal
					$boLine.glAccount:=String:C10($line.glAccount)
					$boLine.checkNumber:=Num:C11($line.checkNumber)
					$boLine.amountPaid:=$line.totalPaid
					$boLine.jobNumber:=Num:C11($line.jobNumber)
					If ($existingJobs[String:C10(Num:C11($line.jobNumber))]#Null:C1517)
						$boLine.UUID_Job:=$existingJobs[String:C10(Num:C11($line.jobNumber))]
					End if
					$boLine.assetListNumber:=Num:C11($line.assetListNumber)
					$boLine.supPsNumber:=Num:C11($line.supPsNumber)
					$boLine.qtyReceived:=Num:C11($line.qtyIn)
					$boLine.taxable:=Bool:C1537($line.taxable)
					$boLine.tax:=Num:C11($line.tax)
					$boLine.inventory:=Bool:C1537($line.inventory)
					$boLine.orderDate:=Date:C102(String:C10($line.orderDate))
					$boLine.requiredDate:=Date:C102(String:C10($line.requiredDate))
					$boLine.dateIn:=Date:C102(String:C10($line.dateIn))
					$boLine.paidDate:=Date:C102(String:C10($line.paidDate))

					$moreData:=New object:C1471()
					$moreData.receivedBy:=$line.receivedBy
					$moreData.freight:=$line.freight
					$moreData.item:=$line.item
					$moreData.tax:=$line.tax
					$moreData.okToPay:=Bool:C1537($line.okToPay)
					$moreData.payAmount:=$line.payAmount
					$moreData.amountOutstanding:=$line.amountOutstanding
					$moreData.vendor:=$line.vendor
					$moreData.invoiceNumber:=$line.invoiceNumber
					$moreData.invoiceDate:=$line.invoiceDate
					$moreData.payBefore:=$line.payBefore
					$moreData.returnToVendor:=Bool:C1537($line.returnToVendor)
					$moreData.exception:=$line.exception
					$moreData.multiChecks:=Bool:C1537($line.multiChecks)
					$moreData.lastPayDate:=$line.lastPayDate
					$moreData.inventory:=Bool:C1537($line.inventory)
					$moreData.consumable:=Bool:C1537($line.consumable)
					$moreData.partNumber:=$line.partNumber
					$moreData.discountDays:=$line.discountDays
					$moreData.relationalString:=$line.relationalString
					$moreData.division:=$line.division
					$moreData.asset:=Bool:C1537($line.asset)
					$moreData.disputedInvoice:=Bool:C1537($line.disputedInvoice)
					$moreData.vendorPartNumber:=$line.vendorPartNumber
					$moreData.invalid:=Bool:C1537($line.invalid)
					$moreData.currency:=$line.currency
					$moreData.virtualInventory:=Bool:C1537($line.virtualInventory)
					$moreData.legacySeqNumber:=$line.seqNumber
					$moreData.checkFlag:=Bool:C1537($line.checkFlag)
					$moreData.units:=$line.units
					$moreData.unitPriceWithSalesTax:=$line.unitPriceWithSalesTax
					$moreData.documentsInDocServer:=$line.documentsInDocServer
					$moreData.confirmationDate:=$line.confirmationDate
					$moreData.comments:=$line.comments
					$moreData.billRecognitionDate:=$line.billRecognitionDate
					$moreData.legacyDateTimeStamp:=$line.dateTimeStamp
					$moreData.legacyCreationDateTimeStamp:=$line.creationDateTimeStamp
					$moreData.legacyUniqueID:=$line.uniqueID
					$boLine.moreData:=$moreData

					$result:=$boLine.save()

					If ($result.success)
						$linesCreated:=$linesCreated+1
					Else
						$failed:=$failed+1
						TRACE:C157
					End if
				End for each
			End if
		End if
	End for each

	ALERT:C41("Import termine - buy orders created: "+String:C10($created)+" | lines created: "+String:C10($linesCreated)+" | notes created: "+String:C10($notesCreated)+" | vendors linked: "+String:C10($linkedVendor)+" | vendors missing: "+String:C10($missingVendor)+" | failed: "+String:C10($failed))
End if
