// ga_operator
// The operator of a lot step (legacy IN_Oper at punch in, Operator at punch out): scanned or typed
// with the scanner prompt, checked against the users, stored as the employee code. The Punch In
// and Punch OUT entries make it mandatory (validation rules); the Start buttons ask for it.
	
singleton Class constructor
	
Function ask()->$staff : 4D:C1709.Entity
	// the operator's code, scanned or typed; Null when cancelled or unknown (with the reason shown)
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
	$staff:=$result.staff
	
Function label($code : Text)->$label : Text
	// "001730 - First Last", or the code alone when nobody has it
	var $staff : 4D:C1709.Entity
	
	$label:=$code
	If ($code="")
		return 
	End if 
	$staff:=ds:C1482.Staff.query("code = :1"; $code).first()
	If ($staff#Null:C1517)
		$label:=$code+" - "+String:C10($staff.firstName)+" "+String:C10($staff.lastName)
	End if 
	
