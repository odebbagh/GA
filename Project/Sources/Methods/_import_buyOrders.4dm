//%attributes = {}

// Imports project/imports/buyOrders_export.json into [BuyingOrder] and
// [BuyingOrderLine].
// - vendor is linked to [Supplier] by normalized name (Supplier carries the QA
//   apparatus and is what AML points at, so a line's part and its order resolve
//   the same company)
// - buyer/requestor are linked to [Staff] by normalized full name when a match exists
// - attention to is linked to the vendor's [Contact] by name
// - addresses go into BuyingOrder.contactDetails (billing/shipping/remit)
// - terms/termsCritical* are filled from the .4wp files exported next to the
//   json (templates + deduplicated per-record Buy_policy_ documents)
// - receiver is linked to [Staff] by the legacy employee code (Recd_by -> Staff.code)
// - division is linked to [Division] by name; part numbers are linked to [AML],
//   scoped to the order's supplier
// - legacy fields with no direct column are kept in moreData

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $line : Object
var $bo : cs:C1710.BuyingOrderEntity
var $boLine : cs:C1710.BuyingOrderLineEntity
var $supplier : cs:C1710.SupplierEntity
var $staff : cs:C1710.StaffEntity
var $eContact : cs:C1710.ContactEntity
var $existingSuppliers : Object
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
var $supplierUUID : Text
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
var $eCarrier : cs:C1710.CustomerCarrierEntity
var $existingCarriers : Object
var $carrierKey : Text
var $unmatchedCarriers : Collection
var $linkedCarrier : Integer
var $missingCarrier : Integer
var $noCarrierValue : Integer
var $eUnit : cs:C1710.UnitEntity
var $existingUnits : Object
var $existingUnitUUID : Object
var $unitKey : Text
var $lineUUIDByKey : Object
var $splitChildren : Collection
var $splitChild : Object
var $childLine : cs:C1710.BuyingOrderLineEntity
var $parentUUID : Text
var $itemValue : Real
var $baseNumber; $splitLevel; $splitLinked; $splitOrphan : Integer
var $unmatchedUnits : Collection
var $linkedUnit : Integer
var $missingUnit : Integer
var $noUnitValue : Integer
var $existingStaffByCode : Object
var $existingContact : Object
var $existingGLAccount : Object
var $glAccountClass : 4D:C1709.DataClass
var $glAccountRow : Object
var $glacKey : Text
var $glLinkedOrders; $glLinkedLines; $glUnmatched : Integer
var $contactKey; $attentionKey : Text
var $unmatchedAttention : Integer
var $existingDivisions : Object
var $eDivision : cs:C1710.DivisionEntity
var $eAML : cs:C1710.AMLEntity
var $existingAML : Object
var $existingAMLByCode : Object
var $amlKey : Text
var $partKey : Text
var $partCodeKey : Text
var $amlCodeKey : Text
var $supplierPrefix : Text
var $receiverCode : Text
var $divisionKey : Text
var $linkedReceiver : Integer
var $missingReceiver : Integer
var $noReceiverValue : Integer
var $unmatchedReceivers : Collection
var $linkedDivision : Integer
var $missingDivision : Integer
var $noDivisionValue : Integer
var $unmatchedDivisions : Collection
var $linkedAML : Integer
var $linkedAMLByCode : Integer
var $ambiguousAMLCode : Integer
var $missingAML : Integer
var $noPartValue : Integer
var $unmatchedParts : Collection

