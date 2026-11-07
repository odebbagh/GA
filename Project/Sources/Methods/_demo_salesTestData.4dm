//%attributes = {}
// _demo_salesTestData
// Test data only, for the Quotes & Leads test plan. Works on customers that have at least
// two contacts (most contacts first, vendors left out). When fewer than $maxCustomers have
// them, other customers get test contacts (Alice, Brian, Carla "Test") until they have three.
// Each of the first $maxCustomers customers then gets:
// - a purchase order "TEST-<customer code>" with two lines (line 1 is released to the job,
//   line 2 is left unreleased) and its amount summed from the lines
// - a job linked to that purchase order and to line 1
// - a lead and a quote with follow-ups, for the saved views and the lead list columns (step 4)
// so a lead or a quote on that customer can link a quote, a PO and a job, and the contact
// dialogs have more than one contact to offer.
// Plus one quote with four lines on the first customer, for the Min. lot charge column and
// Move line up / down (step 5).
// Plus, on the first customer, the quote lifecycle (step 6): a lead for "Create quote", a quote
// sent with the TEST- PO on it, a won one, an expired one and a voided one.
//
// Contacts belong to a customer through Contact.UUID_Company: that is what the contact
// dialogs of panel_lead / panel_quote query.
// Safe to run again: a customer whose TEST- purchase order has its lines is skipped (one left
// without lines by an interrupted run is completed), and a customer that already has two
// contacts gets no new ones. Calls _fix_sequences first, so the Job counter is past the
// imported job numbers.
// Records are saved with ORDA, so the panel callbacks (loadAfterCreation...) do not run:
// what they would set (job number, addresses, dates) is set here.
// What was created and the list of customers with 2+ contacts are shown at the end and
// written to Project/imports/sales_test_data.txt.

var $maxCustomers : Integer
var $counts : Object
var $rows : Collection
var $toComplete : Collection
var $row : Object
var $id : Text
var $customer : cs.CustomerEntity
var $customers : cs.CustomerSelection
var $contact : cs.ContactEntity
var $po : cs.PurchaseOrderEntity
var $line : cs.PurchaseOrderLineEntity
var $job : cs.JobEntity
var $contacts : cs.ContactSelection
var $e : cs.ContactEntity
var $people : Collection
var $person : Object
var $names : Collection
var $lines : Collection
var $res : Object
var $poNum : Text
var $code : Text
var $created : Integer
var $jobNumber : Integer
var $nbNewContacts : Integer
var $i : Integer
var $address : Object
var $message : Text
var $usual : Object
var $uuid : Text
var $assumption : cs.AssumptionEntity

$maxCustomers:=3  // how many customers get a PO and a job

// 1. Contacts per customer (only companies that are customers, vendors left out)
$counts:=New object
For each ($id; ds.Contact.query("UUID_Company # :1"; "0"*32).extract("UUID_Company"))
	$counts[$id]:=Num($counts[$id])+1
End for each

