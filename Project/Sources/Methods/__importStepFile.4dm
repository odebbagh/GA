//%attributes = {}
var $step : cs:C1710.StepEntity
var $template : cs:C1710.StepTemplateEntity
var $stepFile : cs:C1710.StepFileEntity
var $customer : cs:C1710.CustomerEntity
TRUNCATE TABLE:C1051([Step:120])
TRUNCATE TABLE:C1051([StepFile:119])

//MARK:-template_definition
//$file:=Folder(fk resources folder).file("template_definition_export.json")

//$records:=JSON Parse($file.getText())
//For each ($record; $records)

//$template:=ds.StepTemplate.query("name = :1"; $record.Name).first()

//If ($template=Null)
//$template:=ds.StepTemplate.new()
//$template.name:=$record.Name
//End if 

//$template.templateNumber:=$record.Template_num
//$info:=$template.save()

//End for each 

//MARK:-StepTemplates


TRUNCATE TABLE:C1051([Step:120])
TRUNCATE TABLE:C1051([StepFile:119])
$file:=Folder:C1567(fk resources folder:K87:11).file("StepTemplates_export.json")

$records:=JSON Parse:C1218($file.getText())
For each ($record; $records)
	$template:=ds:C1482.StepTemplate.query("templateNumber = :1"; $record.Template).first()
	
	If ($template=Null:C1517)
		$template:=ds:C1482.StepTemplate.new()
		$template.templateNumber:=$record.Template
		$template.name:=$record.Process
		$info:=$template.save()
	End if 
	
	$step:=ds:C1482.Step.new()
	$step.UUID_StepTemplate:=$template.UUID
	$step.description:=$record.Description
	$step.alert:=$record.Step_Alert
	$step.specification:=$record.StepProperty
	$step.areas:=$record.Area
	$step.moreData:=New object:C1471()
	$step.moreData:=$record
	$succ:=$step.save()
	
End for each 
*/
//MARK:-steps_files
/*

$file:=Folder(fk resources folder).file("steps_files.json")

$records:=JSON Parse($file.getText())
For each ($record; $records.records)

$stepFile:=ds.StepFile.query("moreData.UniqueID = :1"; $record.UniqueID).first()

If ($stepFile=Null)
$stepFile:=ds.StepFile.new()
End if 

$customer:=ds.Customer.query("name = :1"; $record.Customer).first()
If ($customer=Null)
$customer:=ds.Customer.new()
$customer.name:=$record.Customer
$info:=$customer.save()
End if 

$stepFile.name:=$record.Name
$stepFile.status:=$record.Inactive
$stepFile.UUID_Customer:=$customer.UUID
$stepFile.creationDate:=$record.Date_made

$stepFile.moreData:=New object()
$stepFile.moreData.Made_by:=$record.Made_by
$stepFile.moreData.Date_mod:=$record.Date_mod
$stepFile.moreData.Mod_by:=$record.Mod_by
$stepFile.moreData.Mod_history:=$record.Mod_history
$stepFile.moreData.S_desc:=$record.S_desc
$stepFile.moreData.Last_change:=$record.Last_change
$stepFile.moreData.Division:=$record.Division
$stepFile.moreData.DateTimeStamp:=$record.DateTimeStamp
$stepFile.moreData.CreationDateTimeStamp:=$record.CreationDateTimeStamp
$stepFile.moreData.UniqueID:=$record.UniqueID
$stepFile.moreData.UpdatedToBlob:=$record.UpdatedToBlob

$succ:=$stepFile.save()

End for each 
*/
/*

$file:=Folder(fk resources folder).file("steps_files.json")

$records:=JSON Parse($file.getText())
For each ($record; $records.records)
$stepFile:=ds.StepFile.query("moreData.UniqueID = :1"; $record.UniqueID).first()

If ($stepFile#Null)
$collection:=New collection()

If ($stepFile.moreData=Null)
$stepFile.moreData:=New object()
End if 
$stepFile.moreData.selectedSteps:=New collection()
For each ($element; $record.steps)

$template:=ds.StepTemplate.query("templateNumber = :1"; $element.typeStepInteger).first()

If ($template=Null)
$template:=ds.StepTemplate.new()
$template.templateNumber:=$element.typeStepInteger
$info:=$template.save()
End if 

$step:=ds.Step.query("description = :1 and UUID_StepTemplate = :2"; $element.descriptionStep; $template.UUID).first()

If ($step=Null)
$step:=ds.Step.new()
$step.UUID_StepTemplate:=$template.UUID
$step.description:=$element.descriptionStep
$step.alert:=$element.alertOrWarningStep
$step.specification:=$element.technicalSpecificationsStep
$step.areas:=$element.areaOrDepartmentRelatedStep
$step.moreData:=New object()
$step.moreData.Process:=$template.name
$step.moreData.Template:=$element.typeStepInteger
$step.moreData.stepFileInfo:=New object()
$step.moreData.stepFileInfo:=$element
$succ:=$step.save()
Else 
//$step.description:=$element.descriptionStep
//$step.alert:=$element.alertOrWarningStep
//$step.specification:=$element.technicalSpecificationsStep
//$step.areas:=$element.areaOrDepartmentRelatedStep

If ($step.moreData=Null)
$step.moreData:=New object()
End if 
$step.moreData.stepFileInfo:=New object()
$step.moreData.stepFileInfo:=$element
$succ:=$step.save()
End if 

$collection.push(New object("order"; $element.orderStep; "UUID"; $step.UUID))
End for each 

For each ($e; $collection)
$e.order:=$e.order+1
End for each 

$stepFile.moreData.selectedSteps:=$collection.orderBy("order")
$sucess:=$stepFile.save()
End if 

End for each 





