//%attributes = {}
$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("steps_files_export.json")

$records:=JSON Parse:C1218($file.getText())

$created:=0
$updated:=0
$failed:=0

For each ($record; $records)
	$col:=$record.arrays.a_tsdesc
	For each ($item; $col)
		$es:=ds:C1482.Step.query("description = :1"; $item)
		If ($es.length=0)
			
			$est:=ds:C1482.StepTemplate.query("name = :1"; $item)
			TRACE:C157
		End if 
	End for each 
End for each 