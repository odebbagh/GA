Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		For each ($poLine; Form:C1466.selectedPoLines)
			$poLine.UUID_Job:=Form:C1466.UUID_Job
			
			$res:=$poLine.save()
			
			If (Not:C34($res.success))
				TRACE:C157
			End if 
		End for each 
		
		ACCEPT:C269
End case 