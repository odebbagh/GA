//%attributes = {}

// _ga_installOneWPModel($modelName; $fileName; $folder; $installed)
// One template file -> one [sfw_DocumentModel] record. Split out of
// _ga_installBuyOrderModel only so the buy order and the receipt go through identical
// code. A missing file is not an error: the receipt template does not exist yet, and
// this simply skips it.

#DECLARE($modelName : Text; $fileName : Text; $folder : cs:C1710.sfw_DocumentFolderEntity; $installed : Collection)

var $file : 4D:C1709.File
var $model : cs:C1710.sfw_DocumentModelEntity
var $result : Object
var $isNew : Boolean

$file:=Folder(fk resources folder).file("4DWriteProPrintTemplates/"+$fileName)
If (Not($file.exists))
	return
End if

$model:=ds.sfw_DocumentModel.query("name = :1"; $modelName).first()
$isNew:=($model=Null)

If ($isNew)
	$model:=ds.sfw_DocumentModel.new()
Else
	//---re-importing throws away whatever was laid out in the editor
	If (Not(cs.sfw_dialog.me.confirm("The model \""+$modelName+"\" already exists."+Char(Carriage return)\
		+"Replace its content with "+$fileName+"? Anything you edited in it will be lost."; "Replace"; "Skip")))
		return
	End if
End if

$model.name:=$modelName
$model.type:=2  // 4D Write Pro
If (cs.sfw_string.me.isAnEmptyUUID(String($model.UUID_DocumentFolder)))
	$model.UUID_DocumentFolder:=$folder.UUID
End if
$model.area:=WP Import document($file.platformPath)

$result:=$model.save()

If ($result.success)
	$installed.push(($isNew ? "Created " : "Updated ")+$modelName+" from "+$fileName)
Else
	cs.sfw_dialog.me.alert("Could not save the model "+$modelName+":"+Char(Carriage return)+String($result.statusText))
End if