
// Purpose: Header QA approval requires every attached document to be approved first.
// modified by 4D/PS [2026-october-05]

Case of 
	
		
	: (Form event code:C388=On Clicked:K2:4)
		
		If (Form:C1466.current_item=Null:C1517)
			return 
		End if 
		$notApprovedDocuments:=New collection:C1472()
		If (Form:C1466.current_item.documents#Null:C1517) && (Form:C1466.current_item.documents.documentsCollection#Null:C1517)
			$notApprovedDocuments:=Form:C1466.current_item.documents.documentsCollection.query("isApproved =:1"; False:C215)
		End if 
		If ($notApprovedDocuments.length=0)
			cs:C1710.Util_ScannerManager.me.UserApprovalByScanning(Form:C1466.current_item)
			
		Else 
			cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff(""; "There is "+String:C10($notApprovedDocuments.length)+" document that has not been approved yet!"))
			Form:C1466.current_item.isApproved:=False:C215
		End if 
		
End case 
