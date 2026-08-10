Class extends DataClass

// ----------------------------------------------
// entryDefinition
// ----------------------------------------------

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("Step"; ["housekeeping"]; "Step Template"; "Step Templates")
	$entry.setDataclass("Step")
	$entry.setDisplayOrder(-200)
	$entry.setIcon("image/entry/stepFile-52x52.png")
	
	$entry.setSearchboxField("description")
	
	$entry.setPanel("panel_step")
	
	$entry.setPanelPage(1; ""; "Step Properties")
	
	$entry.setLBItemsColumn("stepProcess.name"; "Process"; "width:125")
	$entry.setLBItemsColumn("description"; "Description"; "width:100")
	$entry.setLBItemsOrderBy("description")
	
	$entry.enableTransaction()
	
	$entry.activateComment()
	
	
	//Mark:- Function to manage the cache
local Function cacheClear()
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.leadNextStep:=Null:C1517
		End use 
	End if 
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.process=Null:C1517)
		$processColl:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.process:=$processColl.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
	
Function trigger()
	If (Application type:C494=4D Local mode:K5:1)
		This:C1470.cacheClear()
	Else 
		EXECUTE ON CLIENT:C651("@"; "Step"; "clear"; "Step")
	End if 
	
Function _loadAsCollection()->$processColl : Collection
	var $file : 4D:C1709.File
	var $img : Picture
	$processColl:=This:C1470.all().distinct("moreData.Process")
	