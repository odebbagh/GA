//%attributes = {}

var $records : Collection
var $record : Object
var $receivers : 4D.EntitySelection
var $receiver : 4D.Entity
var $receiverDataClass : 4D.DataClass
var $resourcesFolder : 4D.Folder
var $exportsFolder : 4D.Folder
var $file : 4D.File

$records:=New collection:C1472()

$receiverDataClass:=ds["Receiver"]

If ($receiverDataClass=Null:C1517)
	ALERT:C41("DataClass Receiver not found.")
Else 
	$receivers:=$receiverDataClass.all()
	
	For each ($receiver; $receivers)
		$record:=New object:C1471(\
			"Purchase_Order"; $receiver.Purchase_Order; \
			"ErpJobNumber"; $receiver.ErpJobNumber\
			)
		$records.push($record)
	End for each 
	
	$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
	$exportsFolder:=$resourcesFolder.folder("exports")
	
	If (Not:C34($exportsFolder.exists))
		$exportsFolder.create()
	End if 
	
	$file:=$exportsFolder.file("receiverJobs_export.json")
	
	If (Not:C34($file.exists))
		$file.create()
	End if 
	
	$file.setText(JSON Stringify:C1217($records))
	
	ALERT:C41("Export termine: "+$file.platformPath)
End if 
