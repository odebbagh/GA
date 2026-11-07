Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("lead"; ["salesAndQuotes"]; "Leads")
	$entry.setDataclass("Lead")
	$entry.setDisplayOrder(-500)
	$entry.setIcon("image/entry/lead-50x50.png")
	
	$entry.setSearchField("attribute:numCode"; "tag:numCode"; "integer")
	$entry.setSearchField("attribute:leadCode"; "tag:code")
	$entry.setSearchField("attribute:customerName"; "tag:customer")
	
	$entry.setPanel("panel_lead"; 1)
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Interactions")
	$entry.setPanelPage(3; ""; "Jobs & Deliveries")
	// Documents: the framework page (sfw_Document + DocumentData) as page 4. Folders:
	// _ga_createSalesDocFolders. It switches panel_lead to dynamic-source rendering: its object
	// methods are mirrored as class functions of the same name (end of panel_lead) - keep them in
	// step. No "showCountInTab": panel_lead writes "Documents (n)" itself, like its other tabs
	// (the framework would add " [n]", and only above 0)
	$entry.activateDocument()
	
	$entry.setLBItemsColumn("leadCode"; "ID"; "width:50")
	$entry.setLBItemsColumn("customerName"; "Customer"; "subject"; "width:240")
	$entry.setLBItemsColumn("amountText"; "Amount"; "width:80"; "left"; "headerCenter"; "orderByFormula:Num(This.amount)")
	// computed columns (LeadEntity): sorted on a number, a text date would sort day first
	$entry.setLBItemsColumn("pipelineValueText"; "Pipeline"; "width:80"; "left"; "headerCenter"; "orderByFormula:This.pipelineValue")
	$entry.setLBItemsColumn("nextFollowUpText"; "Next follow-up"; "width:90"; "center"; "headerCenter"; "columnName:columnFollowUp"; "orderByFormula:This.nextFollowUpKey")
	$entry.setLBItemsColumn("openInteractions"; "Open"; "width:45:fixed"; "center"; "headerCenter"; "orderByFormula:This.openInteractions")
	$entry.setLBItemsMetaExpression("this.metaColor()")  // an overdue follow-up in red
	$entry.setLBItemsOrderBy("leadCode"; True:C214)  // newest lead first (codes are zero-padded: L00005)
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:lead"; "unitN:leads")
	$entry.setValidationRule("UUID_Customer"; ""; "UUIDNotNull"; "message:The customer must be defined")
	
	
	$entry.activateEvent("LeadEvent"; "UUID_Lead")
	$entry.setAttributesToTrackInModificationEvent("currentNextStep")
	$entry.setEventOptions("dontCreateModifyEventIfNoTrackingAttribute")
	$entry.setLinkManyToOneToTrackInModificationEvent("LeadNextStep"; "UUID_LeadNextStep"; "nextStep.name")
	
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setAllowedProfilesForDeletion("admin")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	// a new quote from the saved lead, linked to it, opened in its own window (ga_sales.createQuoteFromLead)
	$entry.setItemAction("Create quote"; "Lead_createQuote"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification())")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	$entry.setMainViewLabel("All leads")
	$entry.enableTransaction()
	
	$entry.activateComment()
	//$entry.activateSubscription()
	//$entry.activateAssignation()
	
	$entry.setItemListAction("Export Leads - CSV"; "lead_export_csv")
	// the amount x probability of the leads listed, by stage (pipelineSummary below)
	$entry.setItemListAction("Pipeline summary"; "pipelineSummary")

	
	//mark:-Projection
	//$entry.setItemListProjection("Projection to customers"; "projectionToCustomers"; "customer"; "customerService")
	
	$entry.allowMultiSelectionInLB("###,###,##0 ^1;;"; "unit1:lead selected"; "unitN:leads selected"; "nbMinimum:2")
	
	
	
	
	//Mark:- Filters
	
	//service types
	$filter:=cs:C1710.sfw_definitionFilter.new("filterServiceType")
	$filter.setDefaultTitle("All services")
	$filter.setFilterByLinkedEntity("ServiceType"; "UUID_ServiceType"; "uuidService"; "serviceType")
	$filter.setDynamicTitle("name"; "## services")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)
	
	//stages
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCurrentStage")
	$filter.setDefaultTitle("All stages")
	$filter.setFilterByIDInTable("LeadStage"; "stageID"; "currentStageID")
	$filter.setDynamicTitle("name"; "## stages")
	$entry.addFilter($filter)
	
	//priorities
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCurrentPriority")
	$filter.setDefaultTitle("All priorities")
	$filter.setFilterByIDInTable("LeadPriority"; "levelID"; "priorityLevelID")
	$filter.setDynamicTitle("name"; "## priorities")
	$entry.addFilter($filter)


	//Mark:-Views
	// after the columns: "derivedFrom:main" copies the main view as it is at this point
	$view:=cs:C1710.sfw_definitionView.new("openLeads"; "Open leads"; "derivedFrom:main"; $entry)
	$view.setSubset("openLeads")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("myLeads"; "My leads"; "derivedFrom:main"; $entry)
	$view.setSubset("myLeads")
	$view.setPictoLabel("/RESOURCES/sfw/image/picto/user-white.png")
	$entry.setView($view)


	//Mark:-View subsets
	// not won or lost (LeadStage.outcomeOf: the stages marked won / lost, else 6 Won and 7 Lost)
