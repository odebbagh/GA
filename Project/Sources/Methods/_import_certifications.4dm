//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $certificationDataClass : 4D:C1709.DataClass
var $certificationEntity : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $ref : Integer
var $name : Text
var $suffix : Text
var $isPlaceholder : Boolean
var $i : Integer
var $char : Text

$certificationDataClass:=ds:C1482["Certification"]

If ($certificationDataClass=Null:C1517)
	ALERT:C41("DataClass Certification not found. Create the table first.")
Else 
	// TRUNCATE TABLE
	$certificationDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("certifications_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$name:=String:C10($record.name)
			If ($name#"")
				// Skip old placeholder values such as Cert1, Cert2, ...
				$isPlaceholder:=False:C215
				If (Length:C16($name)>=5)
					If (Uppercase:C13(Substring:C12($name; 1; 4))="CERT")
						$suffix:=Substring:C12($name; 5)
						If ($suffix#"")
							$isPlaceholder:=True:C214
							For ($i; 1; Length:C16($suffix))
								$char:=Substring:C12($suffix; $i; 1)
								If (($char<"0") | ($char>"9"))
									$isPlaceholder:=False:C215
								End if 
							End for 
						End if 
					End if 
				End if 
				
				If ($isPlaceholder)
					$failed:=$failed+1
				Else 
					$certificationEntity:=$certificationDataClass.new()
					
					//$ref:=Num($record.ref)
					//If ($ref<=0)
					//$ref:=$created+1
					//End if 
					
					//$certificationEntity.ref:=$ref
					$certificationEntity.name:=$name
					//$certificationEntity.duration:=0
					//$certificationEntity.oneTime:=False
					
					$result:=$certificationEntity.save()
					If ($result.success)
						$created:=$created+1
					Else 
						$failed:=$failed+1
					End if 
				End if 
			End if 
		End for each 
		
		ALERT:C41("Import termine - created: "+String:C10($created)+" | Placeholder: "+String:C10($failed))
	End if 
End if 
