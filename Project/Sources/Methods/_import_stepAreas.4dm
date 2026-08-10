//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $stepAreaDataClass : 4D:C1709.DataClass
var $stepAreaEntity : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $name : Text

$stepAreaDataClass:=ds:C1482["StepArea"]

If ($stepAreaDataClass=Null:C1517)
	ALERT:C41("DataClass StepArea not found. Create the table first.")
Else 
	$stepAreaDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("stepAreas_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$name:=String:C10($record.name)
			If ($name#"")
				$stepAreaEntity:=$stepAreaDataClass.new()
				$stepAreaEntity.name:=$name
				
				$result:=$stepAreaEntity.save()
				If ($result.success)
					$created:=$created+1
				Else 
					$failed:=$failed+1
				End if 
			End if 
		End for each 
		
		ALERT:C41("Import termine - step areas: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
	
End if 
