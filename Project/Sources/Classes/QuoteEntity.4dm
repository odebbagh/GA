Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.code
	
	
	// What the quote document prints (panel_quote.quoteDocument), as plain values: the lines,
	// assumptions and terms are copied, not linked. The Preview tab builds it from the quote being
	// edited; snapshot() freezes it into a QuoteRevision. The preliminary text is the Write Pro
	// document itself here (snapshot() turns it into text)
Function preview()->$preview : Object
	var $contact; $copy : cs:C1710.ContactEntity
	var $customer : cs:C1710.CustomerEntity
	var $line : cs:C1710.QuoteLineEntity
	var $e : 4D:C1709.Entity
	var $uuid : Text
	var $comms : Collection
	var $address : Object

	$preview:=New object:C1471()
	$contact:=This:C1470._mainContact_prv()
	If ($contact#Null:C1517)
		$preview.contactFirstName:=String:C10($contact.firstName)
		$preview.contactName:=String:C10($contact.fullName)

		$customer:=ds:C1482.Customer.query("UUID = :1"; $contact.UUID_Company).first()
		$preview.contactCompany:=($customer=Null:C1517) ? "" : String:C10($customer.name)

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
			If (String:C10($address.detail.state)#"") && (String:C10($address.detail.postcode)#"")
				$preview.contactAddress+=$address.detail.state+" "+$address.detail.postcode+", "
			End if
			If (String:C10($address.detail.country)#"")
				$preview.contactAddress+=$address.detail.country
			End if
		Else
			$preview.contactAddress:=" - "
		End if

		$comms:=New collection:C1472
		If ($contact.contactDetails#Null:C1517) && ($contact.contactDetails.communications#Null:C1517)
			$comms:=$contact.contactDetails.communications
		End if
		$preview.contactTel:=This:C1470._commValue($comms; New collection:C1472("phone"; "mobile"))  // the imports write "phone", older records "mobile"
		$preview.contactExt:=This:C1470._commValue($comms; New collection:C1472("ext"))
		$preview.contactFax:=This:C1470._commValue($comms; New collection:C1472("fax"))
		$preview.contactEmail:=This:C1470._commValue($comms; New collection:C1472("email"; "mail"))  // the imports write "email"
	End if

	// the owner's email / phone / ext: entries {type; contact} of the staff record (the quote import
	// stores the preparer's details there)
	$preview.preparerName:=String:C10(This:C1470.staff.fullName)
	$comms:=New collection:C1472
	If (This:C1470.staff#Null:C1517) && (This:C1470.staff.contactDetails#Null:C1517) && (This:C1470.staff.contactDetails.communications#Null:C1517)
		$comms:=This:C1470.staff.contactDetails.communications
	End if
	$preview.preparerEmail:=This:C1470._commValue($comms; New collection:C1472("email"; "mail"))
	$preview.preparerMobile:=This:C1470._commValue($comms; New collection:C1472("phone"; "mobile"))
	$preview.preparerExt:=This:C1470._commValue($comms; New collection:C1472("ext"))

	// "Copy:" is the first secondary contact (agreed with the client, June 2025)
	$preview.copyName:=""
	$preview.copyCommMeans:=""
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.secondaryContacts#Null:C1517) && (This:C1470.moreData.secondaryContacts.length>0)
		$copy:=ds:C1482.Contact.get(This:C1470.moreData.secondaryContacts[0])
		If ($copy#Null:C1517)
			$preview.copyName:=$copy.fullName
			If ($copy.contactDetails#Null:C1517) && ($copy.contactDetails.communications#Null:C1517)
				$preview.copyCommMeans:=This:C1470._commValue($copy.contactDetails.communications; New collection:C1472("email"; "mail"))
			End if
		End if
	End if

	$preview.quoteNumber:=This:C1470.code
	$preview.quoteRevision:=String:C10(This:C1470.revision.name)
	$preview.quoteDate:=String:C10(cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation))
	$preview.validUntil:=This:C1470.validUntilText  // "" when the quote has no validity date (imported)
	$preview.quoteSubject:=This:C1470.subject
	$preview.quoteReference:=This:C1470.reference
	// not printed, shown by the revision viewer (Quote_revisionView)
	$preview.customerName:=String:C10(This:C1470.customer.name)
	$preview.statusName:=String:C10(This:C1470.status.name)
	$preview.serviceTypeName:=String:C10(This:C1470.serviceType.name)

	// "build": the steps a line was priced from (ga_quoteLinePricing), kept in a frozen revision, not printed
	$preview.quoteLines:=New collection:C1472
	For each ($line; This:C1470.lines.orderBy("num asc"))
		$preview.quoteLines.push(New object:C1471("num"; $line.num; "description"; $line.description; "quantity"; $line.quantity; "unitPrice"; $line.unitPrice; "minLotCharge"; $line.minLotCharge; "amount"; $line.amount; "build"; ($line.moreData=Null:C1517) ? Null:C1517 : $line.moreData.build))
	End for each
	$preview.total:=$preview.quoteLines.sum("amount")
	$preview.optionalPreliminaryTxt_wr:=This:C1470.optionalPreliminaryTxt_wr

	// in the quote's own order (a query on "UUID in" returns them in any order)
	$preview.assumptions:=New collection:C1472
	If (This:C1470.assumptions#Null:C1517)
		For each ($uuid; This:C1470.assumptions.UUIDs || New collection:C1472)
			$e:=ds:C1482.Assumption.get($uuid)
			If ($e#Null:C1517)
				$preview.assumptions.push(New object:C1471("code"; $e.code; "value"; $e.value))
			End if
		End for each
	End if
	$preview.conditions:=New collection:C1472
	If (This:C1470.termsConditions#Null:C1517)
		For each ($uuid; This:C1470.termsConditions.UUIDs || New collection:C1472)
			$e:=ds:C1482.TermCondition.get($uuid)
			If ($e#Null:C1517)
				$preview.conditions.push(New object:C1471("code"; $e.code; "value"; $e.value))
			End if
		End for each
	End if

	// the first "contact" of a contactDetails.communications entry whose type is one of $types
Function _commValue($communications : Collection; $types : Collection)->$value : Text
	var $found : Collection
	If ($communications#Null:C1517)
		$found:=$communications.query("type in :1"; $types)
		If ($found.length>0)
			$value:=String:C10($found[0].contact)
		End if
	End if

	// preview() frozen for a QuoteRevision: the preliminary Write Pro text becomes 4D Write Pro HTML
	// (WP New turns it back into a document), so the object holds nothing but values
Function snapshot()->$snapshot : Object
	var $prelim : Object
	var $html : Text

	$snapshot:=This:C1470.preview()
	$prelim:=$snapshot.optionalPreliminaryTxt_wr
	OB REMOVE:C1226($snapshot; "optionalPreliminaryTxt_wr")
	$snapshot.preliminaryText:=""
	If (_ga_wpHasContent($prelim))  // an empty {} object field is not a Write Pro document
		WP EXPORT VARIABLE($prelim; $html; wk web page html 4D)
		$snapshot.preliminaryText:=$html
	End if

	// New revision (Quote_newRevision): the quote as it is saved is frozen into a QuoteRevision
	// labelled $frozenRevisionUUID, then the quote moves on to $nextRevisionUUID. Both in one
	// transaction, so there is never a copy without the new label or the reverse. Called outside
	// Modify (sfw owns the transaction there), on a quote read from the database.
	// Returns {success; message; revision}
Function newRevision($frozenRevisionUUID : Text; $nextRevisionUUID : Text; $note : Text)->$result : Object
	var $revision : cs:C1710.QuoteRevisionEntity
	var $res : Object

	$result:=New object:C1471("success"; False:C215; "message"; ""; "revision"; Null:C1517)

	ds:C1482.startTransaction()
	$revision:=ds:C1482.QuoteRevision.new()
	$revision.UUID_Quote:=This:C1470.UUID
	$revision.UUID_Revision:=$frozenRevisionUUID
	$revision.num:=Num:C11(This:C1470.revisions.max("num"))+1
	$revision.note:=$note
	$revision.stmp:=cs:C1710.sfw_stmp.me.now()
	$revision.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
	$revision.snapshot:=This:C1470.snapshot()
	$revision.snapshot.quoteRevision:=String:C10(ds:C1482.Revision.get($frozenRevisionUUID).name)  // the label it is frozen as
	$revision.moreData:=New object:C1471
	$res:=$revision.save()
	If (Not:C34(Bool:C1537($res.success)))
		ds:C1482.cancelTransaction()
		$result.message:="The revision could not be saved ("+String:C10($res.statusText)+")."
		return
	End if

	This:C1470.UUID_Revision:=$nextRevisionUUID
	$res:=This:C1470.save()
	If (Not:C34(Bool:C1537($res.success)))
		ds:C1482.cancelTransaction()
		$result.message:="The quote could not be saved ("+String:C10($res.statusText)+"): it may be open in Modify elsewhere."
		return
	End if
	ds:C1482.validateTransaction()

	$result.success:=True:C214
	$result.revision:=$revision
	// the automatic status rules of a new revision (ga_quoteStatus: "revisionSaved"), after the
	// transaction: they run their own. $result.statusChange: {changed; messages}
	$result.statusChange:=cs:C1710.ga_quoteStatus.me.onRevisionSaved(This:C1470; $revision.snapshot.quoteRevision)

	//Mark:-Lifecycle: validity, sent, won / lost, void
	// The dates are sfw_stmp stamps, 0 when not set (imported quotes have no validity date). The
	// actions (item actions of the Quotes entry: Quote_lifecycleAction) run outside Modify and save
	// the quote with its lead (ga_sales.applyQuoteToLeads) and follow-ups (ga_followUps) in one
	// transaction, then add a history line. Statuses: A Active, UCR sent (Under Customer Review),
	// RO won (Received Order), LO lost (Lost Order); CS and C also count as closed
Function defaultValidityDays()->$days : Integer
	$days:=30  // the client, October 2026

Function get validUntil()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpValidUntil; True:C214)

Function set validUntil($date : Date)
	This:C1470.stmpValidUntil:=($date=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)

	// the list column: empty when there is no validity date
Function get validUntilText()->$text : Text
	$text:=(This:C1470.stmpValidUntil=0) ? "" : String:C10(This:C1470.validUntil)

Function get sentDate()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpSent; True:C214)

Function get closedDate()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpClosed; True:C214)

Function get voidedDate()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpVoided; True:C214)

Function get isClosed()->$closed : Boolean
	$closed:=(This:C1470.stmpClosed>0) || (New collection:C1472("RO"; "LO"; "CS"; "C").indexOf(String:C10(This:C1470.status.code))#-1)

Function get isOpen()->$open : Boolean
	$open:=(Not:C34(This:C1470.voided)) && (Not:C34(This:C1470.isClosed))

Function get isExpired()->$expired : Boolean
	$expired:=(This:C1470.isOpen) && (This:C1470.stmpValidUntil>0) && (This:C1470.validUntil<Current date:C33)

	// "won", "lost" or ""
Function get outcome()->$outcome : Text
	Case of
		: (String:C10(This:C1470.status.code)="RO")
			$outcome:="won"
		: (String:C10(This:C1470.status.code)="LO")
			$outcome:="lost"
	End case

	// the Main page line under the status: "Sent 10/10/2026 - Won 13/10/2026", "Voided ..."
Function get lifecycleText()->$text : Text
	var $parts : Collection
	$parts:=New collection:C1472
	If (This:C1470.stmpSent>0)
		$parts.push("Sent "+String:C10(This:C1470.sentDate))
	End if
	If (This:C1470.stmpClosed>0)
		$parts.push(Choose:C955(This:C1470.outcome="lost"; "Lost "; Choose:C955(This:C1470.outcome="won"; "Won "; "Closed "))+String:C10(This:C1470.closedDate))
	End if
	If (This:C1470.voided)
		$parts.push("Voided"+Choose:C955(This:C1470.stmpVoided>0; " "+String:C10(This:C1470.voidedDate); ""))
	End if
	If (This:C1470.isExpired)
		$parts.push("Expired")
	End if
	$text:=$parts.join(" - ")

Function _setStatus($code : Text)
	var $status : cs:C1710.QuoteStatusEntity
	$status:=ds:C1482.QuoteStatus.query("code == :1"; $code).first()
	If ($status#Null:C1517)
		This:C1470.UUID_Status:=$status.UUID
	End if

	// "Mark as sent": status UCR and the sent date; the lead goes to "Quote Sent"; the PROPOSAL_SENT
	// follow-up rule schedules the next call. $origin: a line added to the history when an
	// automatic rule does it (ga_quoteStatus)
Function markAsSent($origin : Text)->$result : Object
	$result:=New object:C1471("success"; False:C215; "message"; "")
	Case of
		: (This:C1470.voided)
			$result.message:="Quote "+This:C1470.code+" is voided: restore it first."
			return
		: (This:C1470.isClosed)
			$result.message:="Quote "+This:C1470.code+" is closed: reopen it first."
			return
		: ($origin="") && (cs:C1710.ga_quoteMinCharge.me.blockingLines(This:C1470).length>0)
			// "block" mode of ga_quoteMinCharge, by hand only: an automatic rule (a PO received) is not stopped
			$result.message:="Quote "+This:C1470.code+" cannot be sent while a line is under its minimum lot charge:\r"+cs:C1710.ga_quoteMinCharge.me.blockingLines(This:C1470).join("\r")
			return
	End case
	ds:C1482.startTransaction()
	This:C1470.stmpSent:=cs:C1710.sfw_stmp.me.now()
	This:C1470._setStatus("UCR")
	If (Not:C34(This:C1470._saveIn($result)))
		return
	End if
	$result.problems:=cs:C1710.ga_sales.me.applyQuoteToLeads(This:C1470; "sent")
	$result.followUp:=cs:C1710.ga_followUps.me.scheduleFromTrigger("PROPOSAL_SENT"; This:C1470; Current date:C33)
	ds:C1482.validateTransaction()
	cs:C1710.ga_events.me.addEvent("quote"; This:C1470.UUID; "quoteSent"; "Quote sent"; New collection:C1472("Sent to the customer on "+String:C10(Current date:C33)+"."; $origin).filter(Formula:C1597($1.result:=(String:C10($1.value)#""))))
	$result.success:=True:C214

	// "Close as won / lost": status RO or LO, the close date and the reason; the lead is closed the
	// same way (stage WN / LS, its W/L reason and close date) and the pending follow-ups cancelled.
	// $origin: a line added to the history when an automatic rule does it (ga_quoteStatus: a
	// customer PO entered on the quote)
Function close($won : Boolean; $reason : Text; $origin : Text)->$result : Object
	var $nb : Integer
	$result:=New object:C1471("success"; False:C215; "message"; "")
	Case of
		: (This:C1470.voided)
			$result.message:="Quote "+This:C1470.code+" is voided: restore it first."
			return
		: (This:C1470.isClosed)
			$result.message:="Quote "+This:C1470.code+" is already closed: reopen it first."
			return
	End case
	ds:C1482.startTransaction()
	This:C1470._setStatus(Choose:C955($won; "RO"; "LO"))
	This:C1470.stmpClosed:=cs:C1710.sfw_stmp.me.now()
	This:C1470.reasonWL:=$reason
	If (Not:C34(This:C1470._saveIn($result)))
		return
	End if
	$result.problems:=cs:C1710.ga_sales.me.applyQuoteToLeads(This:C1470; Choose:C955($won; "won"; "lost"))
	$nb:=cs:C1710.ga_followUps.me.cancelPending(cs:C1710.ga_followUps.me.list(This:C1470))
	ds:C1482.validateTransaction()
	cs:C1710.ga_events.me.addEvent("quote"; This:C1470.UUID; Choose:C955($won; "quoteWon"; "quoteLost"); Choose:C955($won; "Quote won"; "Quote lost"); New collection:C1472(\
		"Reason: "+Choose:C955($reason=""; "(none)"; $reason); \
		Choose:C955($nb=0; ""; String:C10($nb)+" pending follow-up(s) cancelled."); \
		$origin).filter(Formula:C1597($1.result:=(String:C10($1.value)#""))))  // no empty lines
	$result.success:=True:C214
	$result.cancelledFollowUps:=$nb

	// "Reopen": a quote closed by mistake is open again (sent: UCR, else A). The lead is left as it
	// is: its stage is changed by hand
Function reopen()->$result : Object
	$result:=New object:C1471("success"; False:C215; "message"; "")
	If (Not:C34(This:C1470.isClosed))
		$result.message:="Quote "+This:C1470.code+" is not closed."
		return
	End if
	ds:C1482.startTransaction()
	This:C1470._setStatus(Choose:C955(This:C1470.stmpSent>0; "UCR"; "A"))
	This:C1470.stmpClosed:=0
	If (Not:C34(This:C1470._saveIn($result)))
		return
	End if
	ds:C1482.validateTransaction()
	cs:C1710.ga_events.me.addEvent("quote"; This:C1470.UUID; "quoteReopened"; "Quote reopened"; New collection:C1472("Reason kept for the record: "+Choose:C955(This:C1470.reasonWL=""; "(none)"; This:C1470.reasonWL)))
	$result.success:=True:C214

	// "Void" / "Restore": a voided quote stays in the list, greyed (metaColor), and cannot be
	// changed (panel_quote). Voiding cancels the quote's pending follow-ups
Function setVoided($voided : Boolean; $note : Text)->$result : Object
	var $nb : Integer
	$result:=New object:C1471("success"; False:C215; "message"; "")
	If (This:C1470.voided=$voided)
		$result.message:="Quote "+This:C1470.code+Choose:C955($voided; " is already voided."; " is not voided.")
		return
	End if
	ds:C1482.startTransaction()
	This:C1470.voided:=$voided
	This:C1470.stmpVoided:=$voided ? cs:C1710.sfw_stmp.me.now() : 0
	If (Not:C34(This:C1470._saveIn($result)))
		return
	End if
	If ($voided)
		$nb:=cs:C1710.ga_followUps.me.cancelPending(This:C1470.interactions)
	End if
	ds:C1482.validateTransaction()
	cs:C1710.ga_events.me.addEvent("quote"; This:C1470.UUID; Choose:C955($voided; "quoteVoided"; "quoteRestored"); Choose:C955($voided; "Quote voided"; "Quote restored"); New collection:C1472(\
		Choose:C955($note=""; ""; "Note: "+$note); \
		Choose:C955($nb=0; ""; String:C10($nb)+" pending follow-up(s) cancelled.")).filter(Formula:C1597($1.result:=(String:C10($1.value)#""))))  // no empty lines
	$result.success:=True:C214

	// saves the quote inside the transaction of a lifecycle action; on failure cancels it and
	// fills $result.message
Function _saveIn($result : Object)->$ok : Boolean
	var $res : Object
	$res:=This:C1470.save()
	$ok:=Bool:C1537($res.success)
	If (Not:C34($ok))
		ds:C1482.cancelTransaction()
		This:C1470.reload()
		$result.message:="Quote "+This:C1470.code+" could not be saved ("+String:C10($res.statusText)+"): it may be open in Modify elsewhere."
	End if

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
	$amountText:=_ga_usdText($amount)  // "$1,234.56" whatever the Windows region
	
	
Function get amountNumber()->$amount : Real
	$amount:=This:C1470.lines.sum("amount")


Function renumberLines()->$lines : cs:C1710.QuoteLineSelection
	// the lines numbered 1..n in their current order (gaps after a delete, legacy numbers);
	// only the lines whose number changes are saved. Returns them in that order
	var $line : cs:C1710.QuoteLineEntity
	var $num : Integer
	var $info : Object
	$lines:=This:C1470.lines.orderBy("num asc")
	For each ($line; $lines)
		$num+=1
		If ($line.num#$num)
			$line.num:=$num
			$info:=$line.save()
		End if
	End for each

Function moveLine($UUID : Text; $delta : Integer)->$moved : Boolean
	// the line one place up ($delta -1) or down (1): it swaps its number with its neighbour.
	// The caller takes the line again from the data: a reference loaded before is out of date
	var $lines : cs:C1710.QuoteLineSelection
	var $line; $neighbour : cs:C1710.QuoteLineEntity
	var $index; $target; $i; $num : Integer
	var $info : Object
	$lines:=This:C1470.renumberLines()
	$index:=-1
	For ($i; 0; $lines.length-1)
		If ($lines[$i].UUID=$UUID)
			$index:=$i
		End if
	End for
	$target:=$index+$delta
	If ($index#-1) && ($target>=0) && ($target<$lines.length)
		$line:=$lines[$index]
		$neighbour:=$lines[$target]
		$num:=$line.num
		$line.num:=$neighbour.num
		$neighbour.num:=$num
		$info:=$line.save()
		If ($info.success)
			$info:=$neighbour.save()
		End if
		$moved:=$info.success
	End if


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
	// a voided quote is greyed; an open quote past its validity date shows the date in red
	If (This:C1470.voided)
		$meta.stroke:="#A0A0A0"
		$meta.fontStyle:="italic"
	End if
	If (This:C1470.isExpired)
		$meta.cell.columnValidUntil:=New object:C1471("stroke"; "red")
	End if

	
	//Mark:-call back functions
local Function itemLoad()
	// a quote that never had a list (imported that way) gets the default assumptions
	If (This:C1470.assumptions=Null:C1517) || (This:C1470.assumptions.UUIDs=Null:C1517)
		This:C1470.addAssumptions()
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

	// a new quote: sfw's callback, the defaults are in initDefaults (also used by
	// LeadEntity.createQuote, which runs no sfw callback)
local Function loadAfterCreation()
	This:C1470.initDefaults()

	// the code is taken as soon as the quote is created, so the panel shows it (like the job number);
	// a new quote that is cancelled leaves a gap in the series
Function initDefaults()
	This:C1470.code:=This:C1470.calculateCode()
	This:C1470.dateCreation:=Current date:C33()
	If (cs:C1710.sfw_userManager.me.info.UUID_Staff#Null:C1517)  // the owner: the user's staff record
		This:C1470.staff:=ds:C1482.Staff.query("UUID = :1"; cs:C1710.sfw_userManager.me.info.UUID_Staff).first()
	End if
	// a real Write Pro document from the start: saved empty, the "Optional preliminary text" area
	// turned it into one on the next display, and sfw then asked to save a quote nobody changed
	This:C1470.optionalPreliminaryTxt_wr:=WP New:C1317()
	// the default assumptions and every term attached from the start, so those the user removes
	// before the first save stay removed (they used to be attached again in beforeSaveCreation)
	This:C1470.addAssumptions()
	This:C1470.addTermsAndConditions()
	// the first revision level: the label only moves on with "New revision..." (Quote_newRevision)
	This:C1470._setFirstRevision()
	This:C1470._startLifecycle()

	// a copy gets its own code and today's date, not the original's; it starts at the first
	// revision level, with no frozen revision (those stay with the original), and as a new quote:
	// active, not sent, not closed, not voided, valid for the default period
local Function duplicateRecord()
	This:C1470.code:=This:C1470.calculateCode()
	This:C1470.dateCreation:=Current date:C33()
	This:C1470._setFirstRevision()
	This:C1470._startLifecycle()

	// status Active, valid for This.defaultValidityDays from today, nothing sent / closed / voided
Function _startLifecycle()
	This:C1470._setStatus("A")
	This:C1470.validUntil:=Add to date:C393(Current date:C33; 0; 0; This:C1470.defaultValidityDays())
	This:C1470.stmpSent:=0
	This:C1470.stmpClosed:=0
	This:C1470.reasonWL:=""
	This:C1470.voided:=False:C215
	This:C1470.stmpVoided:=0

	// the frozen revisions go with the quote (deleting is admin-only)
local Function beforeDelete()
	var $info : Object
	If (This:C1470.revisions.length>0)
		$info:=This:C1470.revisions.drop()
	End if

Function _setFirstRevision()
	var $first : cs:C1710.RevisionEntity
	$first:=ds:C1482.Revision.firstLevel()
	This:C1470.UUID_Revision:=($first=Null:C1517) ? "0"*32 : $first.UUID

local Function beforeSaveCreation()
	If (This:C1470.code="")
		This:C1470.code:=This:C1470.calculateCode()
	End if
	
	
	
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
	
	
	
	// the assumptions marked Default (Administration > Assumptions); the others are added by hand
	// (panel_quote.bActionAssumptions)
Function addAssumptions()

	$assumptions:=ds:C1482.Assumption.query("isDefault = :1"; True:C214).distinct("UUID")
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
