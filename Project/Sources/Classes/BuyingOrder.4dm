Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("buyingOrders"; ["buying"]; "Buying Orders")
	$entry.setDataclass("BuyingOrder")
	$entry.setDisplayOrder(-100)
	$entry.setIcon("image/entry/buyingOrders-50x50.png")
	
	$entry.setSearchboxField("boNumber"; "placeholder:boNumber")
	$entry.setSearchboxField("supplier.name"; "placeholder:supplierName")
	
	$entry.setPanel("panel_buyingOrder")
	
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "BO Line Items")
	$entry.setPanelPage(3; ""; "Terms")

	// Attachments: the framework Documents page (sfw_Document + DocumentData) as the last
	// panel page, with the file count in the tab. Files are staged on upload and written
	// to the server when the order is saved.
	//
	// NOTE: this switches panel_buyingOrder to dynamic-source rendering, in which every
	// form object method is replaced by sfw_dynamicForm_script calling
	// cs.panel_buyingOrder.me[objectName](). The objects without a class function of that
	// name are mirrored at the end of panel_buyingOrder - they fail silently otherwise.
	$entry.activateDocument("showCountInTab")	
	$entry.setLBItemsColumn("boNumber"; "BO Number"; "width:80"; "center")
	// the order's vendor is a [Supplier] - UUID_Supplier is the FK and the picker reads
	// ds.Supplier.all(). This column was still on customer.name, so it rendered blank.
	$entry.setLBItemsColumn("supplier.name"; "Vendor"; "width:270")
	$entry.setLBItemsColumn("lineItemsTotal"; "Amount"; "width:100"; "format:$##,###,###,##0.00")
	
	$entry.setLBItemsOrderBy("boNumber desc")
	
	// DISABLED [2026-sep-26] - both methods are declared here but neither exists on disk
	// or in the method cache, so these two menu items raise an error as soon as they are
	// clicked. Commented out to keep the panel usable while testing; put them back the
	// moment BuyingOrders_printBuyOrder / BuyingOrders_exportSelection are written.
	// an ITEM action: legacy printed one order at a time. The method still handles a
	// whole list, behind a confirm, if it is ever wired as a list action too.
	$entry.setItemAction("Print Buy Order"; "BuyingOrders_printBuyOrder")
	//$entry.setItemListAction("Export Selection"; "BuyingOrders_exportSelection")
	
	$entry.enableTransaction()

	$entry.activateFavorite()

	// MARK: -Filters
	// Both are stored booleans on [BuyingOrder], so the framework's boolean filter
	// can query them directly.

	// toggle filter on the "Requisition Only" checkbox of the Main page
	$filter:=cs:C1710.sfw_definitionFilter.new("filterRequisitionOnly")
	$filter.setDefaultTitle("All buy orders")
	$filter.setFilterByBooleanExpression("awaitingApproval = :1"; "Awaiting approval"; "Approved buy orders")
	$entry.addFilter($filter)

	// toggle filter on the "Order Closed" checkbox of the Main page
	$filter:=cs:C1710.sfw_definitionFilter.new("filterClosed")
	$filter.setDefaultTitle("Open and closed")
	$filter.setFilterByBooleanExpression("closed = :1"; "Closed orders"; "Open orders")
	$entry.addFilter($filter)