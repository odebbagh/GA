Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Quote
	$entry:=cs:C1710.sfw_definitionEntry.new("quote"; ["salesAndQuotes"]; "  Quotes  ")
	$entry.setDataclass("Quote")
	$entry.setDisplayOrder(-500)
	$entry.setIcon("image/entry/contract-white-50x50.png")
	
	//$entry.setSearchboxField("subject")
	//$entry.setSearchboxField("code")
	$entry.setSearchField("attribute:subject"; "tag:subject")
	$entry.setSearchField("attribute:code"; "tag:code")
	
	// "integer": without it the value is searched as the text "@2025@", which never equals a year
	$entry.setSearchField("attribute:yearCreation"; "tag:yearCreation"; "popupPart:creation"; "onlyWithTag"; "integer")
	$entry.setSearchField("attribute:monthCreation"; "tag:monthCreation"; "popupPart:creation"; "onlyWithTag"; "integer")
	
	
	$entry.setPanel("panel_quote")
	$entry.setPanelPage(1; "staff-32x32.png"; "Main")
	$entry.setPanelPage(2; "staff-32x32.png"; "Lines")
	$entry.setPanelPage(3; "staff-32x32.png"; "Assumptions and Terms")
	$entry.setPanelPage(4; "staff-32x32.png"; "Optional premilinary text")
	$entry.setPanelPage(5; "staff-32x32.png"; "Preview")
	// the frozen copies made by "New revision..." (QuoteRevision, Quote_newRevision). Declared before
	// activateDocument(), which adds Documents after the last page
	$entry.setPanelPage(6; "staff-32x32.png"; "Revisions")
	// the follow-ups of the quote and of its lead (Interaction, ga_followUps): page 7, so Documents is page 8
	$entry.setPanelPage(7; "staff-32x32.png"; "Follow-ups")
	// Documents: the framework page (sfw_Document + DocumentData) as page 8. Folders:
	// _ga_createSalesDocFolders. It switches panel_quote to dynamic-source rendering: its object
	// methods are mirrored as class functions of the same name (end of panel_quote) - keep them in
	// step. No "showCountInTab": panel_quote writes "Lines (n)" and "Documents (n)" itself, as
	// panel_lead does (the framework would add " [n]", and only above 0)
	$entry.activateDocument()
	
	//$entry.setPanelIfNoItemSelected("panel_quote_summary")
	
	$entry.setLBItemsColumn("code"; "Code"; "code"; "width:50"; "orderByFormula:Num(This.code)")  // Q251 before Q1000: the codes are not padded
	$entry.setLBItemsColumn("subject"; "Subject"; "subject"; "width:320")
	//$entry.setLBItemsColumn("dateCreation"; "date"; "width:50:fixed"; "center")
	$entry.setLBItemsColumn("currentStatus"; "Status"; "width:50:fixed"; "columnName:columnStatus"; "center")
	// red once passed on an open quote (metaColor); empty on imported quotes, which have none
	$entry.setLBItemsColumn("validUntilText"; "Valid until"; "width:80:fixed"; "columnName:columnValidUntil"; "center"; "headerCenter"; "orderByFormula:This.stmpValidUntil")
	$entry.setLBItemsMetaExpression("this.metaColor()")
	$entry.setMainViewLabel("All quotes")
	
	$entry.setLBItemsOrderBy("codeNumber"; True:C214)  // newest quote first (Q3041 before Q999)
	
	$entry.setValidationRule("UUID_Staff"; ""; "UUIDNotNull"; "message:The owner must be defined")
	$entry.setValidationRule("UUID_Customer"; ""; "UUIDNotNull"; "message:The customer must be defined")
	
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	// the Preview as a PDF in the "Quotes sent" documents folder; also the button of the Preview tab
	$entry.setItemAction("Save PDF to Documents"; "Quote_savePreviewPdf"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification())")
	// freezes the saved quote (Revisions tab, a PDF in "Quotes sent") and moves it to the next revision
	$entry.setItemAction("New revision..."; "Quote_newRevision"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification())")
	// the lifecycle (Quote_lifecycleAction, QuoteEntity "Lifecycle"): saved at once with the lead's
	// stage and the follow-ups, so only outside Modify
	$entry.setItemAction("Mark as sent"; "Quote_markAsSent"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification()) && Form.current_item.isOpen")
	$entry.setItemAction("Close as won..."; "Quote_closeWon"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification()) && Form.current_item.isOpen")
	$entry.setItemAction("Close as lost..."; "Quote_closeLost"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification()) && Form.current_item.isOpen")
	$entry.setItemAction("Reopen"; "Quote_reopen"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification()) && Form.current_item.isClosed && Not(Form.current_item.voided)")
	$entry.setItemAction("Void... / Restore"; "Quote_voidRestore"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification())")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	$entry.enableTransaction()
	
	$entry.activateEvent("QuoteEvent"; "UUID_Quote")
	//$entry.setAttributesToTrackInModificationEvent("currentNextStep")
	$entry.setEventOptions("dontCreateModifyEventIfNoTrackingAttribute")
	$entry.setLinkManyToOneToTrackInModificationEvent("Revision"; "UUID_Revision"; "revision.name")
	// the status changed by hand (pup_QuoteStatus); the automatic changes write their own line (ga_quoteStatus)
	$entry.setLinkManyToOneToTrackInModificationEvent("Status"; "UUID_Status"; "status.name")
	$entry.setLinkManyToOneToTrackInModificationEvent("Price flow"; "UUID_PriceFlow"; "priceFlow.name")
	$entry.setAttributeStmpToTrackInModificationEvent("Valid until"; "stmpValidUntil")
	
	$entry.activateComment()
	$entry.setAllowedProfilesForDeletion("admin")
	
	//mark:-Projection
	//$entry.setItemListProjection("Projection to customers"; "projectionToCustomers"; "customer"; "customerService")
	
	$entry.allowMultiSelectionInLB("###,###,##0 ^1;;"; "unit1:quote selected"; "unitN:quotes selected"; "nbMinimum:2")
	
	
	
	//Mark:- Filters
	
	//Quote Status
	$filter:=cs:C1710.sfw_definitionFilter.new("filterStatus")
	$filter.setDefaultTitle("All statuses")
	$filter.setFilterByLinkedEntity("QuoteStatus"; "UUID_Status"; "uuidStatus"; "status"; "displayCount:UUID_Status")
	$filter.setDynamicTitle("name"; "## statuses")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)
	
	//Service Types
	$filter:=cs:C1710.sfw_definitionFilter.new("filterServiceType")
	$filter.setDefaultTitle("All service types")
	$filter.setFilterByLinkedEntity("ServiceType"; "UUID_ServiceType"; "uuidServiceType"; "serviceType"; "displayCount:UUID_ServiceType")
	$filter.setDynamicTitle("name"; "## service types")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)
	
	//Revision
	$filter:=cs:C1710.sfw_definitionFilter.new("filterRevision")
	$filter.setDefaultTitle("All revisions")
	$filter.setFilterByLinkedEntity("Revision"; "UUID_Revision"; "uuidRevision"; "revision"; "displayCount:UUID_Revision")
	$filter.setDynamicTitle("name"; "## revisions")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)
	
	
	//Mark:-Views
	// after the columns: "derivedFrom:main" copies the main view as it is at this point
	$view:=cs:C1710.sfw_definitionView.new("pendingQuotes"; "Pending quotes"; "derivedFrom:main"; $entry)
	$view.setSubset("pendingQuotes")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("quotesToFollowUp"; "Quotes to follow up"; "derivedFrom:main"; $entry)
	$view.setSubset("quotesToFollowUp")
	$view.setPictoLabel("/RESOURCES/sfw/image/picto/bell.png")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("expiringQuotes"; "Expiring quotes"; "derivedFrom:main"; $entry)
	$view.setSubset("expiringQuotes")
	$view.setPictoLabel("/RESOURCES/sfw/image/picto/calendar-user.png")
	$entry.setView($view)


	//Mark:-View subsets
	// still open: Active, Under Customer Review or Require Follow-Up, not voided, not closed
	// (the stored fields behind QuoteEntity.isOpen, which is computed and cannot be queried)
