Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Customer
	$entry:=cs:C1710.sfw_definitionEntry.new("customer"; ["customerService"]; "Customers")
	$entry.setDataclass("Customer")
	$entry.setDisplayOrder(100)
	$entry.setIcon("image/entry/customers-white-50x50.png")
	
	$entry.setSearchboxField("name")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "unique"; "message:Customer name is mandatory and must be unique")
	
	$entry.setPanel("panel_customer")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "POs")
	$entry.setPanelPage(3; ""; "Jobs")
	$entry.setPanelPage(4; ""; "Planning")
	$entry.setPanelPage(5; ""; "CFM Receiving")
	$entry.setPanelPage(6; ""; "Invoices")
	$entry.setPanelPage(7; ""; "Contacts")
	
	
	$entry.setLBItemsColumn("name"; "Name"; "xliff:entry.customer.field.name"; "width:200"; "columnName:columnName")
	$entry.setLBItemsMetaExpression("this.metaColor()")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	$entry.setLBItemsOrderBy("name")
	
	//mark:-Projection
	//$entry.setItemListProjection("Projection to quotes"; "projectionToQuotes"; "quote"; "salesAndQuotes")
	//$entry.setItemListProjection("Projection to leads"; "projectionToLeads"; "lead"; "salesAndQuotes")
	
	
	$entry.allowMultiSelectionInLB("###,###,##0 ^1;;"; "unit1:customer selected"; "unitN:customers selected"; "nbMinimum:2")
	
	$entry.activateEvent("CustomerEvent"; "UUID_Customer")
	
	$entry.activateComment()
	
	
	
	
	// MARK: -Filters
	$filter:=cs:C1710.sfw_definitionFilter.new("filterEnabled")
	$filter.setDefaultTitle("All customers")
	$filter.setFilterByBooleanExpression("enabled = :1"; "Enabled"; "Disabled")
	$entry.addFilter($filter)
	
	//Mark: -Views
	$view:=cs:C1710.sfw_definitionView.new("openPOs"; "Customer with Open POs"; "derivedFrom:main"; $entry)
	$view.setSubset("openPOs")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("openTravelers"; "Customer with Open Travelers"; "derivedFrom:main"; $entry)
	$view.setSubset("openTravelers")
	$entry.setView($view)
	
	
Function openPOs()->$customers : cs:C1710.CustomerSelection
	$customers:=ds:C1482.PurchaseOrder.query("openPO = :1"; True:C214).customer
	
	
Function openTravelers()->$customers : cs:C1710.CustomerSelection
	$customers:=ds:C1482.Job.query("shipped = :1"; False:C215).purchaseOrder.customer
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.customers=Null:C1517)
		$customers:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.customers:=$customers.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$customers : Collection
	$customers:=This:C1470.all().toCollection("UUID,name").orderBy("name")
	
local Function vendors()->$vendors : cs:C1710.CustomerSelection

	$vendors:=ds:C1482.Customer.query("vendor = :1"; True:C214)
	