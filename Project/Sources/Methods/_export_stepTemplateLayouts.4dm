//%attributes = {}

ARRAY TEXT:C222($items; 0)
ARRAY LONGINT:C221($refs; 0)

var $records : Collection
var $record : Object
var $seen : Object
var $i : Integer
var $name : Text
var $type : Text
var $key : Text
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()
$seen:=New object:C1471()

// Export from old enumeration.
LIST TO ARRAY:C288("TravPrintForms"; $items; $refs)

For ($i; 1; Size of array:C274($items))
	$name:=$items{$i}
	If ($name#"")
		$key:=Uppercase:C13($name)
		If ($seen[$key]#True:C214)
			$seen[$key]:=True:C214
			If (Substring:C12($name; 1; 2)="L_")
				$type:="large"
			Else 
				$type:="small"
			End if 
			
			$record:=New object:C1471(\
				"name"; $name; \
				"type"; $type\
			)
			$records.push($record)
		End if 
	End if 
End for 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("stepTemplateLayouts_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | layouts: "+String:C10($records.length))
