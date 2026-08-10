Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Bool:C1537(Form:C1466.readOnly))
			return 
		End if 
		
		var $result : Object
		var $profileCheck : Object
		var $timestamp : Text
		var $intendedValue : Boolean
		var $approvalField : Text
		var $dateField : Text
		var $profileIdent : Text
		var $profileLabel : Text
		
		$approvalField:="approvalCustomerService"
		$dateField:="dateCustomerService"
		$profileIdent:="cs"
		$profileLabel:="Customer Service"
		
		$intendedValue:=Bool:C1537(Form:C1466[$approvalField])
		Form:C1466[$approvalField]:=Not:C34($intendedValue)  // revert to initial value
		
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
		
		$profileCheck:=Staff_isInUserProfile($result.staff.code; $profileIdent)
		
		If (Not:C34($profileCheck.isInProfile))
			cs:C1710.sfw_dialog.me.alert("This user is not part of the "+$profileLabel+" profile and cannot validate this approval.")
			return 
		End if 
		
		Form:C1466[$approvalField]:=$intendedValue
		
		If ($intendedValue)
			$timestamp:=String:C10(Current date:C33(*); Internal date short:K1:7)+" "+String:C10(Current time:C178(*); HH MM:K7:2)
			Form:C1466[$dateField]:=$timestamp
		Else 
			Form:C1466[$dateField]:=""
		End if 
End case 
