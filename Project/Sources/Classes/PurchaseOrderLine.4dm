Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : PO Lines
	// Placed directly after "Purchase Orders" in the Customer service vision.
	// Entries are drawn with orderBy("displayOrder desc") (sfw_toolbar.showEntries),
	// so -150 slots this entry between "Purchase Orders" (-100) and "Jobs" (-200).
	$entry:=cs:C1710.sfw_definitionEntry.new("poLines"; ["customerService"]; "PO Lines"; "PO Line")
	$entry.setDataclass("PurchaseOrderLine")
	$entry.setDisplayOrder(-150)
	// No dedicated 50x50 icon exists yet: reuse the purchase order one, the lines
	// belong to it. Swap for image/entry/po-lines-white-50x50.png when available.
	$entry.setIcon("image/entry/purchase-orders-white-50x50.png")

	$entry.setSearchboxField("description")

	$entry.setPanel("panel_poLines")
	$entry.setPanelPage(1; "line-items-32x32.png"; "Infos")

	$entry.setLBItemsColumn("itemNum"; "Item #"; "width:60"; "center")
	$entry.setLBItemsColumn("purchaseOrder.poNum"; "PO Number"; "width:100")
	$entry.setLBItemsColumn("description"; "Description"; "width:260")
	$entry.setLBItemsColumn("qtyOrdered"; "Qty"; "width:60"; "center")
	$entry.setLBItemsColumn("unitPrice"; "Unit Price"; "width:90"; "format:$##,###,###,##0.00")
	$entry.setLBItemsColumn("total"; "Total"; "width:100"; "format:$##,###,###,##0.00")

	$entry.setLBItemsOrderBy("itemNum")

	// A line only exists inside a purchase order: without the parent UUID it would
	// never be reachable from panel_purchaseOrder nor counted in its PO amount.
	$entry.setValidationRule("UUID_PurchaseOrder"; ""; "UUIDNotNull"; "message:The purchase order must be defined")

	$entry.enableTransaction()

	// Same open/closed split the Line Items page of panel_purchaseOrder offers.
	$filter:=cs:C1710.sfw_definitionFilter.new("filterClosed")
	$filter.setDefaultTitle("All PO lines")
	$filter.setFilterByBooleanExpression("closed = :1"; "Closed lines"; "Open lines")
	$entry.addFilter($filter)

	// Narrow the list down to the lines of one purchase order.
	$filter:=cs:C1710.sfw_definitionFilter.new("filterPurchaseOrder")
	$filter.setDefaultTitle("All purchase orders")
	$filter.setFilterByLinkedEntity("PurchaseOrder"; "UUID_PurchaseOrder"; ""; "purchaseOrder")
	$filter.setDynamicTitle("poNum"; "## purchase orders")
	$filter.setOrderForItems("poNum")
	$entry.addFilter($filter)
