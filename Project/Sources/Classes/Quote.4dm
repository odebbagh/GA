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
	
	$entry.setSearchField("attribute:yearCreation"; "tag:yearCreation"; "popupPart:creation"; "onlyWithTag")
	$entry.setSearchField("attribute:monthCreation"; "tag:monthCreation"; "popupPart:creation"; "onlyWithTag")
	
	
	$entry.setPanel("panel_quote")
	$entry.setPanelPage(1; "staff-32x32.png"; "Main")
	$entry.setPanelPage(2; "staff-32x32.png"; "Lines")
	$entry.setPanelPage(3; "staff-32x32.png"; "Assumptions and Terms")
	$entry.setPanelPage(4; "staff-32x32.png"; "Optional premilinary text")
	$entry.setPanelPage(5; "staff-32x32.png"; "Preview")
	
	//$entry.setPanelIfNoItemSelected("panel_quote_summary")
	
	$entry.setLBItemsColumn("code"; "Code"; "code"; "width:50")
	$entry.setLBItemsColumn("subject"; "Subject"; "subject"; "width:320")
	//$entry.setLBItemsColumn("dateCreation"; "date"; "width:50:fixed"; "center")
	$entry.setLBItemsColumn("currentStatus"; "Status"; "width:50:fixed"; "columnName:columnStatus"; "center")
	$entry.setLBItemsMetaExpression("this.metaColor()")
	$entry.setMainViewLabel("All quotes")
	
	$entry.setLBItemsOrderBy("subject")
	
	$entry.setValidationRule("UUID_Staff"; ""; "UUIDNotNull"; "message:The owner must be defined")
	$entry.setValidationRule("UUID_Customer"; ""; "UUIDNotNull"; "message:The customer must be defined")
	
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	$entry.enableTransaction()
	
	$entry.activateEvent("QuoteEvent"; "UUID_Quote")
	//$entry.setAttributesToTrackInModificationEvent("currentNextStep")
	$entry.setEventOptions("dontCreateModifyEventIfNoTrackingAttribute")
	$entry.setLinkManyToOneToTrackInModificationEvent("Revision"; "UUID_Revision"; "revision.name")
	
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
	
	//$view:=cs.sfw_definitionView.new("closedQuotes"; "Closed Quotes"; "derivedFrom:main"; $entry)
	//$view.setSubset("closedQuotes")
	//$view.setPictoLabel("/RESOURCES/sfw/image/picto/view-white-subset.png")
	//$entry.setView($view)
	
	
	//Function closedQuotes()->$es : cs.QuoteSelection
	
	//$es:=This.query("status.code = :1 "; "C")
	
	
	
	
	
	
	
	
	
	
	
	
	