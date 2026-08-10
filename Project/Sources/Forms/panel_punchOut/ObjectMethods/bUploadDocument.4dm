Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		If (Form:C1466.currentStep#Null:C1517)
			var $vhDoc : Text
			var $blob : Blob
			ARRAY TEXT:C222($Apaths; 0)
			
			$vhDoc:=Select document:C905(""; "*"; "select document"; $Apaths)
			If (OK=1)
				DOCUMENT TO BLOB:C525(Document; $blob)
				Form:C1466.currentStep.rejectionBlob:=$blob
				
				OBJECT SET TITLE:C194(*; "fileName"; $vhDoc)
				
				
				$res:=Form:C1466.currentStep.save()
				
				If ($res.success)
					cs:C1710.panel_punchOut.me._activate_save_cancel_button()
				End if 
				
			End if 
		End if 
		
End case 