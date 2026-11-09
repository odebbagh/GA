//%attributes = {}
// Resolves a staff member by code, links to sfw_User, and checks profile membership.
#DECLARE($staffCode : Text; $profileIdent : Text)->$result : Object

var $eStaff : cs:C1710.StaffEntity
var $eUser : cs:C1710.sfw_UserEntity
var $profileIdents : Collection
var $accepted : Collection
var $ident : Variant

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

// The checks in the app ask for "Rec", "Q", "Eng", "p" and "cs"/"CS": the idents of the
// profiles first set up by hand. The profiles the application now creates
// (_import_userProfiles, goldenAltos_definition) use other idents, so each requested ident
// is also satisfied by its equivalents below. The comparison ignores case.
$accepted:=New collection:C1472(Lowercase:C14($profileIdent))
Case of 
	: ($accepted[0]="rec")
		$accepted.push("rc"; "sr")  // Receiving, Shipper & receiver
	: ($accepted[0]="q")
		$accepted.push("qa"; "qi"; "qm"; "qs")  // Quality Assurance, Inspector, Manager, Supervisor
	: ($accepted[0]="eng")
		$accepted.push("en")  // Engineering
	: ($accepted[0]="p")
		$accepted.push("pr"; "pc"; "pm"; "ps")  // Production, Production Control, Manager, Supervisor
End case 
For each ($ident; $profileIdents) Until ($result.isInProfile)
	$result.isInProfile:=($accepted.indexOf(Lowercase:C14(String:C10($ident)))#-1)
End for each 
If (Not:C34($result.isInProfile))
	If (Bool:C1537($eUser.accesses.asDesigner)) && ($profileIdent="admin")
		$result.isInProfile:=True:C214
	End if 
End if 
