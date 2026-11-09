//%attributes = {}
// LotHoldForm_attach($lot; $file) -> True when attached
// Keeps a printed hold form (LotHoldForm_print) with the lot: a framework document
// (sfw_Document, the bytes in DocumentData on the server) whose target is the lot, in the
// "Hold forms" document folder (created the first time). Every print attached is kept, with its
// date: the NCMN printed at the hold, then again once approved.
// They show on the Documents tab of Planning.
#DECLARE($lot : 4D:C1709.Entity; $file : 4D:C1709.File)->$attached : Boolean

var $doc : 4D:C1709.Entity
var $fileInfo : Object
var $folder : 4D:C1709.Entity
var $result : Object

$attached:=False:C215
If ($lot=Null:C1517) || ($file=Null:C1517) || (Not:C34($file.exists))
	return
End if

$folder:=LotHoldForm_attachFolder
If ($folder=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("The \"Hold forms\" document folder could not be created.")
	return
End if

$doc:=ds:C1482.sfw_Document.new()
$doc.UUID:=Generate UUID:C1066
$doc.UUID_DocumentFolder:=$folder.UUID
$doc.UUID_target:=$lot.UUID
$doc.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
$doc.name:=$file.name
$doc.extension:=$file.extension
$doc.stmp:=cs:C1710.sfw_stmp.me.now()
$doc.moreData:=New object:C1471

// what the Documents page shows of a file (sfw_definitionPageDocuments), as a plain object: the
// call runs on the server
$fileInfo:=New object:C1471(\
"name"; $file.name; \
"fullName"; $file.fullName; \
"extension"; $file.extension; \
"size"; $file.size; \
"creationDate"; $file.creationDate; \
"creationTime"; $file.creationTime; \
"modificationDate"; $file.modificationDate; \
"modificationTime"; $file.modificationTime)

$result:=$doc.processSaveFromFile($fileInfo; $file.getContent())
$attached:=Bool:C1537($result.success)
If (Not:C34($attached))
	cs:C1710.sfw_dialog.me.alert("The PDF could not be attached to the lot:\r"+String:C10($result.statusText))
End if
