

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		$file:=Form:C1466.details.sourcePath#"" ? Form:C1466.details.sourcePath : "Document"
		$LocalFile:=Temporary folder:C486+Folder separator:K24:12+$file
		If (Form:C1466.details.blob#Null:C1517)
			BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.details.blob)
			OPEN URL:C673($LocalFile; *)
		Else 
			
		End if 
		
End case 