

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		$LocalFile:=Temporary folder:C486+Folder separator:K24:12+Form:C1466.current_item.spec
		BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.current_item.publishedDocumentBlob)
		OPEN URL:C673($LocalFile; *)
		
End case 