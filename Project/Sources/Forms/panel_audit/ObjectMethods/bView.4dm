

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		$file:=Form:C1466.current_item.document.sourcePath#"" ? Form:C1466.current_item.document.sourcePath : "Audit"+"_"+"ManagementReview"+"_"+String:C10(Form:C1466.current_item.auditNumber)
		$LocalFile:=Temporary folder:C486+Folder separator:K24:12+$file
		BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.current_item.document.blob)
		OPEN URL:C673($LocalFile; *)
		
End case 