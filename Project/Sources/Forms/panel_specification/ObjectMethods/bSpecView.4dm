Case of 
	
	: (Form event code:C388=On Clicked:K2:4)
	
		// the GAF forms are stored as sfw_Document (_import_specFiles), not in publishedDocumentBlob:
		// ga_stepDocuments.openSpecFile opens whichever exists, with its extension
		var $problem : Text
		$problem:=cs:C1710.ga_stepDocuments.me.openSpecFile(Form:C1466.current_item)
		If ($problem#"")
			cs:C1710.sfw_dialog.me.alert($problem)
		End if 
	
End case 
