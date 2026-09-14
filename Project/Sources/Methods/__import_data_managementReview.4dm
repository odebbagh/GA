//%attributes = {"executedOnServer":true}


//ManagementReview

var $eManagementReview : cs:C1710.ManagementReviewEntity
var $attachResult : Object
var $existingReview : cs:C1710.ManagementReviewEntity
var $fwDoc : cs:C1710.sfw_DocumentEntity

$managementReview_log:=Folder:C1567(fk data folder:K87:12).file("DataJson/log_book_export.json")

If ($managementReview_log.exists)
	$managementReviews:=JSON Parse:C1218($managementReview_log.getText())
	
	// Purpose: Remove framework files + rows for existing reviews before TRUNCATE — otherwise sfw_Document UUID_target orphans remain pointing at deleted ManagementReview UUIDs.
	// modified by 4D/PS [2026-may-08]
	For each ($existingReview; ds:C1482.ManagementReview.all())
		For each ($fwDoc; ds:C1482.sfw_Document.query("UUID_target = :1"; $existingReview.UUID))
			$fwDoc.deleteFile()
			$fwDoc.drop()
		End for each 
	End for each 
	
	TRUNCATE TABLE:C1051([ManagementReview:62])
	
	$docs:=Folder:C1567(fk data folder:K87:12).file("DataJson/docServerIndex_export.json")
	$count:=0
	If ($docs.exists)
		
		$documents:=JSON Parse:C1218($docs.getText()).query("TableNumber=:1"; 39)
		
	End if 
	
	
	For each ($managementReview; $managementReviews)
		If (Split string:C1554($managementReview.Book; "\r"; sk trim spaces:K86:2).join("\r")="Management Review")
			
			$eManagementReview:=ds:C1482.ManagementReview.new()
			$eManagementReview.managementReviewNumber:=$managementReview.Page
			$eManagementReview.stmpPage:=cs:C1710.sfw_stmp.me.build(Date:C102($managementReview.Page_Date))
			$eManagementReview.createdBy:=$managementReview.Supervisor
			$eManagementReview.stmpCreationDate:=$managementReview.CreationDateTimeStamp
			$eManagementReview.title:=$managementReview.LogTitle
			
			$eManagementReview.document:=New object:C1471()
			$_documents:=$documents.query("PrimaryKeyValue=:1"; String:C10($managementReview.Page))
			
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
					// Purpose: Binary payload goes through sfw_Document + _ga_managementReview_replaceAtt (same as UI upload), not document.blob.
					// modified by 4D/PS [2026-may-08]
					$doc.UUID_sfwDocument:=""
					$doc.extension:=""
					
					$report:=Folder:C1567(fk data folder:K87:12).file("DataJson/LogBookDocs/"+String:C10($document.UniqueID+$document.PrimaryKeyValue))
					
					$eManagementReview.document:=$doc
					
					$res:=$eManagementReview.save()
					If ($res.success=False:C215)
						TRACE:C157
					Else 
						
						If ($report.exists)
							
							$attachResult:=_ga_managementReview_replaceAtt($eManagementReview; $report.platformPath)
							
							If ($attachResult.success=False:C215)
								TRACE:C157
							Else 
								
								$res:=$eManagementReview.save()
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
			// modified by 4D/PS [2026-may-08]
			If ($_documents.length#1)
				
				$res:=$eManagementReview.save()
				If ($res.success=False:C215)
					TRACE:C157
				End if 
				
			End if 
			
		End if 
		
	End for each 
	
End if 
