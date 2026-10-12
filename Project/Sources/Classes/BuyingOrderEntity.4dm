Class extends Entity


local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.boNumber)

local Function get orderDate()->$date : Date
	$date:=This:C1470.orderStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.orderStmp; True:C214)
	
local Function set orderDate($date : Date)
	This:C1470.orderStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)


local Function rebuildAddress()->$address : Object

	Case of
		: (Form:C1466.addressBilling=1)
			//---"vendor", not "billing". This is the SUPPLIER's trading address - legacy
			//   [BUY_ORDERS]Vendor_add1..Country, the "Issued to:" block on the print.
			//   Calling it billing collided with Bill to, which is OUR address and comes
			//   from the division. The radio variable keeps its name because the Customer,
			//   Job, PO and Vendor panels share it.
			$type:="vendor"
		: (Form:C1466.addressShipping=1)
			$type:="shipping"
		: (Form:C1466.addressRemit=1)
			$type:="remit"
	End case

	If (Form:C1466.subFormAddress=Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
	End if

	If (This:C1470.contactDetails#Null:C1517) && (This:C1470.contactDetails.addresses#Null:C1517)
		$address:=This:C1470.contactDetails.addresses.query("type =:1"; $type).first()
		Form:C1466.subFormAddress.address:=$address

		// while editing, keep the attribute touched so nested address
		// modifications made through the subform are part of the save
		If (Form:C1466.sfw.checkIsInModification())
			This:C1470.contactDetails:=This:C1470.contactDetails
		End if
	Else
		Form:C1466.subFormAddress.address:=Null:C1517
	End if
	Form:C1466.subFormAddress:=Form:C1466.subFormAddress

local Function rebuildContact()->$contacts : Collection
	// The ATTENTION-TO contact's communications, as {name; value; comment} rows for
	// lb_contact on page 1.
	//
	// Not the supplier's. A buy order is addressed to one person - chosen from that
	// vendor's Primary/Secondary contacts through selectContact - and it is that
	// person's phone, fax and email that matter here. So the list stays empty until an
	// Attention To has been picked, and changing the vendor empties it again.
	//
	// Read live from the Contact record rather than copied: a phone number is not part
	// of what was agreed, unlike the addresses, which the order keeps its own copy of.
	var $communications : Collection
	var $object : Object
	var $i : Integer

	$contacts:=New collection:C1472()

	If (This:C1470.contact#Null:C1517) && (This:C1470.contact.contactDetails#Null:C1517)
		$communications:=This:C1470.contact.contactDetails.communications
		If ($communications#Null:C1517)
			For ($i; 0; $communications.length-1)
				$object:=New object:C1471
				$object.name:=$communications[$i].type
				$object.value:=$communications[$i].contact
				$object.comment:=$communications[$i].comment
				$contacts.push($object)
			End for
		End if
	End if

	Form:C1466.lb_contact:=$contacts
local Function loadAfterCreation()
	var $nextNumber : Integer
	var $maxInDb : Integer
	var $all : cs:C1710.BuyingOrderSelection
	
	// Same pattern as customerReceivedMaterial (Lot.number): reserve the next autosequence value.
	$nextNumber:=Sequence number:C244([BuyingOrder:46])
	
	// Keep in sync when existing records were imported with explicit boNumber values.
	$all:=ds:C1482.BuyingOrder.all()
	$maxInDb:=($all.length>0) ? Num:C11($all.max("boNumber")) : 0
	This:C1470.boNumber:=($maxInDb>=$nextNumber) ? ($maxInDb+1) : $nextNumber

	//---The division is not set anywhere else on a new order, and the Division field on
	//   the panel is free text. Default it to the parent division so the order carries
	//   one from the start - legacy took it from <>div, the current division.
	This:C1470.applyDefaultDivision()

	//---Ship to comes from the division and is filled on creation, so a new order carries
	//   our delivery address before a vendor has even been chosen. panel_buyingOrder
	//   refreshes it again when the supplier changes, in case the division changed too.
	This:C1470.applyDivisionShipTo()

	// The issue date is NOT defaulted here Legacy set it from the vendor field's own
	// object method (Buy_Form/Field1), so the date an order carries is the day its
	// supplier was chosen, not the day a blank record was opened. Setting it at creation
	// dated orders that were never completed, and dated an order started on a Friday and
	// filled in on a Monday to the Friday.
	//
	// panel_buyingOrder.selectSupplier fills it instead.

	// Default the status to Requisition on creation
	var $reqStatus : Object
	$reqStatus:=ds:C1482.BOStatus.query("name = :1"; "Requisition").first()
	If ($reqStatus#Null:C1517)
		This:C1470.UUID_Status:=$reqStatus.UUID
	End if
	
	
	

	// ---- Approval ------------------------------------------------------------
	// Legacy [BUY_ORDERS]Requistion was a STORED boolean that trigger table_26
	// recomputed on every save as (Signature1="" | Signature2=""). It was a cache,
	// not a decision, so nothing here stores it: the two approver slots are the
	// state and approval is derived from them.
	//
	// The stored requisitionOnly column is deliberately left alone. It carries what
	// the legacy record said at import time and the Buying panel still shows it;
	// it is history, not the gate.

	// signature1/2 hold the approver's Staff code and are filled by
	// panel_BOReceiving.signApprover. Orders brought over by _import_buyOrders have
	// them EMPTY - that import parks the legacy codes in moreData.legacySignature1/2
	// instead - so those are read as a fallback. Without it no imported order could
	// ever be received.
local Function _signature($slot : Integer)->$signature : Text
	var $moreData : Object

	//---signed1/signed2 (Boolean) are the live signal: panel_buyingOrder.toggleSignature
	//   sets them once the chosen approver has entered their own password. Everything
	//   downstream - approved, awaitingApproval, the receiving gate, the print captions -
	//   goes through this function, so recognising the boolean here is the only change
	//   they need.
	//
	//   Bool(Null) is False, so this is safe before the two columns exist.
	If (Bool:C1537(($slot=1) ? This:C1470.signed1 : This:C1470.signed2))
		$signature:="Signed"
		return
	End if

	//---text signature1/2 and the moreData fallback still answer for imported orders
	$signature:=($slot=1) ? String:C10(This:C1470.signature1) : String:C10(This:C1470.signature2)
	If ($signature="")
		$moreData:=This:C1470.moreData
		If ($moreData#Null:C1517)
			$signature:=($slot=1) ? String:C10($moreData.legacySignature1) : String:C10($moreData.legacySignature2)
		End if 
	End if 

	// Two signatures = approved. This is the gate receiving gets held behind, the
	// same rule recv_mrp enforced with call_abort("This requisition has not been
	// approved").
Function get approved()->$approved : Boolean
	$approved:=(This:C1470._signature(1)#"") & (This:C1470._signature(2)#"")

Function get awaitingApproval()->$result : Boolean
	$result:=Not:C34(This:C1470.approved)

	// Lets the Buying list filter work on the computed attribute instead of a stored
	// cache column. signed1/signed2 are real booleans on every order - _import_buyOrders
	// fills them from the legacy signatures - so the two states are plain queries:
	//
	//     awaiting  = NOT(signed1 AND signed2)  ->  signed1=false OR signed2=false
	//     approved  =     signed1 AND signed2
	//
	// A partially signed order is "awaiting", which is what legacy's trigger said too.
Function query awaitingApproval($event : Object)->$result : cs:C1710.BuyingOrderSelection
	If (Bool:C1537($event.value))
		$result:=This:C1470.query("signed1 = :1 or signed2 = :1"; False:C215)
	Else
		$result:=This:C1470.query("signed1 = :1 and signed2 = :1"; True:C214)
	End if

	//mark:-Printable / document attributes
	//
	// These exist so a document can be driven from the entity itself - either by a print
	// method reading This.<name>, or natively by a Write Pro formula once the template is
	// given the order as its data context. Everything a buy order print needs is here,
	// so adding a field to the print no longer means changing print code.
	//
	// Names deliberately avoid the columns they derive from: the order already has
	// shippingAddress, buyer and division as text columns, and a computed attribute
	// sharing a column or relation name makes This.<name> ambiguous.

	//mark:-Totals

Function recalcTotals()->$changed : Boolean
	// Legacy BO_totalupd: roll the lines up onto the order.
	//
	//     T_Amt      := Sum(Line_total)
	//     T_salestax := Sum(TAX)
	//     T_Paid     := Sum(Pay_amt)      - no accounts payable here, so not carried
	//     T_Due      := T_Amt - T_Paid    - likewise
	//
	// These stay STORED rather than computed, deliberately: lineItemsTotal is the Amount
	// column of the Buying Orders list, so a computed version would sum the lines once
	// per displayed row across every order. Legacy stored them for the same reason and
	// recomputed on demand.
	//
	// Each assignment is guarded by a change test, exactly as BO_totalupd was, so calling
	// this on an order that is already correct touches nothing and leaves it unmodified.
	var $total; $tax : Real

	$changed:=False:C215

	$total:=This:C1470.boLines.sum("lineTotal")
	$tax:=This:C1470.boLines.sum("tax")

	If (Num:C11(This:C1470.lineItemsTotal)#$total)
		This:C1470.lineItemsTotal:=$total
		$changed:=True:C214
	End if

	If (Num:C11(This:C1470.salesTax)#$tax)
		This:C1470.salesTax:=$tax
		$changed:=True:C214
	End if
	//mark:-Closing
	//
	// Legacy IsBuyOrderClosable, which Buy_Form/Field41 called when the Order Closed box
	// was ticked: the box was set to whatever the method returned, so a refusal simply
	// put it back. Unticking was never guarded, and is not here either - re-opening an
	// order stays free.
	//
	// Closing is an ACCOUNTS-PAYABLE act, not a receiving one: the test is that every
	// line is PAID, not that it arrived.

Function closingBlockedReason()->$reason : Text
	// "" when the order may be closed, otherwise why not - in legacy's wording.
	var $line : cs:C1710.BuyingOrderLineEntity
	var $unpaid : Collection

	$reason:=""

	//---two hard disqualifiers, tested first and in this order, as legacy did
	If (This:C1470.asset)
		$reason:="Buy-Order is for Asset Purchase"
		return
	End if

	//---Auto_inc is the blanket-order flag. The column does not exist in this
	//   application yet, so this reads as False and the branch is dormant; it starts
	//   working the day the column is added, without a code change.
	If (Bool:C1537(This:C1470.autoInc))
		$reason:="Buy-Order is set up for automatic referencing"
		return
	End if

	//---then every line must be paid. A zero-value line is ignored, exactly as legacy's
	//   "& (Line_total>0)" did: a no-charge or freight-only line never blocks closing.
	$unpaid:=New collection:C1472()
	For each ($line; This:C1470.boLines.orderBy("number asc, splitLevel asc"))
		If ($line.paidDate=!00-00-00!) && (Num:C11($line.lineTotal)>0)
			$unpaid.push("Item :"+$line.displayNumber+" without DATE-PAID")
		End if
	End for each

	If ($unpaid.length>0)
		$reason:="Unpaid items: "+String:C10($unpaid.length)+Char:C90(Carriage return)+$unpaid.join(Char:C90(Carriage return))
	End if

Function get canBeClosed()->$result : Boolean
	$result:=(This:C1470.closingBlockedReason()="")
	//mark:-GL account
	//
	// The order carries the account as a LINK only - UUID_GLAccount, relation "account".
	// Nothing is duplicated as text: the code and description come through the relation,
	// and the flags come off the account record, which _export_glAccounts precomputed
	// from legacy's ChartOfAccSetBooleanTypeField decision table.
	//
	// Legacy stored [BUY_ORDERS]Asset as a column because it had no computed attributes,
	// the same reason it stored Requistion. It is derived here, and anything that needs
	// to QUERY it can go through the relation: "account.defaultAsset = false".

Function get asset()->$asset : Boolean
	// Legacy [BUY_ORDERS]Asset, set by SetBuyingFieldsBasedonGLacc from the account type.
	// An asset order could never be closed or archived - see IsBuyOrderClosable.
	$asset:=(This:C1470.account#Null:C1517) && Bool:C1537(This:C1470.account.defaultAsset)

Function get glAccountLabel()->$text : Text
	// "5110 - Shop supplies", for display next to the picker.
	$text:=""
	If (This:C1470.account=Null:C1517)
		return
	End if
	$text:=String:C10(This:C1470.account.glac)
	If (String:C10(This:C1470.account.description)#"")
		$text:=$text+" - "+String:C10(This:C1470.account.description)
	End if

Function glAccountBlockedReason()->$reason : Text
	// Legacy SetInheritedBuyItemFields refused an account belonging to another division:
	//     "GL Account X does not belong to divison: Y"
	// GLAccount.UUID_Division is the equivalent; empty means all divisions, which is
	// legacy's <>DesignatorForAllDivisions.
	var $accountDivision : Text
	var $division : cs:C1710.DivisionEntity

	$reason:=""
	If (This:C1470.account=Null:C1517)
		return
	End if

	$accountDivision:=String:C10(This:C1470.account.UUID_Division)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($accountDivision))
		return
	End if

	If (String:C10(This:C1470.division)="")
		return
	End if

	$division:=ds:C1482.Division.query("name = :1 or code = :1"; String:C10(This:C1470.division)).first()
	If ($division=Null:C1517)
		return
	End if

	If (String:C10($division.UUID)#$accountDivision)
		$reason:="GL account "+String:C10(This:C1470.account.glac)+" does not belong to division "+String:C10(This:C1470.division)+"."
	End if
Function get vendorAddressBlock()->$text : Text
	// Legacy SubrBuyOrderAddr: the supplier name, then its billing address, one per line.
	var $lines : Collection

	$lines:=New collection()

	If (This.supplier#Null)
		If (String(This.supplier.name)#"")
			$lines.push(String(This.supplier.name))
		End if
	End if

	$text:=_contactDetailsAddress(This.contactDetails; "vendor")
	If ($text#"")
		$lines.push($text)
	End if

	$text:=$lines.join(Char(Carriage return))

Function get shipToText()->$text : Text
	// The legacy ship-to VERBATIM.
	//
	// [BUY_ORDERS]ShippingAddr was one free-text block and _import_buyOrders stores it
	// unchanged in the shippingAddress column. It ALSO splits it into a structured
	// contactDetails address, but that split is lossy - line 1 becomes street_1, every
	// other line is comma-welded into street_2, city/state/postcode are left empty and
	// the country is hardcoded "US". Reassembling that gave a mangled address with an
	// invented "US" line on the end, which is what the print was showing.
	//
	// So this reads the column. Do not "improve" it to use contactDetails.
	$text:=String(This.shippingAddress)

Function get billToText()->$text : Text
	// Legacy printed YOUR OWN address in the Bill to box from <>GBilladd1 / <>GBilladd2,
	// set from Housekeeping at startup. Here it is the division's remit address, which is
	// the same idea held per division - legacy switched the letterhead by division too.
	//
	// The previous helper read $order.UUID_Division, which does not exist on this table:
	// BuyingOrder carries the division as a TEXT column. That is why the Bill to box has
	// been printing empty.
	//
	// CAVEAT: this queries, so it is two round trips per access. Fine for a document,
	// but do NOT put it in a list box column - it would run once per displayed row.
	var $division : cs:C1710.DivisionEntity
	var $info : cs:C1710.DivisionInfoEntity

	$text:=""
	If (String(This.division)="")
		return
	End if

	$division:=ds.Division.query("name = :1 or code = :1"; String(This.division)).first()
	If ($division=Null)
		return
	End if

	$info:=ds.DivisionInfo.query("UUID_Division = :1"; $division.UUID).first()
	If ($info=Null)
		return
	End if

	//---the division's BILLING address: legacy <>GBilladd1 / <>GBilladd2, which
	//   Housekeeping filled from [Housekeeping_div_add]BillingAddress1 / 2. It was
	//   reading the remit address here, which is a different field in that same record.
	$text:=_contactDetailsAddress($info.contactDetails; "billing")

Function applyDefaultDivision()
	// Writes the parent division's code (or name) into the division text column, unless
	// the order already carries one.
	var $info : cs:C1710.DivisionInfoEntity
	var $division : cs:C1710.DivisionEntity

	If (String:C10(This:C1470.division)#"")
		return
	End if

	$info:=This:C1470.divisionInfo()
	If ($info=Null:C1517) || (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($info.UUID_Division)))
		return
	End if

	$division:=ds:C1482.Division.query("UUID = :1"; String:C10($info.UUID_Division)).first()
	If ($division=Null:C1517)
		return
	End if

	This:C1470.division:=(String:C10($division.code)#"") ? String:C10($division.code) : String:C10($division.name)

	//---and the division's sales tax rate, as legacy did on vendor selection:
	//       : (ST_rate=0)  ST_rate:=GetDefaultSalesTax(Division)
	//   GetDefaultSalesTax read <>SalesTaxFraction{n}, which is
	//   [Housekeeping_div_add]SalesTaxFraction - 0.1025 for GAC. Only when still zero,
	//   so a rate typed by hand is never overwritten.
	If (Num:C11(This:C1470.salesTaxRate)=0)
		If ($info.moreData#Null:C1517)
			If (Num:C11($info.moreData.salesTaxFraction)>0)
				This:C1470.salesTaxRate:=Num:C11($info.moreData.salesTaxFraction)
			End if
		End if
	End if
Function divisionInfo()->$info : cs:C1710.DivisionInfoEntity
	// The DivisionInfo behind this order's division. division is a TEXT column here, so
	// it is resolved by name or code - the same walk billToText does.
	//
	// When the order has no division yet - which is every order at the moment it is
	// created - it falls back to the PARENT division, and then to the only one if there
	// is just one. Legacy did the equivalent: [BUY_ORDERS]Division defaulted from <>div,
	// and [Housekeeping_div_add] marked one record Parent.
	var $division : cs:C1710.DivisionEntity
	var $divisions : cs:C1710.DivisionSelection

	$info:=Null:C1517

	If (String:C10(This:C1470.division)#"")
		$division:=ds:C1482.Division.query("name = :1 or code = :1"; String:C10(This:C1470.division)).first()
		If ($division#Null:C1517)
			$info:=ds:C1482.DivisionInfo.query("UUID_Division = :1"; $division.UUID).first()
			If ($info#Null:C1517)
				return
			End if
		End if
	End if

	//---no division on the order, or none that resolves: the parent
	$info:=ds:C1482.DivisionInfo.query("parent = :1"; True:C214).first()
	If ($info#Null:C1517)
		return
	End if

	//---still nothing: the only one, when there is only one
	$divisions:=ds:C1482.DivisionInfo.all()
	If ($divisions.length=1)
		$info:=$divisions.first()
	End if

Function get shipToAddress()->$address : Object
	// OUR delivery address for this order, as a structured address for the Shipping tab.
	//
	// It is the division's "site" address - legacy [Housekeeping_div_add]SiteAdd1/2, which
	// SubrGetBuyOrderShipAddr wrote into [BUY_ORDERS]ShippingAddr. Never the vendor's.
	var $info : cs:C1710.DivisionInfoEntity
	var $source : Object

	$address:=Null:C1517
	$info:=This:C1470.divisionInfo()
	If ($info=Null:C1517) || ($info.contactDetails=Null:C1517) || ($info.contactDetails.addresses=Null:C1517)
		return
	End if

	$source:=$info.contactDetails.addresses.query("type = :1"; "site").first()
	If ($source=Null:C1517)
		return
	End if

	$address:=OB Copy:C1225($source)
	$address.type:="shipping"

Function get shipToBlock()->$text : Text
	// The free-text ship-to the PO print uses. The division's site address already holds
	// the phone on its second line - the way it is entered on screen - so this is just
	// that address, with no country line: legacy's ShippingAddr was street, then
	// city/state/zip + phone, and nothing else.
	var $info : cs:C1710.DivisionInfoEntity
	var $source : Object
	var $lines : Collection

	$text:=""
	$info:=This:C1470.divisionInfo()
	If ($info=Null:C1517) || ($info.contactDetails=Null:C1517) || ($info.contactDetails.addresses=Null:C1517)
		return
	End if

	$source:=$info.contactDetails.addresses.query("type = :1"; "site").first()
	If ($source=Null:C1517) || ($source.detail=Null:C1517)
		return
	End if

	$lines:=New collection:C1472()
	If (String:C10($source.detail.street_1)#"")
		$lines.push(String:C10($source.detail.street_1))
	End if
	If (String:C10($source.detail.street_2)#"")
		$lines.push(String:C10($source.detail.street_2))
	End if

	$text:=$lines.join(Char:C90(Carriage return:K15:38))

Function applyDivisionShipTo()
	// Writes the division's site address onto this order: the structured "shipping"
	// entry behind the Shipping tab, and the free-text shippingAddress column the print
	// reads.
	//
	// Does nothing when DivisionInfo has not been seeded, so it can never wipe an
	// address someone typed by hand.
	var $address : Object
	var $block : Text
	var $contactDetails : Object

	$address:=This:C1470.shipToAddress
	$block:=This:C1470.shipToBlock

	If ($address=Null:C1517) && ($block="")
		return
	End if

	If ($address#Null:C1517)
		$contactDetails:=This:C1470.contactDetails || New object:C1471()
		If ($contactDetails.addresses=Null:C1517)
			$contactDetails.addresses:=New collection:C1472()
		End if
		$contactDetails.addresses:=$contactDetails.addresses.query("type # :1"; "shipping")
		$contactDetails.addresses.push($address)
		This:C1470.contactDetails:=$contactDetails
	End if

	If ($block#"")
		This:C1470.shippingAddress:=$block
	End if
Function get attentionName()->$text : Text
	$text:=(This.contact#Null) ? String(This.contact.fullName) : ""

Function get attentionFax()->$text : Text
	$text:=(This.contact#Null) ? This.contact.communication("fax") : ""

Function get attentionTel()->$text : Text
	$text:=(This.contact#Null) ? This.contact.communication("phone") : ""

Function get buyerName()->$text : Text
	// staff is the buyer relation - it was renamed off "buyer" because the order also has
	// a buyer TEXT column and the two collided.
	$text:=(This.staff#Null) ? String(This.staff.fullName) : ""

Function get buyerContactBlock()->$text : Text
	// Legacy Field11 rewrote BuyersCode into Tel/Fax/Email at print time.
	$text:=(This.staff#Null) ? This.staff.contactBlock : ""

Function get requestorName()->$text : Text
	$text:=(This.requestor#Null) ? String(This.requestor.fullName) : ""

Function get orderTitle()->$text : Text
	// Legacy RequistionOrOrder set the heading and the approver captions together.
	$text:=This.awaitingApproval ? "Purchase Requisition" : "Purchase Order"

Function get requisitionNotice()->$text : Text
	$text:=This.awaitingApproval ? "This is a requisition and NOT a Purchase Order" : ""
Function get approver1Name()->$text : Text
	$text:=This._approverName(1)

Function get approver2Name()->$text : Text
	$text:=This._approverName(2)

Function get approver1Caption()->$text : Text
	// Legacy RequistionOrOrder: an unsigned requisition says who it is WAITING on.
	$text:=(This._signature(1)="") && This.awaitingApproval ? "To be approved by:" : "Approved by:"

Function get approver2Caption()->$text : Text
	$text:=(This._signature(2)="") && This.awaitingApproval ? "To be approved by:" : "Approved by:"

local Function _approverName($slot : Integer)->$text : Text
	// The approver NAME, not the signature. Legacy printed [BUY_ORDERS]Approver1 -
	// "Ben Mendoza" - while Signature1 held the literal "Signed" that MatchSignature1
	// wrote over the typed password.
	//
	// approver1 and approver2 are real N->1 relations onto Staff, so this traverses them
	// rather than querying by UUID the way the old _boStaffName helper did. No extra
	// round trip, and therefore none of the list box caveat that billToText carries.
	//
	// Imported orders have no approver linked and the name parked in
	// moreData.legacyApprover1/2, so that is the fallback.
	var $staff : cs:C1710.StaffEntity

	$text:=""
	$staff:=($slot=1) ? This.approver1 : This.approver2

	If ($staff#Null)
		$text:=String($staff.fullName)
		If ($text#"")
			return
		End if
	End if

	If (This.moreData#Null)
		$text:=String(($slot=1) ? This.moreData.legacyApprover1 : This.moreData.legacyApprover2)
	End if