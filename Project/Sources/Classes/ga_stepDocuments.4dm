// ga_stepDocuments
// What production sees on the "Forms & Specs" page of Punch In and Punch Out: the specs
// and GAF forms linked to the lot step's own Step, each openable. Only that step's links are
// listed: the specs a form refers to (Specification.moreData.referencedSpecs) belong to the
// form, not to the step, so they are not added.
//
// - The list is read live from the Step's links (StepSpecification), so it always shows
//   the current revision; when the traveller recorded an older revision for this lot step
//   (LotStep.specificationControl), the row says so.
// - The file of a spec or form is its most recent sfw_Document (the bytes are in
//   DocumentData on the server). It is fetched only when shown, and kept in a local cache
//   named after the sfw_Document UUID. A replaced file gets a new sfw_Document, hence a new
//   name, so a revised form is fetched again while an unchanged one is fetched once.
//   Cache files older than 30 days are removed when the class is first used in a process.
singleton Class constructor
	This:C1470._sweepCache()
	
	
// Rows for a lot step: the specs linked to its Step first, then its forms. Each row:
// UUID_Specification, type, spec, revision, title, note, docUUID, hasFile.
Function listFor($lotStep : 4D:C1709.Entity)->$rows : Collection
	var $step : 4D:C1709.Entity
	var $link : 4D:C1709.Entity
	var $spec : 4D:C1709.Entity
	var $doc : 4D:C1709.Entity
	var $item : Object
	var $row : Object
	var $snapshot : Object
	var $seen : Object
	var $docByTarget : Object
	
	$rows:=New collection:C1472
	If ($lotStep=Null:C1517)
		return $rows
	End if 
	$step:=$lotStep.step
	If ($step=Null:C1517)
		return $rows
	End if 
	
	// revisions as the traveller recorded them when this lot step was created
	$snapshot:=New object:C1471
	If ($lotStep.specificationControl#Null:C1517)
		If ($lotStep.specificationControl.items#Null:C1517)
			For each ($item; $lotStep.specificationControl.items)
				$snapshot[String:C10($item.UUID_Specification)]:=String:C10($item.revision)
			End for each 
		End if 
	End if 
	
	$seen:=New object:C1471
	For each ($link; $step.StepSpecifications)
		$spec:=$link.specification
		If ($spec#Null:C1517)
			If ($seen[$spec.UUID]=Null:C1517)
				$seen[$spec.UUID]:=True:C214
				$rows.push(This:C1470._row($spec; False:C215; ""; $snapshot))
			End if 
		End if 
	End for each 
	
	If ($rows.length=0)
		return $rows
	End if 
	
	// one query for every file: the most recent attachment of each spec
	$docByTarget:=New object:C1471
	For each ($doc; ds:C1482.sfw_Document.query("UUID_target IN :1"; $rows.extract("UUID_Specification")).orderBy("stmp desc"))
		If ($docByTarget[$doc.UUID_target]=Null:C1517)
			$docByTarget[$doc.UUID_target]:=$doc.UUID
		End if 
	End for each 
	For each ($row; $rows)
		$row.docUUID:=String:C10($docByTarget[$row.UUID_Specification])
		$row.hasFile:=($row.docUUID#"")
		If (Not:C34($row.hasFile))
			$row.note:=$row.note+Choose:C955($row.note=""; ""; " - ")+"no file"
		End if 
	End for each 
	
	$rows:=$rows.orderBy("sortKey asc, spec asc")
	
	
Function _row($spec : 4D:C1709.Entity; $referenced : Boolean; $note : Text; $snapshot : Object)->$row : Object
	var $recorded : Text
	
	$recorded:=String:C10($snapshot[$spec.UUID])
	If ($recorded#"") && ($recorded#String:C10($spec.revision))
		$note:=$note+Choose:C955($note=""; ""; " - ")+"revised since this traveller (rev "+$recorded+")"
	End if 
	If (Bool:C1537($spec.suppress))
		$note:=$note+Choose:C955($note=""; ""; " - ")+"obsolete"
	End if 
	
	$row:=New object:C1471(\
		"UUID_Specification"; $spec.UUID; \
		"type"; Choose:C955(Bool:C1537($spec.isForm); "Form"; "Spec"); \
		"sortKey"; Choose:C955($referenced; 2; Choose:C955(Bool:C1537($spec.isForm); 1; 0)); \
		"spec"; String:C10($spec.spec); \
		"revision"; String:C10($spec.revision); \
		"title"; String:C10($spec.title); \
		"note"; $note; \
		"docUUID"; ""; \
		"hasFile"; False:C215)
	
	
// The local copy of a stored document, fetched from the server only if not cached yet.
// Null when the document or its file does not exist.
Function localFile($docUUID : Text)->$file : 4D:C1709.File
	var $doc : 4D:C1709.Entity
	var $blob : 4D:C1709.Blob
	
	$file:=Null:C1517
	$doc:=ds:C1482.sfw_Document.get($docUUID)
	If ($doc=Null:C1517)
		return $file
	End if 
	
	$file:=This:C1470._cacheFolder().file($doc.UUID+String:C10($doc.extension))
	If (Not:C34($file.exists))
		// getStoredBlob runs on the server, where DocumentData lives, and returns the bytes
		$blob:=$doc.getStoredBlob()
		If ($blob=Null:C1517)
			$file:=Null:C1517
			return $file
		End if 
		$file.setContent($blob)
	End if 
	
	
// URL for a web area, built the way sfw_definitionPageDocuments builds it for PDFs.
Function urlFor($file : 4D:C1709.File)->$url : Text
	var $path : Text
	
	$path:=Replace string:C233($file.platformPath; Folder separator:K24:12; "/")
	If (Is macOS:C1572)
		$url:="file:///Volumes/"+Replace string:C233($path; " "; "%20")
	Else 
		$url:="file:///"+$path
	End if 
	
	
Function _cacheFolder()->$folder : 4D:C1709.Folder
	$folder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("GA_docCache")
	If (Not:C34($folder.exists))
		$folder.create()
	End if 
	
	
Function _sweepCache()
	var $file : 4D:C1709.File
	
	For each ($file; This:C1470._cacheFolder().files())
		If ($file.modificationDate<(Current date:C33-30))
			$file.delete()
		End if 
	End for each 
	
	
// Opens the file of a Document Control record with the system viewer (the PDF reader for a
// GAF form). The file is the record's most recent sfw_Document - where _import_specFiles puts
// the GAF forms - and, for a record without one, the legacy published document blob.
// The local copy always carries the file's extension, so Windows opens it with the right
// program. Returns "" once opened, else the reason it could not be.
Function openSpecFile($spec : 4D:C1709.Entity)->$problem : Text
	var $doc : 4D:C1709.Entity
	var $file : 4D:C1709.File
	var $blob : 4D:C1709.Blob
	var $extension : Text
	
	$problem:=""
	If ($spec=Null:C1517)
		$problem:="No document is selected."
		return $problem
	End if 
	
	$doc:=ds:C1482.sfw_Document.query("UUID_target = :1"; $spec.UUID).orderBy("stmp desc").first()
	If ($doc#Null:C1517)
		$file:=This:C1470.localFile($doc.UUID)
	End if 
	
	If ($file=Null:C1517)
		$blob:=$spec.publishedDocumentBlob
		If ($blob#Null:C1517)
			If ($blob.size>0)
				$extension:=Lowercase:C14(String:C10($spec.extension))
				If ($extension="")
					$extension:="pdf"
				End if 
				If (Position:C15("."; $extension)#1)
					$extension:="."+$extension
				End if 
				$file:=This:C1470._cacheFolder().file($spec.UUID+"_published"+$extension)
				$file.setContent($blob)
			End if 
		End if 
	End if 
	
	If ($file=Null:C1517)
		$problem:="No file is attached to "+String:C10($spec.spec)+" yet."
		return $problem
	End if 
	If ($file.size=0)
		$problem:="The file of "+String:C10($spec.spec)+" is empty."
		return $problem
	End if 
	OPEN URL:C673($file.platformPath; *)
	
Function chooseStepSpec($lotStep : 4D:C1709.Entity; $anchorObject : Text)
	// "View specs" and the Spec Control field of Punch In / OUT: the specs recorded on this lot
	// step (its traveller), in a small list under the field; the one picked opens in Document Control
	var $specUUIDs : Collection
	var $item : Object
	var $form : Object
	var $l; $t; $r; $b; $winRef : Integer
	
	$specUUIDs:=New collection:C1472
	If ($lotStep#Null:C1517)
		If ($lotStep.specificationControl#Null:C1517)
			If ($lotStep.specificationControl.items#Null:C1517)
				For each ($item; $lotStep.specificationControl.items)
					If (String:C10($item.UUID_Specification)#"")
						$specUUIDs.push($item.UUID_Specification)
					End if 
				End for each 
			End if 
		End if 
	End if 
	If ($specUUIDs.length=0)
		cs:C1710.sfw_dialog.me.alert("No spec is recorded on this step.")
		return 
	End if 
	
	$form:=New object:C1471("lb_items"; ds:C1482.Specification.query("UUID in :1"; $specUUIDs))
	OBJECT GET COORDINATES:C663(*; $anchorObject; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	$winRef:=Open form window:C675("selectSpecDocument"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectSpecDocument"; $form)
	CLOSE WINDOW:C154($winRef)
	If (OK=1) && ($form.item#Null:C1517)
		cs:C1710.sfw.new().openInANewWindow($form.item; "qualityAssurance"; "specification")
	End if 
	
