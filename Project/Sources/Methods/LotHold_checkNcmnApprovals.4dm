//%attributes = {}
// Returns true when the current hold ON event has an NCMN form with all four approvals checked
// (Customer Service, Engineering, QA/QC, Production). Used to control taking a lot off hold.
#DECLARE($lot : 4D:C1709.Entity)->$allApproved : Boolean

var $holdOn : Object
var $ncmn : Object

$allApproved:=False:C215

If ($lot=Null:C1517)
	return $allApproved
End if

$holdOn:=LotHoldForm_getCurrentHoldOn($lot)

If ($holdOn=Null:C1517)
	// no identifiable hold ON event to control: keep legacy behavior and allow
	$allApproved:=True:C214
	return $allApproved
End if

$ncmn:=LotHoldForm_resolveFormForHold($lot; "NCMN"; $holdOn)

If ($ncmn=Null:C1517)
	// no NCMN saved for this hold: approvals cannot be checked
	return $allApproved
End if

$allApproved:=Bool:C1537($ncmn.approvalCustomerService) && \
Bool:C1537($ncmn.approvalEngineering) && \
Bool:C1537($ncmn.approvalQAQC) && \
Bool:C1537($ncmn.approvalProduction)
