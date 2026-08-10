//%attributes = {}
// Resolves staff via barcode scan or manual user code entry for the holdLot dialog.

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

Form:C1466.staffCode:=$result.staff.code
Form:C1466.performedBy:=$result.staff.code+" - "+$result.staff.firstName+" "+$result.staff.lastName
