//%attributes = {"executedOnServer":true}
// _import_specFiles_srv
// Loads the controlled GAF form PDFs from <data folder>/GAF into Document Control: each
// file is attached to its Specification record as an sfw_Document, with the bytes stored
// under DocumentData by the framework (sfw_DocumentEntity.processSaveFromFile). Runs on
// the server, so the files go from the folder to DocumentData without crossing the network.
// Called by _import_specFiles, which shows the result on the client.
//
// Matching rules (established against specControl_export.json and the GAF folder):
// - the code comes from the file name: "gaf-1001-rev 18.pdf" -> GAF-1001, revision 18
// - when the folder holds several revisions of one form, only the highest is loaded
// - the file goes to the ACTIVE record (suppress = False). The legacy system kept each
//   superseded revision as a second, suppressed record with the same code
// - a code with no record is created as a form, except when lettered variants of it exist
//   (gaf-1509 vs GAF-1509A..F): that case is reported, never guessed
// - file revision newer than the record: the record's revision is moved up. The approval
//   fields are deliberately left alone - the folder holds the client's active, already
//   approved forms, and resetting approval would mark them all unapproved
// - file revision older than the record: the file is still attached (it is the only copy
//   available) and the case is reported
//
// Re-runnable. A file whose content is unchanged (same SHA-256) is skipped; a changed one
// replaces the previous attachment. _import_specControl truncates Specification, which gives
// every record a new UUID: the attachments left on the old UUIDs are removed here, so run
// this method again after every _import_specControl.
//
// $options: dryRun (default True), createMissing (default True), updateRevision (default True).
// A call without options is a dry run, so running this by mistake changes nothing.
#DECLARE($options : Object)->$report : Object
	
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $blob : 4D:C1709.Blob
var $latest : Object
var $entry : Object
var $res : Object
var $code : Text
var $rev : Text
var $suffix : Text
var $name : Text
var $hash : Text
var $revNum : Integer
var $dryRun : Boolean
var $createMissing : Boolean
var $updateRevision : Boolean
var $isVariant : Boolean
var $canAttach : Boolean
var $isNew : Boolean
var $esAll : cs:C1710.SpecificationSelection
var $esActive : cs:C1710.SpecificationSelection
var $esDocs : cs:C1710.sfw_DocumentSelection
var $spec : cs:C1710.SpecificationEntity
var $family : cs:C1710.SpecificationEntity
var $doc : cs:C1710.sfw_DocumentEntity
var $old : cs:C1710.sfw_DocumentEntity
var $liveTargets : Collection
	
ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)
	
If ($options=Null:C1517)
	$options:=New object:C1471
End if 
$dryRun:=($options.dryRun=Null:C1517) || Bool:C1537($options.dryRun)
$createMissing:=($options.createMissing=Null:C1517) || Bool:C1537($options.createMissing)
$updateRevision:=($options.updateRevision=Null:C1517) || Bool:C1537($options.updateRevision)
	
$report:=New object:C1471(\
	"dryRun"; $dryRun; \
	"folder"; ""; \
	"reportPath"; ""; \
	"error"; ""; \
	"filesScanned"; 0; \
	"attached"; New collection:C1472; \
	"replaced"; New collection:C1472; \
	"unchanged"; 0; \
	"specsCreated"; New collection:C1472; \
	"revisionsUpdated"; New collection:C1472; \
	"fileOlderThanRecord"; New collection:C1472; \
	"supersededFiles"; New collection:C1472; \
	"unparsable"; New collection:C1472; \
	"ambiguous"; New collection:C1472; \
	"onlySuppressed"; New collection:C1472; \
	"failed"; New collection:C1472; \
	"orphansRemoved"; 0; \
	"activeFormsWithoutFile"; New collection:C1472)
	
$folder:=Folder:C1567(fk data folder:K87:12).folder("GAF")
$report.folder:=$folder.platformPath
If (Not:C34($folder.exists))
	$report.error:="Folder not found: "+$folder.platformPath
	return $report
End if 
	
// 1. Attachments left on Specification UUIDs that no longer exist (after _import_specControl)
$esDocs:=ds:C1482.sfw_Document.query("moreData.source = :1"; "specFiles")
$liveTargets:=ds:C1482.Specification.query("UUID in :1"; $esDocs.distinct("UUID_target")).distinct("UUID")
For each ($old; $esDocs)
	If ($liveTargets.indexOf($old.UUID_target)<0)
		$report.orphansRemoved+=1
		If (Not:C34($dryRun))
			$old.deleteFile()
			$old.drop()
		End if 
	End if 
