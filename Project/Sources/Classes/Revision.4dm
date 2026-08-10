Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("revision"; "administration"; "Revision")
	$entry.setDataclass("Revision")
	$entry.setIcon("image/entry/revision-50x50-W.png"; "image/entry/revision-50x50-B.png")
	$entry.setSearchboxField("name")
	$entry.setDisplayOrder(-20000)
	
	$entry.setPanel("panel_quoteRevision")
	
	$entry.setLBItemsColumn("colorPicto"; ""; "width:20"; "type:picture")
	$entry.setLBItemsColumn("levelID"; ""; "width:50")
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
	If (Storage:C1525.cache.quoteRevision=Null:C1517)
		$quotelevelIDColl:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.quoteRevision:=$quotelevelIDColl.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$quotelevelIDColl : Collection
	$quotelevelIDColl:=This:C1470.all().toCollection("UUID, levelID, code, name, color").orderBy("levelID")