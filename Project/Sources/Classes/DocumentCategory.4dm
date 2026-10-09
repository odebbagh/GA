Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	// Purpose: Administration entry for Document Control / Audit document categories.
	// created by 4D/PS [2026-october-09]
	$entry:=cs:C1710.Util.me.listEntry("documentCategory"; "Document categories"; "DocumentCategory"; -19969)
	
	
local Function cacheClear()
	cs:C1710.Util.me.listCacheClear("specCategories")
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.specCategories=Null:C1517)
		$specCategories:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.specCategories:=$specCategories.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function trigger()
	cs:C1710.Util.me.listTrigger("DocumentCategory")
	
	
Function _loadAsCollection()->$specCategories : Collection
	$specCategories:=This:C1470.all().toCollection("UUID, levelID, name, code, color").orderBy("levelID")
