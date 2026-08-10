//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $specFile : 4D:C1709.File
var $docsFile : 4D:C1709.File
var $records : Collection
var $record : Object
var $documents : Variant
var $_documents : Collection
var $document : Object
var $blob : Blob
var $PublishedDocumentBlob : 4D:C1709.File
var $doc : 4D:C1709.File
var $specification_e : 4D:C1709.Entity
var $res : Object
var $created : Integer
var $failed : Integer

If (ds:C1482["Specification"]=Null:C1517)
	ALERT:C41("DataClass Specification not found.")
Else 
	TRUNCATE TABLE:C1051([Specification:10])
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	
	$specFile:=$importsFolder.file("specControl_export.json")
	If (Not:C34($specFile.exists))
		$specFile:=$importsFolder.file("specification_export.json")
	End if 
	
	If (Not:C34($specFile.exists))
		ALERT:C41("Import file not found (specControl_export.json or specification_export.json): "+$importsFolder.platformPath)
	Else 
		$records:=JSON Parse:C1218($specFile.getText())
		
		$docsFile:=$importsFolder.file("docServerIndex_export.json")
		If ($docsFile.exists)
			$documents:=JSON Parse:C1218($docsFile.getText())
		Else 
			$documents:=Null:C1517
		End if 
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$specification_e:=ds:C1482.Specification.new()
			
			$specification_e.spec:=$record.Spec
			$specification_e.title:=$record.Spec_Title
			$specification_e.stmpRevisionDate:=cs:C1710.sfw_stmp.me.build(Date:C102($record.Revsion_Date))
			$specification_e.revision:=$record.Rev
			
			$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($record.Division; "\r"; sk trim spaces:K86:2).join("\r"))
			If ($division.length>0)
				$specification_e.UUID_Division:=$division[0].UUID
			Else 
				$specification_e.UUID_Division:=""
			End if 
			
			$specification_e.isForm:=$record.Form
			
			$category:=ds:C1482.DocumentCategory.query("name =:1"; Split string:C1554($record.PublishedDocCategory; "\r"; sk trim spaces:K86:2).join("\r"))
			If ($category.length>0)
				$specification_e.UUID_DocumentCategory:=$category[0].UUID
			Else 
				$specification_e.UUID_DocumentCategory:=0
			End if 
			
			$specification_e.remark:=String:C10($record.Remarks)
			$specification_e.extension:=$record.Dosext
			$specification_e.suppress:=$record.Suppress
			$specification_e.reviewIntervalInDays:=$record.ReviewIntervalInDays
			$specification_e.stmpReviewDate:=cs:C1710.sfw_stmp.me.build(Date:C102($record.Review_Date))
			
			$specification_e.moreData:=New object:C1471(\
				"dueReview"; False:C215; \
				"dueApproval"; False:C215\
				)
			
			$stecControllingDetpt:=ds:C1482.ControllingDepartment.query("name =:1"; Split string:C1554($record.ControllingDept; "\r"; sk trim spaces:K86:2).join("\r"))
			If ($stecControllingDetpt.length>0)
				$specification_e.UUID_ControllingDepartment:=$stecControllingDetpt[0].UUID
			Else 
				$specification_e.UUID_ControllingDepartment:=0
			End if 
			
			$PublishedDocumentBlob:=$importsFolder.folder("SpecificationsPublishedDocumentBlobFields").file(String:C10($record.Spec))
			If ($PublishedDocumentBlob.exists)
				
				DOCUMENT TO BLOB:C525($PublishedDocumentBlob.platformPath; $blob)
				$specification_e.publishedDocumentBlob:=$blob
				
			Else 
				
			End if 
			
			
			If ($documents#Null:C1517)
				$_documents:=$documents.query("PrimaryKeyValue=:1 & TableNumber=:2"; String:C10($record.UniqueID); 21)
			Else 
				$_documents:=New collection:C1472()
			End if 
			
			$specification_e.documents:=New object:C1471()
			$specification_e.documents.documentsCollection:=New collection:C1472()
			
			For each ($document; $_documents)
				$docObj:=New object:C1471
				
				$docObj.code:=$document.DocCode
				$docObj.dateTimeStamp:=$document.DateTimeStamp
				$docObj.creationDateTimeStamp:=$document.CreationDateTimeStamp
				$docObj.documentPath:=$document.DocumentPath
				$docObj.sourcePath:=$document.SourcePath
				$docObj.description:=$document.DocDescription
				$docObj.approvalDate:=!00-00-00!
				$docObj.approvedBy:=""
				$docObj.isApproved:=False:C215
				
				$doc:=$importsFolder.folder("SpecificationsDocuments").file(String:C10($document.UniqueID+$document.PrimaryKeyValue))
				If ($doc.exists)
					
					
					DOCUMENT TO BLOB:C525($doc.platformPath; $blob)
					
					$docObj.blob:=$blob
					
				End if 
				
				$specification_e.documents.documentsCollection.push($docObj)
			End for each 
			
			
			$res:=$specification_e.save()
			If ($res.success)
				$created:=$created+1
			Else 
				$failed:=$failed+1
				TRACE:C157
			End if 
		End for each 
		
		ALERT:C41("Import termine - specifications: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
	
End if 
