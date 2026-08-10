

Case of 
		
		
	: (Form event code:C388=On Clicked:K2:4)
		
		$notApprovedDocuments:=Form:C1466.current_item.documents.documentsCollection.query("isApproved =:1"; False:C215)
		If ($notApprovedDocuments.length=0)
			cs:C1710.Util_ScannerManager.me.UserApprovalByScanning(Form:C1466.current_item)
			
		Else 
			cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff(""; "There is "+String:C10($notApprovedDocuments.length)+" document that has not been approved yet!"))
			Form:C1466.current_item.isApproved:=False:C215
		End if 
		
End case 