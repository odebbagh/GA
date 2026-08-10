Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("currency"; "administration"; "Currencies")
	$entry.setXliffLabel("currency.title")
	$entry.setDataclass("sfw_Currency")
	$entry.setDisplayOrder(100)
	$entry.setIcon("sfw/entry/currency-50x50-1.png"; "sfw/entry/currency-50x50.png")
	$entry.setDisplayOrder(-2000)
	
	$entry.setSearchField("attribute:symbol"; "tag:symbol")
	$entry.setSearchField("attribute:name"; "tag:name")
	
	$entry.setPanel("sfw_panel_currency"; 1)
	$entry.setPanelPage(1; ""; "Détails"; "disabled")
	
	$entry.setLBItemsColumn("symbol"; "Symbol"; "width:100"; "xliff:currency.field.symbol")
	$entry.setLBItemsColumn("name"; "Name"; "width:200"; "xliff:currency.field.name")
	$entry.setLBItemsOrderBy("symbol")
	
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:currency"; "unitN:currencies")
	$entry.setValidationRule("symbol"; "entryField_symbol"; "mandatory"; "trimSpace"; "uppercase")
	//$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "capitalize")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	$entry.setToolBarGroup("International")
	
	
	
	//Mark:- Function to manage the cache
local Function cacheClear()
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.currency:=Null:C1517
		End use 
	End if 
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.currency=Null:C1517)
		$currencies:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.currency:=$currencies.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
local Function cacheGet($uuid : Text)->$currency : Object
	If (Storage:C1525.cache=Null:C1517)
		This:C1470.cacheLoad()
	Else 
		If (Storage:C1525.cache.sfw_currency=Null:C1517)
			This:C1470.cacheLoad()
		End if 
	End if 
	
	$indices:=Storage:C1525.cache.currency.indices("UUID = :1"; $uuid)
	If ($indices.length>0)
		$currency:=Storage:C1525.cache.currency[$indices[0]]
	Else 
		$currency:=New object:C1471
	End if 
	
	
Function trigger()
	If (Application type:C494=4D Local mode:K5:1)
		This:C1470.cacheClear()
	Else 
		EXECUTE ON CLIENT:C651("@"; "sfw_cacheManager"; "clear"; "sfw_Currency")
	End if 
	
Function _loadAsCollection()->$currencies : Collection
	
	$currencies:=This:C1470.all().toCollection("UUID, symbol, name").orderBy("name")