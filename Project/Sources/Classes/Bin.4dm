Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("Bin"; ["customerService"]; "Bins")
	$entry.setDataclass("Bin")
	$entry.setDisplayOrder(-600)
	$entry.setIcon("image/entry/bin-white-50x50.png")
	
	$entry.setSearchboxField("binLocationPath")
	
	$entry.setPanel("panel_bin")
	
	$entry.setPanelPage(1; ""; "Main")
	
	$entry.setLBItemsColumn("binLocationPath"; "Location Path"; "width:200")
	$entry.setLBItemsColumn("inventoryNames"; "Inventory"; "width:220"; "orderByFormula:This.inventoryNames")
	$entry.setLBItemsOrderBy("binLocationPath")
	
	$entry.enableTransaction()

	$entry.activateComment()

	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.bins=Null:C1517)
		$bins:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.bins:=$bins.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$bins : Collection
	$bins:=This:C1470.all().toCollection("UUID, binLocationPath, isEmpty").orderBy("binLocationPath")
	