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
	
	$entry.setLBItemsColumn("boNumber"; "BO Number"; "width:80"; "center")
	$entry.setLBItemsColumn("customer.name"; "Vendor"; "width:270")
	$entry.setLBItemsColumn("lineItemsTotal"; "Amount"; "width:100"; "format:$##,###,###,##0.00")
	
	$entry.setLBItemsOrderBy("boNumber desc")
	
	$entry.setItemListAction("Print Buy Order"; "BuyingOrders_printBuyOrder")
	$entry.setItemListAction("Export Selection"; "BuyingOrders_exportSelection")
	
	$entry.enableTransaction()
	
	$entry.activateFavorite()