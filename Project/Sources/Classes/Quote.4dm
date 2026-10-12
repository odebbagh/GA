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
	
	//$entry.setPanelIfNoItemSelected("panel_quote_summary")
	
	$entry.setLBItemsColumn("code"; "Code"; "code"; "width:50"; "orderByFormula:Num(This.code)")  // Q251 before Q1000: the codes are not padded
	$entry.setLBItemsColumn("subject"; "Subject"; "subject"; "width:320")
	//$entry.setLBItemsColumn("dateCreation"; "date"; "width:50:fixed"; "center")
	$entry.setLBItemsColumn("currentStatus"; "Status"; "width:50:fixed"; "columnName:columnStatus"; "center")
	$entry.setLBItemsMetaExpression("this.metaColor()")
	$entry.setMainViewLabel("All quotes")
	
	$entry.setLBItemsOrderBy("codeNumber"; True:C214)  // newest quote first (Q3041 before Q999)
	
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
