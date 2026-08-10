//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $holdCodeDataClass : 4D:C1709.DataClass
var $holdCodeEntity : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $code : Text

$holdCodeDataClass:=ds:C1482["HoldCode"]

If ($holdCodeDataClass=Null:C1517)
	ALERT:C41("DataClass HoldCode not found. Create the table first.")
Else 
	$holdCodeDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("holdCodes_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$code:=String:C10($record.code)
			If ($code="")
				$code:=String:C10($record.name)
			End if 
			If ($code#"")
				$holdCodeEntity:=$holdCodeDataClass.new()
				$holdCodeEntity.Code:=$code
				
				$result:=$holdCodeEntity.save()
				If ($result.success)
					$created:=$created+1
				Else 
					$failed:=$failed+1
				End if 
			End if 
		End for each 
		
		ALERT:C41("Import termine - hold codes: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
End if 
