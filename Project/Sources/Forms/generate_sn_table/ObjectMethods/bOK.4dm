Case of 
	: (Form:C1466.itemsNumber=0)
		ALERT:C41("Value has to be superior to 0.")
	
	: (Num:C11(Form:C1466.customerCount)>0) && (Form:C1466.itemsNumber#Num:C11(Form:C1466.customerCount))
		// partial serialization is real (a few customers serialize part of a lot): allowed, after a warning
		If (cs:C1710.sfw_dialog.me.confirm("The customer count is "+String:C10(Form:C1466.customerCount)+": serialize "+String:C10(Form:C1466.itemsNumber)+" unit(s) instead?"; "Serialize "+String:C10(Form:C1466.itemsNumber); "Back"))
			ACCEPT:C269
		End if 
	
	Else 
		ACCEPT:C269
End case 
