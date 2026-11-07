//%attributes = {"executedOnServer":true}

// Purpose: Import Reject_Criteria hierarchical list from Sources/lists.json into RejectCriteriaCategory and RejectCriteriaItem tables.
// Parameters: none
// Returns: nothing (populates tables; alerts on save failure)
// created by 4D/PS [2026-may-19]
// modified by 4D/PS [2026-oct-02] resolve lists.json path; init moreData; reload caches
var $listsFile : 4D:C1709.File
var $listDef; $rejectList : Object
var $rootItem; $childItem : Object
var $eCategory : cs:C1710.RejectCriteriaCategoryEntity
var $eItem : cs:C1710.RejectCriteriaItemEntity
var $info : Object
var $categoryLevelID; $itemLevelID; $categoryCount; $itemCount : Integer
var $colors : Collection
var $colorIndex : Integer

$colors:=New collection:C1472("#3CB371"; "#FFFF00"; "#FF7F50"; "#1E90FF"; "#FF0000"; "#32CD32"; "#808080")

$listsFile:=File:C1566("/SOURCES/lists.json")
If ($listsFile=Null:C1517) || (Not:C34($listsFile.exists))
	$listsFile:=Folder:C1567(fk database folder:K87:14).folder("Sources").file("lists.json")
End if 
If (Not:C34($listsFile.exists))
	$listsFile:=Folder:C1567(fk database folder:K87:14).folder("Project/Sources").file("lists.json")
End if 
If (Not:C34($listsFile.exists))
	$listsFile:=Folder:C1567(fk resources folder:K87:11).parent.folder("Project/Sources").file("lists.json")
End if 
If (Not:C34($listsFile.exists))
	ALERT:C41("lists.json not found: "+$listsFile.path)
	return 
End if 

$listDef:=JSON Parse:C1218($listsFile.getText())
$rejectList:=$listDef["Reject_Criteria"]
If ($rejectList=Null:C1517)
	ALERT:C41("Reject_Criteria list not found in lists.json")
	return 
End if 

$rootItems:=$rejectList.items
If ($rootItems=Null:C1517)
	ALERT:C41("Reject_Criteria.items is empty or missing")
	return 
End if 

// Items first (FK), then categories
TRUNCATE TABLE:C1051([RejectCriteriaItem:147])
TRUNCATE TABLE:C1051([RejectCriteriaCategory:146])

$categoryLevelID:=1
$itemLevelID:=1
$categoryCount:=0
$itemCount:=0
$colorIndex:=0

// Purpose: Use levelID (unique per table, from 1) and color instead of listRef/sortOrder.
// modified by 4D/PS [2026-may-19]
For each ($rootItem; $rootItems)
	
	If (Value type:C1509($rootItem.text)=Is text:K8:3) && ($rootItem.text#"")
		
		$eCategory:=ds:C1482.RejectCriteriaCategory.new()
		$eCategory.levelID:=$categoryLevelID
		$eCategory.name:=$rootItem.text
		$eCategory.color:=$colors[$colorIndex%$colors.length]
		$eCategory.moreData:=New object:C1471("barcodeData"; "")
		$colorIndex:=$colorIndex+1
		
		$info:=$eCategory.save()
		If (Not:C34($info.success))
			ALERT:C41("RejectCriteriaCategory save failed for \""+$rootItem.text+"\": "+JSON Stringify:C1217($info))
			return 
		End if 
		
		$categoryLevelID:=$categoryLevelID+1
		$categoryCount:=$categoryCount+1
		
		If ($rootItem.subTree#Null:C1517)
			$childItems:=$rootItem.subTree.items
			If ($childItems#Null:C1517)
				For each ($childItem; $childItems)
					If (Value type:C1509($childItem.text)=Is text:K8:3) && ($childItem.text#"")
						$eItem:=ds:C1482.RejectCriteriaItem.new()
						$eItem.UUID_RejectCriteriaCategory:=$eCategory.UUID
						$eItem.levelID:=$itemLevelID
						$eItem.name:=$childItem.text
						$eItem.color:=$colors[$colorIndex%$colors.length]
						$eItem.moreData:=New object:C1471("barcodeData"; "")
						$colorIndex:=$colorIndex+1
						$info:=$eItem.save()
						If (Not:C34($info.success))
							ALERT:C41("RejectCriteriaItem save failed for \""+$childItem.text+"\": "+JSON Stringify:C1217($info))
							return 
						End if 
						$itemLevelID:=$itemLevelID+1
						$itemCount:=$itemCount+1
					End if 
				End for each 
			End if 
		End if 
		
	End if 
	
End for each 

ds:C1482.RejectCriteriaCategory.cacheClear()
ds:C1482.RejectCriteriaItem.cacheLoad()
ds:C1482.RejectCriteriaCategory.cacheLoad()

ALERT:C41("Reject criteria import done: "+String:C10($categoryCount)+" categories, "+String:C10($itemCount)+" items.")
