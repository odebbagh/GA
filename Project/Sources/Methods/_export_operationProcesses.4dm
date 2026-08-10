//%attributes = {}
//%attributes = {}

ARRAY TEXT:C222($items; 0)
ARRAY LONGINT:C221($refs; 0)

var $records : Collection
var $i : Integer
var $listRef : Integer
var $itemRef : Integer
var $itemText : Text
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()
ALL RECORDS:C47([Save_lists])
QUERY:C277([Save_lists]; [Save_lists]List_name="OperationsCodesList")

While (Not:C34(End selection:C36([Save_lists])))
	$listRef:=BLOB to list:C557([Save_lists]l_blob)
	
	For ($i; 1; Count list items:C380($listRef))
		GET LIST ITEM:C378($listRef; $i; $itemRef; $itemText)
		
		If ($itemText#"")
			$records.push($itemText)
		End if 
	End for 

	NEXT RECORD:C51([Save_lists])
End while 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("operationProcesses_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | lists: "+String:C10($records.length))
