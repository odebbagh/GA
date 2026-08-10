

Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : CAO
	$entry:=cs:C1710.sfw_definitionEntry.new("CAO"; ["accounting"]; "CAOs"; "CAO")
	$entry.setDataclass("CAO")
	$entry.setDisplayOrder(-100)
	$entry.setIcon("image/entry/charOfAccount-white-50x50.png")
	
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_CAO"; 1)
	$entry.setPanelPage(1; ""; "Main")
	
	//$entry.setLBItemsColumn("dateCreated"; "Created"; "width:100")
	$entry.setLBItemsColumn("name"; "Name"; "width:150")
	$entry.setLBItemsColumn("type.name"; "Type"; "width:150")
	$entry.setLBItemsColumn("typeDetail.name"; "Type Detail"; "width:100")
	$entry.setLBItemsColumn("balance"; "Balance"; "width:50")
	
	$entry.setSubset("activeCAOs")
	$entry.setLBItemsOrderBy("name")
	$entry.setMainViewLabel("All Actives Account")
	
	$entry.setItemListAction("Print Chart Of Account List"; "_ga_printCAOSelection")
	$entry.setItemListAction("Export Chart Of Account List"; "_ga_exportCAOSelection")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.enableTransaction()
	
	$entry.activateFavorite()
	
	
	
	// MARK: -Views
	$view:=cs:C1710.sfw_definitionView.new("inactiveCAOs"; "Inactive Accounts"; "derivedFrom:main"; $entry)
	$view.setSubset("inactiveCAOs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/caos-16x16.png")
	$entry.setView($view)
	
	
Function activeCAOs()->$caos : cs:C1710.CAOSelection
	$caos:=ds:C1482.CAO.query("isInacActive =:1 "; False:C215)
	
	
Function inactiveCAOs()->$caos : cs:C1710.CAOSelection
	$caos:=ds:C1482.CAO.query("isInacActive =:1 "; True:C214)
	
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.parentAccounts=Null:C1517)
		$parentAccounts:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.parentAccounts:=$parentAccounts.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$parentAccounts : Collection
	$parentAccounts:=ds:C1482.CAO.query("UUID #:1"; Form:C1466.current_item.UUID).toCollection("UUID,name,accountNumber,description").orderBy("accountNumber")
	
	
	