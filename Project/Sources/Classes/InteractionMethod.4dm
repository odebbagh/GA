Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("interactionMethod"; "administration"; "Interaction method")
	$entry.setDataclass("InteractionMethod")
	$entry.setIcon("image/entry/interactionMethod-50x50-W.png"; "image/entry/interactionMethod-50x50-B.png")
	$entry.setDisplayOrder(-30000)
	
	$entry.setSearchboxField("levelID")
	$entry.setSearchboxField("code")
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_interactionMethod")
	
	$entry.setLBItemsColumn("colorPicto"; ""; "width:20"; "type:picture")
	$entry.setLBItemsColumn("levelID"; "ID"; "width:30")
	$entry.setLBItemsColumn("code"; "Code"; "width:80")
	$entry.setLBItemsColumn("name"; "Name"; "width:200")
	
	$entry.setLBItemsOrderBy("levelID")
	$entry.setLBItemsOrderBy("code")
	
	$entry.setLBItemsCounter("###0###0##0^1;;"; "unit1:method"; "unitN:methods")
	
	$entry.setValidationRule("levelID"; "entryField_levelID"; "mandatory"; "trimSpace"; "capitalize")
	$entry.setValidationRule("code"; "entryField_code"; "mandatory"; "trimSpace"; "uppercase")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "capitalize")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	
	$entry.setToolBarGroup("leadParameters"; "Lead P."; "sfw/entry/leadParam-50x50.png")
	
	
	//Mark:- Function to manage the cache
local Function cacheClear()
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.interactionMethod:=Null:C1517
		End use 
	End if 
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.interactionMethod=Null:C1517)
		$interactionMethodrColl:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.interactionMethod:=$interactionMethodrColl.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
local Function cacheGet($uuid : Text)->$interactionMethod : Object
	If (Storage:C1525.cache=Null:C1517)
		This:C1470.cacheLoad()
	Else 
		If (Storage:C1525.cache.interactionMethod=Null:C1517)
			This:C1470.cacheLoad()
		End if 
	End if 
	$indices:=Storage:C1525.cache.interactionMethod.indices("UUID = :1"; $uuid)
	If ($indices.length>0)
		$interactionMethod:=Storage:C1525.cache.interactionMethod[$indices[0]]
	Else 
		$interactionMethod:=New object:C1471
	End if 
	
	
Function trigger()
	If (Application type:C494=4D Local mode:K5:1)
		This:C1470.cacheClear()
	Else 
		EXECUTE ON CLIENT:C651("@"; "sfw_cacheManager"; "clear"; "InteractionMethod")
	End if 
	
Function _loadAsCollection()->$interactionMethodrColl : Collection
	var $file : 4D:C1709.File
	var $img : Picture
	$interactionMethodrColl:=This:C1470.all().toCollection("UUID, levelID, code, name, color").orderBy("levelID")