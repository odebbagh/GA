Class extends DataClass


// Purpose: SFW administration entry for CAR origin values (CAR P. toolbar group).
// created by 4D/PS [2026-oct-02]
local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("qcarOrigin"; "administration"; "CAR origins")
	$entry.setDataclass("QcarOrigin")
	$entry.setIcon("image/entry/carParam-50x50.png"; "image/entry/carParam-50x50.png")
	$entry.setDisplayOrder(-19998)
	
	$entry.setSearchboxField("levelID")
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_qcarOrigin")
	
	$entry.setLBItemsColumn("levelID"; "ID"; "width:30")
	$entry.setLBItemsColumn("name"; "Name"; "width:280")
	$entry.setLBItemsColumn("usesTraveler"; "Traveler"; "width:80"; "type:boolean")
	
	$entry.setLBItemsOrderBy("levelID")
	
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	$entry.setToolBarGroup("CARParameters"; "CAR P."; "image/entry/carParam-50x50.png")
	
	
local Function cacheClear()
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.qcarOrigin:=Null:C1517
		End use 
	End if 
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.qcarOrigin=Null:C1517)
		$coll:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.qcarOrigin:=$coll.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function trigger()
	If (Application type:C494=4D Local mode:K5:1)
		This:C1470.cacheClear()
	Else 
		EXECUTE ON CLIENT:C651("@"; "sfw_cacheManager"; "clear"; "QcarOrigin")
	End if 
	
	
Function _loadAsCollection()->$origins : Collection
	$origins:=This:C1470.all().toCollection("UUID, levelID, name, usesTraveler").orderBy("levelID")
	
