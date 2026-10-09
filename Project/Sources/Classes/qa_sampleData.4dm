property _qaDocIndex : Collection
property _attachedFiles : Integer
property _karlaLogin : Text
property _qaSupplierNames : Collection

singleton Class constructor
	// Purpose: Build a small linked QA dataset from DataJson (Karla test server, without Omar's full import).
	// created by 4D/PS [2026-october-09]
	This:C1470._qaDocIndex:=Null:C1517
	This:C1470._attachedFiles:=0
	This:C1470._karlaLogin:=""
	This:C1470._qaSupplierNames:=New collection:C1472


Function run()
	var $folder : 4D:C1709.Folder
	var $summary : Object
	
	$folder:=This:C1470._dataJsonFolder()
	If ($folder=Null:C1517)
		return 
	End if
	This:C1470._qaDocIndex:=Null:C1517
	This:C1470._attachedFiles:=0
	This:C1470._karlaLogin:=""
	This:C1470._qaSupplierNames:=New collection:C1472
	
	// Purpose: Do not call __import_data_lists — Omar's CustomerStatus no longer has levelID.
	// modified by 4D/PS [2026-october-09]
	This:C1470._seedQaLists()
	__import_data_rejectCriteria
	__import_data_qcarOrigin
	
	This:C1470._clearQaTables()
	
	$summary:=New object:C1471(\
		"certifications"; 0; \
		"staff"; 0; \
		"assignments"; 0; \
		"customers"; 0; \
		"lots"; 0; \
		"qcars"; 0; \
		"specifications"; 0; \
		"suppliers"; 0; \
		"aml"; 0; \
		"audits"; 0; \
		"reviews"; 0; \
		"rmas"; 0)
	
	$summary.certifications:=This:C1470._importCertifications($folder)
	// Purpose: Customers / Staff / Team live in their real tables so CAR bForward and Department work. CAR itself stays a small JSON slice (Omar import gap).
	// modified by 4D/PS [2026-october-09]
	$summary.customers:=This:C1470._importCustomers($folder)
	$summary.staff:=This:C1470._importStaffSample($folder)
	$summary.assignments:=This:C1470._importStaffTrainings($folder)
	$summary.lots:=This:C1470._ensureLots()
	$summary.qcars:=This:C1470._importQcars($folder)
	$summary.specifications:=This:C1470._importSpecifications($folder)
	$summary.suppliers:=This:C1470._importSuppliers($folder)
	$summary.aml:=This:C1470._importAml($folder)
	$summary.audits:=This:C1470._importAudits($folder)
	$summary.reviews:=This:C1470._importReviews($folder)
	$summary.rmas:=This:C1470._createRmas()
	
	ALERT:C41("QA sample data ready.\r\r"+\
		"Certifications: "+String:C10($summary.certifications)+"\r"+\
		"Staff: "+String:C10($summary.staff)+"\r"+\
		"Departments (Team): "+String:C10(ds:C1482.Team.all().length)+"\r"+\
		"Certification assignments: "+String:C10($summary.assignments)+"\r"+\
		"Customers: "+String:C10($summary.customers)+"\r"+\
		"Lots/travelers: "+String:C10($summary.lots)+"\r"+\
		"CAR: "+String:C10($summary.qcars)+"\r"+\
		"Document Control: "+String:C10($summary.specifications)+"\r"+\
		"AVL: "+String:C10($summary.suppliers)+"\r"+\
		"AML: "+String:C10($summary.aml)+"\r"+\
		"Audits: "+String:C10($summary.audits)+"\r"+\
		"Reviews: "+String:C10($summary.reviews)+"\r"+\
		"RMA: "+String:C10($summary.rmas)+"\r"+\
		"Attached files: "+String:C10(This:C1470._attachedFiles)+"\r\r"+\
		"Karla Dy login: "+This:C1470._karlaLogin+"\r"+\
		"Password: pSzjGX!Ey9P1c~p (same as GoldenAltos staff import)")
	
	
	// Purpose: Resolve DataJson next to the .4DD (copy GoldenAltos Data\\DataJson here if missing).
	// created by 4D/PS [2026-october-09]
Function _dataJsonFolder()->$folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk data folder:K87:12).folder("DataJson")
	If ($folder.exists)
		return 
	End if 
	ALERT:C41("DataJson folder not found in the data folder:\r"+$folder.platformPath+\
		"\r\rCopy the DataJson pack you already have (GoldenAltos Data\\DataJson) into this database data folder, then run __import_qa_sample again.")
	$folder:=Null:C1517
	
	
	// Purpose: Seed only the lookup rows QA needs (Division, document categories, audit status).
	// created by 4D/PS [2026-october-09]
Function _seedQaLists()
	This:C1470._ensureNamedRow(ds:C1482.Division; "GAC"; 1)
	This:C1470._ensureNamedRow(ds:C1482.DocumentCategory; "Military Standard"; 1)
	This:C1470._ensureNamedRow(ds:C1482.DocumentCategory; "Customer Service"; 2)
	This:C1470._ensureNamedRow(ds:C1482.DocumentCategory; "Document Control"; 3)
	This:C1470._ensureNamedRow(ds:C1482.DocumentCategory; "Internal- Procedure"; 4)
	This:C1470._ensureNamedRow(ds:C1482.ControllingDepartment; "QA"; 1)
	This:C1470._ensureNamedRow(ds:C1482.ControllingDepartment; "Purchasing"; 2)
	This:C1470._ensureNamedRow(ds:C1482.ControllingDepartment; "Customer"; 3)
	This:C1470._ensureNamedRow(ds:C1482.AuditStatus; "C - Conforming"; 1)
	This:C1470._ensureNamedRow(ds:C1482.AuditStatus; "OFI - Opportunity for Improvement"; 2)
	This:C1470._ensureNamedRow(ds:C1482.AuditStatus; "NCR - Nonconformance"; 3)
	
	
Function _ensureNamedRow($dataclass : 4D:C1709.DataClass; $name : Text; $level : Integer)
	var $entity : 4D:C1709.Entity
	
	$name:=This:C1470._text($name)
	If ($name="")
		return 
	End if 
	If ($dataclass.query("name = :1"; $name).length>0)
		return 
	End if 
	$entity:=$dataclass.new()
	$entity.name:=$name
	$entity.levelID:=$level
	$entity.color:="#FFFFFF"
	This:C1470._ensureMoreData($entity; $dataclass.getInfo().name)
	$entity.save()
	
	
	// Purpose: Replace QA operational rows only. Does not wipe sfw_User, jobs, or purchase orders.
	// created by 4D/PS [2026-october-09]
Function _clearQaTables()
	var $audit : cs:C1710.AuditEntity
	var $review : cs:C1710.ManagementReviewEntity
	var $fwDoc : cs:C1710.sfw_DocumentEntity
	
	For each ($audit; ds:C1482.Audit.all())
		For each ($fwDoc; ds:C1482.sfw_Document.query("UUID_target = :1"; $audit.UUID))
			$fwDoc.deleteFile()
			$fwDoc.drop()
		End for each 
	End for each 
	For each ($review; ds:C1482.ManagementReview.all())
		For each ($fwDoc; ds:C1482.sfw_Document.query("UUID_target = :1"; $review.UUID))
			$fwDoc.deleteFile()
			$fwDoc.drop()
		End for each 
	End for each 
	TRUNCATE TABLE:C1051([CertificationAssignment:134])
	TRUNCATE TABLE:C1051([Membership:137])
	TRUNCATE TABLE:C1051([Team:136])
	TRUNCATE TABLE:C1051([StaffRole:63])
	TRUNCATE TABLE:C1051([Staff:135])
	TRUNCATE TABLE:C1051([Certification:124])
	TRUNCATE TABLE:C1051([ObjectiveEvidence:149])
	TRUNCATE TABLE:C1051([Qcar:138])
	TRUNCATE TABLE:C1051([RMA:44])
	TRUNCATE TABLE:C1051([Specification:10])
	TRUNCATE TABLE:C1051([Audit:139])
	TRUNCATE TABLE:C1051([ManagementReview:62])
	TRUNCATE TABLE:C1051([AML:56])
	This:C1470._dropSupplierContacts()
	TRUNCATE TABLE:C1051([Supplier:57])
	
	
Function _parseFile($folder : 4D:C1709.Folder; $name : Text)->$rows : Collection
	var $file : 4D:C1709.File
	
	$rows:=New collection:C1472
	$file:=$folder.file($name)
	If (Not:C34($file.exists))
		ALERT:C41("Missing DataJson file: "+$name)
		return 
	End if 
	$rows:=JSON Parse:C1218($file.getText())
	If ($rows=Null:C1517)
		$rows:=New collection:C1472
	End if 
	
	
	// Purpose: Optional JSON (Customer_Log) — do not stop the sample run if Omar's pack is incomplete.
	// created by 4D/PS [2026-october-09]
Function _parseFileIfExists($folder : 4D:C1709.Folder; $name : Text)->$rows : Collection
	var $file : 4D:C1709.File
	
	$rows:=New collection:C1472
	$file:=$folder.file($name)
	If (Not:C34($file.exists))
		return 
	End if 
	$rows:=JSON Parse:C1218($file.getText())
	If ($rows=Null:C1517)
		$rows:=New collection:C1472
	End if 
	
	
	// Purpose: DocServerIndex + exported blobs (SpecificationsDocuments, SuppliersDocs, LogBookDocs).
	// created by 4D/PS [2026-october-09]