Function pendingQuotes()->$quotes : cs:C1710.QuoteSelection
	$quotes:=ds:C1482.Quote.query("status.code in :1 & voided = :2 & stmpClosed = :3"; ["A"; "UCR"; "RFU"]; False:C215; 0)

	// pending, and either marked Require Follow-Up or with a follow-up due today or before: a
	// SCHEDULED interaction of the quote or of its lead (as ga_followUps.list gathers them)
Function quotesToFollowUp()->$quotes : cs:C1710.QuoteSelection
	var $due : cs:C1710.InteractionSelection
	var $pending : cs:C1710.QuoteSelection
	$pending:=ds:C1482.Quote.pendingQuotes()
	$due:=ds:C1482.Interaction.query("UUID_Type = :1 & stmpFollowUp > 0 & stmpFollowUp <= :2"; cs:C1710.ga_followUps.me.typeUUID("SCHEDULED"); cs:C1710.sfw_stmp.me.build(Current date:C33; ?23:59:59?))
	$quotes:=$pending.and($due.quote.or($due.lead.quote)).or($pending.query("status.code = :1"; "RFU"))

	// pending with a validity date in the next 30 days, or already gone (0 = no validity date:
	// the imported quotes are not in it)
Function expiringQuotes()->$quotes : cs:C1710.QuoteSelection
	$quotes:=ds:C1482.Quote.pendingQuotes().query("stmpValidUntil > 0 & stmpValidUntil <= :1"; cs:C1710.sfw_stmp.me.build(Current date:C33+30; ?23:59:59?))

	
	
	
	
	
	
	
	
	
	
	
	

// the creation date of a legacy quote, from the Qdate of quotes.json (__import_data_quote,
// _fix_quoteDates). Built by date arithmetic: Date("2019-07-17") gave !00-00-00! here
Function legacyDate($value : Variant)->$date : Date
	var $text : Text
	
	Case of 
		: (Value type:C1509($value)=Is date:K8:7)  // JSON Parse already made it a date, in local time
			$date:=$value
		: (Value type:C1509($value)=Is text:K8:3)
			$text:=$value
			If (Length:C16($text)>=10) && (Num:C11(Substring:C12($text; 1; 4))>0)
				$date:=Add to date:C393(!2000-01-01!; Num:C11(Substring:C12($text; 1; 4))-2000; Num:C11(Substring:C12($text; 6; 2))-1; Num:C11(Substring:C12($text; 9; 2))-1)
				// local midnight written in UTC: "2019-07-17T23:00:00Z" is 18 July (UTC+1)
				If (Num:C11(Substring:C12($text; 12; 2))>=12)
					$date:=$date+1
				End if 
			End if 
	End case 
