//%attributes = {}
// LotHoldForm_print($formFieldName; $form)
// Prints a hold form on the Golden Altos paper form it replaces: the NCMN on GAF-1014
// (Non-Conforming Material Notice), the ISSNF on GAF-1514 (Internal Start/Stop Notification).
//
// The layout is the Write Pro model of the same name in Document Management > Models: its fixed
// text (titles, labels, "GAF-1014, Rev. 08") is edited there, by the users, when the form gets a
// new revision. Every {{token}} in it is filled from the form, the lot, its job and customer
// (LotHoldForm_printContext lists them). The model is only read, never changed: each print fills
// a copy. Saved as a PDF on the desktop and opened; then the user chooses whether it is attached
// to the lot's documents (LotHoldForm_attach).
//
// Called from the Print button of the NCMN / ISSNF windows (what is on screen, saved or not) and
// from the hold list menu (the form saved for that hold). $form.lot_UUID names the lot: set by
// LotHoldForm_resolveForm / LotHoldForm_resolveFormForHold.
#DECLARE($formFieldName : Text; $form : Object)

var $context : Object
var $doc : Object
var $file : 4D:C1709.File
var $fileName : Text
var $lot : 4D:C1709.Entity
var $model : 4D:C1709.Entity
var $modelName : Text
var $path : Text

Case of
	: ($formFieldName="NCMN")
		$modelName:="GAF-1014"
	: ($formFieldName="ISSNF")
		$modelName:="GAF-1514"
	Else
		return
End case

If ($form=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("No "+$formFieldName+" was saved for this hold.")
	return
End if

$lot:=Null:C1517
If ($form.lot_UUID#Null:C1517)
	$lot:=ds:C1482.Lot.get($form.lot_UUID)
End if
If ($lot=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("The lot of this "+$formFieldName+" was not found.")
	return
End if

// the model; the seed file only while the model has not been installed
$model:=ds:C1482.sfw_DocumentModel.query("name = :1"; $modelName).first()
If ($model#Null:C1517)
	$doc:=OB Copy:C1225($model.area)
Else
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/"+$modelName+".4wp")
	If (Not:C34($file.exists))
		cs:C1710.sfw_dialog.me.alert("No document model named "+$modelName+".\rRun _ga_installHoldFormModels to create it.")
		return
	End if
	$doc:=WP Import document:C1318($file.platformPath)
End if

$context:=LotHoldForm_printContext($formFieldName; $form; $lot)
_wpFill($doc; $context)

$fileName:=$modelName+"_"+$formFieldName
If (String:C10($form.ncmnNumber)#"")
	$fileName:=$modelName+"_"+String:C10($form.ncmnNumber)
End if
$fileName:=$fileName+"_Lot"+Replace string:C233($lot.displayNumber; "/"; "-")+".pdf"
$path:=System folder:C487(Desktop:K41:16)+$fileName

WP EXPORT DOCUMENT:C1337($doc; $path; wk pdf:K81:315)
If (Test path name:C476($path)#Is a document:K24:1)
	cs:C1710.sfw_dialog.me.alert("The PDF could not be written to "+$path+".")
	return
End if
OPEN URL:C673($path)

// kept with the lot only if the user says so (a draft printed to check it is not)
If (cs:C1710.sfw_dialog.me.confirm("Attach this "+$modelName+" to the documents of lot "+$lot.displayNumber+"?\r"\
+"It goes to the \"Hold forms\" folder of the lot's Documents tab (Planning)."; "Attach"; "Don't attach"))
	If (LotHoldForm_attach($lot; File:C1566($path; fk platform path:K87:2)))
		cs:C1710.sfw_dialog.me.info($fileName+" is attached to lot "+$lot.displayNumber+".")
	End if
End if
