//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $unitsDataClass : 4D:C1709.DataClass
var $unitsEntity : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $levelID : Integer
var $name : Text

$unitsDataClass:=ds:C1482["InventoryUnits"]

If ($unitsDataClass=Null:C1517)
	ALERT:C41("DataClass InventoryUnits not found. Create the table first.")
Else 
	$unitsDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("inventoryUnits_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$name:=$record.name
			If ($name#"")
				$unitsEntity:=$unitsDataClass.new()
				$levelID:=$created+1
				
				$unitsEntity.levelID:=$levelID
				$unitsEntity.name:=$name
				$unitsEntity.code:=Uppercase:C13($name)
				
				$result:=$unitsEntity.save()
				If ($result.success)
					$created:=$created+1
				Else 
					$failed:=$failed+1
				End if 
			End if 
		End for each 
		
		ALERT:C41("Import termine - created: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
End if 
