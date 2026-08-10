Class extends DataClass


local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.ImprovementResponses=Null:C1517)
		$ImprovementResponses:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.ImprovementResponses:=$ImprovementResponses.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$ImprovementResponses : Collection
	$ImprovementResponses:=This:C1470.all().toCollection("UUID, levelID,name").orderBy("levelID")
	