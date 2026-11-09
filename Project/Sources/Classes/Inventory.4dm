Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("inventories"; ["customerService"]; "Inventories"; "Inventory")
	$entry.setDataclass("Inventory")
	$entry.setDisplayOrder(-600)
	$entry.setIcon("image/entry/inventories-white-50x50.png")
	
	$entry.setSearchboxField("stockNum")
	
	
	$entry.setPanel("panel_inventory"; 1)
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Pulls & History")
	// Documents: the framework page (sfw_Document + DocumentData), page 3, with the file count in the
	// tab - 412 legacy materials had documents. It switches panel_inventory to dynamic-source
	// rendering: its object methods are mirrored as class functions of the same name (end of
	// panel_inventory) - keep them in step.
	$entry.activateDocument("showCountInTab")
	
	
	$entry.setLBItemsColumn("code"; "ID"; "width:80"; "center")
	$entry.setLBItemsColumn("ownerName"; "Customer / Vendor"; "width:200"; "orderByFormula:This.ownerName")
	$entry.setLBItemsColumn("partNumberDisplay"; "Part #"; "width:160")
	
	$entry.setLBItemsOrderBy("code")
	
	// no validation rules on the quantities: the stock is never typed (ga_stock), and the framework's
	// "mandatory" does not check numbers
	
	$view:=cs:C1710.sfw_definitionView.new("qaPending"; "QA Pending"; "derivedFrom:main"; $entry)
	$view.setSubset("qaPending")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/terminated-user-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("outOfStock"; "Out Of Stock"; "derivedFrom:main"; $entry)
	$view.setSubset("outOfStock")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/terminated-user-16x16.png")
	$entry.setView($view)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCustomer")
	$filter.setDefaultTitle("All Customers")
	$filter.setFilterByLinkedEntity("Customer"; "UUID_Customer"; ""; "customer")
	$filter.setDynamicTitle("name"; "## customers")
	$filter.setOrderForItems("name")
	$filter.setAttributeLabelForItem("name")
	$entry.addFilter($filter)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterReceivedBy")
	$filter.setDefaultTitle("Received By: All")
	$filter.setFilterByLinkedEntity("Staff"; "UUID_Staff"; ""; "receiver")
	$filter.setDynamicTitle("fullName"; "## staffs")
	$filter.setOrderForItems("fullName")
	$filter.setAttributeLabelForItem("fullName")
	$entry.addFilter($filter)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterClassification")
	$filter.setDefaultTitle("All Classifications")
	$filter.setFilterByLinkedEntity("InventoryClassification"; "UUID_InventoryClassification"; ""; "inventoryClassification")
	$filter.setDynamicTitle("name"; "## classifications")
	$filter.setOrderForItems("name")
	$filter.setAttributeLabelForItem("name")
	$entry.addFilter($filter)
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.enableTransaction()
	
Function qaPending()->$inventories : cs:C1710.InventorySelection
	$inventories:=ds:C1482.Inventory.query("IQA_status = :1"; "In Progress")
	
Function outOfStock()->$inventories : cs:C1710.InventorySelection
	$inventories:=ds:C1482.Inventory.query("availableQty = :1"; 0)