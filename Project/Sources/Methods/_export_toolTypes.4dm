//%attributes = {}

var $records : Collection
var $record : Object
var $tools : Collection
var $parts : Collection
var $toolName : Text
var $toolRaw : Text
var $toolDate : Date
var $toolItemRef : Integer
var $listRefTools : Integer
var $j : Integer
var $listName : Text
var $type : Text
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()

ALL RECORDS:C47([Save_lists])
QUERY:C277([Save_lists]; [Save_lists]List_name="Z@")

While (Not:C34(End selection:C36([Save_lists])))
	$listName:=[Save_lists]List_name
	$type:=Substring:C12($listName; 2)
	
	$tools:=New collection:C1472()
	$listRefTools:=BLOB to list:C557([Save_lists]l_blob)
	
	For ($j; 1; Count list items:C380($listRefTools))
		GET LIST ITEM:C378($listRefTools; $j; $toolItemRef; $toolRaw)
		
		$parts:=Split string:C1554($toolRaw; "*")
		$toolName:=$parts[0]
		$toolDate:=!00-00-00!
		If ($parts.length>1)
			$toolDate:=Date:C102($parts[1])
		End if 
		
		$tools.push(New object:C1471(\
			"name"; $toolName; \
			"date"; $toolDate\
		))
	End for 
	
	$record:=New object:C1471(\
		"type"; $type; \
		"tools"; $tools\
	)
	$records.push($record)
	
	NEXT RECORD:C51([Save_lists])
End while 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("toolTypes_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | tool types: "+String:C10($records.length))
