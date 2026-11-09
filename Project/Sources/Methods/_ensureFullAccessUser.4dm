//%attributes = {}
// _ensureFullAccessUser -> Object
// Creates (or repairs) the Omar Debbagh account, which must always be there with full
// access whatever the import file happens to contain. Called at the end of
// _import_users, and safe to run on its own at any time.
//
// WHAT "FULL ACCESS" MEANS HERE
//   Visions and entries are both granted by the same three-tier rule
//   (sfw_toolbar.pupVisions / sfw_definitionEntry.isDisplayable):
//     1. the vision/entry names one of the user's profiles in its own allowedProfiles
//     2. or, failing that, a profile of the user lists it in
//        moreData.allowedVisions / moreData.allowedEntries
//     3. and no profile of the user lists it in restrictVisions / restrictEntries
//
//   So the account is given three memberships:
//     admin      - almost every vision and entry in this application is declared
//                  setAllowedProfiles("admin"), so this alone covers tier 1
//     FULLACCESS - a profile carrying EVERY vision and EVERY entry ident, read from the
//                  definition at runtime. This covers tier 2, i.e. anything that is
//                  gated on some other profile now or later, and is re-read on every run
//                  so a newly added vision or entry is picked up
//     designer   - set through the asDesigner setter, which also creates the designer
//                  inscription and unlocks the developer-only tools
//   None of the three carries restrictVisions / restrictEntries, so nothing is taken
//   back at tier 3.
//
// The account is NOT flagged with a temporary password: it is a deliberate, known
// full-access account, and a temporary flag would also stop it approving buy orders
// (cs.Util_Authorizer refuses accounts still on a temporary password).

#DECLARE->$result : Object

var $login : Text
var $staffCode : Text
var $password : Text
var $fullAccessIdent : Text

$login:="odebbagh"
$staffCode:="ODEBBAGH"
$password:="GoldenAltos1!"
$fullAccessIdent:="FULLACCESS"

var $eUser : cs:C1710.sfw_UserEntity
var $eStaff : cs:C1710.StaffEntity
var $eAdminProfile : cs:C1710.sfw_UserProfileEntity
var $eFullProfile : cs:C1710.sfw_UserProfileEntity
var $allVisions : Collection
var $allEntries : Collection
var $info : Object

$result:=New object:C1471("success"; False:C215; "created"; False:C215; "messages"; New collection:C1472)

//---the account
$eUser:=ds:C1482.sfw_User.query("login = :1"; $login).first()

If ($eUser=Null:C1517)
	$eUser:=ds:C1482.sfw_User.new()
	$eUser.UUID:=Generate UUID:C1066
	$eUser.login:=$login
	$result.created:=True:C214
End if

$eUser.firstName:="Omar"
$eUser.lastName:="Debbagh"
$eUser.isInactive:=False:C215

//a complete accesses.password block, not temporary: the login paths read
//accesses.password.hash without guarding, and a temporary flag would block approvals
$eUser.accesses:=($eUser.accesses=Null:C1517) ? New object:C1471 : $eUser.accesses
$eUser.accesses.password:=($eUser.accesses.password=Null:C1517) ? New object:C1471 : $eUser.accesses.password
$eUser.accesses.password.hash:=Generate password hash:C1533($password; cs:C1710.sfw_passwordManager.me.hashOptions)
$eUser.accesses.password.temporary:=False:C215
$eUser.accesses.password.lastChange:=cs:C1710.sfw_stmp.me.now()

$eUser.moreData:=($eUser.moreData=Null:C1517) ? New object:C1471 : $eUser.moreData
$eUser.moreData.createdBy:="_ensureFullAccessUser"
$eUser.moreData.forcedAccount:=True:C214

$info:=$eUser.save()
If (Not:C34($info.success))
	$result.messages.push("account save failed: "+JSON Stringify:C1217($info))
	return
End if

