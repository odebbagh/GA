

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		If (Form:C1466.details.docPath#"")
			$LocalFile:=Temporary folder:C486+Folder separator:K24:12+Form:C1466.details.docPath
		Else 
			$LocalFile:=Temporary folder:C486+Folder separator:K24:12+Form:C1466.details.docName
		End if 
		If (Form:C1466.type="Reject Form")
			If (BLOB size:C605(Form:C1466.details.blob)#0)
				BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.details.blob)
				
			Else 
				Form:C1466.details.blob:=_ga_getQCRejectNotice()
				BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.details.blob)
			End if 
		End if 
		
		OPEN URL:C673($LocalFile; *)
		
End case 