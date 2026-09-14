Class extends DataClass


// Purpose: SFW administration entry for CAR reject-criteria child items (CAR P. toolbar group).
// created by 4D/PS [2026-may-19]
local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("rejectCriteriaItem"; "administration"; "CAR criteria items")
	$entry.setDataclass("RejectCriteriaItem")
	$entry.setIcon("image/entry/carItem-50x50.png"; "image/entry/carItem-50x50.png")
	$entry.setDisplayOrder(-19999)
	
	$entry.setSearchboxField("levelID")
	$entry.setSearchboxField("name")
	$entry.setSearchboxField("rejectCriteriaCategory.name"; "placeholder:category")
	
	$entry.setPanel("panel_rejectCriteriaItem")
	
	$entry.setLBItemsColumn("colorPicto"; ""; "width:20"; "type:picture")
	$entry.setLBItemsColumn("levelID"; "ID"; "width:30")
	$entry.setLBItemsColumn("rejectCriteriaCategory.name"; "Category"; "width:160")
	$entry.setLBItemsColumn("name"; "Name"; "width:280")
	
	$entry.setLBItemsOrderBy("levelID")
	
	$entry.setValidationRule("levelID"; "entryField_levelID"; "mandatory"; "trimSpace")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")
	$entry.setValidationRule("UUID_RejectCriteriaCategory"; "pup_category"; "mandatory")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	$entry.setToolBarGroup("CARParameters"; "CAR P."; "image/entry/carParam-50x50.png")
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterRejectCriteriaCategory")
	$filter.setDefaultTitle("All categories")
	$filter.setFilterByLinkedEntity("RejectCriteriaCategory"; "UUID_RejectCriteriaCategory"; ""; "rejectCriteriaCategory")
	$filter.setDynamicTitle("name"; "## category")
	$entry.addFilter($filter)
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.rejectCriteriaItem=Null:C1517)
		$coll:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.rejectCriteriaItem:=$coll.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
	// Purpose: Align collection projection with levelID, name, color (reference-table pattern).
	// modified by 4D/PS [2026-may-19]
Function _loadAsCollection()->$items : Collection
	$items:=This:C1470.all().toCollection("UUID, UUID_RejectCriteriaCategory, levelID, name, color").orderBy("levelID")
	