Function _docIndex($folder : 4D:C1709.Folder)->$docs : Collection
	If (This:C1470._qaDocIndex#Null:C1517)
		$docs:=This:C1470._qaDocIndex
		return 
	End if 
	$docs:=This:C1470._parseFile($folder; "docServerIndex_export.json")
	This:C1470._qaDocIndex:=$docs
	
	
Function _indexRows($folder : 4D:C1709.Folder; $tableNumber : Integer; $primaryKey : Variant)->$rows : Collection
	$rows:=This:C1470._docIndex($folder).query("TableNumber = :1 & PrimaryKeyValue = :2"; $tableNumber; String:C10($primaryKey))
	If ($rows.length=0)
		$rows:=This:C1470._docIndex($folder).query("TableNumber = :1 & PrimaryKeyValue = :2"; $tableNumber; $primaryKey)
	End if 
	
	
Function _indexBlobFile($folder : 4D:C1709.Folder; $subfolder : Text; $indexRow : Object)->$file : 4D:C1709.File
	var $leaf : Text
	
	$file:=Null:C1517
	If ($indexRow=Null:C1517)
		return 
	End if 
	$leaf:=String:C10($indexRow.UniqueID)+String:C10($indexRow.PrimaryKeyValue)
	If ($leaf="")
		return 
	End if 
	$file:=$folder.folder($subfolder).file($leaf)
	If (Not:C34($file.exists))
		$file:=Null:C1517
	End if 
	
	
Function _attachedDocFromIndex($folder : 4D:C1709.Folder; $subfolder : Text; $indexRow : Object)->$doc : Object
	var $file : 4D:C1709.File
	var $blob : Blob
	
	$doc:=Null:C1517
	$file:=This:C1470._indexBlobFile($folder; $subfolder; $indexRow)
	If ($file=Null:C1517)
		return 
	End if 
	DOCUMENT TO BLOB:C525($file.platformPath; $blob)
	If (BLOB size:C605($blob)=0)
		return 
	End if 
	$doc:=New object:C1471(\
		"code"; This:C1470._text($indexRow.DocCode); \
		"dateTimeStamp"; Num:C11($indexRow.DateTimeStamp); \
		"creationDateTimeStamp"; Num:C11($indexRow.CreationDateTimeStamp); \
		"documentPath"; This:C1470._text($indexRow.DocumentPath); \
		"sourcePath"; This:C1470._text($indexRow.SourcePath); \
		"description"; This:C1470._text($indexRow.DocDescription); \
		"approvalDate"; !00-00-00!; \
		"approvedBy"; ""; \
		"isApproved"; False:C215; \
		"blob"; $blob)
	This:C1470._attachedFiles:=This:C1470._attachedFiles+1
	
	
Function _collectAttachedDocs($folder : 4D:C1709.Folder; $subfolder : Text; $tableNumber : Integer; $primaryKey : Variant)->$docs : Collection
	var $indexRow; $doc : Object
	var $max : Integer
	
	$docs:=New collection:C1472
	$max:=5
	For each ($indexRow; This:C1470._indexRows($folder; $tableNumber; $primaryKey))
		If ($docs.length>=$max)
			break
		End if 
		$doc:=This:C1470._attachedDocFromIndex($folder; $subfolder; $indexRow)
		If ($doc#Null:C1517)
			$docs.push($doc)
		End if 
	End for each 
	
	
Function _namedTempFromIndex($folder : 4D:C1709.Folder; $subfolder : Text; $indexRow : Object)->$path : Text
	var $file : 4D:C1709.File
	var $blob : Blob
	var $po : Object
	var $name; $ext : Text
	
	$path:=""
	$file:=This:C1470._indexBlobFile($folder; $subfolder; $indexRow)
	If ($file=Null:C1517)
		return 
	End if 
	DOCUMENT TO BLOB:C525($file.platformPath; $blob)
	If (BLOB size:C605($blob)=0)
		return 
	End if 
	$po:=Path to object:C1547(This:C1470._text($indexRow.SourcePath))
	$name:=String:C10($po.name)
	$ext:=String:C10($po.extension)
	If ($name="")
		$name:=$file.name
	End if 
	$path:=Temporary folder:C486+$name+$ext
	BLOB TO DOCUMENT:C526($path; $blob)
	
	
Function _attachFrameworkFile($entity : Variant; $folder : 4D:C1709.Folder; $subfolder : Text; $tableNumber : Integer; $primaryKey : Variant; $kind : Text)
	var $indexRow : Object
	var $path : Text
	var $result : Object
	
	For each ($indexRow; This:C1470._indexRows($folder; $tableNumber; $primaryKey))
		$path:=This:C1470._namedTempFromIndex($folder; $subfolder; $indexRow)
		If ($path="")
			continue
		End if 
		If ($kind="audit")
			$result:=_ga_audit_replaceAttachment($entity; $path)
		Else 
			$result:=_ga_managementReview_replaceAtt($entity; $path)
		End if 
		If (Bool:C1537($result.success))
			$entity.save()
			This:C1470._attachedFiles:=This:C1470._attachedFiles+1
			break
		End if 
	End for each 
	
	
Function _attachQcarEvidence($qcar : cs:C1710.QcarEntity; $folder : 4D:C1709.Folder)
	var $indexRow; $po : Object
	var $file : 4D:C1709.File
	var $oe : cs:C1710.ObjectiveEvidenceEntity
	var $blob : Blob
	var $attached : Integer
	var $sub : Text
	
	$attached:=0
	For each ($sub; New collection:C1472("QcarDocs"; "QCARSDocs"; "CARDocs"))
		For each ($indexRow; This:C1470._indexRows($folder; 20; $qcar.qcarNumber))
			$file:=This:C1470._indexBlobFile($folder; $sub; $indexRow)
			If ($file=Null:C1517)
				continue
			End if 
			DOCUMENT TO BLOB:C525($file.platformPath; $blob)
			If (BLOB size:C605($blob)=0)
				continue
			End if 
			$po:=Path to object:C1547(This:C1470._text($indexRow.SourcePath))
			$oe:=ds:C1482.ObjectiveEvidence.new()
			$oe.UUID_Qcar:=$qcar.UUID
			$oe.name:=(String:C10($po.name)="") ? $file.name : String:C10($po.name)
			$oe.extension:=String:C10($po.extension)
			$oe.blob:=$blob
			This:C1470._ensureMoreData($oe; "ObjectiveEvidence")
			If ($oe.save().success)
				$attached:=$attached+1
				This:C1470._attachedFiles:=This:C1470._attachedFiles+1
			End if 
		End for each 
		If ($attached>0)
			return 
		End if 
	End for each 
	If ($attached=0)
		This:C1470._attachQcarEvidenceFallback($qcar; $folder)
	End if 
	
	
	// Purpose: Table 20 CAR blobs were not exported; reuse a real SpecificationDocuments PDF so Objective Evidence can be opened.
	// created by 4D/PS [2026-october-09]
Function _attachQcarEvidenceFallback($qcar : cs:C1710.QcarEntity; $folder : 4D:C1709.Folder)
	var $indexRow; $doc; $po : Object
	var $oe : cs:C1710.ObjectiveEvidenceEntity
	
	For each ($indexRow; This:C1470._docIndex($folder).query("TableNumber = :1"; 21))
		$doc:=This:C1470._attachedDocFromIndex($folder; "SpecificationsDocuments"; $indexRow)
		If ($doc=Null:C1517)
			continue
		End if 
		$po:=Path to object:C1547(String:C10($doc.sourcePath))
		$oe:=ds:C1482.ObjectiveEvidence.new()
		$oe.UUID_Qcar:=$qcar.UUID
		$oe.name:=(String:C10($po.name)="") ? "CAR-"+String:C10($qcar.qcarNumber)+" evidence" : String:C10($po.name)
		$oe.extension:=(String:C10($po.extension)="") ? ".pdf" : String:C10($po.extension)
		$oe.blob:=$doc.blob
		This:C1470._ensureMoreData($oe; "ObjectiveEvidence")
		$oe.save()
		break
	End for each 
	
	
Function _jsonDate($value : Variant)->$date : Date
	var $raw : Text
	
	$date:=!00-00-00!
	If ($value=Null:C1517)
		return 
	End if 
	$raw:=String:C10($value)
	If ($raw="") || (Position:C15("0000-00-00"; $raw)=1)
		return 
	End if 
	$date:=Date:C102($value)
	
	
Function _stampFromJsonDate($value : Variant)->$stmp : Integer
	var $date : Date
	
	$stmp:=0
	$date:=This:C1470._jsonDate($value)
	If ($date=!00-00-00!)
		return 
	End if 
	$stmp:=cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
	
	
	// Purpose: Current Year CARs view hides 2020 JSON dates; keep day/month, move into this year.
	// created by 4D/PS [2026-october-09]
Function _stampShiftedToThisYear($value : Variant; $deltaYears : Integer)->$stmp : Integer
	var $date : Date
	
	$stmp:=0
	$date:=This:C1470._dateShiftedToThisYear($value; $deltaYears)
	If ($date=!00-00-00!)
		return 
	End if 
	$stmp:=cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
	
	
Function _dateShiftedToThisYear($value : Variant; $deltaYears : Integer)->$date : Date
	$date:=This:C1470._jsonDate($value)
	If ($date=!00-00-00!)
		return 
	End if 
	If ($deltaYears#0)
		$date:=Add to date:C393($date; $deltaYears; 0; 0)
	End if 
	If ($date>Current date:C33(*))
		$date:=Current date:C33(*)
	End if
	
	
Function _text($value : Variant)->$text : Text
	$text:=Split string:C1554(String:C10($value); "\r"; sk trim spaces:K86:2).join("\r")
	$text:=Replace string:C233($text; "\n"; "")
	
	
	// Purpose: Legacy export used underscores in first names (Karla_patricia); show a normal given name.
	// created by 4D/PS [2026-october-09]
Function _personName($value : Variant)->$text : Text
	$text:=This:C1470._text($value)
	$text:=Replace string:C233($text; "_"; " ")
	While (Position:C15("  "; $text)>0)
		$text:=Replace string:C233($text; "  "; " ")
	End while 
	$text:=Split string:C1554($text; " "; sk trim spaces:K86:2+sk ignore empty strings:K86:1).join(" ")
	
	
Function _barcode($dataclass : Text)->$code : Text
	$code:=String:C10(ds:C1482.sfw_Counter.getNextValue($dataclass); "0000000000")
	
	
	// Purpose: moreData must exist and always carry barcodeData before any nested attribute is used.
	// created by 4D/PS [2026-october-09]
Function _ensureMoreData($entity : 4D:C1709.Entity; $dataclassName : Text; $extra : Object)
	var $key : Text
	
	If ($entity=Null:C1517)
		return 
	End if 
	If ($entity.moreData=Null:C1517)
		$entity.moreData:=New object:C1471
	End if 
	If ($extra#Null:C1517)
		For each ($key; OB Keys:C1719($extra))
			$entity.moreData[$key]:=$extra[$key]
		End for each 
	End if 
	If (Not:C34(OB Is defined:C1231($entity.moreData; "barcodeData"))) | (String:C10($entity.moreData.barcodeData)="")
		$entity.moreData.barcodeData:=This:C1470._barcode($dataclassName)
	End if
	
	
Function _importCertifications($folder : 4D:C1709.Folder)->$count : Integer
	var $rows : Collection
	var $row : Object
	var $cert : cs:C1710.CertificationEntity
	var $res : Object
	
	$count:=0
	$rows:=This:C1470._parseFile($folder; "certifications_export.json")
	For each ($row; $rows)
		$cert:=ds:C1482.Certification.new()
		$cert.ref:=Num:C11($row.ref)
		$cert.name:=This:C1470._text($row.name)
		$cert.oneTime:=Bool:C1537($row.oneTime)
		$cert.duration:=_ga_certificationImportDuration(($row.duration#Null:C1517) ? Num:C11($row.duration) : 0; $cert.oneTime)
		$cert.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("Certification"))
		$res:=$cert.save()
		If ($res.success)
			$count:=$count+1
		End if 
	End for each 
	_ga_certFixZeroDuration
	
	
	// Purpose: Staff entry stores shift as "1" or "2"; v18 JSON used A/B.
	// created by 4D/PS [2026-october-09]
Function _staffShift($value : Variant)->$shift : Text
	$shift:=Uppercase:C13(This:C1470._text($value))
	Case of 
		: ($shift="2") || ($shift="B")
			$shift:="2"
		Else 
			$shift:="1"
	End case 
	
	
Function _staffCodes()->$codes : Collection
	$codes:=New collection:C1472("001695"; "001726"; "001486"; "001631"; "001633")
	
	
	// Purpose: Same login rule as GoldenAltos staff import: lowercase firstName+lastName, no spaces.
	// created by 4D/PS [2026-october-09]
Function _staffLogin($firstName : Text; $lastName : Text)->$login : Text
	$login:=Lowercase:C14(Replace string:C233($firstName+$lastName; " "; ""))
	
	
Function _ensureProfile($ident : Text; $name : Text)->$profile : cs:C1710.sfw_UserProfileEntity
	$profile:=ds:C1482.sfw_UserProfile.query("ident = :1"; $ident).first()
	If ($profile#Null:C1517)
		return 
	End if 
	$profile:=ds:C1482.sfw_UserProfile.new()
	$profile.UUID:=Generate UUID:C1066
	$profile.ident:=$ident
	$profile.name:=$name
	$profile.moreData:=New object:C1471("autoCreation"; cs:C1710.sfw_stmp.me.now())
	If ($ident="qa")
		$profile.moreData.allowedVisions:=New collection:C1472("qualityAssurance")
	End if 
	If (Not:C34($profile.save().success))
		$profile:=Null:C1517
	End if 
	
	
Function _grantProfiles($user : cs:C1710.sfw_UserEntity; $idents : Collection)
	var $ident : Text
	var $profile : cs:C1710.sfw_UserProfileEntity
	var $inscription : cs:C1710.sfw_UserInscriptionEntity
	var $who : Text
	var $names : Object
	
	If ($user=Null:C1517)
		return 
	End if 
	$who:=16*"00"
	If (cs:C1710.sfw_userManager.me.info#Null:C1517) && (String:C10(cs:C1710.sfw_userManager.me.info.UUID)#"")
		$who:=cs:C1710.sfw_userManager.me.info.UUID
	End if 
	For each ($inscription; ds:C1482.sfw_UserInscription.query("UUID_User = :1"; $user.UUID))
		$inscription.drop()
	End for each 
	$names:=New object:C1471("admin"; "administrator"; "qm"; "Quality Manager"; "qs"; "Quality Supervisor"; "qi"; "Quality Inspector"; "dc"; "Document Controller"; "qa"; "Quality Assurance")
	For each ($ident; $idents)
		$profile:=This:C1470._ensureProfile($ident; String:C10($names[$ident]))
		If ($profile=Null:C1517)
			continue
		End if 
		$inscription:=ds:C1482.sfw_UserInscription.new()
		$inscription.UUID:=Generate UUID:C1066
		$inscription.UUID_User:=$user.UUID
		$inscription.UUID_UserProfile:=$profile.UUID
		$inscription.UUID_whoHasGiven:=$who
		$inscription.stmp_given:=cs:C1710.sfw_stmp.me.now()
		$inscription.moreData:=New object:C1471
		$inscription.save()
	End for each 
	
	
	// Purpose: Create or reuse sfw_User like GoldenAltos staff import; Karla gets admin+QA edit profiles.
	// created by 4D/PS [2026-october-09]
Function _ensureStaffUser($firstName : Text; $lastName : Text; $inactive : Boolean; $isKarla : Boolean)->$user : cs:C1710.sfw_UserEntity
	var $login : Text
	var $res : Object
	var $stmp : Integer
	
	$login:=This:C1470._staffLogin($firstName; $lastName)
	If ($login="")
		$user:=Null:C1517
		return 
	End if 
	$user:=ds:C1482.sfw_User.query("login = :1"; $login).first()
	If ($user=Null:C1517)
		$user:=ds:C1482.sfw_User.new()
		$user.login:=$login
	End if 
	$user.firstName:=$firstName
	$user.lastName:=$lastName
	$user.isInactive:=$inactive
	$stmp:=cs:C1710.sfw_stmp.me.now()
	$user.accesses:=New object:C1471(\
		"asDesigner"; False:C215; \
		"password"; New object:C1471(\
		"temporary"; False:C215; \
		"sendTemporaryByMail"; False:C215; \
		"lastReset"; $stmp; \
		"hash"; "$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri"; \
		"lastChange"; $stmp))
	If ($user.moreData=Null:C1517)
		$user.moreData:=New object:C1471
	End if 
	If (String:C10($user.moreData.barcodeData)="")
		$user.moreData.barcodeData:=This:C1470._barcode("sfw_User")
	End if 
	$res:=$user.save()
	If (Not:C34($res.success))
		$user:=Null:C1517
		return 
	End if 
	$user.asDesigner:=False:C215
	If ($isKarla)
		This:C1470._karlaLogin:=$login
		This:C1470._grantProfiles($user; New collection:C1472("admin"; "qm"; "qs"; "qi"; "dc"))
	End if 
	
	
Function _staffCodeFromRow($row : Object)->$code : Text
	$code:=This:C1470._text($row.employeeCode)
	If ($code="")
		$code:=This:C1470._text($row.code)
	End if 
	
	
Function _departmentFromRow($row : Object)->$department : Text
	$department:=This:C1470._text($row.department)
	If ($department="")
		$department:=This:C1470._text($row.Department)
	End if 
	
	
Function _importStaffSample($folder : 4D:C1709.Folder)->$count : Integer
	var $rows : Collection
	var $row : Object
	var $staff : cs:C1710.StaffEntity
	var $user : cs:C1710.sfw_UserEntity
	var $division : cs:C1710.DivisionSelection
	var $code; $firstName; $lastName; $divName : Text
	var $res : Object
	var $isKarla : Boolean
	
	$count:=0
	$rows:=This:C1470._parseFile($folder; "staff_export.json")
	For each ($row; $rows)
		This:C1470._ensureTeamByName(This:C1470._departmentFromRow($row))
		$divName:=This:C1470._text($row.division)
		If ($divName#"")
			This:C1470._ensureNamedRow(ds:C1482.Division; $divName; Num:C11(ds:C1482.Division.all().max("levelID"))+1)
		End if 
	End for each 
	For each ($row; $rows)
		$code:=This:C1470._staffCodeFromRow($row)
		$firstName:=This:C1470._personName($row.firstName)
		$lastName:=This:C1470._personName($row.lastName)
		If ($code="") && ($firstName="") && ($lastName="")
			continue
		End if 
		If ($code#"") && (ds:C1482.Staff.query("code = :1"; $code).length>0)
			continue
		End if 
		$isKarla:=($code="001695")
		$user:=This:C1470._ensureStaffUser($firstName; $lastName; Bool:C1537($row.terminated); $isKarla)
		$staff:=ds:C1482.Staff.new()
		$staff.UUID_User:=($user#Null:C1517) ? $user.UUID : 16*"00"
		$staff.code:=$code
		$staff.firstName:=$firstName
		$staff.lastName:=$lastName
		$staff.citizenShipStatus:=This:C1470._text($row.citizenShipStatus)
		$staff.terminated:=Bool:C1537($row.terminated)
		$staff.inactive:=$staff.terminated
		$staff.shift:=This:C1470._staffShift($row.shift)
		$staff.contactDetails:=($row.contactDetails#Null:C1517) ? $row.contactDetails : New object:C1471("addresses"; New collection:C1472; "communications"; New collection:C1472)
		$staff.stmpHire:=This:C1470._stampFromJsonDate($row.hireDate)
		$staff.stmpRetrain:=This:C1470._stampFromJsonDate($row.retrainDate)
		$staff.stmpTermination:=This:C1470._stampFromJsonDate($row.terminationDate)
		$staff.stmpCreation:=Num:C11($row.creationDate)
		$division:=ds:C1482.Division.query("name = :1"; This:C1470._text($row.division))
		$staff.UUID_Division:=($division.length>0) ? $division[0].UUID : 16*"00"
		$staff.moreData:=New object:C1471("retrainNotified"; False:C215; "barcodeData"; This:C1470._barcode("Staff"))
		$res:=$staff.save()
		If ($res.success)
			$count:=$count+1
			This:C1470._linkStaffTeams($staff; $row)
		End if 
	End for each 
	This:C1470._invalidateTeamCache() 
	
	
Function _linkStaffTeams($staff : cs:C1710.StaffEntity; $row : Object)
	var $team : cs:C1710.TeamEntity
	var $membership : cs:C1710.MembershipEntity
	var $department : Text
	
	// Purpose: Staff Department popup shows the first Membership team. Team.name comes from JSON Employees.Department (every department, not a QA/Production subset).
	// modified by 4D/PS [2026-october-09]
	$department:=This:C1470._departmentFromRow($row)
	If ($department="")
		return 
	End if 
	$team:=This:C1470._ensureTeamByName($department)
	If ($team=Null:C1517)
		return 
	End if 
	$membership:=ds:C1482.Membership.new()
	$membership.UUID_Staff:=$staff.UUID
	$membership.UUID_Team:=$team.UUID
	This:C1470._ensureMoreData($membership; "Membership")
	$membership.save()
	
	
	// Purpose: Reuse or create a Team named from JSON Employees.Department (no invented labels).
	// created by 4D/PS [2026-october-09]
Function _ensureTeamByName($name : Text)->$team : cs:C1710.TeamEntity
	var $maxLevel : Integer
	var $res : Object
	
	$name:=This:C1470._text($name)
	If ($name="")
		$team:=Null:C1517
		return 
	End if 
	$team:=ds:C1482.Team.query("name = :1"; $name).first()
	If ($team#Null:C1517)
		return 
	End if 
	$team:=ds:C1482.Team.new()
	$team.name:=$name
	$maxLevel:=Num:C11(ds:C1482.Team.all().max("levelID"))
	$team.levelID:=$maxLevel+1
	This:C1470._ensureMoreData($team; "Team")
	$res:=$team.save()
	If (Not:C34($res.success))
		$team:=Null:C1517
	End if 
	This:C1470._invalidateTeamCache()
	
	
	// Purpose: Staff Department popup reads Storage.cache.teams; refresh after sample import.
	// created by 4D/PS [2026-october-09]
Function _invalidateTeamCache()
	If (Storage:C1525.cache=Null:C1517)
		return 
	End if 
	Use (Storage:C1525.cache)
		OB REMOVE:C1226(Storage:C1525.cache; "teams")
	End use 
	
	
Function _importStaffTrainings($folder : 4D:C1709.Folder)->$count : Integer
	var $rows : Collection
	var $row : Object
	var $staff : cs:C1710.StaffEntity
	var $certImport : Object
	var $assignment : cs:C1710.CertificationAssignmentEntity
	var $counter : Integer
	var $res : Object
	
	$count:=0
	$counter:=ds:C1482.Certification.all().extract("ref").max()
	If ($counter=Null:C1517)
		$counter:=0
	End if 
	$rows:=This:C1470._parseFile($folder; "employeeTraining_export.json")
	For each ($row; $rows)
		$staff:=ds:C1482.Staff.query("code = :1"; String:C10($row.Employee_Code)).first()
		If ($staff=Null:C1517) && (Num:C11($row.Employee_Code)>0)
			$staff:=ds:C1482.Staff.query("code = :1"; String:C10(Num:C11($row.Employee_Code); "000000")).first()
		End if 
		If ($staff=Null:C1517)
			continue
		End if 
		$assignment:=ds:C1482.CertificationAssignment.new()
		$assignment.UUID_Staff:=$staff.UUID
		$assignment.certificationStmp:=This:C1470._stampFromJsonDate($row.Tdate)
		$certImport:=ds:C1482.Certification.importForLegacyTraining(String:C10($row.T_Type); Num:C11($row.Duration); $counter)
		$counter:=$certImport.refCounter
		If ($certImport.success) && ($certImport.certification#Null:C1517)
			$assignment.UUID_Certification:=$certImport.certification.UUID
			$assignment.expiredIn:=$certImport.validityDays
			This:C1470._ensureMoreData($assignment; "CertificationAssignment"; New object:C1471("overrideCertExpired"; False:C215))
			$res:=$assignment.save()
			If ($res.success)
				$count:=$count+1
			End if 
		End if 
	End for each 
	For each ($staff; ds:C1482.Staff.all())
		If (ds:C1482.CertificationAssignment.query("UUID_Staff = :1"; $staff.UUID).length>0)
			$staff.recomputeRetrainDate()
		End if 
	End for each 
	
	
Function _ensureCustomer($name : Text)->$customer : cs:C1710.CustomerEntity
	var $res : Object
	
	$name:=This:C1470._text($name)
	If ($name="")
		$customer:=Null:C1517
		return 
	End if 
	$customer:=ds:C1482.Customer.query("name = :1"; $name).first()
	If ($customer#Null:C1517)
		return 
	End if 
	$customer:=ds:C1482.Customer.new()
	$customer.name:=$name
	$customer.code:=Substring:C12(Replace string:C233($name; " "; ""); 1; 8)
	$customer.enabled:=True:C214
	$customer.contactDetails:=New object:C1471("addresses"; New collection:C1472; "communications"; New collection:C1472)
	$customer.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("Customer"))
	$res:=$customer.save()
	If (Not:C34($res.success))
		$customer:=Null:C1517
	End if 
	
	
	// Purpose: Fill Customer from Customer_Log.json (real table, not a stub). CAR bForward needs these rows.
	// created by 4D/PS [2026-october-09]
Function _importCustomers($folder : 4D:C1709.Folder)->$count : Integer
	var $rows : Collection
	var $row : Object
	var $customer : cs:C1710.CustomerEntity
	var $name; $code : Text
	
	$count:=0
	$rows:=This:C1470._parseFileIfExists($folder; "Customer_Log.json")
	If ($rows.length=0)
		$rows:=This:C1470._parseFileIfExists($folder; "customers.json")
	End if 
	For each ($row; $rows)
		$name:=This:C1470._text($row.Customer)
		If ($name="")
			$name:=This:C1470._text($row.name)
		End if 
		If ($name="")
			continue
		End if 
		$customer:=This:C1470._ensureCustomer($name)
		If ($customer=Null:C1517)
			continue
		End if 
		$code:=This:C1470._text($row.Cust_Code)
		If ($code="")
			$code:=This:C1470._text($row.code)
		End if 
		If ($code#"")
			$customer.code:=$code
			$customer.codeNumber:=Num:C11(Replace string:C233($code; "-"; ""))
		End if 
		$customer.enabled:=True:C214
		$customer.accountNum:=This:C1470._text($row.Account_num)
		$customer.resaleLicenseNumber:=This:C1470._text($row.resaleLicenseNumber)
		This:C1470._fillCustomerAddresses($customer; $row)
		This:C1470._ensureMoreData($customer; "Customer")
		If ($customer.save().success)
			$count:=$count+1
		End if 
	End for each 
	This:C1470._ensureCustomer("ROCHESTER ELECTRONICS")
	This:C1470._ensureCustomer("Anadyne Inc")
	This:C1470._ensureCustomer("Leviton Lighting")
	This:C1470._ensureCustomer("VORAGO Technologies")
	If (Storage:C1525.cache#Null:C1517)
		Use (Storage:C1525.cache)
			OB REMOVE:C1226(Storage:C1525.cache; "customers")
		End use 
	End if 
	
	
Function _fillCustomerAddresses($customer : cs:C1710.CustomerEntity; $row : Object)
	var $addresses : Collection
	var $address : Object
	
	If ($customer=Null:C1517) || ($row=Null:C1517)
		return 
	End if 
	If ($customer.contactDetails=Null:C1517)
		$customer.contactDetails:=New object:C1471
	End if 
	$addresses:=New collection:C1472
	$address:=This:C1470._customerAddress("billing"; $row.Bill_Address1; $row.Bill_Address2; $row.Bill_add_city; $row.Bill_addr_zip)
	If ($address#Null:C1517)
		$addresses.push($address)
	End if 
	$address:=This:C1470._customerAddress("shipping"; $row.Ship_Address1; $row.Ship_Address2; $row.Ship_addr_city; $row.Ship_Addr_zip)
	If ($address#Null:C1517)
		$addresses.push($address)
	End if 
	If ($addresses.length>0)
		$customer.contactDetails.addresses:=$addresses
	Else 
		If ($customer.contactDetails.addresses=Null:C1517)
			$customer.contactDetails.addresses:=New collection:C1472
		End if 
	End if 
	If ($customer.contactDetails.communications=Null:C1517)
		$customer.contactDetails.communications:=New collection:C1472
	End if 
	
	
Function _customerAddress($type : Text; $street1 : Variant; $street2 : Variant; $city : Variant; $zip : Variant)->$address : Object
	var $s1 : Text
	
	$s1:=This:C1470._text($street1)
	If ($s1="")
		$address:=Null:C1517
		return 
	End if 
	$address:=New object:C1471("type"; $type; "detail"; New object:C1471(\
		"country"; "US"; \
		"iso_code_2"; "US"; \
		"street_1"; $s1; \
		"city"; This:C1470._text($city); \
		"postcode"; This:C1470._text($zip)))
	If (This:C1470._text($street2)#"")
		$address.detail.street_2:=This:C1470._text($street2)
	End if 
	
	
Function _ensureLot($lotNumber : Text; $customerName : Text; $device : Text; $poNumber : Text)->$lot : cs:C1710.LotEntity
	var $res : Object
	
	$lotNumber:=This:C1470._text($lotNumber)
	$poNumber:=This:C1470._text($poNumber)
	If ($poNumber="")
		$poNumber:=This:C1470._lotPoFromJson($lotNumber)
	End if 
	$lot:=ds:C1482.Lot.query("lotNumber = :1"; $lotNumber).first()
	If ($lot#Null:C1517)
		If ($poNumber#"") && (String:C10($lot.poNumber)="")
			$lot.poNumber:=$poNumber
			$lot.save()
		End if 
		This:C1470._ensureLotOperationalLinks($lot; $customerName)
		return 
	End if 
	$lot:=ds:C1482.Lot.new()
	$lot.lotNumber:=$lotNumber
	$lot.customer:=This:C1470._text($customerName)
	$lot.device:=This:C1470._text($device)
	$lot.poNumber:=$poNumber
	If (Num:C11($lotNumber)>0) && (ds:C1482.Lot.query("number = :1"; Num:C11($lotNumber)).length=0)
		$lot.number:=Num:C11($lotNumber)
	End if 
	$lot.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("Lot"))
	$res:=$lot.save()
	If (Not:C34($res.success))
		$lot:=Null:C1517
		return 
	End if 
	This:C1470._ensureLotOperationalLinks($lot; $customerName)
	
	
	// Purpose: Traveler bForward opens Planning (Lot + Job + PO + Customer in the real tables).
	// created by 4D/PS [2026-october-09]
Function _ensureLotOperationalLinks($lot : cs:C1710.LotEntity; $customerName : Text)
	var $customer : cs:C1710.CustomerEntity
	var $po : cs:C1710.PurchaseOrderEntity
	var $job : cs:C1710.JobEntity
	var $res : Object
	
	$job:=Null:C1517
	If ($lot=Null:C1517)
		return 
	End if 
	$customer:=This:C1470._ensureCustomer($customerName)
	If ($customer#Null:C1517)
		$lot.customer:=$customer.name
	End if 
	$po:=This:C1470._ensurePurchaseOrder(String:C10($lot.poNumber); $customer)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($lot.UUID_Job))=False:C215)
		$job:=ds:C1482.Job.get($lot.UUID_Job)
	End if 
	If ($job=Null:C1517)
		$job:=ds:C1482.Job.new()
		$job.deviceNumber:=This:C1470._text($lot.device)
		$job.customerName:=This:C1470._text($lot.customer)
		If ($customer#Null:C1517)
			$job.UUID_Customer:=$customer.UUID
		End if 
		If ($po#Null:C1517)
			$job.UUID_PurchaseOrder:=$po.UUID
			$job.poNumber:=$po.poNumber
		End if 
		This:C1470._ensureMoreData($job; "Job")
		$res:=$job.save()
		If ($res.success)
			$lot.UUID_Job:=$job.UUID
		End if 
	End if 
	$lot.save()
	
	
Function _ensurePurchaseOrder($poText : Text; $customer : cs:C1710.CustomerEntity)->$po : cs:C1710.PurchaseOrderEntity
	var $maxPo : Integer
	var $res : Object
	
	$poText:=This:C1470._text($poText)
	If ($poText="")
		$po:=Null:C1517
		return 
	End if 
	$po:=ds:C1482.PurchaseOrder.query("oldPoNumber = :1 OR poNum = :1"; $poText).first()
	If ($po=Null:C1517) && (Num:C11($poText)#0)
		$po:=ds:C1482.PurchaseOrder.query("poNumber = :1"; Num:C11($poText)).first()
	End if 
	If ($po#Null:C1517)
		return 
	End if 
	$po:=ds:C1482.PurchaseOrder.new()
	$po.oldPoNumber:=$poText
	$po.poNum:=$poText
	$po.poNumber:=Num:C11($poText)
	If ($po.poNumber=0)
		$maxPo:=Num:C11(ds:C1482.PurchaseOrder.all().max("poNumber"))
		$po.poNumber:=($maxPo>0) ? ($maxPo+1) : 1
	End if 
	$po.openPO:=True:C214
	If ($customer#Null:C1517)
		$po.UUID_Customer:=$customer.UUID
		$po.customer_name:=$customer.name
	End if 
	This:C1470._ensureMoreData($po; "PurchaseOrder")
	$res:=$po.save()
	If (Not:C34($res.success))
		$po:=Null:C1517
	End if 
	
	
	// Purpose: PO# on CAR comes from Lot.poNumber; values taken from archived_jobs_export.json (not invented).
	// created by 4D/PS [2026-october-09]
Function _lotPoFromJson($lotNumber : Text)->$po : Text
	$po:=""
	Case of 
		: ($lotNumber="200250")
			$po:="231845"
		: ($lotNumber="200391")
			$po:="Leviton - Credit Card"
		: ($lotNumber="206459")
			$po:="1094"
	End case 
	
	
Function _ensureLots()->$count : Integer
	$count:=0
	If (This:C1470._ensureLot("200250"; "ROCHESTER ELECTRONICS"; "LM7711/BHA (M38510/10302BHA)"; "231845")#Null:C1517)
		$count:=$count+1
	End if 
	If (This:C1470._ensureLot("104414"; "Anadyne Inc"; ""; "")#Null:C1517)
		$count:=$count+1
	End if 
	If (This:C1470._ensureLot("200391"; "Leviton Lighting"; "XHP70"; "Leviton - Credit Card")#Null:C1517)
		$count:=$count+1
	End if 
	If (This:C1470._ensureLot("206459"; "VORAGO Technologies"; "VA10800-CQ12803ECA"; "1094")#Null:C1517)
		$count:=$count+1
	End if 
	
	
	// Purpose: v18 qcar_export.json stores qcarNumber as text ("8"), not an integer.
	// created by 4D/PS [2026-october-09]
Function _findJsonByNumber($rows : Collection; $number : Integer)->$row : Object
	$row:=$rows.query("qcarNumber = :1"; String:C10($number)).first()
	If ($row=Null:C1517)
		$row:=$rows.query("qcarNumber = :1"; $number).first()
	End if 
	
	
Function _staffLabel($value : Variant)->$name : Text
	var $staff : cs:C1710.StaffEntity
	var $code : Text
	
	$name:=This:C1470._personName($value)
	If ($name="")
		return 
	End if 
	$code:=Replace string:C233($name; " "; "")
	If (Position:C15("ID"; Uppercase:C13($code))=1)
		$code:=Substring:C12($code; 3)
	End if 
	$staff:=ds:C1482.Staff.query("code = :1"; $code).first()
	If ($staff=Null:C1517) && (Num:C11($code)>0)
		$staff:=ds:C1482.Staff.query("code = :1"; String:C10(Num:C11($code); "000000")).first()
	End if 
	If ($staff#Null:C1517)
		$name:=This:C1470._personName($staff.firstName+" "+$staff.lastName)
	End if 
	
	
Function _applyRejectCriteria($qcar : cs:C1710.QcarEntity; $category : Text)
	var $items : cs:C1710.RejectCriteriaItemSelection
	var $cats : cs:C1710.RejectCriteriaCategorySelection
	var $token : Text
	
	$category:=This:C1470._text($category)
	If ($category="")
		return 
	End if 
	$items:=ds:C1482.RejectCriteriaItem.query("name = :1"; $category)
	If ($items.length=0)
		$token:=Split string:C1554($category; ","; sk trim spaces:K86:2+sk ignore empty strings:K86:1)[0]
		If ($token#$category)
			$items:=ds:C1482.RejectCriteriaItem.query("name = :1"; $token)
		End if 
	End if 
	If ($items.length=0)
		$items:=ds:C1482.RejectCriteriaItem.query("name = :1"; "@"+$category+"@")
	End if 
	If ($items.length>0)
		$qcar.UUID_RejectCriteriaItem:=$items[0].UUID
		$qcar.UUID_RejectCriteriaCategory:=$items[0].UUID_RejectCriteriaCategory
		return 
	End if 
	$cats:=ds:C1482.RejectCriteriaCategory.query("name = :1"; $category)
	If ($cats.length=0)
		$cats:=ds:C1482.RejectCriteriaCategory.query("name = :1"; "@"+$category+"@")
	End if 
	If ($cats.length>0)
		$qcar.UUID_RejectCriteriaCategory:=$cats[0].UUID
	End if 
	
	
Function _importQcars($folder : 4D:C1709.Folder)->$count : Integer
	var $rows; $wanted : Collection
	var $row : Object
	var $qcar : cs:C1710.QcarEntity
	var $origin : cs:C1710.QcarOriginEntity
	var $customer : cs:C1710.CustomerEntity
	var $lot : cs:C1710.LotEntity
	var $res : Object
	var $number; $deltaYears : Integer
	var $lotNumber; $category; $originName; $snippet : Text
	var $issuedRaw : Date
	
	$count:=0
	// Purpose: 8/12/13 are the linked traveler CARs; 147 stays open for the Open CARs view.
	$wanted:=New collection:C1472(8; 12; 13; 147)
	$rows:=This:C1470._parseFile($folder; "qcar_export.json")
	For each ($number; $wanted)
		$row:=This:C1470._findJsonByNumber($rows; $number)
		If ($row=Null:C1517)
			continue
		End if 
		$issuedRaw:=This:C1470._jsonDate($row.issuedDate)
		$deltaYears:=0
		If ($issuedRaw#!00-00-00!)
			$deltaYears:=Year of:C25(Current date:C33(*))-Year of:C25($issuedRaw)
		End if 
		$qcar:=ds:C1482.Qcar.new()
		$qcar.UUID_Lot:=16*"00"
		$qcar.UUID_Customer:=16*"00"
		$qcar.UUID_RejectCriteriaCategory:=16*"00"
		$qcar.UUID_RejectCriteriaItem:=16*"00"
		$qcar.UUID_QcarOrigin:=16*"00"
		$qcar.qcarNumber:=Num:C11($row.qcarNumber)
		$qcar.device:=This:C1470._text($row.device)
		$qcar.issuedBy:=This:C1470._staffLabel($row.issuedBy)
		$qcar.issuedTo:=This:C1470._text($row.issuedTo)
		$qcar.issuedStmp:=This:C1470._stampShiftedToThisYear($row.issuedDate; $deltaYears)
		$qcar.openDate:=This:C1470._dateShiftedToThisYear($row.issuedDate; $deltaYears)
		$qcar.closedStmp:=This:C1470._stampShiftedToThisYear($row.closedDate; $deltaYears)
		$qcar.targetCloseStmp:=This:C1470._stampShiftedToThisYear($row.targetCloseDate; $deltaYears)
		$qcar.submitStmp:=This:C1470._stampShiftedToThisYear($row.submitDate; $deltaYears)
		$qcar.verifiedBy:=This:C1470._staffLabel($row.verifiedBy)
		$qcar.verifiedStmp:=This:C1470._stampShiftedToThisYear($row.verifiedDate; $deltaYears)
		$qcar.verified:=($qcar.verifiedStmp#0) || ($qcar.verifiedBy#"")
		$qcar.void:=Bool:C1537($row.void)
		$qcar.submit:=Bool:C1537($row.submit)
		$qcar.inLine:=False:C215
		$category:=This:C1470._text($row.category)
		$qcar.internal:=(Position:C15("external"; Lowercase:C14($category))=0)
		$qcar.initiator8D:=$qcar.issuedBy
		$snippet:=This:C1470._text($row.d2)
		If (Length:C16($snippet)>255)
			$snippet:=Substring:C12($snippet; 1; 255)
		End if 
		$qcar.initialResponse:=$snippet
		If ($qcar.closedStmp#0)
			$qcar.revisionDate:=This:C1470._dateShiftedToThisYear($row.closedDate; $deltaYears)
		Else 
			$qcar.revisionDate:=$qcar.openDate
		End if 
		$qcar._initCorrectiveActionReport()
		$qcar.correctiveActionReport.d2:=This:C1470._text($row.d2)
		$qcar.correctiveActionReport.d3:=This:C1470._text($row.d3)
		$qcar.correctiveActionReport.d4:=This:C1470._text($row.d4)
		$qcar.correctiveActionReport.d5:=This:C1470._text($row.d5)
		$qcar.correctiveActionReport.d6:=This:C1470._text($row.d6)
		$qcar.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("Qcar"); "externalParty"; "")
		If (Not:C34($qcar.internal))
			$qcar.moreData.externalParty:=This:C1470._text($row.issuedBy)
		End if 
		$lotNumber:=This:C1470._text($row.lotNumber)
		This:C1470._applyRejectCriteria($qcar; $category)
		$customer:=This:C1470._ensureCustomer($row.customer)
		If ($customer#Null:C1517)
			$qcar.UUID_Customer:=$customer.UUID
		End if 
		If ($lotNumber="") || ($lotNumber="Non-Lot-Specific")
			// Purpose: Karla C — no traveler; Other origin = Customer; Customer stays pickable, PO# empty.
			$qcar.otherOriginChecked:=True:C214
			$origin:=ds:C1482.QcarOrigin.query("name = :1"; "Customer").first()
			If ($origin#Null:C1517)
				$qcar.UUID_QcarOrigin:=$origin.UUID
			End if 
		Else 
			$qcar.otherOriginChecked:=False:C215
			$lot:=This:C1470._ensureLot($lotNumber; $row.customer; $row.device; This:C1470._lotPoFromJson($lotNumber))
			If ($lot#Null:C1517)
				$qcar.UUID_Lot:=$lot.UUID
				If ($qcar.device="")
					$qcar.device:=This:C1470._text($lot.device)
				End if 
			End if 
		End if 
		$res:=$qcar.save()
		If ($res.success)
			$count:=$count+1
			This:C1470._attachQcarEvidence($qcar; $folder)
		End if 
	End for each 
	If ($count=0)
		ALERT:C41("No CAR rows were imported from qcar_export.json (looked for 8, 12, 13, 147).")
	End if 
	
	
Function _importSpecifications($folder : 4D:C1709.Folder)->$count : Integer
	var $rows : Collection
	var $row : Object
	var $spec : cs:C1710.SpecificationEntity
	var $division : cs:C1710.DivisionSelection
	var $category : cs:C1710.DocumentCategorySelection
	var $wanted : Collection
	var $name : Text
	var $res : Object
	var $pub : 4D:C1709.File
	var $blob : Blob
	
	$count:=0
	$wanted:=New collection:C1472("MIL-STD-202-208A"; "CS-11003"; "CS-11006"; "CS-11007"; "DC-11500")
	$rows:=This:C1470._parseFile($folder; "specification_export.json")
	For each ($name; $wanted)
		$row:=$rows.query("Spec = :1"; $name).first()
		If ($row=Null:C1517)
			continue
		End if 
		$spec:=ds:C1482.Specification.new()
		$spec.spec:=This:C1470._text($row.Spec)
		$spec.title:=This:C1470._text($row.Spec_Title)
		$spec.revision:=This:C1470._text($row.Rev)
		$spec.stmpRevisionDate:=This:C1470._stampFromJsonDate($row.Revsion_Date)
		$spec.isForm:=Bool:C1537($row.Form)
		$spec.remark:=This:C1470._text($row.Remarks)
		$spec.extension:=This:C1470._text($row.Dosext)
		$spec.suppress:=Bool:C1537($row.Suppress)
		$spec.reviewIntervalInDays:=Num:C11($row.ReviewIntervalInDays)
		$spec.stmpReviewDate:=This:C1470._stampFromJsonDate($row.Review_Date)
		$division:=ds:C1482.Division.query("name = :1"; This:C1470._text($row.Division))
		$spec.UUID_Division:=($division.length>0) ? $division[0].UUID : ""
		$category:=ds:C1482.DocumentCategory.query("name = :1"; This:C1470._text($row.PublishedDocCategory))
		If ($category.length>0)
			$spec.UUID_DocumentCategory:=$category[0].UUID
		End if 
		$spec.moreData:=New object:C1471("dueReview"; False:C215; "dueApproval"; False:C215; "barcodeData"; This:C1470._barcode("Specification"))
		$spec.documents:=New object:C1471("documentsCollection"; This:C1470._collectAttachedDocs($folder; "SpecificationsDocuments"; 21; $row.UniqueID))
		$pub:=$folder.folder("SpecificationsPublishedDocumentBlobFields").file(This:C1470._text($row.Spec))
		If (Not:C34($pub.exists))
			$pub:=$folder.folder("SpecificationsPublishedDocumentBlobField").file(This:C1470._text($row.Spec))
		End if 
		If ($pub.exists)
			DOCUMENT TO BLOB:C525($pub.platformPath; $blob)
			If (BLOB size:C605($blob)>0)
				$spec.publishedDocumentBlob:=$blob
				This:C1470._attachedFiles:=This:C1470._attachedFiles+1
			End if 
		End if 
		$res:=$spec.save()
		If ($res.success)
			$count:=$count+1
		End if 
	End for each 
	
	
	// Purpose: Drop Contact rows that belong to AVL suppliers before Supplier is truncated.
	// created by 4D/PS [2026-october-09]
Function _dropSupplierContacts()
	var $uuids : Collection
	var $supplier : cs:C1710.SupplierEntity
	var $contact : cs:C1710.ContactEntity
	
	$uuids:=New collection:C1472
	For each ($supplier; ds:C1482.Supplier.all())
		$uuids.push($supplier.UUID)
	End for each 
	If ($uuids.length=0)
		return 
	End if 
	For each ($contact; ds:C1482.Contact.query("UUID_Company in :1"; $uuids))
		$contact.drop()
	End for each 
	
	
	// Purpose: Pick JSON suppliers that Karla can recognize — prefer AVL rows with a street that also appear on AML.
	// created by 4D/PS [2026-october-09]
Function _pickSupplierRows($folder : 4D:C1709.Folder)->$picked : Collection
	var $all; $aml; $amlNames; $seen : Collection
	var $row : Object
	var $name : Text
	var $hasAddr; $inAml : Boolean
	
	$picked:=New collection:C1472
	$seen:=New collection:C1472
	$amlNames:=New collection:C1472
	$all:=This:C1470._parseFile($folder; "suppliers_export.json")
	$aml:=This:C1470._parseFile($folder; "aml_export.json")
	For each ($row; $aml)
		$name:=This:C1470._text($row.Supplier)
		If ($name#"") && ($amlNames.indexOf($name)=-1)
			$amlNames.push($name)
		End if 
	End for each 
	This:C1470._appendSupplierPick($picked; $seen; $all; $amlNames; True:C214; True:C214; 12)
	This:C1470._appendSupplierPick($picked; $seen; $all; $amlNames; True:C214; False:C215; 12)
	This:C1470._appendSupplierPick($picked; $seen; $all; $amlNames; False:C215; False:C215; 12)
	
	
Function _appendSupplierPick($picked : Collection; $seen : Collection; $all : Collection; $amlNames : Collection; $needAddr : Boolean; $needAml : Boolean; $max : Integer)
	var $row : Object
	var $name : Text
	var $hasAddr; $inAml : Boolean
	
	For each ($row; $all)
		If ($picked.length>=$max)
			return 
		End if 
		$name:=This:C1470._text($row.Supplier)
		If ($name="") || ($seen.indexOf($name)#-1)
			continue
		End if 
		$hasAddr:=(This:C1470._text($row.Address1)#"")
		$inAml:=($amlNames.indexOf($name)#-1)
		If (Bool:C1537($needAddr)) && (Not:C34($hasAddr))
			continue
		End if 
		If (Bool:C1537($needAml)) && (Not:C34($inAml))
			continue
		End if 
		$picked.push($row)
		$seen.push($name)
	End for each 
	
	
	// Purpose: Same address object as __import_data_avl_aml (v18 Address1/2/3, State, Zip / remit_*).
	// created by 4D/PS [2026-october-09]
Function _jsonSupplierAddress($row : Object; $type : Text)->$address : Object
	$address:=New object:C1471
	$address.type:=$type
	$address.detail:=New object:C1471
	$address.detail.country:="US"
	$address.detail.iso_code_2:="US"
	If ($type="remit")
		$address.detail.street_1:=This:C1470._text($row.remit_add1)
		If (This:C1470._text($row.remit_add2)#"")
			$address.detail.street_2:=This:C1470._text($row.remit_add2)
		End if 
		$address.detail.city:=This:C1470._text($row.remit_add3)
		$address.detail.state:=This:C1470._text($row.remit_st)
		$address.detail.postcode:=This:C1470._text($row.remit_zip)
	Else 
		$address.detail.street_1:=This:C1470._text($row.Address1)
		If (This:C1470._text($row.Address2)#"")
			$address.detail.street_2:=This:C1470._text($row.Address2)
		End if 
		$address.detail.city:=This:C1470._text($row.Address3)
		$address.detail.state:=This:C1470._text($row.State)
		$address.detail.postcode:=This:C1470._text($row.Zip)
	End if 
	
	
Function _addSupplierContact($supplier : cs:C1710.SupplierEntity; $row : Object; $title : Text)
	var $contact : cs:C1710.ContactEntity
	var $prefix; $first; $last : Text
	var $comm : Object
	
	$prefix:=($title="Primary") ? "C1" : "C2"
	$first:=This:C1470._personName($row[$prefix+"_first_name"])
	$last:=This:C1470._personName($row[$prefix+"_last_name"])
	If ($first="") && ($last="")
		return 
	End if 
	$contact:=ds:C1482.Contact.new()
	$contact.UUID_Company:=$supplier.UUID
	$contact.firstName:=$first
	$contact.lastName:=$last
	$contact.title:=$title
	$contact.contactDetails:=New object:C1471("addresses"; New collection:C1472; "communications"; New collection:C1472)
	$comm:=New object:C1471("type"; "phone"; "comment"; ""; "contact"; This:C1470._text($row[$prefix+"_tel"]))
	$contact.contactDetails.communications.push($comm)
	$comm:=New object:C1471("type"; "fax"; "comment"; ""; "contact"; This:C1470._text($row[$prefix+"_fax"]))
	$contact.contactDetails.communications.push($comm)
	$comm:=New object:C1471("type"; "email"; "comment"; ""; "contact"; This:C1470._text($row[$prefix+"_Email"]))
	$contact.contactDetails.communications.push($comm)
	This:C1470._ensureMoreData($contact; "Contact")
	$contact.save()
	
	
Function _unitsLevel($name : Text)->$level : Integer
	var $unit : cs:C1710.UnitsSelection
	
	$level:=0
	If ($name="")
		return 
	End if 
	$unit:=ds:C1482.Units.query("name = :1"; $name)
	If ($unit.length>0)
		$level:=Num:C11($unit[0].levelID)
	End if 
	
	
Function _importSuppliers($folder : 4D:C1709.Folder)->$count : Integer
	var $picked : Collection
	var $row : Object
	var $supplier : cs:C1710.SupplierEntity
	var $division : cs:C1710.DivisionSelection
	var $res : Object
	var $name : Text
	
	$count:=0
	This:C1470._qaSupplierNames:=New collection:C1472
	$picked:=This:C1470._pickSupplierRows($folder)
	For each ($row; $picked)
		$name:=This:C1470._text($row.Supplier)
		$supplier:=ds:C1482.Supplier.new()
		$supplier.name:=$name
		$supplier.code:=This:C1470._text($row.code)
		$supplier.disqualified:=Bool:C1537($row.Disqualified)
		$supplier.enteredBy:=This:C1470._text($row.Entry_by)
		$supplier.qaComment:=This:C1470._text($row.QA_Comments)
		$supplier.approvedByQA:=Bool:C1537($row.ApprovedByQA)
		$supplier.approvedByCustomer:=Bool:C1537($row.ApprovedByCustomer)
		$supplier.allowedLotProcessing:=Bool:C1537($row.lot_processing_allowed)
		$supplier.webService:=This:C1470._text($row.WebService)
		$supplier.auditRequired:=Bool:C1537($row.Audit_Required)
		$supplier.deactivated:=Bool:C1537($row.Deactivate)
		$supplier.stmpLastAudit:=This:C1470._stampFromJsonDate($row.Last_Audit_Date)
		$supplier.stmpNextAudit:=This:C1470._stampFromJsonDate($row.Next_Audit_Due)
		$supplier.contactDetails:=New object:C1471("addresses"; New collection:C1472; "communications"; New collection:C1472)
		$supplier.contactDetails.addresses.push(This:C1470._jsonSupplierAddress($row; "main"))
		$supplier.contactDetails.addresses.push(This:C1470._jsonSupplierAddress($row; "remit"))
		$supplier.RatingData:=New object:C1471("items"; New collection:C1472)
		This:C1470._ensureMoreData($supplier; "Supplier"; New object:C1471("criticalOverdueAudit"; False:C215))
		$division:=ds:C1482.Division.query("name = :1"; This:C1470._text($row.Division))
		$supplier.UUID_Division:=($division.length>0) ? $division[0].UUID : ""
		$supplier.attachedDocuments:=New object:C1471("documents"; This:C1470._collectAttachedDocs($folder; "SuppliersDocs"; 18; $row.UniqueID))
		$res:=$supplier.save()
		If ($res.success)
			$count:=$count+1
			This:C1470._qaSupplierNames.push($name)
			This:C1470._addSupplierContact($supplier; $row; "Primary")
			This:C1470._addSupplierContact($supplier; $row; "Secondary")
		End if 
	End for each 
	
	
Function _importAml($folder : 4D:C1709.Folder)->$count : Integer
	var $rows : Collection
	var $row : Object
	var $aml : cs:C1710.AMLEntity
	var $supplier : cs:C1710.SupplierSelection
	var $part : cs:C1710.PartDataEntity
	var $division : cs:C1710.DivisionSelection
	var $perSupplier : Object
	var $name : Text
	var $res : Object
	
	$count:=0
	If (This:C1470._qaSupplierNames.length=0)
		return 
	End if 
	$perSupplier:=New object:C1471
	$rows:=This:C1470._parseFile($folder; "aml_export.json")
	For each ($row; $rows)
		If ($count>=18)
			break
		End if 
		$name:=This:C1470._text($row.Supplier)
		If (This:C1470._qaSupplierNames.indexOf($name)=-1)
			continue
		End if 
		If (Num:C11($perSupplier[$name])>=2)
			continue
		End if 
		$aml:=ds:C1482.AML.new()
		$aml.ourPartNum:=This:C1470._text($row.OUR_partnum)
		$aml.vendorPartnum:=This:C1470._text($row.Vendor_partnum)
		$aml.critical:=Bool:C1537($row.Critical)
		$aml.service:=Bool:C1537($row.Service)
		$aml.serviceType:=This:C1470._text($row.Service_type)
		$aml.enteredBy:=This:C1470._text($row.EnteredBy)
		$aml.capacity:=Num:C11($row.Capacity)
		$aml.makeInactive:=Bool:C1537($row.MakeInactive)
		$aml.comment:=This:C1470._text($row.Comments)
		$aml.description:=This:C1470._text($row.Description)
		$aml.minInventoryLevel:=Num:C11($row.MinInventoryLevel)
		$aml.transFactorNumerator:=Num:C11($row.TransFactorNumerator)
		$aml.transFactorDenominator:=Num:C11($row.TransFactorDenominator)
		$aml.inventoryUnits:=This:C1470._unitsLevel(This:C1470._text($row.InventoryUnits))
		$aml.procurementUnits:=This:C1470._unitsLevel(This:C1470._text($row.ProcurementUnits))
		$aml.attachedDocuments:=New object:C1471("documents"; New collection:C1472)
		$division:=ds:C1482.Division.query("name = :1"; This:C1470._text($row.Division))
		$aml.UUID_Division:=($division.length>0) ? $division[0].UUID : ""
		$part:=ds:C1482.PartData.query("internalPartNum = :1"; $aml.ourPartNum).first()
		If ($part=Null:C1517) && ($aml.ourPartNum#"")
			$part:=ds:C1482.PartData.new()
			$part.internalPartNum:=$aml.ourPartNum
			This:C1470._ensureMoreData($part; "PartData")
			$part.save()
		End if 
		If ($part#Null:C1517)
			$aml.UUID_PartData:=$part.UUID
		End if 
		This:C1470._ensureMoreData($aml; "AML")
		$supplier:=ds:C1482.Supplier.query("name = :1"; $name)
		If ($supplier.length>0)
			$aml.UUID_Supplier:=$supplier[0].UUID
			If (Num:C11($perSupplier[$name])=0)
				If ($supplier[0].attachedDocuments#Null:C1517) && ($supplier[0].attachedDocuments.documents#Null:C1517) && ($supplier[0].attachedDocuments.documents.length>0)
					$aml.attachedDocuments.documents.push(OB Copy:C1225($supplier[0].attachedDocuments.documents[0]))
					This:C1470._attachedFiles:=This:C1470._attachedFiles+1
				End if 
			End if 
		End if 
		$res:=$aml.save()
		If ($res.success)
			$count:=$count+1
			$perSupplier[$name]:=Num:C11($perSupplier[$name])+1
		End if 
	End for each 
	This:C1470._markCriticalSuppliers()
	
	
	// Purpose: Same as full AVL import — supplier is critical when any linked AML part is critical.
	// created by 4D/PS [2026-october-09]
Function _markCriticalSuppliers()
	var $supplier : cs:C1710.SupplierEntity
	
	For each ($supplier; ds:C1482.Supplier.all())
		If (ds:C1482.AML.query("UUID_Supplier = :1 AND critical = :2"; $supplier.UUID; True:C214).length>0)
			$supplier.critical:=True:C214
			$supplier.save()
		End if 
	End for each 
	
	
Function _importAudits($folder : 4D:C1709.Folder)->$count : Integer
	var $rows; $wanted : Collection
	var $row : Object
	var $audit : cs:C1710.AuditEntity
	var $res : Object
	var $page : Integer
	
	$count:=0
	$wanted:=New collection:C1472(6; 7)
	$rows:=This:C1470._parseFile($folder; "log_book_export.json")
	For each ($page; $wanted)
		$row:=$rows.query("Page = :1"; $page).first()
		If ($row=Null:C1517)
			$row:=$rows.query("Page = :1"; String:C10($page)).first()
		End if 
		If ($row=Null:C1517)
			continue
		End if 
		$audit:=ds:C1482.Audit.new()
		$audit.auditNumber:=Num:C11($row.Page)
		$audit.stmpPage:=This:C1470._stampFromJsonDate($row.Page_Date)
		$audit.supervisor:=This:C1470._text($row.Supervisor)
		$audit.stmpCreationDate:=Num:C11($row.CreationDateTimeStamp)
		$audit.title:=This:C1470._text($row.LogTitle)
		$audit.storageFilename:=This:C1470._text($row.StoragedFilename)
		$audit.type:="Internal"
		$audit.auditReport:=WP New:C1317()
		$audit.activities:=New object:C1471("collection"; New collection:C1472)
		$audit.auditTeam:=New object:C1471("teamMembers"; New collection:C1472)
		$audit.document:=New object:C1471("code"; ""; "creationDateTimeStamp"; 0; "documentPath"; ""; "sourcePath"; ""; "description"; ""; "approvalDate"; !00-00-00!; "approvedBy"; ""; "isApproved"; False:C215; "UUID_sfwDocument"; ""; "extension"; "")
		$audit.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("Audit"))
		$res:=$audit.save()
		If ($res.success)
			$count:=$count+1
			This:C1470._attachFrameworkFile($audit; $folder; "LogBookDocs"; 39; $audit.auditNumber; "audit")
		End if 
	End for each 
	
	
Function _importReviews($folder : 4D:C1709.Folder)->$count : Integer
	var $rows; $wanted : Collection
	var $row : Object
	var $review : cs:C1710.ManagementReviewEntity
	var $res : Object
	var $page : Integer
	
	$count:=0
	$wanted:=New collection:C1472(3; 4)
	$rows:=This:C1470._parseFile($folder; "log_book_export.json")
	For each ($page; $wanted)
		$row:=$rows.query("Page = :1"; $page).first()
		If ($row=Null:C1517)
			$row:=$rows.query("Page = :1"; String:C10($page)).first()
		End if 
		If ($row=Null:C1517)
			continue
		End if 
		$review:=ds:C1482.ManagementReview.new()
		$review.managementReviewNumber:=Num:C11($row.Page)
		$review.stmpPage:=This:C1470._stampFromJsonDate($row.Page_Date)
		$review.createdBy:=This:C1470._text($row.Supervisor)
		$review.stmpCreationDate:=Num:C11($row.CreationDateTimeStamp)
		$review.title:=This:C1470._text($row.LogTitle)
		$review.document:=New object:C1471("code"; ""; "creationDateTimeStamp"; 0; "documentPath"; ""; "sourcePath"; ""; "description"; ""; "approvalDate"; !00-00-00!; "approvedBy"; ""; "isApproved"; False:C215; "UUID_sfwDocument"; ""; "extension"; "")
		$review.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("ManagementReview"))
		$res:=$review.save()
		If ($res.success)
			$count:=$count+1
			This:C1470._attachFrameworkFile($review; $folder; "LogBookDocs"; 39; $review.managementReviewNumber; "review")
		End if 
	End for each 
	
	
Function _createRmas()->$count : Integer
	var $qcar : cs:C1710.QcarEntity
	var $rma : cs:C1710.RMAEntity
	var $res : Object
	
	$count:=0
	$qcar:=ds:C1482.Qcar.query("qcarNumber = :1"; 8).first()
	If ($qcar=Null:C1517)
		return 
	End if 
	$rma:=ds:C1482.RMA.new()
	$rma.rmaNumber:=1
	$rma.UUID_Qcar:=$qcar.UUID
	$rma.travelerNumber:="200250"
	$rma.status:="Open"
	$rma.invoiceNumber:=1001
	$rma.authorizedBy:="QA"
	$rma.description:="QA sample RMA linked to CAR 8 / traveler 200250 ("+$qcar.device+")"
	$rma.reasonForReturn:="Quality"
	$rma.dateReceived:=Current date:C33(*)
	$rma.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("RMA"))
	$res:=$rma.save()
	If ($res.success)
		$count:=$count+1
	End if 
	$rma:=ds:C1482.RMA.new()
	$rma.rmaNumber:=2
	$rma.travelerNumber:="200391"
	$rma.status:="Open"
	$rma.invoiceNumber:=1002
	$rma.authorizedBy:="QA"
	$rma.description:="QA sample RMA without CAR, traveler 200391"
	$rma.reasonForReturn:="Customer return"
	$rma.dateReceived:=Current date:C33(*)
	$rma.moreData:=New object:C1471("barcodeData"; This:C1470._barcode("RMA"))
	$res:=$rma.save()
	If ($res.success)
		$count:=$count+1
	End if 
