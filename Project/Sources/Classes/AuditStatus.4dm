Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	// Purpose: Administration entry for Audit status dropdown.
	// created by 4D/PS [2026-october-09]
	$entry:=cs:C1710.Util.me.listEntry("auditStatus"; "Audit statuses"; "AuditStatus"; -19966)
	
	
local Function cacheClear()
	cs:C1710.Util.me.listCacheClear("auditStatus")
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.auditStatus=Null:C1517)
		$auditStatus:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.auditStatus:=$auditStatus.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function trigger()
	cs:C1710.Util.me.listTrigger("AuditStatus")
	
	
Function _loadAsCollection()->$auditStatus : Collection
	$auditStatus:=This:C1470.all().toCollection("UUID, levelID, name, code, color").orderBy("levelID")
