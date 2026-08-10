//%attributes = {}
// Resolves staff via barcode or user code, validates QA profile, applies QA signoff on lot step.
#DECLARE($lotStep : 4D:C1709.Entity; $qaRejected : Boolean)->$result : Object

var $scanResult : Object
var $profileCheck : Object
var $display : Text

$result:=New object:C1471("success"; False:C215; "cancelled"; False:C215; "display"; "")

If ($lotStep=Null:C1517)
	return $result
End if 

$scanResult:=cs:C1710.Util_ScannerManager.me.resolveStaffFromScanOrRequest()

If ($scanResult.cancelled)
	$result.cancelled:=True:C214
	return $result
End if 

If (Not:C34($scanResult.success))
	Case of 
		: ($scanResult.failureReason="codeNotFound")
			cs:C1710.sfw_dialog.me.alert("The user code entered does not correspond to any existing user.")
		: ($scanResult.failureReason="barcodeNotFound")
			cs:C1710.sfw_dialog.me.alert("The scanned barcode does not correspond to any existing user.")
		: ($scanResult.failureReason="noUserAccount")
			cs:C1710.sfw_dialog.me.alert("This employee does not have an application user account.")
		Else 
			cs:C1710.sfw_dialog.me.alert("Unable to identify the user.")
	End case 
	return $result
End if 

$profileCheck:=Staff_isInUserProfile($scanResult.staff.code; "Q")

If (Not:C34($profileCheck.isInProfile))
	cs:C1710.sfw_dialog.me.alert("This user is not part of the QA/QC profile and cannot sign off this step.")
	return $result
End if 

$lotStep.qaRejected:=$qaRejected
$lotStep.approvedBy:=$scanResult.staff.code
$lotStep.isApproved:=Not:C34($qaRejected)
$lotStep.stmpApproval:=cs:C1710.sfw_stmp.me.now()
$display:=String:C10($scanResult.staff.code)
$result.success:=True:C214
$result.display:=$display
$result.staff:=$scanResult.staff

return $result
