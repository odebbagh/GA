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
	$entry.setPanelPage(3; ""; "Jobs & Deliveries"; "disabled")
	
	$entry.setLBItemsColumn("leadCode"; "ID"; "width:50")
	$entry.setLBItemsColumn("customerName"; "Customer"; "subject"; "width:300")
	$entry.setLBItemsColumn("amountText"; "Amount"; "width:80"; "left"; "headerCenter")
	$entry.setLBItemsOrderBy("leadCode")
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
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	$entry.setMainViewLabel("All leads")
	$entry.enableTransaction()
	
	$entry.activateComment()
	//$entry.activateSubscription()
	//$entry.activateAssignation()
	
	$entry.setItemListAction("Export Leads - CSV"; "lead_export_csv")
	
	
	//mark:-Projection
	//$entry.setItemListProjection("Projection to customers"; "projectionToCustomers"; "customer"; "customerService")
	
	$entry.allowMultiSelectionInLB("###,###,##0 ^1;;"; "unit1:customer selected"; "unitN:customers selected"; "nbMinimum:2")
	
	
	
	
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
	$filter.setDynamicTitle("name"; "## statuses")
	$entry.addFilter($filter)
	
	//priorities
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCurrentPriority")
	$filter.setDefaultTitle("All priorities")
	$filter.setFilterByIDInTable("LeadPriority"; "levelID"; "priorityLevelID")
	$filter.setDynamicTitle("name"; "## priorities")
	$entry.addFilter($filter)
	