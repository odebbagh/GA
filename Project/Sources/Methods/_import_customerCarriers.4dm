//%attributes = {}
// Imports the customer carriers into the CustomerCarrier lookup table.
// Was previously done inline by _import_customers; it now lives here so the lookup can
// be (re)loaded on its own. Run this BEFORE _import_customers, which only links the
// customers to the carriers it finds here.

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $carrier : cs:C1710.CustomerCarrierEntity
var $result : Object
var $created : Integer
var $failed : Integer
var $name : Text

TRUNCATE TABLE:C1051([CustomerCarrier:7])

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("customers_carriers_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else
	$records:=JSON Parse:C1218($file.getText())

	$created:=0
	$failed:=0

	For each ($record; $records)
		$name:=String:C10($record.name)
		If ($name#"")
			// the source only carries the name: keep the import idempotent on it
			$carrier:=ds:C1482.CustomerCarrier.query("name = :1"; $name).first()
			If ($carrier=Null:C1517)
				$carrier:=ds:C1482.CustomerCarrier.new()
				$carrier.name:=$name
				$carrier.code:=Uppercase:C13($name)
				$carrier.levelID:=$created+1

				$result:=$carrier.save()
				If ($result.success)
					$created:=$created+1
				Else
					$failed:=$failed+1
				End if
			End if
		End if
	End for each

	ALERT:C41("Import termine - carriers created: "+String:C10($created)+" | failed: "+String:C10($failed))
End if
