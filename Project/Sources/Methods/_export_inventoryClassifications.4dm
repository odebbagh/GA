//%attributes = {}

ARRAY TEXT:C222($items; 0)
ARRAY LONGINT:C221($refs; 0)

var $i : Integer
var $records : Collection
var $record : Object
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection:C1472()

// Export directly from old choice-list enumeration.
LIST TO ARRAY:C288("InventoryClassification"; $items; $refs)

For ($i; 1; Size of array:C274($items))
	$record:=New object:C1471(\
		"ID"; $refs{$i}; \
		"name"; $items{$i}; \
		"code"; String:C10($refs{$i})\
		)
	$records.push($record)
End for 
	
$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("inventoryClassifications_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath)
