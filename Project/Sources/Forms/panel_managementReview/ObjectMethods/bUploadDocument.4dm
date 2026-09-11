Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		// Purpose: Pick a file, persist bytes via sfw_Document (DocumentData), and refresh UI — keeps blobs off ManagementReview.document (legacy blob field cleared in _ga_managementReview_replaceAtt).
		// modified by 4D/PS [2026-may-08]
		var $pickLabel : Text
		var $file : 4D:C1709.File
		var $attachResult : Object
		
		ARRAY TEXT:C222($Apaths; 0)
		
		$pickLabel:=Select document:C905(""; "*"; "select document"; $Apaths)
		If (OK=1)
			
			$file:=File:C1566(Document; fk platform path:K87:2)
			$attachResult:=_ga_managementReview_replaceAtt(Form:C1466.current_item; $file.platformPath)
			
			If ($attachResult.success=True:C214)
				
				OBJECT SET TITLE:C194(*; "fileName"; ($file.extension#"") ? ($file.name+"."+$file.extension) : $file.name)
				cs:C1710.panel_managementReview.me._activate_save_cancel_button()
				
			Else 
				
				cs:C1710.sfw_dialog.me.alert(String:C10($attachResult.error))
				
			End if 
			
		End if 
		
		
End case 