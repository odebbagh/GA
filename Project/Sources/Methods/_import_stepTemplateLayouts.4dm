//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $layoutDataClass : 4D:C1709.DataClass
var $layoutEntity : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $name : Text
var $type : Text
var $seen : Object
var $key : Text

$layoutDataClass:=ds:C1482["StepTemplateLayout"]

If ($layoutDataClass=Null:C1517)
	ALERT:C41("DataClass StepTemplateLayout not found. Create the table first.")
Else 
	// TRUNCATE TABLE
	$layoutDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("stepTemplateLayouts_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		$seen:=New object:C1471()
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$name:=String:C10($record.name)
			$type:=String:C10($record.type)
			
			If (($name#"") & ($type#""))
				$key:=Uppercase:C13($type+"|"+$name)
				If ($seen[$key]#True:C214)
					$seen[$key]:=True:C214
					
					$layoutEntity:=$layoutDataClass.new()
					$layoutEntity.type:=$type
					$layoutEntity.name:=$name
					$layoutEntity.moreData:=New object:C1471()
					
					$result:=$layoutEntity.save()
					If ($result.success)
						$created:=$created+1
					Else 
						$failed:=$failed+1
					End if 
				End if 
			End if 
		End for each 
		
		ALERT:C41("Import termine - layouts: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
End if 
