//%attributes = {}
// _ga_attachFileToTarget($targetUUID; $folderIdent; $file) -> the sfw_Document created, Null on failure
// Keeps a file with a record: a framework document (sfw_Document, the bytes in DocumentData on the
// server) whose target is the record, in the document folder of that ident. It shows on the
// Documents tab of the record's entry. Same steps as LotHoldForm_attach, for any entry.
// Used by Quote_savePreviewPdf (folder quoteSent).
#DECLARE($targetUUID : Text; $folderIdent : Text; $file : 4D:C1709.File)->$doc : 4D:C1709.Entity

var $fileInfo : Object
var $folder : 4D:C1709.Entity
var $result : Object

$doc:=Null:C1517
If (cs:C1710.sfw_string.me.isAnEmptyUUID($targetUUID)) || ($file=Null:C1517) || (Not:C34($file.exists))
	return
End if

$folder:=ds:C1482.sfw_DocumentFolder.query("ident = :1"; $folderIdent).first()
If ($folder=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("The document folder \""+$folderIdent+"\" was not found.")
	return
End if

$doc:=ds:C1482.sfw_Document.new()
$doc.UUID:=Generate UUID:C1066
$doc.UUID_DocumentFolder:=$folder.UUID
$doc.UUID_target:=$targetUUID
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
If (Not:C34(Bool:C1537($result.success)))
	cs:C1710.sfw_dialog.me.alert("The file could not be attached:\r"+String:C10($result.statusText))
	$doc:=Null:C1517
End if