Function openLeads()->$leads : cs:C1710.LeadSelection
	$leads:=ds:C1482.Lead.query("not(currentStageID in :1)"; ds:C1482.Lead.closedStageIDs())

	// the open leads whose owner is the user's staff record (none for a user without one)
Function myLeads()->$leads : cs:C1710.LeadSelection
	var $staffUUID : Text
	$staffUUID:=String:C10(cs:C1710.sfw_userManager.me.info.UUID_Staff)
	If ($staffUUID="")
		$staffUUID:="0"*32
	End if
	$leads:=ds:C1482.Lead.openLeads().query("UUID_Staff = :1"; $staffUUID)

Function closedStageIDs()->$ids : Collection
	var $stage : cs:C1710.LeadStageEntity
	$ids:=New collection:C1472
	For each ($stage; ds:C1482.LeadStage.all())
		If (ds:C1482.LeadStage.outcomeOf($stage.stageID)#"")
			$ids.push($stage.stageID)
		End if
	End for each

	// the InteractionType SCHEDULED (a follow-up still to make), from the cache LeadEntity.afterCreation loads
Function scheduledTypeUUID()->$uuid : Text
	var $types : Collection
	If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.interactionType=Null:C1517)
		ds:C1482.InteractionType.cacheLoad()
	End if
	$types:=Storage:C1525.cache.interactionType.query("code == :1"; "SCHEDULED")
	$uuid:=($types.length>0) ? $types[0].UUID : "0"*32


	//Mark:-List actions
	// "Pipeline summary": the leads listed (view, filters and search applied), open ones only,
	// with their amount and their weighted value (amount x probability), in total and by stage.
	// Run by sfw with .call(): ds.Lead, not This
Function pipelineSummary()
	var $lead : cs:C1710.LeadEntity
	var $byStage; $stage : Object
	var $stageName; $message : Text
	var $count : Integer
	var $amount; $weighted : Real

	$byStage:=New object:C1471
	For each ($lead; Form:C1466.sfw.lb_items)
		If (Not:C34($lead.isClosed))
			$stageName:=$lead.stage
			If ($byStage[$stageName]=Null:C1517)
				$byStage[$stageName]:=New object:C1471("name"; $stageName; "stageID"; Num:C11($lead.currentStageID); "count"; 0; "amount"; 0; "weighted"; 0)
			End if
			$byStage[$stageName].count+=1
			$byStage[$stageName].amount+=Num:C11($lead.amount)
			$byStage[$stageName].weighted+=$lead.pipelineValue
			$count+=1
			$amount+=Num:C11($lead.amount)
			$weighted+=$lead.pipelineValue
		End if
	End for each

	$message:="Pipeline of the "+String:C10($count)+" open lead"+(($count>1) ? "s" : "")+" listed"
	$message+=" (out of "+String:C10(Form:C1466.sfw.lb_items.length)+")"+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)
	$message+="Amount: "+_ga_usdText($amount)+Char:C90(Carriage return:K15:38)
	$message+="Weighted (amount x probability): "+_ga_usdText($weighted)+Char:C90(Carriage return:K15:38)
	If ($count>0)
		$message+=Char:C90(Carriage return:K15:38)+"By stage:"+Char:C90(Carriage return:K15:38)
		For each ($stage; OB Values:C1718($byStage).orderBy("stageID"))
			$message+="  "+$stage.name+": "+String:C10($stage.count)+" - "+_ga_usdText($stage.amount)+", weighted "+_ga_usdText($stage.weighted)+Char:C90(Carriage return:K15:38)
		End for each
	End if
	cs:C1710.sfw_dialog.me.info($message)
	