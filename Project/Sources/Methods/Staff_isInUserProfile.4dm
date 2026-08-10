//%attributes = {}
// Resolves a staff member by code, links to sfw_User, and checks profile membership.
#DECLARE($staffCode : Text; $profileIdent : Text)->$result : Object

var $eStaff : cs:C1710.StaffEntity
var $eUser : cs:C1710.sfw_UserEntity
var $profileIdents : Collection

$result:=New object:C1471(\
	"success"; False:C215; \
	"isInProfile"; False:C215; \
	"staff"; Null:C1517; \
	"user"; Null:C1517; \
	"profileIdents"; New collection:C1472(); \
	"failureReason"; ""\
	)

If ($staffCode="") | ($profileIdent="")
	$result.failureReason:="missingParameter"
	return $result
End if 

$eStaff:=ds:C1482.Staff.query("code = :1"; $staffCode).first()

If ($eStaff=Null:C1517)
	$result.failureReason:="staffNotFound"
	return $result
End if 

$result.staff:=$eStaff
$eUser:=$eStaff.user

If ($eUser=Null:C1517)
	$result.failureReason:="userNotFound"
	return $result
End if 

$result.user:=$eUser
$result.success:=True:C214

$profileIdents:=$eUser.userInscriptions.userProfile.ident
$result.profileIdents:=$profileIdents.copy()

If ($profileIdents.indexOf($profileIdent)#-1)
	$result.isInProfile:=True:C214
Else 
	If (Bool:C1537($eUser.accesses.asDesigner)) && ($profileIdent="admin")
		$result.isInProfile:=True:C214
	End if 
End if 
