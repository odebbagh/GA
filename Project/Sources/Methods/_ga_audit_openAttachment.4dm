//%attributes = {}

// Purpose: Open the Audit attachment (OPEN URL) — resolve blob via UUID_sfwDocument / legacy document.blob, write temp file with a safe leaf name.
// Parameters: $audit — cs.AuditEntity. Returns: Boolean — True after OPEN URL.
// created by 4D/PS [2026-may-26]

#DECLARE($audit : cs:C1710.AuditEntity)->$ok : Boolean

var $blob : 4D:C1709.Blob
var $uuidDoc : Text
var $eDoc : cs:C1710.sfw_DocumentEntity
var $baseLeaf : Text
var $ext : Text
var $leafSrc : Text
var $normalized : Text
var $parts : Collection
var $localFile : Text

$ok:=False:C215
If ($audit=Null:C1517) || ($audit.document=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("No attachment is available for this audit.")
	return 
End if 

$leafSrc:=""
$uuidDoc:=String:C10($audit.document.UUID_sfwDocument)
If ($uuidDoc#"") && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($uuidDoc)))
	$eDoc:=ds:C1482.sfw_Document.get($uuidDoc)
	If ($eDoc#Null:C1517)
		$blob:=$eDoc.getStoredBlob()
		$leafSrc:=String:C10($eDoc.name)
		$ext:=Lowercase:C14(String:C10($eDoc.extension))
		If ($ext="") && ($eDoc.moreData#Null:C1517) && ($eDoc.moreData.fileInfo#Null:C1517)\
			 && (OB Is defined:C1231($eDoc.moreData.fileInfo; "extension"))
			$ext:=Lowercase:C14(String:C10($eDoc.moreData.fileInfo.extension))
		End if 
	End if 
End if 

If (($blob=Null:C1517) || (BLOB size:C605($blob)=0)) && (OB Is defined:C1231($audit.document; "blob"))
	$blob:=$audit.document.blob
	If ($ext="")
		$ext:=Lowercase:C14(String:C10($audit.document.extension))
	End if 
	If ($leafSrc="")
		$leafSrc:=String:C10($audit.document.sourcePath)
	End if 
End if 

If ($blob=Null:C1517) || (BLOB size:C605($blob)=0)
	cs:C1710.sfw_dialog.me.alert("No attachment is available for this audit.")
	return 
End if 

$baseLeaf:=""
If ($leafSrc#"")
	$normalized:=Replace string:C233($leafSrc; "\\"; "/")
	$parts:=Split string:C1554($normalized; "/"; sk trim spaces:K86:2)
	$baseLeaf:=($parts.length>0) ? String:C10($parts[$parts.length-1]) : $leafSrc
End if 
If ($baseLeaf="")
	$baseLeaf:="Audit_"+String:C10($audit.auditNumber)
End if 
If ($ext#"") && (Position:C15("."; $baseLeaf)=0)
	$baseLeaf:=$baseLeaf+"."+$ext
End if 

// Purpose: Safe temp filename — replace characters invalid on Windows paths (sourcePath / stored names are not always valid paths).
// modified by 4D/PS [2026-may-26]
$baseLeaf:=Replace string:C233($baseLeaf; "\\"; "_")
$baseLeaf:=Replace string:C233($baseLeaf; "/"; "_")
$baseLeaf:=Replace string:C233($baseLeaf; ":"; "_")
$baseLeaf:=Replace string:C233($baseLeaf; "*"; "_")
$baseLeaf:=Replace string:C233($baseLeaf; "?"; "_")
$baseLeaf:=Replace string:C233($baseLeaf; Char:C90(34); "_")
$baseLeaf:=Replace string:C233($baseLeaf; "<"; "_")
$baseLeaf:=Replace string:C233($baseLeaf; ">"; "_")
$baseLeaf:=Replace string:C233($baseLeaf; "|"; "_")
If ($baseLeaf="")
	$baseLeaf:="attachment.bin"
End if 

$localFile:=Temporary folder:C486+Folder separator:K24:12+$baseLeaf
BLOB TO DOCUMENT:C526($localFile; $blob)
OPEN URL:C673($localFile; *)
$ok:=True:C214
