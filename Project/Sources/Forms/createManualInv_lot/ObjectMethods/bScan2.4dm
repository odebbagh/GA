Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		var $profileCheck : Object
		var $result : Object
		
		$result:=cs:C1710.Util_ScannerManager.me.resolveStaffFromScanOrRequest()
		
		If ($result.cancelled)
			return 
		End if 
		
		If (Not:C34($result.success))
			Case of 
				: ($result.failureReason="codeNotFound")
					cs:C1710.sfw_dialog.me.alert("The user code entered does not correspond to any existing user.")
				: ($result.failureReason="barcodeNotFound")
					cs:C1710.sfw_dialog.me.alert("The scanned barcode does not correspond to any existing user.")
				: ($result.failureReason="noUserAccount")
					cs:C1710.sfw_dialog.me.alert("This employee does not have an application user account.")
				Else 
					cs:C1710.sfw_dialog.me.alert("Unable to identify the user.")
			End case 
			return 
		End if 
		
		$profileCheck:=Staff_isInUserProfile($result.staff.code; "Rec")
		If (Not:C34($profileCheck.isInProfile))
			cs:C1710.sfw_dialog.me.alert("This user is not part of the Receiving profile and cannot be set as Received By.")
			return 
		End if 
		
		Form:C1466.inventory_e.UUID_Staff:=$result.staff.UUID
		Form:C1466.receivedBy:=$result.staff.code
		
	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(Self:C308->); 9000; 9019))
		
	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case 
