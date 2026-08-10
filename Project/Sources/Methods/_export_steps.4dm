//%attributes = {}

var $records : Collection
var $record : Object
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()

ALL RECORDS:C47([StepTemplates])

While (Not:C34(End selection:C36([StepTemplates])))
	$record:=New object:C1471(\
		"Process"; [StepTemplates]Process; \
		"Description"; [StepTemplates]Description; \
		"Step_Alert"; [StepTemplates]Step_Alert; \
		"Template"; [StepTemplates]Template; \
		"Area"; [StepTemplates]Area; \
		"StepProperty"; [StepTemplates]StepProperty; \
		"ControlSpec"; [StepTemplates]ControlSpec\
		)
	
	$records.push($record)
	NEXT RECORD:C51([StepTemplates])
End while 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("steps_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | steps: "+String:C10($records.length))
