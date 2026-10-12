Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.code
	
	
Function preview()->$preview : Object
	var $contact : cs:C1710.ContactEntity
	$preview:=New object:C1471()
	$contact:=This:C1470._mainContact_prv()
	If ($contact#Null:C1517)
		$preview.contactFirstName:=String:C10($contact.firstName)
		$preview.contactName:=String:C10($contact.fullName)
		
		$customer:=ds:C1482.Customer.query("UUID = :1"; $contact.UUID_Company).first()
		
		$preview.contactCompany:=String:C10($customer.name)
		
		$preview.contactAddress:=""
		If ($contact.contactDetails#Null:C1517) && ($contact.contactDetails.addresses#Null:C1517) && ($contact.contactDetails.addresses.length#0)
			$address:=$contact.contactDetails.addresses[0]
			If (String:C10($address.detail.street_1)#"")
				$preview.contactAddress+=$address.detail.street_1+", "
			End if 
			
			If (String:C10($address.detail.street_2)#"")
				$preview.contactAddress+=$address.detail.street_2+", "
			End if 
			
			If (String:C10($address.detail.city)#"")
				$preview.contactAddress+=$address.detail.city+", "
			End if 
			
			If (String:C10($address.detail.state)#"") & (String:C10($address.detail.postcode)#"")
				$preview.contactAddress+=$address.detail.state+" "+$address.detail.postcode+", "
			End if 
			
			If (String:C10($address.detail.country)#"")
				$preview.contactAddress+=$address.detail.country
			End if 
		Else 
			$preview.contactAddress:=" - "
		End if 
		
		If ($contact.contactDetails#Null:C1517) && ($contact.contactDetails.communications#Null:C1517) && ($contact.contactDetails.communications.length#0)
			$comms:=$contact.contactDetails.communications
			
			$items:=$comms.query("type == :1"; "mobile")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactTel:=$items[0].contact
			Else 
				$preview.contactTel:=""
			End if 
			
			$items:=$comms.query("type == :1"; "ext")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactExt:=$items[0].contact
			Else 
				$preview.contactExt:=""
			End if 
			
			$items:=$comms.query("type == :1"; "fax")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactFax:=$items[0].contact
			Else 
				$preview.contactFax:=""
			End if 
			
			$items:=$comms.query("type == :1"; "mail")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactEmail:=$items[0].contact
			Else 
				$preview.contactEmail:=""
			End if 
			
		Else 
			$preview.contactTel:=""
			$preview.contactExt:=""
			$preview.contactFax:=""
			$preview.contactEmail:=""
		End if 
	End if 
	$preview.preparerName:=This:C1470.staff.fullName
	If (This:C1470.staff.contactDetails#Null:C1517) && (This:C1470.staff.contactDetails.communications#Null:C1517) && (This:C1470.staff.contactDetails.communications.length#0)
		$comm:=This:C1470.staff.contactDetails.communications[0]
		TRACE:C157
		$preview.preparerEmail:=String:C10($comm.email)
		$preview.preparerMobile:=String:C10($comm.mobile)
		$preview.preparerExt:=String:C10($comm.ext)
	Else 
		$preview.preparerEmail:=$comm.email
		$preview.preparerMobile:=$comm.mobile
		$preview.preparerExt:=$comm.ext
	End if 
	
	$preview.copyName:=""  // to get from the old database
	$preview.copyCommMeans:=""  // to get from the old database
	
	$preview.quoteNumber:=This:C1470.code
	$preview.quoteRevision:=String:C10(This:C1470.revision.name)
	$preview.quoteDate:=String:C10(cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation))
	$preview.quoteSubject:=This:C1470.subject
	$preview.quoteReference:=This:C1470.reference
	
	$preview.quoteLines:=This:C1470.lines
	$preview.optionalPreliminaryTxt_wr:=This:C1470.optionalPreliminaryTxt_wr
	
	$preview.assumptions:=ds:C1482.Assumption.query("UUID in :1"; This:C1470.assumptions.UUIDs)
	
	$preview.conditions:=ds:C1482.TermCondition.query("UUID in :1"; This:C1470.termsConditions.UUIDs)
	
Function get dateCreation()->$createDate : Date
	$createDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation; True:C214)
	
Function set dateCreation($createDate : Date)
	This:C1470.stmpCreation:=cs:C1710.sfw_stmp.me.build($createDate)
	
	
Function get yearCreation()->$year : Integer
	$year:=Year of:C25(Date:C102(This:C1470.dateCreation))

	// search "yearCreation:2025" (also >2024, <=2025, #2025): a stmpCreation range, indexed
Function query yearCreation($event : Object)->$result : Object
	var $year : Integer
	var $start; $end : Integer

	$year:=Num:C11($event.value)
	// 1 January by date arithmetic: Date("2026-01-01") gave !00-00-00! and every search found nothing
	$start:=cs:C1710.sfw_stmp.me.build(Add to date:C393(!2000-01-01!; $year-2000; 0; 0); ?00:00:00?)
	$end:=cs:C1710.sfw_stmp.me.build(Add to date:C393(!2000-01-01!; $year+1-2000; 0; 0); ?00:00:00?)
	Case of
		: ($event.operator=">")
			$result:=New object:C1471("query"; "stmpCreation >= :1"; "parameters"; New collection:C1472($end))
		: ($event.operator=">=")
			$result:=New object:C1471("query"; "stmpCreation >= :1"; "parameters"; New collection:C1472($start))
		: ($event.operator="<")
			$result:=New object:C1471("query"; "stmpCreation < :1 and stmpCreation > 0"; "parameters"; New collection:C1472($start))
		: ($event.operator="<=")
			$result:=New object:C1471("query"; "stmpCreation < :1 and stmpCreation > 0"; "parameters"; New collection:C1472($end))
		: ($event.operator="#") || ($event.operator="!=") || ($event.operator="!==")
			$result:=New object:C1471("query"; "stmpCreation < :1 or stmpCreation >= :2"; "parameters"; New collection:C1472($start; $end))
		Else
			$result:=New object:C1471("query"; "stmpCreation >= :1 and stmpCreation < :2"; "parameters"; New collection:C1472($start; $end))
	End case

Function get monthCreation()->$month : Integer
	$month:=Month of:C24(Date:C102(This:C1470.dateCreation))

	// search "monthCreation:3": March of any year (add yearCreation:2025 for one year). A month
	// is not one stamp range, so the matching quotes are listed once and searched by UUID
Function query monthCreation($event : Object)->$result : Object
	var $month; $quoteMonth : Integer
	var $quote : Object
	var $uuids : Collection
	var $keep : Boolean

	$month:=Num:C11($event.value)
	$uuids:=New collection:C1472
	For each ($quote; ds:C1482.Quote.query("stmpCreation > 0").toCollection("UUID, stmpCreation"))
		$quoteMonth:=Month of:C24(cs:C1710.sfw_stmp.me.getDate($quote.stmpCreation))
		Case of
			: ($event.operator=">")
				$keep:=($quoteMonth>$month)
			: ($event.operator=">=")
				$keep:=($quoteMonth>=$month)
			: ($event.operator="<")
				$keep:=($quoteMonth<$month)
			: ($event.operator="<=")
				$keep:=($quoteMonth<=$month)
			: ($event.operator="#") || ($event.operator="!=") || ($event.operator="!==")
				$keep:=($quoteMonth#$month)
			Else
				$keep:=($quoteMonth=$month)
		End case
		If ($keep)
			$uuids.push($quote.UUID)
		End if
	End for each
	$result:=New object:C1471("query"; "UUID in :1"; "parameters"; New collection:C1472($uuids))

	// the code as a number, for the list order: the codes are not padded (Q999 < Q3041)
Function get codeNumber()->$number : Integer
	$number:=Num:C11(This:C1470.code)

	
	
Function get amount()->$amountText : Text
	$amount:=This:C1470.lines.sum("amount")
	$amountText:="$"+String:C10($amount; "###,###,###,#00.00")
	
	
Function get amountNumber()->$amount : Real
	$amount:=This:C1470.lines.sum("amount")
	
	
Function contacts()->$contacts : Collection
	var $e_mainContact : cs:C1710.ContactEntity
	var $secondaryContacts : cs:C1710.ContactSelection
	
	$contacts:=New collection:C1472()
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.mainContact#Null:C1517)
		$e_mainContact:=ds:C1482.Contact.get(This:C1470.moreData.mainContact.UUID)
		If ($e_mainContact#Null:C1517)
			$mainContact:=$e_mainContact.toObject()
			$mainContact.type:="Main"
			$contacts.push($mainContact)
		End if 
	End if 
	
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.secondaryContacts#Null:C1517)
		$secondaryContacts:=ds:C1482.Contact.query("UUID in :1"; This:C1470.moreData.secondaryContacts)
		For each ($e_contact; $secondaryContacts)
			$contact:=$e_contact.toObject()
			$contact.type:="Secondary"
			$contacts.push($contact)
		End for each 
	End if 
	
Function _mainContact_prv()->$mainContact : cs:C1710.ContactEntity
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.mainContact#Null:C1517)
		$mainContact:=ds:C1482.Contact.get(This:C1470.moreData.mainContact.UUID)
	End if 
	
	
	
	
Function get currentStatus()->$status : Text
	$status:=This:C1470.status.code
	
	
Function orderBy currentStatus($event : Object)->$result : Text
	If ($event.descending=True:C214)
		$result:="status.code desc"
	Else 
		$result:="status.code"
	End if 
	
local Function metaColor()->$meta : Object
	$meta:=New object:C1471
	$meta.cell:=New object:C1471
	
	$meta.cell.columnStatus:=New object:C1471
	If (Form:C1466.current_lb_item=Null:C1517) || (Form:C1466.current_lb_item.UUID#This:C1470.UUID)
		$meta.cell.columnStatus.stroke:=This:C1470.status.color || "black"
	End if 
	$meta.cell.columnREID:=New object:C1471
	$meta.cell.columnREID.stroke:="SlateGrey"
	
	
	//Mark:-call back functions
local Function itemLoad()
	$assumptions:=ds:C1482.Assumption.all().distinct("UUID")
	If (This:C1470.assumptions=Null:C1517)
		This:C1470.assumptions:=New object:C1471()
	End if 
	If (This:C1470.assumptions.UUIDs=Null:C1517)
		This:C1470.assumptions.UUIDs:=New collection:C1472()
		This:C1470.assumptions.UUIDs:=$assumptions
	End if 
	
	$terms:=ds:C1482.TermCondition.all().distinct("UUID")
	If (This:C1470.termsConditions=Null:C1517)
		This:C1470.termsConditions:=New object:C1471()
	End if 
	If (This:C1470.termsConditions.UUIDs=Null:C1517)
		This:C1470.termsConditions.UUIDs:=New collection:C1472()
		This:C1470.termsConditions.UUIDs:=$terms
	End if 
	
	
	
	
	
	
	
local Function beforeSave()
	// an existing quote without a code (imported that way) gets the next one when it is saved
	If (This:C1470.code="")
		This:C1470.code:=This:C1470.calculateCode()
	End if

	// the code is taken as soon as the quote is created, so the panel shows it (like the job number);
	// a new quote that is cancelled leaves a gap in the series
local Function loadAfterCreation()
	This:C1470.code:=This:C1470.calculateCode()
	This:C1470.dateCreation:=Current date:C33()
	If (cs:C1710.sfw_userManager.me.info.UUID_Staff#Null:C1517)  // the owner: the user's staff record
		This:C1470.staff:=ds:C1482.Staff.query("UUID = :1"; cs:C1710.sfw_userManager.me.info.UUID_Staff).first()
	End if
	// a real Write Pro document from the start: saved empty, the "Optional preliminary text" area
	// turned it into one on the next display, and sfw then asked to save a quote nobody changed
	This:C1470.optionalPreliminaryTxt_wr:=WP New:C1317()

	// a copy gets its own code and today's date, not the original's
local Function duplicateRecord()
	This:C1470.code:=This:C1470.calculateCode()
	This:C1470.dateCreation:=Current date:C33()

local Function beforeSaveCreation()
	If (This:C1470.code="")
		This:C1470.code:=This:C1470.calculateCode()
	End if
	This:C1470.addAssumptions()
	This:C1470.addTermsAndConditions()
	
	
	
Function calculateCode()->$leadCode : Text
	
	var $eQuoteCounter : cs:C1710.sfw_CounterEntity
	
	$leadCode:="Q"
	//$eQuoteCounter:=ds.sfw_Counter.query("ident = :1"; "quoteCode").first()
	//If ($eQuoteCounter=Null)
	//$eQuoteCounter:=ds.sfw_Counter.new()
	//$eQuoteCounter.ident:="quoteCode"
	//$eQuoteCounter.currentValue:=1
	//End if 
	$test:=ds:C1482.sfw_Counter.getNextValue("quoteCode")

	// no padding: the series goes on from the legacy codes (Q251...Q3040), which the PO import
	// and the quote imports match as text; _fix_sequences keeps "quoteCode" past them
	$leadCode+=String:C10($test)
	
	
	
Function addAssumptions()
	
	$assumptions:=ds:C1482.Assumption.all().distinct("UUID")
	If (This:C1470.assumptions=Null:C1517)
		This:C1470.assumptions:=New object:C1471()
	End if 
	If (This:C1470.assumptions.UUIDs=Null:C1517)
		This:C1470.assumptions.UUIDs:=New collection:C1472()
	End if 
	This:C1470.assumptions.UUIDs:=$assumptions
	
	
Function addTermsAndConditions()
	
	$terms:=ds:C1482.TermCondition.all().distinct("UUID")
	If (This:C1470.termsConditions=Null:C1517)
		This:C1470.termsConditions:=New object:C1471()
	End if 
	If (This:C1470.termsConditions.UUIDs=Null:C1517)
		This:C1470.termsConditions.UUIDs:=New collection:C1472()
	End if 
	
	
	This:C1470.termsConditions.UUIDs:=$terms
