

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		$doc:=WP New:C1317()
		
		$range:=WP Text range:C1341($doc; wk end text:K81:164; wk end text:K81:164)
		
		WP Insert picture:C1437($range; Form:C1466.barCode; wk append:K81:179)
		
		PRINT SETTINGS:C106
		
		WP PRINT:C1343($doc)
		
		//WRITE PICTURE FILE(""; Form.barCode)
		
End case 
