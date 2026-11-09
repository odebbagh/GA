//%attributes = {}
// _newStaffFor($eUser; $legacyEmployee; $importTag; $nextCodeID_ptr) -> StaffEntity
// Builds (but does not save) the Staff row that belongs to $eUser, and links it back
// through UUID_User.
//
// $legacyEmployee is the matching employees[] entry from users_export.json, or Null when
// the account has no employee behind it (the old application's role logins: CFO,
// CustomerService, CS1..CS4, and the initials accounts). In that case the Staff row is
// still created, named after the account, so the 1:1 link always holds.
//
// $nextCodeID_ptr points at the caller's running codeID counter, so codes stay unique
// across both passes without re-querying the table every time.

#DECLARE($eUser : cs:C1710.sfw_UserEntity; $legacyEmployee : Object; $importTag : Text; \
$nextCodeID_ptr : Pointer)->$eStaff : cs:C1710.StaffEntity

var $code : Text

$eStaff:=ds:C1482.Staff.new()
$eStaff.UUID:=Generate UUID:C1066
$eStaff.UUID_User:=$eUser.UUID
$eStaff.stmpCreation:=cs:C1710.sfw_stmp.me.now()

//---code: keep the legacy employee code, it is the value people know and what the old
//   application prompts for as v_emp_code. codeID follows it when it is numeric and
//   free, otherwise it continues the local sequence.
$code:=""
If ($legacyEmployee#Null:C1517)
	$code:=String:C10($legacyEmployee.employeeCode)
End if

If ($code#"")
	$eStaff.code:=$code
	If (String:C10(Num:C11($code))=$code) && (ds:C1482.Staff.query("codeID = :1"; Num:C11($code)).length=0)
		$eStaff.codeID:=Num:C11($code)
	Else
		$eStaff.codeID:=$nextCodeID_ptr->
		$nextCodeID_ptr->:=$nextCodeID_ptr->+1
	End if
Else
	//---no employee behind this account: mint a code from the sequence, as
	//   StaffEntity.loadAfterCreation does for a hand-created record
	$eStaff.codeID:=$nextCodeID_ptr->
	$nextCodeID_ptr->:=$nextCodeID_ptr->+1
	$eStaff.code:=String:C10($eStaff.codeID; "00000#")
End if

$eStaff.firstName:=$eUser.firstName
$eStaff.lastName:=$eUser.lastName
$eStaff.inactive:=$eUser.isInactive
$eStaff.terminated:=False:C215

$eStaff.moreData:=New object:C1471(\
	"importedBy"; $importTag; \
	"importedAt"; cs:C1710.sfw_stmp.me.now(); \
	"login"; $eUser.login\
	)

$eStaff.contactDetails:=New object:C1471("communications"; New collection:C1472())

//---Defensive: _import_users only ever passes a real employee, so this is a guard
//   rather than a path that gets used. The row is still valid without it, just bare.
If ($legacyEmployee=Null:C1517)
	$eStaff.moreData.source:="accountWithoutEmployee"
	return
End if

$eStaff.moreData.source:="employee"

$eStaff.firstName:=String:C10($legacyEmployee.firstName)
$eStaff.lastName:=String:C10($legacyEmployee.lastName)
$eStaff.terminated:=Bool:C1537($legacyEmployee.terminated)
$eStaff.inactive:=Bool:C1537($legacyEmployee.terminated)
$eStaff.citizenShipStatus:=String:C10($legacyEmployee.citizenShipStatus)

//---dates go through the computed setters, which convert to the stmp integers
$eStaff.hireDate:=Date:C102($legacyEmployee.hireDate)
$eStaff.terminationDate:=Date:C102($legacyEmployee.terminationDate)
$eStaff.retrainDate:=Date:C102($legacyEmployee.retrainDate)

//---division: matched by name, created when missing
If (String:C10($legacyEmployee.division)#"")
	var $eDivision : cs:C1710.DivisionEntity
	$eDivision:=ds:C1482.Division.query("name = :1"; String:C10($legacyEmployee.division)).first()
	If ($eDivision=Null:C1517)
		$eDivision:=ds:C1482.Division.new()
		$eDivision.UUID:=Generate UUID:C1066
		$eDivision.name:=String:C10($legacyEmployee.division)
		$eDivision.save()
	End if
	If ($eDivision#Null:C1517)
		$eStaff.UUID_Division:=$eDivision.UUID
	End if
End if

//---contact details: the address subform and StaffEntity.email expect a collection of
//   {type; contact}, where the e-mail type is "mail"
If (String:C10($legacyEmployee.emailAddress)#"")
	$eStaff.contactDetails.communications.push(New object:C1471("type"; "mail"; "contact"; String:C10($legacyEmployee.emailAddress)))
End if
If (String:C10($legacyEmployee.telephone)#"")
	$eStaff.contactDetails.communications.push(New object:C1471("type"; "phone"; "contact"; String:C10($legacyEmployee.telephone)))
End if
If (String:C10($legacyEmployee.mobile)#"")
	$eStaff.contactDetails.communications.push(New object:C1471("type"; "mobile"; "contact"; String:C10($legacyEmployee.mobile)))
End if
If (String:C10($legacyEmployee.fax)#"")
	$eStaff.contactDetails.communications.push(New object:C1471("type"; "fax"; "contact"; String:C10($legacyEmployee.fax)))
End if

//---no column here for these, kept for reconciliation. The legacy Cert1..16 flags are
//   modelled as CertificationAssignment records in this application, so they are parked
//   rather than guessed at.
$eStaff.moreData.legacy:=New object:C1471(\
	"uniqueID"; $legacyEmployee.uniqueID; \
	"employeeCode"; $legacyEmployee.employeeCode; \
	"department"; $legacyEmployee.department; \
	"shift"; $legacyEmployee.shift; \
	"skillCode"; $legacyEmployee.skillCode; \
	"skillCodeText"; $legacyEmployee.skillCodeText; \
	"teamMembershipCode"; $legacyEmployee.teamMembershipCode; \
	"training"; $legacyEmployee.training; \
	"schedulableResource"; $legacyEmployee.schedulableResource; \
	"history"; $legacyEmployee.history; \
	"certifications"; $legacyEmployee.legacyCertifications\
	)