// drop the notes attached to the buy orders AND their lines that are about to be
// truncated, so re-running the import does not leave orphaned comments behind
ds:C1482.sfw_Comment.query("UUID_target IN :1"; ds:C1482.BuyingOrder.all().UUID).drop()
ds:C1482.sfw_Comment.query("UUID_target IN :1"; ds:C1482.BuyingOrderLine.all().UUID).drop()

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
	$linkedCarrier:=0
	$missingCarrier:=0
	$noCarrierValue:=0
	$unmatchedCarriers:=New collection:C1472
	$linkedUnit:=0
	$missingUnit:=0
	$noUnitValue:=0
	$unmatchedUnits:=New collection:C1472
	$linkedReceiver:=0
	$missingReceiver:=0
	$noReceiverValue:=0
	$unmatchedReceivers:=New collection:C1472
	$linkedDivision:=0
	$missingDivision:=0
	$noDivisionValue:=0
	$unmatchedDivisions:=New collection:C1472
	$linkedAML:=0
	$linkedAMLByCode:=0
	$ambiguousAMLCode:=0
	$missingAML:=0
	$noPartValue:=0
	$unmatchedParts:=New collection:C1472

	// Map SUPPLIERS by normalized name to link the buy order to its vendor.
	// Supplier is the faithful port of legacy [Suppliers] and carries the QA approval
	// apparatus (approvedByQA, disqualified, audits) the legacy rules depend on. AML
	// points here too, so a line's part and its order resolve the SAME company.
	$existingSuppliers:=New object:C1471()

	For each ($supplier; ds:C1482.Supplier.all())
		$normalizedName:=Lowercase:C14($supplier.name)
		$normalizedName:=Replace string:C233($normalizedName; " "; "")
		$normalizedName:=Replace string:C233($normalizedName; "."; "")
		$normalizedName:=Replace string:C233($normalizedName; ","; "")
		$normalizedName:=Replace string:C233($normalizedName; "-"; "")
		$normalizedName:=Replace string:C233($normalizedName; "_"; "")
		$normalizedName:=Replace string:C233($normalizedName; "'"; "")

		If ($normalizedName#"")
			$existingSuppliers[$normalizedName]:=$supplier.UUID
		End if
	End for each

	// Map every unit of measure by its folded key, plus the legacy spellings kept as
	// aliases on the row, so a buy line whose Units reads "PKG" or "Hrs" lands on the
	// "Pack" / "Hour" row of [Unit]. _import_units seeds both.
	// BuyingOrderLine.units is a text column, not a foreign key, so linking here means
	// writing the canonical [Unit] name into it. The raw legacy value stays in
	// moreData.units, so nothing is lost.
	$existingUnits:=New object:C1471()
	$existingUnitUUID:=New object:C1471()

	For each ($eUnit; ds:C1482.Unit.all())
		$unitKey:=_unitMatchKey($eUnit.name)
		If ($unitKey#"")
			$existingUnits[$unitKey]:=$eUnit.name
			$existingUnitUUID[$unitKey]:=$eUnit.UUID
		End if
		If ($eUnit.moreData.aliasKeys#Null:C1517)
			For each ($unitKey; $eUnit.moreData.aliasKeys)
				If ($unitKey#"") && ($existingUnits[$unitKey]=Null:C1517)
					$existingUnits[$unitKey]:=$eUnit.name
					$existingUnitUUID[$unitKey]:=$eUnit.UUID
				End if
			End for each
		End if
	End for each

	// Map every carrier by its folded key, plus the legacy spellings kept as aliases
	// on the row, so a shipVia of "fedex Std Overnight" reaches
	// "FedEx Standard Overnight". _import_customerCarriers seeds both.
	$existingCarriers:=New object:C1471()

	For each ($eCarrier; ds:C1482.CustomerCarrier.all())
		$carrierKey:=_carrierMatchKey($eCarrier.name)
		If ($carrierKey#"")
			$existingCarriers[$carrierKey]:=$eCarrier.UUID
		End if
		If ($eCarrier.moreData.aliasKeys#Null:C1517)
			For each ($carrierKey; $eCarrier.moreData.aliasKeys)
				If ($carrierKey#"") && ($existingCarriers[$carrierKey]=Null:C1517)
					$existingCarriers[$carrierKey]:=$eCarrier.UUID
				End if
			End for each
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


	// Map staff by legacy EMPLOYEE CODE for the line receiver. Recd_by is a six-digit
	// code ("001492"), not a name, so the full-name map above cannot serve it.
	// _newStaffFor writes that code verbatim into Staff.code, which is the join key.
	// Requires _import_users to have run - without Staff rows every line reports as
	// an unmatched receiver rather than failing.
	$existingStaffByCode:=New object:C1471()

	For each ($staff; ds:C1482.Staff.all())
		$receiverCode:=Replace string:C233(String:C10($staff.code); " "; "")
		If ($receiverCode#"")
			$existingStaffByCode[$receiverCode]:=$staff.UUID
		End if
	End for each

	// Map the GL accounts by their code, so the buy order and its lines carry the LINK
	// and not only the legacy text.
	//
	// _import_glAccounts also back-links, but this import TRUNCATES both tables, so a
	// re-run would otherwise drop every link until the GL import was run again. Doing it
	// here makes the two imports order-independent: whichever runs last, the links hold.
	//
	// The table and the FK are both optional - a database without them imports exactly
	// as before and the counters simply read zero.
	$existingGLAccount:=New object:C1471()
	$glAccountClass:=ds:C1482["GLAccount"]

	If ($glAccountClass#Null:C1517)
		For each ($glAccountRow; $glAccountClass.all())
			$glacKey:=String:C10($glAccountRow.glac)
			If ($glacKey#"") && ($existingGLAccount[$glacKey]=Null:C1517)
				$existingGLAccount[$glacKey]:=$glAccountRow.UUID
			End if
		End for each
	End if
	// Map the vendors' contacts by supplier + normalized FULL name, for "attention to".
	//
	// The export stores attention as a whole name - "GREGORIO  LA ROSA", "HARRY MOROYAN",
	// often with a double space - while this table splits it into firstName/lastName.
	// The previous matcher compared that whole string against firstName alone, so it hit
	// only the handful of contacts whose first name happened to be the entire name:
	// 3,759 of the 3,898 orders carrying an attention name could never match, and their
	// UUID_AttentionTo was left empty.
	//
	// Same folding as $existingStaff above: lowercase, strip spaces and punctuation, so
	// the double spaces and any "LA ROSA" / "LAROSA" difference stop mattering. Keyed by
	// supplier as well, because two vendors can both have a "John Smith".
	$existingContact:=New object:C1471()

	For each ($eContact; ds:C1482.Contact.all())
		$contactKey:=Lowercase:C14(String:C10($eContact.firstName)+String:C10($eContact.lastName))
		$contactKey:=Replace string:C233($contactKey; " "; "")
		$contactKey:=Replace string:C233($contactKey; "."; "")
		$contactKey:=Replace string:C233($contactKey; ","; "")
		$contactKey:=Replace string:C233($contactKey; "-"; "")
		$contactKey:=Replace string:C233($contactKey; "_"; "")
		$contactKey:=Replace string:C233($contactKey; "'"; "")

		If ($contactKey#"") && (String:C10($eContact.UUID_Company)#"")
			//---first one wins, so a duplicated contact cannot flip the link between runs
			If ($existingContact[String:C10($eContact.UUID_Company)+"|"+$contactKey]=Null:C1517)
				$existingContact[String:C10($eContact.UUID_Company)+"|"+$contactKey]:=$eContact.UUID
			End if
		End if
	End for each
	// Map divisions by folded name. Every legacy buy line reads "GAC", the one row
	// that exists, but the map is built generically so a second division needs no
	// code change. Unlike _newStaffFor this does NOT create missing divisions - an
	// unexpected value is reported instead of silently minting a row.
	$existingDivisions:=New object:C1471()

	For each ($eDivision; ds:C1482.Division.all())
		$divisionKey:=Lowercase:C14(Replace string:C233(String:C10($eDivision.name); " "; ""))
		If ($divisionKey#"")
			$existingDivisions[$divisionKey]:=$eDivision.UUID
		End if
	End for each

	// Map AML rows by SUPPLIER + our part number. The legacy picker (BI_EntryF/Field17)
	// filtered AVL on "Supplier = the order's vendor" + Service=False + MakeInactive=False,
	// so a bare part-number match is not equivalent: the same part number can exist for
	// several vendors and matching across them is precisely the cross-vendor bug the
	// Supplier decision was taken to avoid. Scoped lookup only; misses are reported.
	// isApproved is deliberately NOT filtered here - historical lines were placed before
	// that flag existed, so requiring it would drop legitimate links.
	$existingAML:=New object:C1471()
	$existingAMLByCode:=New object:C1471()

	For each ($eAML; ds:C1482.AML.query("service = :1 and makeInactive = :2"; False:C215; False:C215))
		$partKey:=_amlPartKey($eAML.ourPartNum; False:C215)
		If ($partKey#"") && (String:C10($eAML.UUID_Supplier)#"")
			$amlKey:=String:C10($eAML.UUID_Supplier)+"|"+$partKey
			If ($existingAML[$amlKey]=Null:C1517)
				$existingAML[$amlKey]:=$eAML.UUID
			End if

			// AML carries the same "code + description" spelling the buy lines do - 146 of
			// its 394 rows have a description glued onto ourPartNum, and the two sides word
			// it differently ("CF-015    LOCTITE ABLESTIK QMI2569" against
			// "CF-015   LOCTITE ABLESTIK QMI2569"). So the leading-code fallback has to fold
			// BOTH sides, not just the line: a second map, keyed on the code alone.
			//
			// A code that resolves to two different AML rows for one supplier is stored as
			// "" and skipped at lookup. Guessing between them would invent a link, which is
			// worse than leaving the line unmatched.
			$amlCodeKey:=_amlPartKey($eAML.ourPartNum; True:C214)
			If ($amlCodeKey#"")
				$amlCodeKey:=String:C10($eAML.UUID_Supplier)+"|"+$amlCodeKey
				Case of
					: ($existingAMLByCode[$amlCodeKey]=Null:C1517)
						$existingAMLByCode[$amlCodeKey]:=$eAML.UUID
					: ($existingAMLByCode[$amlCodeKey]#$eAML.UUID)
						$existingAMLByCode[$amlCodeKey]:=""  // ambiguous, never used
				End case
			End if
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
		// shipVia: the legacy free text is kept as it was, and the same value is
		// resolved to the [CustomerCarrier] lookup so the panel can show a real link.
		// No match leaves UUID_CustomerCarrier empty rather than inventing a carrier.
		$bo.shipVia:=String:C10($record.shipVia)
		$carrierKey:=_carrierMatchKey($bo.shipVia)
		Case of
			: ($carrierKey="")
				$noCarrierValue:=$noCarrierValue+1
			: ($existingCarriers[$carrierKey]#Null:C1517)
				$bo.UUID_CustomerCarrier:=$existingCarriers[$carrierKey]
				$linkedCarrier:=$linkedCarrier+1
			Else
				$missingCarrier:=$missingCarrier+1
				If ($unmatchedCarriers.indexOf($bo.shipVia)=-1)
					$unmatchedCarriers.push($bo.shipVia)
				End if
		End case
		$bo.division:=String:C10($record.division)
		$bo.salesTax:=$record.salesTax
		$bo.lineItemsTotal:=$record.lineItemsTotal
		$bo.shippingAddress:=String:C10($record.shipping_address)
		$bo.accountNumber:=Num:C11(String:C10($record.glac))

		//---the order's GL account as a LINK. accountNumber above is the same value as a
		//   number, which truncates a code like "5110-1" at the dash; moreData.glac keeps
		//   the text verbatim and is what the match is made on.
		If ($existingGLAccount[String:C10($record.glac)]#Null:C1517)
			$bo.UUID_GLAccount:=$existingGLAccount[String:C10($record.glac)]
			$glLinkedOrders:=$glLinkedOrders+1
		Else
			If (String:C10($record.glac)#"")
				$glUnmatched:=$glUnmatched+1
			End if
		End if
		$bo.closed:=Bool:C1537($record.closed)
		//---requisitionOnly is NOT written any more. Legacy [BUY_ORDERS]Requistion was a
		//   cache its trigger recomputed on every save, never a fact of its own, so it is
		//   derived here instead - see BuyingOrderEntity.awaitingApproval. The column can
		//   be dropped from the structure.

		// vendor -> customer link (normalized name)
		$supplierUUID:=""
		$normalizedName:=Lowercase:C14(String:C10($record.vendor_name))
		$normalizedName:=Replace string:C233($normalizedName; " "; "")
		$normalizedName:=Replace string:C233($normalizedName; "."; "")
		$normalizedName:=Replace string:C233($normalizedName; ","; "")
		$normalizedName:=Replace string:C233($normalizedName; "-"; "")
		$normalizedName:=Replace string:C233($normalizedName; "_"; "")
		$normalizedName:=Replace string:C233($normalizedName; "'"; "")

		If ($normalizedName#"") && ($existingSuppliers[$normalizedName]#Null:C1517)
			$supplierUUID:=$existingSuppliers[$normalizedName]
			$bo.UUID_Supplier:=$supplierUUID
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

		// attention to -> contact of the vendor, matched on the folded FULL name
		If ($supplierUUID#"") && (String:C10($record.attention.name)#"")
			$attentionKey:=Lowercase:C14(String:C10($record.attention.name))
			$attentionKey:=Replace string:C233($attentionKey; " "; "")
			$attentionKey:=Replace string:C233($attentionKey; "."; "")
			$attentionKey:=Replace string:C233($attentionKey; ","; "")
			$attentionKey:=Replace string:C233($attentionKey; "-"; "")
			$attentionKey:=Replace string:C233($attentionKey; "_"; "")
			$attentionKey:=Replace string:C233($attentionKey; "'"; "")

			If ($attentionKey#"") && ($existingContact[$supplierUUID+"|"+$attentionKey]#Null:C1517)
				$bo.UUID_AttentionTo:=$existingContact[$supplierUUID+"|"+$attentionKey]
			Else
				//---no contact of that name for this vendor. The raw value is already kept
				//   in moreData.attention, so nothing is lost; it just is not a link.
				$unmatchedAttention:=$unmatchedAttention+1
			End if
		End if

		// addresses -> contactDetails (billing/shipping/remit), built locally
		// and assigned once (same rule as _import_vendors)
		$contactDetails:=New object:C1471()
		$addresses:=New collection:C1472()

		If (String:C10($record.vendor_address.address_1)#"") | (String:C10($record.vendor_address.city)#"")
			$address:=New object:C1471()
			//---the SUPPLIER's trading address. Named "vendor" rather than "billing" so
			//   it cannot be confused with Bill to, which is our own address and lives on
			//   the division.
			$address.type:="vendor"
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

		//---signed1/signed2 are the live approval state for every order, imported or not,
		//   so the legacy signatures are folded into them here. Legacy [BUY_ORDERS]
		//   Signature1/2 held the literal "Signed" once MatchSignature1/2 accepted the
		//   password, and its table_26 trigger derived Requistion as
		//       (Signature1="" | Signature2="")
		//   which is exactly Not(signed1 and signed2).
		$bo.signed1:=(String:C10($record.signature1)#"")
		$bo.signed2:=(String:C10($record.signature2)#"")
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
				$lineUUIDByKey:=New object:C1471()
				$splitChildren:=New collection:C1472()
				For each ($line; $record.lines)

					$boLine:=ds:C1482.BuyingOrderLine.new()
					$boLine.UUID:=Generate UUID:C1066

					$boLine.UUID_BuyingOrder:=$bo.UUID
					$boLine.boNumber:=$record.boNumber
					$lineOrder:=$lineOrder+1
					$boLine.order:=$lineOrder
					$boLine.legacySeqNum:=Num:C11($line.seqNumber)
					$boLine.description:=String:C10($line.description)
					$boLine.qty:=Num:C11($line.qty)
					$boLine.qtyOrdered:=Num:C11($line.qty)
					// units: resolved to the canonical [Unit] name. No match keeps the
					// legacy text as it was rather than inventing a unit.
					$boLine.units:=String:C10($line.units)
					$unitKey:=_unitMatchKey($boLine.units)
					Case of
						: ($unitKey="")
							$noUnitValue:=$noUnitValue+1
						: ($existingUnits[$unitKey]#Null:C1517)
							$boLine.units:=$existingUnits[$unitKey]
							$boLine.UUID_Unit:=$existingUnitUUID[$unitKey]  // the relation existed but was never set
							$linkedUnit:=$linkedUnit+1
						Else
							$missingUnit:=$missingUnit+1
							If ($unmatchedUnits.indexOf(String:C10($line.units))=-1)
								$unmatchedUnits.push(String:C10($line.units))
							End if
					End case
					$boLine.unitPrice:=$line.unitPrice
					$boLine.lineTotal:=$line.lineTotal
					$boLine.glAccount:=String:C10($line.glAccount)

					//---and the link, same map
					If ($existingGLAccount[String:C10($line.glAccount)]#Null:C1517)
						$boLine.UUID_GLAccount:=$existingGLAccount[String:C10($line.glAccount)]
						$glLinkedLines:=$glLinkedLines+1
					Else
						If (String:C10($line.glAccount)#"")
							$glUnmatched:=$glUnmatched+1
						End if
					End if
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
					// The line number within the order. Legacy [BUY_ITEMS]Item is a REAL, and a
					// partial receipt duplicated the line with Item+0.1 - so 1, 1.1, 1.2 is ONE
					// PO line split twice, not three lines. number is Integer here, so writing
					// Num(item) straight into it rounded 1.1 back to 1 and silently collapsed
					// 162 rows onto duplicate item numbers across 66 orders.
					// The split is now a link instead, the same shape [Lot] already uses
					// (UUID_LotParent / splitLevel): number stays the PO line number the vendor
					// was sent, and splitLevel counts the generation. The parent link is wired
					// in a second pass below, once every line of the order has a UUID.
					$itemValue:=Num:C11($line.item)
					$baseNumber:=Int:C8($itemValue)
					$splitLevel:=Round:C94(($itemValue-$baseNumber)*10; 0)
					$boLine.number:=$baseNumber
					$boLine.splitLevel:=$splitLevel
					$lineUUIDByKey[String:C10($baseNumber)+"|"+String:C10($splitLevel)]:=$boLine.UUID
					If ($splitLevel>0)
						$splitChildren.push(New object:C1471("uuid"; $boLine.UUID; "base"; $baseNumber; "level"; $splitLevel))
					End if 
					$boLine.confirmationDate:=Date:C102(String:C10($line.confirmationDate))

					// ---- second pass: columns and relations added in U1/U2 --------------
					// freight is a per-line shipping cost that sits OUTSIDE lineTotal: it adds
					// to what is owed but is not part of the goods' value.
					$boLine.freight:=Num:C11($line.freight)
					// GL classification. NOT mutually exclusive in the legacy data: every
					// inventory=true line is also asset=true (710 of 710), so these are
					// carried across verbatim rather than collapsed into one state.
					$boLine.consumable:=Bool:C1537($line.consumable)
					$boLine.asset:=Bool:C1537($line.asset)
					// Real money, and the entered field when an order is in VAT mode.
					$boLine.unitPriceWithTax:=Num:C11($line.unitPriceWithSalesTax)

					// receiver: Recd_by holds a legacy employee code, matched on Staff.code
					$receiverCode:=Replace string:C233(String:C10($line.receivedBy); " "; "")
					Case of
						: ($receiverCode="")
							$noReceiverValue:=$noReceiverValue+1
						: ($existingStaffByCode[$receiverCode]#Null:C1517)
							$boLine.UUID_Staff:=$existingStaffByCode[$receiverCode]
							$linkedReceiver:=$linkedReceiver+1
						Else
							$missingReceiver:=$missingReceiver+1
							If ($unmatchedReceivers.indexOf($receiverCode)=-1)
								$unmatchedReceivers.push($receiverCode)
							End if
					End case

					// division: matched by name, never created
					$divisionKey:=Lowercase:C14(Replace string:C233(String:C10($line.division); " "; ""))
					Case of
						: ($divisionKey="")
							$noDivisionValue:=$noDivisionValue+1
						: ($existingDivisions[$divisionKey]#Null:C1517)
							$boLine.UUID_Division:=$existingDivisions[$divisionKey]
							$linkedDivision:=$linkedDivision+1
						Else
							$missingDivision:=$missingDivision+1
							If ($unmatchedDivisions.indexOf(String:C10($line.division))=-1)
								$unmatchedDivisions.push(String:C10($line.division))
							End if
					End case

					// aml: one relation replaces both Part_num and Vendor_partnum. Scoped to
					// the order's supplier, so an unlinked order can never produce a link.
					// Only about 1,371 of 11,860 legacy lines carry a part number at all.
					$partKey:=_amlPartKey($line.partNumber; False:C215)
					// Fallback for the "code + description" spelling, folded on both sides - see the
					// map above and _amlPartKey. Empty when the value has no distinct leading code,
					// so it can never fire on a part number that is already whole.
					$partCodeKey:=_amlPartKey($line.partNumber; True:C214)
					$supplierPrefix:=String:C10($bo.UUID_Supplier)+"|"
					Case of
						: ($partKey="") | (String:C10($bo.UUID_Supplier)="")
							$noPartValue:=$noPartValue+1
						: ($existingAML[$supplierPrefix+$partKey]#Null:C1517)
							$boLine.UUID_AML:=$existingAML[$supplierPrefix+$partKey]
							$linkedAML:=$linkedAML+1
						: ($partCodeKey#"") && ($existingAMLByCode[$supplierPrefix+$partCodeKey]="")
							// the code maps to more than one AML row for this supplier: leave it unlinked
							// rather than pick one of them
							$ambiguousAMLCode:=$ambiguousAMLCode+1
						: ($partCodeKey#"") && ($existingAMLByCode[$supplierPrefix+$partCodeKey]#Null:C1517)
							$boLine.UUID_AML:=$existingAMLByCode[$supplierPrefix+$partCodeKey]
							$linkedAMLByCode:=$linkedAMLByCode+1
						Else
							$missingAML:=$missingAML+1
							If ($unmatchedParts.indexOf(String:C10($line.partNumber))=-1)
								$unmatchedParts.push(String:C10($line.partNumber))
							End if
					End case

					$moreData:=New object:C1471()

					// Fields that still belong to modules this application does not have yet
					// (accounts payable), plus the legacy identity keys. Grouped under one
					// clearly named bag so a legacy value is never mistaken for live data.
					// See Documentation/buyItems_field_migration.md.
					$moreData.legacy:=New object:C1471(\
						"invoiceNumber"; $line.invoiceNumber; \
						"invoiceDate"; $line.invoiceDate; \
						"billRecognitionDate"; $line.billRecognitionDate; \
						"payAmount"; $line.payAmount; \
						"amountOutstanding"; $line.amountOutstanding; \
						"okToPay"; Bool:C1537($line.okToPay); \
						"multiChecks"; Bool:C1537($line.multiChecks); \
						"lastPayDate"; $line.lastPayDate; \
						"payBefore"; $line.payBefore; \
						"disputedInvoice"; Bool:C1537($line.disputedInvoice); \
						"discountDays"; $line.discountDays; \
						"invalid"; Bool:C1537($line.invalid); \
						"checkFlag"; Bool:C1537($line.checkFlag); \
						"exception"; $line.exception; \
						"item"; $line.item; \
						"seqNumber"; $line.seqNumber; \
						"uniqueID"; $line.uniqueID; \
						"dateTimeStamp"; $line.dateTimeStamp; \
						"creationDateTimeStamp"; $line.creationDateTimeStamp; \
						"comments"; $line.comments; \
						"units"; $line.units; \
						"partNumber"; $line.partNumber; \
						"vendorPartNumber"; $line.vendorPartNumber\
						)

					// The vendor-returns workflow does not exist in GA (section 3 of the
					// migration document). This is NOT waiting on a column - it is waiting on
					// a workflow, so it is kept apart from anything the second pass consumed.
					$moreData.pendingWorkflow:=New object:C1471(\
						"returnToVendor"; Bool:C1537($line.returnToVendor)\
						)

					// Deliberately NOT carried over:
					//   vendor               - buyingOrder.supplier already gives it
					//   relationalString     - superseded by real UUID relations
					//   currency             - always "US$" in the legacy data; client confirmed
					//   documentsInDocServer - superseded by the framework Documents feature
					//   inventory / tax      - real columns above; no duplicate here
					//
					// virtualInventory is NOT carried either, but that is a known gap rather than
					// a cleanup: it is set on 654 lines and is perfectly disjoint from inventory
					// (zero overlap across 11,860 rows), so it is a fourth classification state,
					// not a duplicate. It needs its own boolean column; until then every re-run of
					// this import loses it. See the O1 findings in
					// Documentation/buyItems_field_migration.md.


					$boLine.moreData:=$moreData

					$result:=$boLine.save()

					If ($result.success)
						$linesCreated:=$linesCreated+1

						// Legacy line comments -> built-in notes feature (sfw_Comment), the same
						// way the buy order's internal notes are handled above. The boItems entry
						// has activateComment(), so these show up in the Notes tab of the line.
						// One legacy field can hold several notes separated by carriage returns;
						// each becomes its own note. The raw text also stays in moreData.comments.
						$notes:=Replace string:C233(String:C10($line.comments); "\r\n"; "\r")
						$notes:=Replace string:C233($notes; "\n"; "\r")
						$noteItems:=Split string:C1554($notes; "\r"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)

						For each ($note; $noteItems)
							$eComment:=ds:C1482.sfw_Comment.new()
							$eComment.UUID:=Generate UUID:C1066
							$eComment.UUID_target:=$boLine.UUID
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
					Else
						$failed:=$failed+1
						TRACE:C157
					End if
				End for each

				//---- backorder chains -------------------------------------------------
				// Second pass, per order: every line now has a UUID, so a split child can be
				// attached to the generation above it. 1.1's parent is 1, 1.2's parent is
				// 1.1. A child whose parent is missing from the order is counted rather than
				// left pointing nowhere.
				For each ($splitChild; $splitChildren)
					$parentUUID:=String:C10($lineUUIDByKey[String:C10($splitChild.base)+"|"+String:C10($splitChild.level-1)])
					If ($parentUUID="")
						$splitOrphan:=$splitOrphan+1
						continue
					End if
					$childLine:=ds:C1482.BuyingOrderLine.query("UUID = :1"; $splitChild.uuid).first()
					If ($childLine=Null:C1517)
						$splitOrphan:=$splitOrphan+1
						continue
					End if
					$childLine.UUID_LineParent:=$parentUUID
					$result:=$childLine.save()
					If ($result.success)
						$splitLinked:=$splitLinked+1
					Else
						$splitOrphan:=$splitOrphan+1
					End if
				End for each
			End if
		End if
	End for each

	ALERT:C41("Import termine - buy orders created: "+String:C10($created)+" | lines created: "+String:C10($linesCreated)+" | backorder links: "+String:C10($splitLinked)+" | backorder orphans: "+String:C10($splitOrphan)+" | notes created: "+String:C10($notesCreated)+" | vendors linked: "+String:C10($linkedVendor)+" | vendors missing: "+String:C10($missingVendor)+" | attention-to unmatched: "+String:C10($unmatchedAttention)+" | GL linked (orders/lines): "+String:C10($glLinkedOrders)+"/"+String:C10($glLinkedLines)+" | GL unmatched: "+String:C10($glUnmatched)+" | failed: "+String:C10($failed)\
		+"\rcarriers linked: "+String:C10($linkedCarrier)+" | no shipVia: "+String:C10($noCarrierValue)+" | shipVia not matched: "+String:C10($missingCarrier)\
		+"\runits linked: "+String:C10($linkedUnit)+" | no unit: "+String:C10($noUnitValue)+" | unit not matched: "+String:C10($missingUnit)\
		+(($unmatchedCarriers.length>0) ? "\r\rshipVia values with no carrier in the lookup:\r"+$unmatchedCarriers.join("\r") : "")\
		+(($unmatchedUnits.length>0) ? "\r\runit values with no row in [Unit]:\r"+$unmatchedUnits.join("\r") : "")\
		+"\rreceivers linked: "+String:C10($linkedReceiver)+" | no Recd_by: "+String:C10($noReceiverValue)+" | Recd_by not matched: "+String:C10($missingReceiver)\
		+"\rdivisions linked: "+String:C10($linkedDivision)+" | no division: "+String:C10($noDivisionValue)+" | division not matched: "+String:C10($missingDivision)\
		+"\rAML linked: "+String:C10($linkedAML)+" | also linked on leading code only: "+String:C10($linkedAMLByCode)+" | no part number: "+String:C10($noPartValue)+" | code ambiguous, skipped: "+String:C10($ambiguousAMLCode)+" | part not in AML for this supplier: "+String:C10($missingAML)\
		+(($unmatchedReceivers.length>0) ? "\r\rRecd_by codes with no row in [Staff] (run _import_users first):\r"+$unmatchedReceivers.join("\r") : "")\
		+(($unmatchedDivisions.length>0) ? "\r\rdivision values with no row in [Division]:\r"+$unmatchedDivisions.join("\r") : "")\
		+(($unmatchedParts.length>0) ? "\r\rpart numbers with no AML row for the order's supplier:\r"+$unmatchedParts.join("\r") : ""))
End if
