//%attributes = {"executedOnServer":true}


//Audit
var $eAudit : cs:C1710.AuditEntity
var $attachResult : Object
var $existingAudit : cs:C1710.AuditEntity
var $fwDoc : cs:C1710.sfw_DocumentEntity

$audit_log:=Folder:C1567(fk data folder:K87:12).file("DataJson/log_book_export.json")

If ($audit_log.exists)
	$audits:=JSON Parse:C1218($audit_log.getText())
	
	// Purpose: Remove framework files + rows for existing audits before TRUNCATE — otherwise sfw_Document UUID_target orphans remain pointing at deleted Audit UUIDs.
	// modified by 4D/PS [2026-may-26]
	For each ($existingAudit; ds:C1482.Audit.all())
		For each ($fwDoc; ds:C1482.sfw_Document.query("UUID_target = :1"; $existingAudit.UUID))
			$fwDoc.deleteFile()
			$fwDoc.drop()
		End for each 
	End for each 
	
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
					// Purpose: Binary payload goes through sfw_Document + _ga_audit_replaceAttachment (same as UI upload), not document.blob.
					// modified by 4D/PS [2026-may-26]
					$doc.UUID_sfwDocument:=""
					$doc.extension:=""
					
					$report:=Folder:C1567(fk data folder:K87:12).file("DataJson/LogBookDocs/"+String:C10($document.UniqueID+$document.PrimaryKeyValue))
					
					$eAudit.document:=$doc
					
					$res:=$eAudit.save()
					If ($res.success=False:C215)
						TRACE:C157
					Else 
						
						If ($report.exists)
							
							$attachResult:=_ga_audit_replaceAttachment($eAudit; $report.platformPath)
							
							If ($attachResult.success=False:C215)
								TRACE:C157
							Else 
								
								$res:=$eAudit.save()
								If ($res.success=False:C215)
									TRACE:C157
								End if 
								
							End if 
							
						End if 
						
					End if 
					
				Else 
					TRACE:C157
					
			End case 
			
			// Purpose: Single-document imports already saved inside the branch (record + attachment linkage).
			// modified by 4D/PS [2026-may-26]
			If ($_documents.length#1)
				
				$res:=$eAudit.save()
				If ($res.success=False:C215)
					TRACE:C157
				End if 
				
			End if 
			
		End if 
		
	End for each 
	
End if 
