Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		var $vhDoc : Text
		var $blob : Blob
		ARRAY TEXT:C222($Apaths; 0)
		
		$vhDoc:=Select document:C905(""; "*"; "select document"; $Apaths)
		If (OK=1)
			DOCUMENT TO BLOB:C525(Document; $blob)
			Form:C1466.details.blob:=$blob
			
			OBJECT SET TITLE:C194(*; "fileName"; $vhDoc)
			
			Form:C1466.details.approvalDate:=!00-00-00!
			Form:C1466.details.approvedBy:=""
			Form:C1466.details.isApproved:=False:C215
			Form:C1466.documentHasChanged:=True:C214
			
			$buffer:=New object:C1471()
			$buffer.event:="modifyDocument"
			$buffer.label:="New Document uploaded"
			$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
			Form:C1466.bufferOfEvents.push($buffer)
			
		End if 
		
		
End case 