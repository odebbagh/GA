//%attributes = {"executedOnServer":true}


//Audit
var $eAudit : cs:C1710.AuditEntity

$audit_log:=Folder:C1567(fk data folder:K87:12).file("DataJson/log_book_export.json")

If ($audit_log.exists)
	$audits:=JSON Parse:C1218($audit_log.getText())
	
	TRUNCATE TABLE:C1051([Audit:139])
	
	$docs:=Folder:C1567(fk data folder:K87:12).file("DataJson/docServerIndex_export.json")
	$count:=0
	If ($docs.exists)
		
		$documents:=JSON Parse:C1218($docs.getText()).query("TableNumber=:1"; 39)
		
	End if 
	
	
	For each ($audit; $audits)
		If (Split string:C1554($audit.Book; "\r"; sk trim spaces:K86:2).join("\r")="Internal Audits")
			
			$eAudit:=ds:C1482.Audit.new()
			$eAudit.auditNumber:=$audit.Page
			$eAudit.stmpPage:=cs:C1710.sfw_stmp.me.build(Date:C102($audit.Page_Date))
			$eAudit.supervisor:=$audit.Supervisor  //  TODO : Change to createdBy
			$eAudit.stmpCreationDate:=$audit.CreationDateTimeStamp
			$eAudit.title:=$audit.LogTitle
			$eAudit.storageFilename:=$audit.StoragedFilename
			$eAudit.type:=Split string:C1554($audit.Book; "\r"; sk trim spaces:K86:2).join("\r")="Internal Audits" ? "Internal" : "External"
			
			$eAudit.auditReport:=WP New:C1317()
			
			$eAudit.activities:=New object:C1471()
			$eAudit.activities.collection:=New collection:C1472()
			
			$eAudit.auditTeam:=New object:C1471()
			$eAudit.auditTeam.teamMembers:=New collection:C1472()
			
			$eAudit.document:=New object:C1471()
			$_documents:=$documents.query("PrimaryKeyValue=:1"; String:C10($audit.Page))
			
			Case of 
				: ($_documents.length=0)
					
				: ($_documents.length=1)
					
					$document:=$_documents[0]
					
					$doc:=New object:C1471
					
					$doc.code:=$document.DocCode
					$doc.creationDateTimeStamp:=$document.CreationDateTimeStamp
					$doc.documentPath:=$document.DocumentPath
					$doc.sourcePath:=$document.SourcePath
					$doc.description:=$document.DocDescription
					$doc.approvalDate:=!00-00-00!
					$doc.approvedBy:=""
					$doc.isApproved:=False:C215
					
					$report:=Folder:C1567(fk data folder:K87:12).file("DataJson/LogBookDocs/"+String:C10($document.UniqueID+$document.PrimaryKeyValue))
					If ($report.exists)
						
						var $blob : Blob
						DOCUMENT TO BLOB:C525($report.platformPath; $blob)
						
						$doc.blob:=$blob
						
					End if 
					
					$eAudit.document:=$doc
					
				Else 
					TRACE:C157
					
/*
For each ($document; $_documents)
$doc:=New object
				
$doc.code:=$document.DocCode
$doc.creationDateTimeStamp:=$document.CreationDateTimeStamp
$doc.documentPath:=$document.DocumentPath
$doc.sourcePath:=$document.SourcePath
$doc.description:=$document.DocDescription
$doc.approvalDate:=!00-00-00!
$doc.approvedBy:=""
$doc.isApproved:=False
				
				
$report:=Folder(fk data folder).file("DataJson/LogBookDocs/"+String($document.UniqueID+$document.PrimaryKeyValue))
If ($report.exists)
				
C_BLOB($blob)
DOCUMENT TO BLOB($report.platformPath; $blob)
				
$doc.blob:=$blob
				
End if 
				
$eAudit.attachedDocuments.documents.push($doc)
				
End for each 
*/
					
			End case 
			
			$res:=$eAudit.save()
			If (Not:C34($res.success))
				TRACE:C157
			End if 
			
		End if 
		
	End for each 
	
End if 
