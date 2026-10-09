Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	// Purpose: Administration entry for AML inventory / procurement unit dropdowns.
	// created by 4D/PS [2026-october-09]
	$entry:=cs:C1710.Util.me.listEntry("units"; "Units"; "Units"; -19967)
	
	
local Function cacheClear()
	cs:C1710.Util.me.listCacheClear("units")
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.units=Null:C1517)
		$units:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.units:=$units.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function trigger()
	cs:C1710.Util.me.listTrigger("Units")
	
	
Function _loadAsCollection()->$units : Collection
	$units:=This:C1470.all().toCollection("UUID, levelID, name, code, color").orderBy("levelID")
