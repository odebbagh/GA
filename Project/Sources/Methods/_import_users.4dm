//%attributes = {}
// _import_users
// Imports the REAL PEOPLE from the old application into the two tables this application
// uses for them, one row each, linked:
//
//   sfw_User : the account      (login, first name, last name)
//   Staff    : the person       (code, hire/termination, division, contact details)
//   Staff.UUID_User : the link between them
//
// Source is the employees[] side of users_export.json, i.e. the old [Employees] table.
//
// The old application's own logins are NOT imported. They were never people: the 4D
// password system only ever held role accounts (CFO, CustomerService, CS1..CS4, SALES,
// QC, Inventory, p/cuser1..4, the *_template accounts) and initials-only accounts (MRB,
// ADP, LTL...), none of which carries a first or last name. They remain in
// users_export.json if they are ever needed.
//
// Input: <database folder>/project/imports/users_export.json  (from _export_users)
//
// PROFILES ARE NOT HANDLED HERE - that is managed separately. Note that the old
// application kept access on those ROLE logins, not on people, so once the logins are
// left out the only per-person signals available are division and department, which are
// carried on both rows below.
//
//===================================================================================
// THIS METHOD DELETES EVERY ACCOUNT AND STAFF ROW IT HAS EVER CREATED, then rebuilds
// them from the file. Rows are recognised as imported when they carry either
// moreData.importedBy = "_import_users" (this version) or a moreData.legacy block (what
// earlier runs of this method wrote, before the tag existed).
//
// Never deleted: the framework's own admin / designer accounts, the account you are
// logged in with, and anything created by hand. Truncating sfw_User outright would lock
// you out of the application.
//===================================================================================

var $importTag : Text
$importTag:="_import_users"

// Logins that must survive whatever else happens.
var $protectedLogins : Collection
$protectedLogins:=New collection:C1472("admin"; "administrator"; "designer"; "odebbagh")

// [Employees]Password is a stored legacy password. False = no legacy password is carried
// over and the account gets a fresh temporary one instead (see below). Set True only if
// you deliberately want it carried over (hashed, and flagged temporary so it must be
// changed on first login).
var $applyLegacyPasswords : Boolean
$applyLegacyPasswords:=False:C215

// Password given to accounts that get no legacy one.
//
// A value here = every imported account gets THIS SAME known temporary password, so you
// can sign in as any imported employee. Flagged temporary, so the application asks for a
// new one on first login. Convenient on a test database.
// ---> CLEAR IT BEFORE IMPORTING INTO A LIVE DATABASE. <---
//
// Empty = a DIFFERENT random temporary password per account, hashed and never written
// down: the accounts are complete and the application works, but nobody can sign in as
// an imported employee until an administrator resets their password. That is the right
// setting for a live import.
//
// Whatever is used has to satisfy sfw_passwordManager.ckeckPasswordRules, otherwise the
// user is stuck at the change-password step: 12 characters or more, with an uppercase,
// a lowercase, a digit and one of ! # $ % & * + - = ? ^ _ ~ @
var $sharedTemporaryPassword : Text
$sharedTemporaryPassword:="GoldenAltos1!"

//===================================================================================

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $payload : Object
var $legacyEmployee; $info : Object
var $eUser : cs:C1710.sfw_UserEntity
var $eStaff : cs:C1710.StaffEntity
var $esUsers : cs:C1710.sfw_UserSelection
var $esStaff : cs:C1710.StaffSelection
var $esInscriptions : cs:C1710.sfw_UserInscriptionSelection
var $doomedUserUUIDs : Collection
var $report : Collection
var $login; $code : Text
var $temporaryPassword : Text
var $usersCreated; $staffCreated; $skipped; $failed : Integer
var $deletedUsers; $deletedStaff; $deletedInscriptions : Integer
var $nextCodeID : Integer

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("users_export.json")

If (Not:C34($file.exists))
	ALERT:C41("users_export.json not found in "+$importsFolder.platformPath)
	return
End if

$payload:=JSON Parse:C1218($file.getText())

If ($payload=Null:C1517) || ($payload.employees=Null:C1517)
	ALERT:C41("users_export.json is empty, malformed, or has no employees[] section.")
	return
End if