End for each 
	
// 2. Scan the folder, keeping the highest revision of each form
$latest:=New object:C1471
For each ($file; $folder.files(fk ignore invisible))
	If (Lowercase:C14($file.extension)#".pdf")
		continue
	End if 
	$report.filesScanned+=1
	$name:=$file.name
	
	// code: "gaf", optional separators, digits, then at most one letter not followed by another
	If (Not:C34(Match regex:C1019("(?i)^gaf[ -]*([0-9]+)([a-z]?)(?![a-z])"; $name; 1; $pos; $len)))
		$report.unparsable.push($file.fullName)
		continue
	End if 
	$code:="GAF-"+Substring:C12($name; $pos{1}; $len{1})
	If ($len{2}>0)
		$code:=$code+Uppercase:C13(Substring:C12($name; $pos{2}; $len{2}))
	End if 
	
	// revision: the digits after "rev"; whatever follows is a title hint ("WIRE PULL")
	$rev:=""
	$suffix:=""
	If (Match regex:C1019("(?i)rev[ .-]*([0-9]+)(.*)$"; $name; 1; $pos; $len))
		$rev:=String:C10(Num:C11(Substring:C12($name; $pos{1}; $len{1})); "00")
		$suffix:=cs:C1710.sfw_string.me.trimSpace(Substring:C12($name; $pos{2}; $len{2}))
	End if 
	$revNum:=Num:C11($rev)
	
	Case of 
		: ($latest[$code]=Null:C1517)
			$latest[$code]:=New object:C1471("file"; $file; "rev"; $rev; "revNum"; $revNum; "suffix"; $suffix)
		: ($revNum>$latest[$code].revNum)
			$report.supersededFiles.push($latest[$code].file.fullName)
			$latest[$code]:=New object:C1471("file"; $file; "rev"; $rev; "revNum"; $revNum; "suffix"; $suffix)
		Else 
			$report.supersededFiles.push($file.fullName)
	End case 
End for each 
	
// 3. Attach each form to its active Specification record
For each ($code; $latest)
	$entry:=$latest[$code]
	$file:=$entry.file
	$spec:=Null:C1517
	$canAttach:=False:C215
	$isNew:=False:C215
	
	$esAll:=ds:C1482.Specification.query("spec = :1"; $code)
	$esActive:=$esAll.query("suppress = :1"; False:C215)
	
	Case of 
		: ($esActive.length>1)
			$report.ambiguous.push(New object:C1471("code"; $code; "reason"; String:C10($esActive.length)+" active records with this code"))
	
		: ($esActive.length=1)
			$spec:=$esActive.first()
			$canAttach:=True:C214
	
		: ($esAll.length>0)
			// the form exists but every record is suppressed: obsolete in Document Control
			$report.onlySuppressed.push($code)
	
		Else 
			$isVariant:=False:C215
			For each ($family; ds:C1482.Specification.query("spec = :1"; $code+"@")) Until ($isVariant)
				$isVariant:=Match regex:C1019("(?i)^"+$code+"[A-Z]$"; $family.spec; 1)
			End for each 
	
			Case of 
				: ($isVariant)
					$report.ambiguous.push(New object:C1471("code"; $code; "reason"; "lettered variants exist ("+$code+"A...): not created"))
				: (Not:C34($createMissing))
					$report.ambiguous.push(New object:C1471("code"; $code; "reason"; "no record (createMissing is off)"))
				Else 
					$report.specsCreated.push(New object:C1471("code"; $code; "revision"; $entry.rev; "title"; $entry.suffix))
					$canAttach:=True:C214
					$isNew:=True:C214
					If (Not:C34($dryRun))
						$spec:=ds:C1482.Specification.new()
						$spec.UUID:=Generate UUID:C1066
						$spec.spec:=$code
						$spec.revision:=$entry.rev
						$spec.title:=$entry.suffix
						$spec.isForm:=True:C214
						$spec.stmpRevisionDate:=cs:C1710.sfw_stmp.me.build($file.modificationDate)
						$spec.moreData:=New object:C1471("createdBy"; "_import_specFiles"; "createdOn"; cs:C1710.sfw_stmp.me.now())
						$res:=$spec.save()
						If (Not:C34($res.success))
							$report.failed.push(New object:C1471("code"; $code; "reason"; "record creation: "+JSON Stringify:C1217($res)))
							$spec:=Null:C1517
							$canAttach:=False:C215
						End if 
					End if 
			End case 
	End case 
	
	// revision check against an existing record
	If ($canAttach) && (Not:C34($isNew))
		Case of 
			: (Num:C11($spec.revision)<$entry.revNum)
				If ($updateRevision)
					$report.revisionsUpdated.push(New object:C1471("code"; $code; "from"; $spec.revision; "to"; $entry.rev))
					If (Not:C34($dryRun))
						$spec.moreData:=$spec.moreData || New object:C1471
						If ($spec.moreData.revisionHistory=Null:C1517)
							$spec.moreData.revisionHistory:=New collection:C1472
						End if 
						$spec.moreData.revisionHistory.push(New object:C1471("from"; $spec.revision; "to"; $entry.rev; "source"; "_import_specFiles"; "stmp"; cs:C1710.sfw_stmp.me.now()))
						$spec.revision:=$entry.rev
						$spec.stmpRevisionDate:=cs:C1710.sfw_stmp.me.build($file.modificationDate)
						$res:=$spec.save()
						If (Not:C34($res.success))
							$report.failed.push(New object:C1471("code"; $code; "reason"; "revision update: "+JSON Stringify:C1217($res)))
						End if 
					End if 
				End if 
	
			: (Num:C11($spec.revision)>$entry.revNum)
				$report.fileOlderThanRecord.push(New object:C1471("code"; $code; "record"; $spec.revision; "file"; $entry.rev; "fileName"; $file.fullName))
		End case 
	End if 
	
	If (Not:C34($canAttach))
		continue
	End if 
	
	If ($file.size=0)
		$report.failed.push(New object:C1471("code"; $code; "reason"; "empty file: "+$file.fullName))
		continue
	End if 
	
	$blob:=$file.getContent()
	$hash:=Generate digest($blob; SHA256 digest)
	
	If ($spec=Null:C1517)
		// dry run of a record that would be created: it would get its first attachment
		$report.attached.push($code)
		continue
	End if 
	
	$esDocs:=ds:C1482.sfw_Document.query("UUID_target = :1 AND moreData.source = :2"; $spec.UUID; "specFiles")
	If ($esDocs.length=1) && (String:C10($esDocs.first().moreData.sha256)=$hash)
		$report.unchanged+=1
		continue
	End if 
	
	If ($esDocs.length>0)
		$report.replaced.push($code)
	Else 
		$report.attached.push($code)
	End if 
	
	If (Not:C34($dryRun))
		For each ($old; $esDocs)
			$old.deleteFile()
			$old.drop()
		End for each 
	
		$doc:=ds:C1482.sfw_Document.new()
		$doc.UUID:=Generate UUID:C1066
		$doc.UUID_target:=$spec.UUID
		$doc.name:=$file.name
		$doc.extension:=Lowercase:C14($file.extension)
		$doc.stmp:=cs:C1710.sfw_stmp.me.now()
		// size is stored here so sfw_DocumentEntity.displayableSize never has to read the file
		$doc.moreData:=New object:C1471(\
			"source"; "specFiles"; \
			"specCode"; $code; \
			"fileRevision"; $entry.rev; \
			"size"; $file.size; \
			"sha256"; $hash; \
			"originalName"; $file.fullName)
	
		$res:=$doc.processSaveFromFile($file; $blob)
		If (Not:C34(Bool:C1537($res.success)))
			$report.failed.push(New object:C1471("code"; $code; "reason"; "attachment: "+JSON Stringify:C1217($res)))
		End if 
	End if 
End for each 
	
// 4. Active forms in Document Control with no file in the folder
For each ($spec; ds:C1482.Specification.query("isForm = :1 AND suppress = :2 AND spec = :3"; True:C214; False:C215; "GAF@"))
	If ($latest[$spec.spec]=Null:C1517)
		$report.activeFormsWithoutFile.push($spec.spec)
	End if 
End for each 
	
$file:=Folder:C1567(fk data folder:K87:12).file("GAF_import_report.json")
$report.reportPath:=$file.platformPath
$file.setText(JSON Stringify:C1217($report; *))
