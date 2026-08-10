
Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Credit sMemo
	$entry:=cs:C1710.sfw_definitionEntry.new("SalesTransaction"; ["accounting"]; "Sales Transaction"; "SalesTransaction")
	$entry.setDataclass("SalesTransaction")
	$entry.setDisplayOrder(-400)
	$entry.setIcon("image/entry/sales-Transaction-50x50.png")
	
	//$entry.setSearchboxField("creditMemo.cmNum"; "placeholder:cmNum")
	//$entry.setSearchboxField("customer.name"; "placeholder:customer")
	
	$entry.setPanel("panel_salesTransaction"; 1)
	$entry.setPanelPage(1; ""; "Main")
	
	$entry.setLBItemsColumn("transactionNumber"; "#"; "width:50")
	$entry.setLBItemsColumn("customer.name"; "Customer"; "width:200")
	$entry.setLBItemsColumn("transactionType.name"; "Type"; "width:100")
	
	//$entry.setLBItemsColumn("creditMemo.cmTotal"; "Total"; "width:100")
	
	$entry.setLBItemsColumn("transactionDate"; "Date"; "width:50")
	
	//$entry.setLBItemsOrderBy("creditMemo.cmNum")
	$entry.setMainViewLabel("All sales transaction")
	
	$entry.setItemListAction("Export to Excel"; "_ga_exportSalesTransactionSelection")
	
	$entry.setItemListAction("Print selection"; "_ga_printSalesTransactionSelection")
	
	$entry.setItemAction("Receive Payement"; "_ga_receivePayement")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	$entry.enableTransaction()
	
	$entry.activateFavorite()
	
	