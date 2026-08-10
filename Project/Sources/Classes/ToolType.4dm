Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("toolType"; ["housekeeping"]; "Tool Type")
	$entry.setDataclass("ToolType")
	$entry.setDisplayOrder(-300)
	$entry.setIcon("image/entry/tools-white-50x50.png")
	
	$entry.setSearchboxField("type")
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_tools")
	$entry.setPanelPage(1; ""; "Main")
	
	
	$entry.setLBItemsColumn("name"; "Name"; "width:250")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.setLBItemsOrderBy("name")
	$entry.enableTransaction()
	
	