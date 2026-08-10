//%attributes = {"executedOnServer":true}


//ManagementReview

var $eManagementReview : cs:C1710.ManagementReviewEntity

$managementReview_log:=Folder:C1567(fk data folder:K87:12).file("DataJson/log_book_export.json")

If ($managementReview_log.exists)
	$managementReviews:=JSON Parse:C1218($managementReview_log.getText())
	
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
					
					$report:=Folder:C1567(fk data folder:K87:12).file("DataJson/LogBookDocs/"+String:C10($document.UniqueID+$document.PrimaryKeyValue))
					If ($report.exists)
						
						var $blob : Blob
						DOCUMENT TO BLOB:C525($report.platformPath; $blob)
						
						$doc.blob:=$blob
						
					End if 
					
					$eManagementReview.document:=$doc
					
				Else 
					TRACE:C157
					
			End case 
			
			$res:=$eManagementReview.save()
			If (Not:C34($res.success))
				TRACE:C157
			End if 
			
		End if 
		
	End for each 
	
End if 
