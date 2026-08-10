//%attributes = {}

var $records : Collection
var $seen : Object
var $inventories : 4D.EntitySelection
var $inventory : 4D.Entity
var $inventoryDataClass : 4D.DataClass
var $value : Text
var $key : Text
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection()
$seen:=New object()

$inventoryDataClass:=ds["Inventory"]

If ($inventoryDataClass=Null)
	ALERT("DataClass Inventory not found.")
Else 
	$inventories:=$inventoryDataClass.all()
	
	For each ($inventory; $inventories)
		$value:=String($inventory.Units)
		$key:=Uppercase($value)
		
		If (($value#"") & ($seen[$key]=Null))
			$seen[$key]:=True
			$records.push(New object(\
				"name"; $value\
			))
		End if 
	End for each 
	
	$resourcesFolder:=Folder(fk resources folder)
	$exportsFolder:=$resourcesFolder.folder("exports")
	
	If (Not($exportsFolder.exists))
		$exportsFolder.create()
	End if 
	
	$file:=$exportsFolder.file("inventoryUnits_export.json")
	
	If (Not($file.exists))
		$file.create()
	End if 
	
	$file.setText(JSON Stringify($records))
	
	ALERT("Export termine: "+$file.platformPath+" | distinct units: "+String($records.length))
End if 