$rows:=New collection
For each ($id; $counts)
	If ($counts[$id]>=2)
		$customer:=ds.Customer.get($id)
		If ($customer#Null) && (Not(Bool($customer.vendor)))
			$rows.push(New object("uuid"; $id; "name"; $customer.name; "code"; $customer.code; "nbContacts"; $counts[$id]))
		End if
	End if
End for each
$rows:=$rows.orderBy("nbContacts desc, name asc")

// customers that will get test contacts: those with one contact first, then by name
$toComplete:=New collection
If ($rows.length<$maxCustomers)
	$customers:=ds.Customer.query("vendor = :1 and not(UUID in :2)"; False; $rows.extract("uuid"))
	For each ($customer; $customers)
		$toComplete.push(New object("uuid"; $customer.UUID; "name"; $customer.name; "code"; $customer.code; "nbContacts"; Num($counts[$customer.UUID])))
	End for each
	$toComplete:=$toComplete.orderBy("nbContacts desc, name asc").slice(0; $maxCustomers-$rows.length)
End if

If ($rows.length=0) && ($toComplete.length=0)
	cs.sfw_dialog.me.alert("There is no customer in the data file: nothing was created.")
	return
End if

$message:=String($rows.length)+" customers have two contacts or more."
If ($toComplete.length>0)
	$message+="\r"+String($toComplete.length)+" more will get test contacts: "+$toComplete.extract("name").join(", ")+"."
End if
$message+="\rCreate a test purchase order, job, lead and quote for "+String($rows.length+$toComplete.length)+" customers?"
If (Not(cs.sfw_dialog.me.confirm($message; "Create"; "Cancel")))
	return
End if

$lines:=New collection
$lines.push("Sales test data - "+String(Current date)+" "+String(Current time))
$lines.push("")

// 2. Test contacts, up to three per customer
$people:=New collection
$people.push(New object("firstName"; "Alice"; "title"; "Buyer"; "phone"; "408-555-0101"))
$people.push(New object("firstName"; "Brian"; "title"; "Test Engineer"; "phone"; "408-555-0102"))
$people.push(New object("firstName"; "Carla"; "title"; "Quality Manager"; "phone"; "408-555-0103"))

For each ($row; $toComplete)
	$nbNewContacts:=0
	For ($i; $row.nbContacts; 2)
		$person:=$people[$i]
		$code:=Lowercase(Choose($row.code#""; $row.code; Substring($row.uuid; 1; 6)))

		$contact:=ds.Contact.new()
		$contact.UUID_Company:=$row.uuid
		$contact.UUID_Customer:=$row.uuid
		$contact.firstName:=$person.firstName
		$contact.lastName:="Test"
		$contact.title:=$person.title
		$contact.contactDetails:=New object("addresses"; New collection; "communications"; New collection)
		$contact.contactDetails.addresses.push(New object("type"; "main"; "detail"; New object(\
			"street_1"; "1 Test Street"; "street_2"; ""; "city"; "San Jose"; "state"; "CA"; \
			"postcode"; "95134"; "country"; "United States"; "iso_code_2"; "US")))
		$contact.contactDetails.communications.push(New object("type"; "phone"; "contact"; $person.phone; "comment"; ""))
		$contact.contactDetails.communications.push(New object("type"; "email"; "contact"; Lowercase($person.firstName)+".test@"+$code+".example.com"; "comment"; ""))
		$res:=$contact.save()
		If ($res.success)
			$nbNewContacts+=1
		Else
			$lines.push($row.name+": contact "+$person.firstName+" Test not saved ("+String($res.statusText)+")")
		End if
	End for
	$lines.push($row.name+": "+String($nbNewContacts)+" test contacts added")
	$row.nbContacts+=$nbNewContacts
	$rows.push($row)
End for each

// 3. A PO, its two lines and a job for each of the first customers
// the Job counter first: after the legacy import it is far behind the job numbers in use
_fix_sequences
For each ($row; $rows)
	If ($created>=$maxCustomers)
		break
	End if

	$customer:=ds.Customer.get($row.uuid)
	$poNum:="TEST-"+Choose($customer.code#""; $customer.code; Substring($row.uuid; 1; 8))

	$contacts:=ds.Contact.query("UUID_Company = :1"; $row.uuid).orderBy("lastName asc, firstName asc")
	$names:=New collection
	For each ($e; $contacts)
		$names.push($e.fullName)
	End for each

	// purchase order: a complete one means this customer is done; one without lines (a run that
	// stopped half way) is reused and gets its job and lines now
	$po:=ds.PurchaseOrder.query("poNum = :1"; $poNum).first()
	If ($po#Null)
		If (ds.PurchaseOrderLine.query("UUID_PurchaseOrder = :1"; $po.UUID).length>0)
			$lines.push($customer.name+": already has PO "+$poNum+", skipped")
			$created+=1
			continue
		End if
	Else
		$po:=ds.PurchaseOrder.new()
		$po.UUID_Customer:=$customer.UUID
		$po.customer_name:=$customer.name
		$po.poNum:=$poNum
		$po.logDate:=Current date
		$po.openPO:=True
		$po.currency:="USD"
		$po.description:="Test purchase order for the Quotes & Leads tests"
		$po.address:=New object("addresses"; New collection)
		$res:=$po.save()
		If (Not($res.success))
			$lines.push($customer.name+": PO not saved ("+String($res.statusText)+")")
			continue
		End if
	End if

	// job: the table's counter, as JobEntity.loadAfterCreation does (_fix_sequences moved it past
	// the imported job numbers above); should the number be taken anyway, the highest + 1
	$jobNumber:=Sequence number([Job])
	If (ds.Job.query("jobNumber = :1"; $jobNumber).length>0)
		$lines.push($customer.name+": job counter gave "+String($jobNumber)+", already used; highest + 1 taken instead")
		$jobNumber:=Num(ds.Job.all().max("jobNumber"))+1
	End if

	$address:=New object("addresses"; New collection)
	$address.addresses.push(New object("type"; "billing"; "detail"; New object("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; "")))
	$address.addresses.push(New object("type"; "shipping"; "detail"; New object("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; "")))

	$job:=ds.Job.new()
	$job.jobNumber:=$jobNumber
	$job.UUID_Customer:=$customer.UUID
	$job.customerName:=$customer.name
	$job.UUID_PurchaseOrder:=$po.UUID
	$job.dateCreated:=Current date
	$job.stmpExpected:=cs.sfw_stmp.me.build(Current date+21; ?00:00:00?)
	$job.deviceNumber:="TEST-DEV-001"
	$job.process:="Test"
	$job.qty:=100
	$job.jobComment:="Test job for the Quotes & Leads tests"
	$job.address:=$address
	$res:=$job.save()
	If (Not($res.success))
		$lines.push($customer.name+": PO "+$poNum+" created, job not saved ("+String($res.statusText)+")")
		continue
	End if

	// line 1: released to the job
	$line:=ds.PurchaseOrderLine.new()
	$line.UUID_PurchaseOrder:=$po.UUID
	$line.UUID_Job:=$job.UUID
	$line.itemNum:=1
	$line.seqNum:=1
	$line.description:="Electrical test, 100 units"
	$line.partNum:="TEST-DEV-001"
	$line.dateOrdered:=Current date
	$line.customerRequestedDate:=Current date+21
	$line.qtyOrdered:=100
	$line.unitPrice:=12.5
	$line.total:=$line.qtyOrdered*$line.unitPrice
	$line.currency:="USD"
	$res:=$line.save()

	// line 2: not released yet
	$line:=ds.PurchaseOrderLine.new()
	$line.UUID_PurchaseOrder:=$po.UUID
	$line.itemNum:=2
	$line.seqNum:=2
	$line.description:="Minimum lot charge"
	$line.partNum:="TEST-DEV-001"
	$line.dateOrdered:=Current date
	$line.customerRequestedDate:=Current date+21
	$line.qtyOrdered:=1
	$line.unitPrice:=500
	$line.total:=$line.qtyOrdered*$line.unitPrice
	$line.currency:="USD"
	$line.unreleased:=True
	$res:=$line.save()

	$po.poAmount:=ds.PurchaseOrderLine.query("UUID_PurchaseOrder = :1"; $po.UUID).sum("total")
	$res:=$po.save()

	$lines.push($customer.name+" ("+$customer.code+"): PO "+$poNum+" ($"+String($po.poAmount; "###,##0.00")+"), job "+String($jobNumber)+", contacts: "+$names.join(", "))
	$created+=1
End for each

// 4. For the saved views and the lead list columns: for each of the same customers, a lead
// owned by the user (amount and probability, so a pipeline value), with an overdue follow-up
// and one next week, and an Active quote linked to it, valid 10 more days, with a follow-up due
// today. They show in Open leads / My leads, Pending / Expiring quotes and Quotes to follow
// up. Marked moreData.salesViewsTest: a customer that has one is skipped on the next run.
var $lead : cs.LeadEntity
var $quote : cs.QuoteEntity
var $interaction : cs.InteractionEntity
var $stage : cs.LeadStageEntity
var $status : cs.QuoteStatusEntity
var $scheduledUUID : Text
var $nbViews : Integer
var $offset : Real

$stage:=ds.LeadStage.query("code == :1"; "QO").first()  // Quote Sent
$status:=ds.QuoteStatus.query("code == :1"; "A").first()  // Active
$scheduledUUID:=cs.ga_followUps.me.typeUUID("SCHEDULED")
$lines.push("")
For each ($row; $rows.slice(0; $maxCustomers))
	$nbViews+=1
	$customer:=ds.Customer.get($row.uuid)
	If (ds.Lead.query("UUID_Customer = :1 and moreData.salesViewsTest = :2"; $customer.UUID; True).length>0)
		$lines.push($customer.name+": already has its saved-views lead and quote, skipped")
		continue
	End if

	$quote:=ds.Quote.new()
	$quote.code:=$quote.calculateCode()
	$quote.subject:="Test quote for the saved views"
	$quote.UUID_Customer:=$customer.UUID
	$quote.UUID_Status:=($status=Null) ? ("0"*32) : $status.UUID
	$quote.UUID_Staff:=String(cs.sfw_userManager.me.info.UUID_Staff) || ("0"*32)
	$quote.stmpCreation:=cs.sfw_stmp.me.now()
	$quote.stmpValidUntil:=cs.sfw_stmp.me.build(Current date+10)
	$quote._setFirstRevision()
	$res:=$quote.save()

	$lead:=ds.Lead.new()
	$lead.leadCode:=$lead.calculateCode()
	$lead.UUID_Customer:=$customer.UUID
	$lead.UUID_Staff:=String(cs.sfw_userManager.me.info.UUID_Staff) || ("0"*32)
	$lead.UUID_Quote:=$quote.UUID
	$lead.currentStageID:=($stage=Null) ? 0 : $stage.stageID
	$lead.amount:=25000*$nbViews
	$lead.probabilityPC:=10+(20*$nbViews)  // 30, 50, 70 %
	$lead.stmpCreation:=cs.sfw_stmp.me.now()
	$lead.moreData:=New object("salesViewsTest"; True; "secondaryContacts"; New collection)
	$res:=$lead.save()
	If (Not($res.success))
		$lines.push($customer.name+": saved-views lead not saved ("+String($res.statusText)+")")
		continue
	End if

	// on the lead: overdue (red in the list) and next week; on the quote: due today
	For each ($offset; New collection(-3; 7; 0))
		$interaction:=ds.Interaction.new()
		If ($offset=0)
			$interaction.UUID_Quote:=$quote.UUID
			$interaction.number:=ds.Interaction.sequence(""; $quote.UUID)
		Else
			$interaction.UUID_Lead:=$lead.UUID
			$interaction.number:=ds.Interaction.sequence($lead.UUID)
		End if
		$interaction.UUID_Staff:=$lead.UUID_Staff
		$interaction.UUID_Type:=$scheduledUUID
		$interaction.stmpCreation:=cs.sfw_stmp.me.now()
		$interaction.stmpFollowUp:=cs.sfw_stmp.me.build(Current date+$offset)
		$interaction.notes:="Test follow-up for the saved views"
		$res:=$interaction.save()
	End for each
	$lines.push($customer.name+": lead "+$lead.leadCode+" ("+_ga_usdText($lead.amount)+" at "+String($lead.probabilityPC)+"%) and quote "+$quote.code+" (valid until "+String(Current date+10)+"), 3 follow-ups")
End for each

// 5. For the quote lines (Min. lot charge column, Move line up / down): one Active quote on the
// first customer, with its main contact (the preview asks for one) and four lines numbered 1..4.
// Line 2 has a minimum lot charge below quantity x unit price (not applied), line 3 one above it
// (applied: 350 instead of 160). Total 2,275.00. Marked moreData.quoteLinesTest: made only once.
var $quoteLine : cs.QuoteLineEntity
var $demoLines : Collection
var $demoLine : Object
var $mainContact : cs.ContactEntity

$lines.push("")
If (ds.Quote.query("moreData.quoteLinesTest = :1"; True).length>0)
	$lines.push("Quote lines demo: already there, skipped")
Else
	$customer:=ds.Customer.get($rows[0].uuid)
	$mainContact:=ds.Contact.query("UUID_Company = :1"; $customer.UUID).orderBy("lastName asc, firstName asc").first()

	$quote:=ds.Quote.new()
	$quote.code:=$quote.calculateCode()
	$quote.subject:="Test quote for the quote lines"
	$quote.reference:="Min. lot charge and line order demo"
	$quote.UUID_Customer:=$customer.UUID
	$quote.UUID_Status:=($status=Null) ? ("0"*32) : $status.UUID
	$quote.UUID_Staff:=String(cs.sfw_userManager.me.info.UUID_Staff) || ("0"*32)
	$quote.stmpCreation:=cs.sfw_stmp.me.now()
	$quote.stmpValidUntil:=cs.sfw_stmp.me.build(Current date+30)
	$quote.assumptions:=New object("UUIDs"; New collection)
	$quote.termsConditions:=New object("UUIDs"; New collection)
	$quote.moreData:=New object("quoteLinesTest"; True; "secondaryContacts"; New collection)
	If ($mainContact#Null)
		$quote.moreData.mainContact:=New object("UUID"; $mainContact.UUID)
	End if
	$quote._setFirstRevision()
	$res:=$quote.save()
	If (Not($res.success))
		$lines.push("Quote lines demo: quote not saved ("+String($res.statusText)+")")
	Else
		$demoLines:=New collection
		$demoLines.push(New object("description"; "Electrical test at 25 C, 500 units"; "quantity"; 500; "unitPrice"; 1.2; "minLotCharge"; 0))
		$demoLines.push(New object("description"; "Burn-in 48 h, 500 units"; "quantity"; 500; "unitPrice"; 2.5; "minLotCharge"; 1000))
		$demoLines.push(New object("description"; "X-ray inspection, sample of 20"; "quantity"; 20; "unitPrice"; 8; "minLotCharge"; 350))
		$demoLines.push(New object("description"; "Tape and reel"; "quantity"; 500; "unitPrice"; 0.15; "minLotCharge"; 0))
		$i:=0
		For each ($demoLine; $demoLines)
			$i+=1
			$quoteLine:=ds.QuoteLine.new()
			$quoteLine.UUID_Quote:=$quote.UUID
			$quoteLine.num:=$i
			$quoteLine.description:=$demoLine.description
			$quoteLine.quantity:=$demoLine.quantity
			$quoteLine.unitPrice:=$demoLine.unitPrice
			$quoteLine.minLotCharge:=$demoLine.minLotCharge
			$quoteLine.moreData:=New object
			$res:=$quoteLine.save()
			If (Not($res.success))
				$lines.push("Quote lines demo: line "+String($i)+" not saved ("+String($res.statusText)+")")
			End if
		End for each
		$lines.push("Quote lines demo: quote "+$quote.code+" on "+$customer.name+", "+String($quote.lines.length)+" lines, total "+$quote.amount)
	End if
End if

// 5b. Default assumptions: a new quote gets only those (QuoteEntity.addAssumptions). When none is
// marked yet, the usual ones of the recent quotes are, as _fix_assumptionDefaults "Apply" does.
// Before step 6, whose quotes are created with them.
If (ds.Assumption.query("isDefault = :1"; True).length=0)
	$usual:=ds.Assumption.usualOnRecentQuotes(300)
	For each ($uuid; $usual.UUIDs)
		$assumption:=ds.Assumption.get($uuid)
		$assumption.isDefault:=True
		$res:=$assumption.save()
	End for each
	$lines.push("Default assumptions: "+String($usual.UUIDs.length)+" marked (on half of the recent quotes or more)")
Else
	$lines.push("Default assumptions: "+String(ds.Assumption.query("isDefault = :1"; True).length)+" already marked")
End if

// 6. The quote lifecycle (ga_sales, ga_followUps, QuoteEntity "Lifecycle"), on the first customer,
// through the same functions as the item actions (history lines included):
// - the PROPOSAL_SENT trigger gets 3 days when it has none, so "Mark as sent" schedules a follow-up
// - lead "to quote": nothing linked yet, for "Create quote" live
// - lead "sent": quote created from it and marked as sent (lead at Quote Sent, follow-up in 3
//   days), the customer's TEST- PO entered on the quote when it has none (the lead gets the PO
//   and the job)
// - lead "won": quote created, sent, closed as won with a reason (lead Won, same reason)
// - a quote past its validity date (red in the list) and a voided one (greyed), without a lead
// The leads are marked moreData.lifecycleTest: a customer that has them is skipped on the next run.
var $trigger : cs.InteractionTriggerEntity
var $leadSent; $leadWon : cs.LeadEntity
var $quoteSent; $quoteWon : cs.QuoteEntity
var $customerContacts : cs.ContactSelection
var $leadMoreData : Object
var $kind : Text

$lines.push("")
$trigger:=ds.InteractionTrigger.query("code == :1"; "PROPOSAL_SENT").first()
Case of
	: ($trigger=Null)
		$lines.push("Lifecycle: no PROPOSAL_SENT trigger, \"Mark as sent\" schedules no follow-up")
	: ($trigger.moreData#Null) && (String($trigger.moreData.daysAfterLeadCreation)#"")
		$lines.push("Lifecycle: PROPOSAL_SENT already schedules a follow-up "+String($trigger.moreData.daysAfterLeadCreation)+" days after \"Mark as sent\"")
	Else
		$leadMoreData:=($trigger.moreData=Null) ? New object : OB Copy($trigger.moreData)
		$leadMoreData.daysAfterLeadCreation:="3"
		$trigger.moreData:=$leadMoreData
		$res:=$trigger.save()
		$lines.push("Lifecycle: PROPOSAL_SENT set to a follow-up 3 days after \"Mark as sent\"")
End case

$customer:=($rows.length=0) ? Null : ds.Customer.get($rows[0].uuid)
Case of
	: ($customer=Null)
	: (ds.Lead.query("UUID_Customer = :1 and moreData.lifecycleTest = :2"; $customer.UUID; True).length>0)
		$lines.push($customer.name+": already has its lifecycle leads and quotes, skipped")
	Else
		// the leads' contacts: the customer's first one as main, the others as secondary
		$customerContacts:=ds.Contact.query("UUID_Company = :1"; $customer.UUID).orderBy("lastName asc, firstName asc")
		$leadMoreData:=New object("lifecycleTest"; True; "secondaryContacts"; New collection)
		If ($customerContacts.length>0)
			$leadMoreData.mainContact:=New object("UUID"; $customerContacts.first().UUID)
			$leadMoreData.secondaryContacts:=$customerContacts.slice(1).extract("UUID")
		End if
		$stage:=ds.LeadStage.query("code == :1"; "QA").first()  // Qualified

		For each ($kind; New collection("to quote"; "sent"; "won"))
			$lead:=ds.Lead.new()
			$lead.leadCode:=$lead.calculateCode()
			$lead.UUID_Customer:=$customer.UUID
			$lead.UUID_Staff:=String(cs.sfw_userManager.me.info.UUID_Staff) || ("0"*32)
			$lead.currentStageID:=($stage=Null) ? 0 : $stage.stageID
			$lead.amount:=Choose($kind="won"; 18000; 12000)
			$lead.probabilityPC:=Choose($kind="to quote"; 20; 60)
			$lead.stmpCreation:=cs.sfw_stmp.me.now()
			$lead.moreData:=OB Copy($leadMoreData)
			$res:=$lead.save()
			Case of
				: (Not($res.success))
					$lines.push($customer.name+": lifecycle lead \""+$kind+"\" not saved ("+String($res.statusText)+")")
				: ($kind="to quote")
					$lines.push($customer.name+": lead "+$lead.leadCode+" for \"Create quote\"")
				: ($kind="sent")
					$leadSent:=$lead
				: ($kind="won")
					$leadWon:=$lead
			End case
		End for each

		// sent, with the customer's TEST- PO entered on it (when the PO has no quote yet)
		If ($leadSent#Null)
			$res:=cs.ga_sales.me.createQuoteFromLead($leadSent)
			If ($res.success)
				$quoteSent:=$res.quote
				$res:=$quoteSent.markAsSent()
				$poNum:="TEST-"+Choose($customer.code#""; $customer.code; Substring($customer.UUID; 1; 8))
				$po:=ds.PurchaseOrder.query("poNum = :1"; $poNum).first()
				If ($po#Null) && (cs.sfw_string.me.isAnEmptyUUID($po.UUID_Quote))
					$po.UUID_Quote:=$quoteSent.UUID
					$res:=$po.save()
					cs.ga_sales.me.syncLeadsFromPurchaseOrder($po)
				End if
				$leadSent.reload()
				$lines.push($customer.name+": lead "+$leadSent.leadCode+" -> quote "+$quoteSent.code+" sent"+(($leadSent.purchaseOrder=Null) ? "" : ", PO "+String($leadSent.purchaseOrder.poNum)+(($leadSent.job=Null) ? "" : " and job "+String($leadSent.job.jobNumber))+" on the lead"))
			Else
				$lines.push($customer.name+": quote from lead "+$leadSent.leadCode+" not created ("+String($res.message)+")")
			End if
		End if

		// won, with a reason
		If ($leadWon#Null)
			$res:=cs.ga_sales.me.createQuoteFromLead($leadWon)
			If ($res.success)
				$quoteWon:=$res.quote
				$res:=$quoteWon.markAsSent()
				$res:=$quoteWon.close(True; "Best turnaround time, price accepted")
				$lines.push($customer.name+": lead "+$leadWon.leadCode+" -> quote "+$quoteWon.code+" won")
			Else
				$lines.push($customer.name+": quote from lead "+$leadWon.leadCode+" not created ("+String($res.message)+")")
			End if
		End if

		// expired and voided, without a lead
		For each ($kind; New collection("expired"; "voided"))
			$quote:=ds.Quote.new()
			$quote.initDefaults()
			$quote.UUID_Customer:=$customer.UUID
			$quote.subject:="Test quote ("+$kind+")"
			$quote.moreData:=New object("lifecycleTest"; True)
			If ($kind="expired")
				$quote.dateCreation:=Current date-35
				$quote.validUntil:=Current date-5
			End if
			$res:=$quote.save()
			Case of
				: (Not($res.success))
					$lines.push($customer.name+": "+$kind+" quote not saved ("+String($res.statusText)+")")
				: ($kind="voided")
					$res:=$quote.setVoided(True; "Test: replaced by another quote")
					$lines.push($customer.name+": quote "+$quote.code+" voided")
				Else
					$lines.push($customer.name+": quote "+$quote.code+" expired (valid until "+String($quote.validUntil)+")")
			End case
		End for each
End case

// 7. Report: what was created, then every customer that can be used for the contact tests
$lines.push("")
$lines.push("Customers with two contacts or more ("+String($rows.length)+"):")
For each ($row; $rows)
	$lines.push("  "+$row.name+" ("+$row.code+"): "+String($row.nbContacts)+" contacts")
End for each

Folder(fk database folder).folder("Project/imports").file("sales_test_data.txt").setText($lines.join("\r\n"))
// the dialog: everything above the customer list (the file has it all)
cs.sfw_dialog.me.info($lines.slice(0; $lines.length-$rows.length-2).join("\r")+"\r\rFull list in Project/imports/sales_test_data.txt")
