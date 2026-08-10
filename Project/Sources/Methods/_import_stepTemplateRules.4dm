//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $ruleDataClass : 4D:C1709.DataClass
var $ruleEntity : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $name : Text
var $description : Text
var $bit : Text
var $levelID : Integer

$ruleDataClass:=ds:C1482["StepTemplateRule"]

If ($ruleDataClass=Null:C1517)
	ALERT:C41("DataClass StepTemplateRule not found. Create the table first.")
Else 
	$ruleDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("stepTemplateRules_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$name:=String:C10($record.name)
			$description:=String:C10($record.description)
			$bit:=String:C10($record.bit)
			If ($bit="")
				$bit:=String:C10($record.hex)
			End if 
			If ($name#"")
				$ruleEntity:=$ruleDataClass.new()
				
				$levelID:=Num:C11($record.levelID)
				If ($levelID<=0)
					$levelID:=$created+1
				End if 
				
				$ruleEntity.name:=$name
				$ruleEntity.description:=$description
				$ruleEntity.bit:=$bit
				$ruleEntity.levelID:=$levelID
				
				$result:=$ruleEntity.save()
				If ($result.success)
					$created:=$created+1
				Else 
					$failed:=$failed+1
				End if 
			End if 
		End for each 
		
		ALERT:C41("Import termine - StepTemplateRule: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
	
End if 
