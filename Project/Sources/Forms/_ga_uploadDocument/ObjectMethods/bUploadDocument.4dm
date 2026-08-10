Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		var $vhDoc : Text
		var $blob : Blob
		ARRAY TEXT:C222($Apaths; 0)
		
		$vhDoc:=Select document:C905(""; "*"; "select document"; $Apaths)
		If (OK=1)
			DOCUMENT TO BLOB:C525(Document; $blob)
			Form:C1466.details.blob:=$blob
			Form:C1466.details.docPath:=$vhDoc
			OBJECT SET TITLE:C194(*; "fileName"; $vhDoc)
			
			Form:C1466.documentHasChanged:=True:C214
		End if 
		
		
End case 