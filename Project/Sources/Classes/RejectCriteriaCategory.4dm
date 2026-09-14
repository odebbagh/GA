Class extends DataClass


// Purpose: SFW administration entry for CAR reject-criteria root categories (CAR P. toolbar group).
// created by 4D/PS [2026-may-19]
local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("rejectCriteriaCategory"; "administration"; "CAR categories")
	$entry.setDataclass("RejectCriteriaCategory")
	$entry.setIcon("image/entry/carCategory-50x50.png"; "image/entry/carCategory-50x50.png")
	// Purpose: Higher displayOrder than rejectCriteriaItem so this entry registers CAR P. toolbar icon first.
	// modified by 4D/PS [2026-may-19]
	$entry.setDisplayOrder(-19999)
	
	$entry.setSearchboxField("levelID")
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_rejectCriteriaCategory")
	
	// Purpose: Declare page 2 so the framework renders the "Criteria Items" tab in the panel header.
	// modified by 4D/PS [2026-may-19]
	$entry.setPanelPage(1; ""; "Category")
	$entry.setPanelPage(2; ""; "Criteria Items")
	
	$entry.setLBItemsColumn("colorPicto"; ""; "width:20"; "type:picture")
	$entry.setLBItemsColumn("levelID"; "ID"; "width:30")
	$entry.setLBItemsColumn("name"; "Name"; "width:280")
	
	$entry.setLBItemsOrderBy("levelID")
	
	$entry.setValidationRule("levelID"; "entryField_levelID"; "mandatory"; "trimSpace")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "capitalize")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	// Purpose: Toolbar group icon must exist under Resources (qcar-white-50x50.png is missing).
	// modified by 4D/PS [2026-may-19]
	$entry.setToolBarGroup("CARParameters"; "CAR P."; "image/entry/carParam-50x50.png")
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	//If (Storage.cache.rejectCriteriaCategory=Null)
	$coll:=This:C1470._loadAsCollection()
	Use (Storage:C1525.cache)
		Storage:C1525.cache.rejectCriteriaCategory:=$coll.copy(ck shared:K85:29; Storage:C1525.cache)
	End use 
	//End if 
	
	
	// Purpose: Align collection projection with levelID, name, color (reference-table pattern).
	// modified by 4D/PS [2026-may-19]
Function _loadAsCollection()->$categories : Collection
	$categories:=This:C1470.all().toCollection("UUID, levelID, name, color").orderBy("levelID")
	