$usersCreated:=0
$staffCreated:=0
$skipped:=0
$failed:=0
$deletedUsers:=0
$deletedStaff:=0
$deletedInscriptions:=0
$report:=New collection:C1472

//===================================================================================
// 0. delete everything this import has ever created
//===================================================================================
// Two markers, because the first version of this method did not write a tag:
//   moreData.importedBy = the tag   -> written by this version
//   moreData.legacy     # null      -> written by the earlier version
$esUsers:=ds:C1482.sfw_User.query("moreData.importedBy = :1 or moreData.legacy # null"; $importTag)

//---never delete the framework accounts or the session's own account
$doomedUserUUIDs:=New collection:C1472
For each ($eUser; $esUsers)
	If ($protectedLogins.indexOf(Lowercase:C14(String:C10($eUser.login)))#-1)
		continue
	End if
	If ($eUser.UUID=cs:C1710.sfw_userManager.me.info.UUID)
		continue
	End if
	If (Bool:C1537($eUser.asDesigner))
		continue
	End if
	$doomedUserUUIDs.push($eUser.UUID)
End for each

//---Staff: everything imported, plus anything still pointing at an account about to go
$esStaff:=ds:C1482.Staff.query(\
	"moreData.importedBy = :1 or moreData.legacy # null or UUID_User in :2"; $importTag; $doomedUserUUIDs)
$deletedStaff:=$esStaff.length
$info:=$esStaff.drop()

//---inscriptions of the doomed accounts, before the accounts themselves
If ($doomedUserUUIDs.length>0)
	$esInscriptions:=ds:C1482.sfw_UserInscription.query("UUID_User in :1"; $doomedUserUUIDs)
	$deletedInscriptions:=$esInscriptions.length
	$info:=$esInscriptions.drop()

	$esUsers:=ds:C1482.sfw_User.query("UUID in :1"; $doomedUserUUIDs)
	$deletedUsers:=$esUsers.length
	$info:=$esUsers.drop()
End if

//---Staff.codeID is a numeric sequence (StaffEntity.loadAfterCreation uses max+1):
//   continue it from whatever survived.
$nextCodeID:=ds:C1482.Staff.all().max("codeID")+1

//===================================================================================
// 1. one account + one Staff row per employee
//===================================================================================
For each ($legacyEmployee; $payload.employees)

	$code:=String:C10($legacyEmployee.employeeCode)

	//---a person needs a name: without one there is nothing to build an account from
	$login:=cs:C1710.sfw_string.me.stringCapitalize(\
		[String:C10($legacyEmployee.firstName); String:C10($legacyEmployee.lastName)].join(" "; ck ignore null or empty:K85:5))

	If ($login="")
		$skipped:=$skipped+1
		$report.push(New object:C1471("kind"; "employee"; "key"; $code; "action"; "skipped (no name)"))
		continue
	End if

	If ($code="")
		$skipped:=$skipped+1
		$report.push(New object:C1471("kind"; "employee"; "key"; $login; "action"; "skipped (no employee code)"))
		continue
	End if

	//---the account: the person's identity, and nothing else
	$eUser:=ds:C1482.sfw_User.new()
	$eUser.UUID:=Generate UUID:C1066
	$eUser.login:=_uniqueLogin($login)
	$eUser.firstName:=String:C10($legacyEmployee.firstName)
	$eUser.lastName:=String:C10($legacyEmployee.lastName)
	$eUser.isInactive:=Bool:C1537($legacyEmployee.terminated)

	$eUser.moreData:=New object:C1471(\
		"importedBy"; $importTag; \
		"employeeCode"; $code; \
		"emailAddress"; String:C10($legacyEmployee.emailAddress); \
		"division"; String:C10($legacyEmployee.division); \
		"department"; String:C10($legacyEmployee.department); \
		"importedAt"; cs:C1710.sfw_stmp.me.now()\
		)

	If ($applyLegacyPasswords) && (String:C10($legacyEmployee.password)#"")
		$eUser.accesses:=New object:C1471
		$eUser.accesses.password:=New object:C1471
		$eUser.accesses.password.hash:=Generate password hash:C1533(String:C10($legacyEmployee.password); cs:C1710.sfw_passwordManager.me.hashOptions)
		$eUser.accesses.password.temporary:=True:C214  // must be changed on first login
		$eUser.accesses.password.lastReset:=cs:C1710.sfw_stmp.me.now()
	End if

	$info:=$eUser.save()

	If (Not:C34($info.success))
		$failed:=$failed+1
		$report.push(New object:C1471("kind"; "account"; "key"; $login; "action"; "SAVE FAILED"))
		continue
	End if
	$usersCreated:=$usersCreated+1

	//---every account must end up with a complete accesses.password block, even when no
	//   legacy password was carried over. The login paths read
	//   $eUser.accesses.password.hash without guarding, so an account left with no
	//   accesses at all crashes them with "Object or Collection Expected" - including
	//   sfw_userManager.login, which runs at startup for a remembered account.
	//   Done after the first save on purpose: the creation save keeps exactly the
	//   behaviour it had before, and this second one only updates an existing entity.
	If ($eUser.accesses=Null:C1517) || ($eUser.accesses.password=Null:C1517)
		If ($sharedTemporaryPassword#"")
			$temporaryPassword:=$sharedTemporaryPassword
		Else
			$temporaryPassword:=cs:C1710.sfw_passwordManager.me.generateTemporaryPassword()
		End if

		$eUser.accesses:=($eUser.accesses=Null:C1517) ? New object:C1471 : $eUser.accesses
		$eUser.accesses.password:=New object:C1471
		$eUser.accesses.password.hash:=Generate password hash:C1533($temporaryPassword; cs:C1710.sfw_passwordManager.me.hashOptions)
		$eUser.accesses.password.temporary:=True:C214  // must be changed on first login
		$eUser.accesses.password.lastReset:=cs:C1710.sfw_stmp.me.now()
		//sendTemporaryByMail is deliberately NOT set: it would make sfw_UserEntity.afterSave
		//mail every imported account and save it a second time.

		$info:=$eUser.save()
		If (Not:C34($info.success))
			$report.push(New object:C1471("kind"; "account"; "key"; $login; "action"; "PASSWORD BLOCK NOT WRITTEN"))
		End if
	End if

	//---and the Staff row it belongs to, carrying the business data
	$eStaff:=_newStaffFor($eUser; $legacyEmployee; $importTag; ->$nextCodeID)
	$info:=$eStaff.save()

	If ($info.success)
		$staffCreated:=$staffCreated+1
		$report.push(New object:C1471(\
			"kind"; "person"; "key"; $code; "login"; $eUser.login; \
			"name"; $eUser.firstName+" "+$eUser.lastName; "action"; "created"))
	Else
		$failed:=$failed+1
		$report.push(New object:C1471("kind"; "staff"; "key"; $code; "action"; "SAVE FAILED"))
	End if
End for each

//===================================================================================
$file:=$importsFolder.file("users_import_report.json")
If (Not:C34($file.exists))
	$file.create()
End if
$file.setText(JSON Stringify:C1217(New object:C1471(\
	"deleted"; New object:C1471(\
	"accounts"; $deletedUsers; \
	"staff"; $deletedStaff; \
	"profileInscriptions"; $deletedInscriptions\
	); \
	"created"; New object:C1471(\
	"accounts"; $usersCreated; \
	"staff"; $staffCreated\
	); \
	"skipped"; $skipped; \
	"failed"; $failed; \
	"details"; $report\
	)))

// The forced full-access account. Created whatever the file contained, and repaired if
// a previous run left it short. Its login is in $protectedLogins above, so the delete
// pass never touches it.
var $forcedAccount : Object
$forcedAccount:=_ensureFullAccessUser

ALERT:C41("Import done."+Char:C90(13)+\
	"deleted - accounts: "+String:C10($deletedUsers)+"  staff: "+String:C10($deletedStaff)+"  inscriptions: "+String:C10($deletedInscriptions)+Char:C90(13)+\
	"created - accounts: "+String:C10($usersCreated)+"  staff: "+String:C10($staffCreated)+Char:C90(13)+\
	"skipped: "+String:C10($skipped)+"   failed: "+String:C10($failed)+Char:C90(13)+\
	"report: "+$file.platformPath+Char:C90(13)+Char:C90(13)+\
	"full access account: "+$forcedAccount.messages.join(Char:C90(13)))
