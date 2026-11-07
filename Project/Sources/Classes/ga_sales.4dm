// ga_sales
// The rules shared by leads and quotes, called from panel_lead, panel_quote, panel_purchaseOrder
// and the receiving screens, so they also hold for code that saves without the sfw callbacks:
// - contacts: making a secondary contact the main one (moreData.mainContact / secondaryContacts)
// - "Create quote" on a lead (LeadEntity.createQuote)
// - a quote sent, won or lost moves its lead's stage (applyQuoteToLeads)
// - a customer PO on a quote fills its lead's PO and job (syncLeadsFromPurchaseOrder)

singleton Class constructor


	//Mark:-Contacts
	// $entity (a Lead or a Quote): the secondary contact $uuid becomes the main one, and the
	// previous main contact a secondary one. moreData is replaced, not changed in place, so the
	// entity is marked as modified
Function makeMainContact($entity : Object; $uuid : Text)->$done : Boolean
	var $moreData : Object
	var $secondaries : Collection
	var $index : Integer

	If ($entity=Null:C1517) || ($entity.moreData=Null:C1517) || ($entity.moreData.secondaryContacts=Null:C1517)
		return
	End if
	$index:=$entity.moreData.secondaryContacts.indexOf($uuid)
	If ($index=-1)
		return
	End if
	$moreData:=OB Copy:C1225($entity.moreData)
	$secondaries:=$moreData.secondaryContacts
	$secondaries.remove($index)
	If ($moreData.mainContact#Null:C1517) && (String:C10($moreData.mainContact.UUID)#"")
		$secondaries.insert($index; $moreData.mainContact.UUID)
	End if
	$moreData.mainContact:={UUID: $uuid}
	$moreData.secondaryContacts:=$secondaries
	$entity.moreData:=$moreData
	$done:=True:C214

	
	
	//Mark:-Quote lifecycle -> lead
	// the leads of $quote follow it (the client, October 2026: automatically):
	// - "sent": stage QO "Quote Sent", unless the lead is already further on or closed
	// - "won" / "lost": the won / lost stage (LeadStage moreData.outcome, else WN / LS), the quote's
	//   reason as the lead's W/L reason, the close date
	// Called inside the quote's transaction (QuoteEntity.markAsSent / close). A history line on the
	// lead. Returns the messages of the leads that could not be saved
Function applyQuoteToLeads($quote : cs:C1710.QuoteEntity; $event : Text)->$problems : Collection
	var $lead : cs:C1710.LeadEntity
	var $stage; $previous : cs:C1710.LeadStageEntity
	var $res : Object
	var $lines : Collection
	
	$problems:=New collection:C1472
	$stage:=This:C1470.stageFor($event)
	If ($stage=Null:C1517) || ($quote=Null:C1517)
		return 
	End if 
	For each ($lead; $quote.leads)
		$previous:=ds:C1482.LeadStage.query("stageID = :1"; $lead.currentStageID).first()
		$lines:=New collection:C1472
		If ($event="sent")
			If (ds:C1482.LeadStage.outcomeOf($lead.currentStageID)#"") || ($lead.currentStageID>=$stage.stageID)
				continue  // closed, or already at "Quote Sent" or further
			End if 
		Else   // won, lost
			If ($quote.reasonWL#"")
				$lead.reasonWL:=$quote.reasonWL
				$lines.push("W/L reason: "+$quote.reasonWL)
			End if 
			$lead.dateClose:=Current date:C33
		End if 
		$lead.currentStageID:=$stage.stageID
		$lines.insert(0; "Stage: "+(($previous=Null:C1517) ? "-" : $previous.name)+" -> "+$stage.name+" (quote "+$quote.code+" "+$event+")")
		$res:=$lead.save()
		If (Bool:C1537($res.success))
			cs:C1710.ga_events.me.addEvent("lead"; $lead.UUID; "leadQuoteOutcome"; "Quote "+$event; $lines)
		Else 
			$problems.push("Lead "+$lead.leadCode+" could not be updated ("+String:C10($res.statusText)+"): it may be open in Modify elsewhere.")
		End if 
	End for each 
	
	// the lead stage of a quote event: "sent" (QO), "won", "lost" (moreData.outcome, else WN / LS)
Function stageFor($event : Text)->$stage : cs:C1710.LeadStageEntity
	Case of 
		: ($event="sent")
			$stage:=ds:C1482.LeadStage.query("code == :1"; "QO").first()
		: ($event="won") || ($event="lost")
			$stage:=ds:C1482.LeadStage.query("moreData.outcome = :1"; $event).first()
			If ($stage=Null:C1517)
				$stage:=ds:C1482.LeadStage.query("code == :1"; Choose:C955($event="won"; "WN"; "LS")).first()
			End if 
	End case 
	
	
	//Mark:-Customer PO -> lead
	// the jobs of $pos: on the PO itself (Job.UUID_PurchaseOrder) or on its lines
	// (PurchaseOrderLine.UUID_Job), the two links JobEntity.purchaseOrderOrLine reads
Function jobsOfPurchaseOrders($pos : cs:C1710.PurchaseOrderSelection)->$jobs : cs:C1710.JobSelection
	If ($pos=Null:C1517) || ($pos.length=0)
		$jobs:=ds:C1482.Job.newSelection()
		return 
	End if 
	$jobs:=ds:C1482.Job.query("UUID_PurchaseOrder in :1 or UUID in :2"; $pos.distinct("UUID"); $pos.lineItems.distinct("UUID_Job"))
	
	// a customer PO entered on a quote fills the PO of the quote's leads, and their job once the PO
	// has one (the first by number). Only empty links are filled: a lead already pointing to
	// another PO or job keeps it. The quote itself is closed as won by ga_quoteStatus (the client,
	// 13 October 2026), which moves the lead to Won. Called by PurchaseOrderEntity.afterSave / afterCreation
	// (inside the PO's transaction) and _fix_leadPoLinks ($report: a line per lead; $dryRun: nothing
	// saved). Returns the number of leads changed
Function syncLeadsFromPurchaseOrder($po : cs:C1710.PurchaseOrderEntity; $report : Collection; $dryRun : Boolean)->$nb : Integer
	var $lead : cs:C1710.LeadEntity
	var $job : cs:C1710.JobEntity
	var $lines : Collection
	
	If ($po=Null:C1517) || (cs:C1710.sfw_string.me.isAnEmptyUUID($po.UUID_Quote)) || ($po.quote=Null:C1517)
		return 
	End if 
	$job:=This:C1470.jobsOfPurchaseOrders(ds:C1482.PurchaseOrder.query("UUID = :1"; $po.UUID)).orderBy("jobNumber asc").first()
	For each ($lead; $po.quote.leads)
		$lines:=New collection:C1472
		If (cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_PurchaseOrder))
			$lead.UUID_PurchaseOrder:=$po.UUID
			$lines.push("PO "+String:C10($po.poNum)+" (entered on quote "+$po.quote.code+")")
		End if 
		If ($lead.UUID_PurchaseOrder=$po.UUID) && (cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_Job)) && ($job#Null:C1517)
			$lead.UUID_Job:=$job.UUID
			$lines.push("Job "+String:C10($job.jobNumber))
		End if 
		If ($lines.length>0)
			If ($report#Null:C1517)
				$report.push("Lead "+$lead.leadCode+": "+$lines.join(", "))
			End if 
			Case of 
				: ($dryRun)
					$nb+=1
					$lead.reload()  // nothing kept: the report only
				: (Bool:C1537($lead.save().success))
					$nb+=1
					cs:C1710.ga_events.me.addEvent("lead"; $lead.UUID; "leadOrder"; "Customer order"; $lines)
				: ($report#Null:C1517)
					$report.push("  Lead "+$lead.leadCode+" could not be saved (open in Modify elsewhere?)")
			End case 
		End if 
	End for each 
	
	
	//Mark:-Lead -> quote
	// "Create quote" on a lead (Lead_createQuote): a new quote with the quote defaults
	// (QuoteEntity.initDefaults: code, date, assumptions, terms, revision, 30 days' validity) and
	// the lead's customer, owner, service type and contacts; the lead is linked to it
	// (Lead.UUID_Quote, one quote per lead). Both saved in one transaction, with a history line on
	// each. Returns {success; message; quote}
Function createQuoteFromLead($lead : cs:C1710.LeadEntity)->$result : Object
	var $quote : cs:C1710.QuoteEntity
	var $moreData; $res : Object
	var $service : Text
	
	$result:=New object:C1471("success"; False:C215; "message"; ""; "quote"; Null:C1517)
	If ($lead=Null:C1517)
		return 
	End if 
	$quote:=ds:C1482.Quote.new()
	$quote.initDefaults()
	$quote.UUID_Customer:=$lead.UUID_Customer
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_Staff)))
		$quote.UUID_Staff:=$lead.UUID_Staff
	End if 
	$quote.UUID_ServiceType:=$lead.UUID_ServiceType
	$service:=($lead.serviceType=Null:C1517) ? "" : String:C10($lead.serviceType.name)
	$quote.subject:=$lead.leadCode+Choose:C955($service=""; ""; " - "+$service)
	$moreData:=($quote.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($quote.moreData)
	If ($lead.moreData#Null:C1517)
		If ($lead.moreData.mainContact#Null:C1517)
			$moreData.mainContact:=OB Copy:C1225($lead.moreData.mainContact)
		End if 
		$moreData.secondaryContacts:=($lead.moreData.secondaryContacts=Null:C1517) ? New collection:C1472 : $lead.moreData.secondaryContacts.copy()
	End if 
	$quote.moreData:=$moreData
	
	ds:C1482.startTransaction()
	$res:=$quote.save()
	If (Bool:C1537($res.success))
		$lead.UUID_Quote:=$quote.UUID
		$res:=$lead.save()
	End if 
	If (Not:C34(Bool:C1537($res.success)))
		ds:C1482.cancelTransaction()
		$lead.reload()
		$result.message:="The quote could not be created ("+String:C10($res.statusText)+"): the lead may be open in Modify elsewhere."
		return 
	End if 
	ds:C1482.validateTransaction()
	cs:C1710.ga_events.me.addEvent("lead"; $lead.UUID; "leadQuoteCreated"; "Quote created"; New collection:C1472("Quote "+$quote.code+" created from this lead."))
	cs:C1710.ga_events.me.addEvent("quote"; $quote.UUID; "quoteFromLead"; "Created from a lead"; New collection:C1472("Created from lead "+$lead.leadCode+"."))
	$result.success:=True:C214
	$result.quote:=$quote
	
