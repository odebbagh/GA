Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	// Purpose: Administration entry so Division dropdowns (Staff, AML, AVL, Document Control) can be edited.
	// created by 4D/PS [2026-october-09]
	$entry:=cs:C1710.Util.me.listEntry("division"; "Divisions"; "Division"; -19970)
	
	
local Function cacheClear()
	cs:C1710.Util.me.listCacheClear("divisions")
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.divisions=Null:C1517)
		$divisions:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.divisions:=$divisions.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function trigger()
	cs:C1710.Util.me.listTrigger("Division")
	
	
Function _loadAsCollection()->$divisions : Collection
	$divisions:=This:C1470.all().toCollection("UUID, levelID, name, code, color").orderBy("name")
