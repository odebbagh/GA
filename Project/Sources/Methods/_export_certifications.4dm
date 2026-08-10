//%attributes = {}

ARRAY TEXT:C222($items; 0)
ARRAY LONGINT:C221($refs; 0)

var $records : Collection
var $record : Object
var $i : Integer
var $name : Text
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()

// Export from old choice-list enumeration.
LIST TO ARRAY:C288("Certification list"; $items; $refs)

For ($i; 1; Size of array:C274($items))
	$name:=$items{$i}
	If ($name#"")
		$record:=New object:C1471(\
			"ref"; $refs{$i}; \
			"name"; $name\
		)
		$records.push($record)
	End if 
End for 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("certifications_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | certifications: "+String:C10($records.length))
