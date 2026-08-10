Class extends DataClass


//administration




local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("quotes"; "administration"; "Quotes status")
	$entry.setDataclass("QuoteStatus")
	$entry.setIcon("image/entry/quoteStatus-50x50-W.png"; "image/entry/quoteStatus-50x50-B.png")
	$entry.setSearchboxField("name")
	$entry.setDisplayOrder(-20000)
	
	$entry.setPanel("panel_quoteStatus")
	
	$entry.setLBItemsColumn("colorPicto"; ""; "width:20"; "type:picture")
	$entry.setLBItemsColumn("statusID"; ""; "width:50")
	$entry.setLBItemsColumn("code"; "Code"; "width:50")
	$entry.setLBItemsColumn("name"; "Name")
	
	
	$entry.setLBItemsOrderBy("code")
	
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.setToolBarGroup("QuoteParameters"; "Quote P."; "sfw/entry/quoteParam-50x50.png")
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.quoteStatus=Null:C1517)
		$quoteStatusColl:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.quoteStatus:=$quoteStatusColl.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$quoteStatusColl : Collection
	$quoteStatusColl:=This:C1470.all().toCollection("UUID, statusID, code, name, color").orderBy("statusID")