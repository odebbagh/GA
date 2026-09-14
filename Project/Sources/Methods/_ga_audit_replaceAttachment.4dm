//%attributes = {}

// Purpose: Replace the Audit file attachment using the framework storage pipeline (sfw_Document + DocumentData).
// Removes every existing sfw_Document row targeting this audit UUID, persists the new file bytes, then stores only references on Audit.document (UUID_sfwDocument, paths, extension — no embedded blob).
//
// Parameters:
// $audit — cs.AuditEntity — must be saved (UUID assigned) before calling.
// $platformPath — Text — absolute path readable by DOCUMENT TO BLOB (client path on desktop; server path when import runs on server).
//
// Returns: Object — { success: Boolean ; error: Text }
//
// created by 4D/PS [2026-may-26]

#DECLARE($audit : cs:C1710.AuditEntity; $platformPath : Text)->$result : Object

var $blob : 4D:C1709.Blob
var $file : 4D:C1709.File
var $eDoc : cs:C1710.sfw_DocumentEntity
var $oldDoc : cs:C1710.sfw_DocumentEntity
var $processResult : Object

$result:=New object:C1471("success"; False:C215; "error"; "")

If ($audit=Null:C1517)
	$result.error:="Missing audit record."
	return 
End if 

If ($audit.isNew())
	$result.error:="Save the audit before attaching a file."
	return 
End if 

If ($platformPath="")
	$result.error:="Missing file path."
	return 
End if 

DOCUMENT TO BLOB:C525($platformPath; $blob)
If ($blob=Null:C1517) || (BLOB size:C605($blob)=0)
	$result.error:="The selected file is empty or unreadable."
	return 
End if 

$file:=File:C1566($platformPath; fk platform path:K87:2)

// Purpose: Drop prior attachment rows so each audit keeps at most one logical file; also clears orphaned framework rows for this UUID_target.
// modified by 4D/PS [2026-may-26]
For each ($oldDoc; ds:C1482.sfw_Document.query("UUID_target = :1"; $audit.UUID))
	$oldDoc.deleteFile()
	$oldDoc.drop()
End for each 

If ($audit.document=Null:C1517)
	$audit.document:=New object:C1471
End if 

If (OB Is defined:C1231($audit.document; "blob"))
	OB REMOVE:C1226($audit.document; "blob")
End if 

// Purpose: New framework row — UUID_DocumentFolder / UUID_DocumentModel left unset like simple uploads in sfw_definitionPageDocuments._uploadFile().
// modified by 4D/PS [2026-may-26]
$eDoc:=ds:C1482.sfw_Document.new()
$eDoc.UUID:=Generate UUID:C1066
$eDoc.UUID_target:=$audit.UUID
$eDoc.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
$eDoc.name:=$file.name
$eDoc.extension:=$file.extension
$eDoc.stmp:=cs:C1710.sfw_stmp.me.now()
$eDoc.moreData:=New object:C1471

$processResult:=$eDoc.processSaveFromFile($file; $blob)
If ($processResult.success=False:C215)
	$result.error:="Could not persist the attachment to document storage."
	return 
End if 

// Purpose: Keep legacy metadata fields intact; only refresh linkage + display hints on the embedded document object.
// modified by 4D/PS [2026-may-26]
$audit.document.UUID_sfwDocument:=$eDoc.UUID
$audit.document.sourcePath:=$file.fullName
$audit.document.extension:=$file.extension

$result.success:=True:C214
