//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $tools : Collection
var $tool : Object
var $toolTypeDataClass : 4D:C1709.DataClass
var $toolDataClass : 4D:C1709.DataClass
var $toolTypeEntity : 4D:C1709.Entity
var $toolEntity : 4D:C1709.Entity
var $result : Object
var $createdTypes : Integer
var $createdTools : Integer
var $failed : Integer
var $type : Text
var $toolName : Text
var $toolDate : Date

$toolTypeDataClass:=ds:C1482["ToolType"]
$toolDataClass:=ds:C1482["Tool"]

If (($toolTypeDataClass=Null:C1517) | ($toolDataClass=Null:C1517))
	ALERT:C41("DataClass ToolType or Tool not found.")
Else 
	// TRUNCATE TABLE (children first, then parents)
	$toolDataClass.all().drop()
	$toolTypeDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("toolTypes_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$createdTypes:=0
		$createdTools:=0
		$failed:=0
		
		For each ($record; $records)
			$type:=String:C10($record.type)
			If ($type#"")
				$toolTypeEntity:=$toolTypeDataClass.new()
				$toolTypeEntity.type:=$type
				$toolTypeEntity.name:=$type
				$toolTypeEntity.date:=!00-00-00!
				
				$result:=$toolTypeEntity.save()
				If ($result.success)
					$createdTypes:=$createdTypes+1
					
					$tools:=$record.tools
					For each ($tool; $tools)
						$toolName:=String:C10($tool.name)
						If ($toolName#"")
							$toolEntity:=$toolDataClass.new()
							$toolEntity.UUID_ToolType:=$toolTypeEntity.UUID
							$toolEntity.name:=$toolName
							$toolDate:=!00-00-00!
							If (String:C10($tool.date)#"")
								$toolDate:=Date:C102(String:C10($tool.date))
							End if 
							$toolEntity.date:=$toolDate
							
							$result:=$toolEntity.save()
							If ($result.success)
								$createdTools:=$createdTools+1
							Else 
								$failed:=$failed+1
							End if 
						End if 
					End for each 
				Else 
					$failed:=$failed+1
				End if 
			End if 
		End for each 
		
		ALERT:C41("Import termine - tool types: "+String:C10($createdTypes)+" | tools: "+String:C10($createdTools)+" | failed: "+String:C10($failed))
	End if 
End if 
