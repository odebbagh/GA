Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		For each ($lot; Form:C1466.selectedLots)
			$lot.UUID_Job:=Form:C1466.UUID_Job
			
			$res:=$lot.save()
			
			If (Not:C34($res.success))
				TRACE:C157
			End if 
		End for each 
		
		ACCEPT:C269
End case 