//---the person behind the account, so the scanner and the approval flow can find it
$eStaff:=ds:C1482.Staff.query("UUID_User = :1"; $eUser.UUID).first()

If ($eStaff=Null:C1517)
	$eStaff:=ds:C1482.Staff.query("code = :1"; $staffCode).first()
End if

If ($eStaff=Null:C1517)
	$eStaff:=ds:C1482.Staff.new()
	$eStaff.UUID:=Generate UUID:C1066
	$eStaff.codeID:=Num:C11(ds:C1482.Staff.all().max("codeID"))+1
	$eStaff.code:=$staffCode
	$eStaff.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$eStaff.contactDetails:=New object:C1471("communications"; New collection:C1472())
End if

$eStaff.UUID_User:=$eUser.UUID
$eStaff.firstName:="Omar"
$eStaff.lastName:="Debbagh"
$eStaff.inactive:=False:C215
$eStaff.terminated:=False:C215

$eStaff.moreData:=($eStaff.moreData=Null:C1517) ? New object:C1471 : $eStaff.moreData
$eStaff.moreData.createdBy:="_ensureFullAccessUser"
$eStaff.moreData.login:=$login
If (String:C10($eStaff.moreData.barcodeData)="")
	$eStaff.moreData.barcodeData:=String:C10($eStaff.codeID; "0000000000")
End if

$info:=$eStaff.save()
If (Not:C34($info.success))
	$result.messages.push("staff save failed: "+JSON Stringify:C1217($info))
End if

//---tier 1: the admin profile, which almost everything in this application is gated on
$eAdminProfile:=cs:C1710.sfw_userManager.me.getAdmistratorProfil()
_ensureUserInscription($eUser; $eAdminProfile; "_ensureFullAccessUser")

//---tier 2: a profile listing every vision and every entry, re-read from the definition
//   on each run so anything added later is covered
$allVisions:=cs:C1710.sfw_definition.me.visions.query("label # :1"; "-").extract("ident")
$allEntries:=cs:C1710.sfw_definition.me.entries.query("not(label in :1)"; New collection:C1472(""; "-")).extract("ident")

$eFullProfile:=ds:C1482.sfw_UserProfile.query("ident = :1"; $fullAccessIdent).first()
If ($eFullProfile=Null:C1517)
	$eFullProfile:=ds:C1482.sfw_UserProfile.new()
	$eFullProfile.UUID:=Generate UUID:C1066
	$eFullProfile.ident:=$fullAccessIdent
	$eFullProfile.name:="Full access"
End if

$eFullProfile.moreData:=($eFullProfile.moreData=Null:C1517) ? New object:C1471 : $eFullProfile.moreData
$eFullProfile.moreData.createdBy:="_ensureFullAccessUser"
$eFullProfile.moreData.allowedVisions:=$allVisions
$eFullProfile.moreData.allowedEntries:=$allEntries
//nothing is taken back at tier 3
OB REMOVE:C1226($eFullProfile.moreData; "restrictVisions")
OB REMOVE:C1226($eFullProfile.moreData; "restrictEntries")

$info:=$eFullProfile.save()
If ($info.success)
	_ensureUserInscription($eUser; $eFullProfile; "_ensureFullAccessUser")
Else
	$result.messages.push("full access profile save failed: "+JSON Stringify:C1217($info))
End if

//---designer. The setter also creates the designer inscription, so it needs a saved
//   account, which it has by now.
If (Not:C34(Bool:C1537($eUser.asDesigner)))
	$eUser.asDesigner:=True:C214
	$eUser.save()
End if

$result.success:=True:C214
$result.login:=$login
$result.password:=$password
$result.messages.push(($result.created ? "created" : "updated")+" "+$login\
	+" - admin + "+$fullAccessIdent+" + designer"\
	+" | visions: "+String:C10($allVisions.length)\
	+" | entries: "+String:C10($allEntries.length))
