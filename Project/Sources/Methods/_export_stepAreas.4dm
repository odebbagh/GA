//%attributes = {}

ARRAY TEXT:C222($items; 0)
ARRAY LONGINT:C221($refs; 0)

var $records : Collection
var $record : Object
var $i : Integer
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()

// Export from old enumeration.
LIST TO ARRAY:C288("Areas"; $items; $refs)

For ($i; 1; Size of array:C274($items))
	If ($items{$i}#"")
		$record:=New object:C1471(\
			"levelID"; $refs{$i}; \
			"name"; $items{$i}\
		)
		$records.push($record)
	End if 
End for 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("stepAreas_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | step areas: "+String:C10($records.length))
