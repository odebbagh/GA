Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("bom"; ["customerService"]; "Bom"; "Bom")
	$entry.setDataclass("BOM")
	$entry.setDisplayOrder(-1000)
	$entry.setIcon("image/entry/bill.png")
	
	$entry.setSearchboxField("customer.name")
	
	$entry.setPanel("panel_bom")
	$entry.setPanelPage(1; ""; "Bom Items")
	
	$entry.setLBItemsColumn("customer.name"; "Customer Name"; "width:250")
	$entry.setLBItemsColumn("Bom_Part_Num"; "Part Number"; "width:100")
	
	$entry.setLBItemsOrderBy("Bom_Part_Num")
	
	//$entry.setValidationRule("Bom_Part_Num"; "entryField_poNumber"; "notZero"; "message:the poNumber is mandatory")
	//$entry.setValidationRule("Bom_Part_Num"; "entryField_poNumber"; "unique"; "message:the ident is must be unique")
	
	//$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	//$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.enableTransaction()