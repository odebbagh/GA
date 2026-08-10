//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $data : Object
var $paths : Collection
var $path : Text
var $parts : Collection
var $idx : Integer
var $accPath : Text
var $created : Integer
var $existing : Integer
var $failed : Integer
var $seen : Object
var $bin : cs:C1710.BinEntity
var $saveResult : Object

TRUNCATE TABLE:C1051([Bin:95])

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("warehouseBins_levels.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$data:=JSON Parse:C1218($file.getText())
	$paths:=$data.paths
	
	If ($paths=Null:C1517)
		ALERT:C41("Invalid JSON format. Missing 'paths' collection.")
	Else 
		$seen:=New object:C1471()
		$created:=0
		$existing:=0
		$failed:=0
		
		For each ($path; $paths)
			$parts:=Split string:C1554($path; "/"; sk trim spaces:K86:2)
			$accPath:=""
			
			For ($idx; 0; $parts.length-1)
				If (String:C10($parts[$idx])#"")
					$accPath:=($accPath="") ? String:C10($parts[$idx]) : ($accPath+"/"+String:C10($parts[$idx]))
					
					If ($seen[$accPath]=Null:C1517)
						$seen[$accPath]:=True:C214
						
						$bin:=ds:C1482.Bin.query("binLocationPath = :1"; $accPath).first()
						If ($bin=Null:C1517)
							$bin:=ds:C1482.Bin.new()
							$bin.binLocationPath:=$accPath
							$saveResult:=$bin.save()
							
							If ($saveResult.success)
								$created:=$created+1
							Else 
								$failed:=$failed+1
							End if 
						Else 
							$existing:=$existing+1
						End if 
					End if 
				End if 
			End for 
		End for each 
		
		// Refresh shared cache used by the bin picker utility.
		If (Storage:C1525#Null:C1517)
			If (Storage:C1525.cache#Null:C1517)
				Use (Storage:C1525.cache)
					Storage:C1525.cache.bins:=Null:C1517
				End use 
			End if 
		End if 
		ds:C1482.Bin.cacheLoad()
		
		ALERT:C41("Warehouse bins import termine - created: "+String:C10($created)+" | existing: "+String:C10($existing)+" | failed: "+String:C10($failed))
	End if 
End if 
