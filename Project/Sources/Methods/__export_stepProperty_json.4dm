//%attributes = {}

ARRAY TEXT:C222($items; 0)
ARRAY LONGINT:C221($refs; 0)

var $i : Integer
var $records : Collection
var $record : Object
var $export : Object
var $dataFolder : 4D.Folder
var $exportFolder : 4D.Folder
var $file : 4D.File

LIST TO ARRAY:C288("StepProperty"; $items; $refs)

$records:=New collection:C1472()

For ($i; 1; Size of array:C274($items))
	$record:=New object:C1471(\
		"name"; $items{$i}; \
		"ref"; $refs{$i}\
		)
	$records.push($record)
End for 

$export:=New object:C1471(\
	"enumName"; "StepProperty"; \
	"items"; $records\
	)

$dataFolder:=Folder:C1567(fk data folder:K87:12)
$exportFolder:=$dataFolder.folder("DataJson")

If (Not:C34($exportFolder.exists))
	$exportFolder.create()
End if 

$file:=$exportFolder.file("stepProperty_enum_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($export))

ALERT:C41("Export termine: "+$file.platformPath)
