Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	// Purpose: Administration entry so Facilities Equipment location dropdowns can be edited.
	// created by 4D/PS [2026-november-03]
	$entry:=cs:C1710.Util.me.listEntry("equipmentLocation"; "Equipment locations"; "EquipmentLocation"; -19964)
	
	
local Function cacheClear()
	cs:C1710.Util.me.listCacheClear("equipmentLocations")
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.equipmentLocations=Null:C1517)
		$locations:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.equipmentLocations:=$locations.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function trigger()
	cs:C1710.Util.me.listTrigger("EquipmentLocation")
	
	
Function _loadAsCollection()->$locations : Collection
	$locations:=This:C1470.all().toCollection("UUID,levelID,name,code,color").orderBy("name")
	
