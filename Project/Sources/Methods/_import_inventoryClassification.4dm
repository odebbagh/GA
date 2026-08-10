//%attributes = {}
//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $classificationDataClass : 4D:C1709.DataClass
var $classification : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $levelID : Integer

$classificationDataClass:=ds:C1482["InventoryClassification"]

If ($classificationDataClass=Null:C1517)
	ALERT:C41("DataClass InventoryClassification not found. Create the table first.")
Else 
	$classificationDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("inventoryClassifications_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$classification:=$classificationDataClass.new()
			$levelID:=Num:C11($record.ID)
			If ($levelID<=0)
				$levelID:=$created+1
			End if 
			
			$classification.levelID:=$levelID
			$classification.name:=String:C10($record.name)
			$classification.code:=String:C10($record.code)
			
			$result:=$classification.save()
			If ($result.success)
				$created:=$created+1
			Else 
				$failed:=$failed+1
			End if 
		End for each 
		
		ALERT:C41("Import termine - created: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
End if 
