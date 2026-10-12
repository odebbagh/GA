//%attributes = {}
// Test data for the BO approval flow (cs.Util_Authorizer).
//
// WHY THERE ARE TWO TABLES PER PERSON
//   [sfw_User] is the ACCOUNT : login, first/last name, accesses (the bcrypt password
//                               hash the login form checks), isInactive
//   [Staff]    is the PERSON  : code, barcode, hire data, division, contact details
//   Staff.UUID_User links them, one to one.
//   The scanner finds the person through [Staff] (code / moreData.barcodeData); the
//   approval then needs the account behind it for the profile and the password.
//
// HOW PERMISSIONS ARE GRANTED
//   [sfw_UserInscription] is the join table between a user and a profile. It is what
//   userInscriptions.userProfile.ident reads, so it is what the profile check tests.
//   VISIONS ARE A PROPERTY OF THE PROFILE, not of the user: a vision shows up when
//   either the vision's own allowedProfiles names one of the user's profiles, or one
//   of those profiles carries the vision in moreData.allowedVisions
//   (see sfw_toolbar.pupVisions).
//   In this application every vision except "facilities" is declared
//   setAllowedProfiles("admin"), which is why a user holding only BOAPPROVER sees
//   almost nothing. Each test user therefore also gets its OWN vision profile.
//
// THE FOUR USERS
//   BOAPP1  approves           | visions: Buying, Receiving
//   BOAPP2  approves           | visions: Customer service, Sales & Quotes, Accounting
//   BOAPP3  NOT in the profile | visions: Production, Housekeeping, Quality Assurance
//   BOAPP4  temporary password | visions: ALL + designer access
//
//   BOAPP4 does double duty: it is the browse-everything/designer account and the
//   "still on its temporary password" refusal case. Designer access does NOT bypass
//   that refusal, which is worth seeing. To make it a plain designer account instead,
//   set its "temporaryPassword" below to False.
//
// Every test password is the same: Test-Approve1!
// Barcodes are the staff codeID padded to 10 digits, so they can be typed into the
// scan window by hand when no reader is around.
//
// Re-runnable and self-repairing: existing rows are reused, profiles and inscriptions
// are topped up, vision lists are rewritten. Everything carries
// moreData.createdBy = "_create_testData_boApprovers".

var $tag : Text
var $testPassword : Text
var $approverProfileIdent : Text

$tag:="_create_testData_boApprovers"
$testPassword:="Test-Approve1!"
$approverProfileIdent:="BOAPPROVER"

var $people : Collection
var $person : Object
var $allVisionIdents : Collection
var $eApproverProfile : cs:C1710.sfw_UserProfileEntity
var $eVisionProfile : cs:C1710.sfw_UserProfileEntity
var $eUser : cs:C1710.sfw_UserEntity
var $eStaff : cs:C1710.StaffEntity
var $result : Object
var $report : Collection
var $nextCodeID : Integer
var $hash : Text
var $visions : Collection
var $created : Boolean

$report:=New collection:C1472

//---every vision the application declares, minus the "-" separator, exactly as
//   sfw_panel_profile lists them. Read at runtime so a new vision is picked up.
$allVisionIdents:=cs:C1710.sfw_definition.me.visions.query("label # :1"; "-").extract("ident")

//---the approval right
$eApproverProfile:=_testData_profile($approverProfileIdent; "BO Approver"; Null:C1517; $tag)
If ($eApproverProfile=Null:C1517)
	ALERT:C41("Could not create the BO Approver profile.")
	return
End if

//---the people
$people:=New collection:C1472

$people.push(New object:C1471(\
	"code"; "BOAPP1"; \
	"firstName"; "Alba"; \
	"lastName"; "Approver"; \
	"login"; "boapp1"; \
	"inProfile"; True:C214; \
	"temporaryPassword"; False:C215; \
	"inactive"; False:C215; \
	"asDesigner"; False:C215; \
	"visionProfileIdent"; "BOAPPVIS1"; \
	"visionProfileName"; "BO Test - Buying side"; \
	"visions"; New collection:C1472("buying"; "receiving")))

$people.push(New object:C1471(\
	"code"; "BOAPP2"; \
	"firstName"; "Bruno"; \
	"lastName"; "Approver"; \
	"login"; "boapp2"; \
	"inProfile"; True:C214; \
	"temporaryPassword"; False:C215; \
	"inactive"; False:C215; \
	"asDesigner"; False:C215; \
	"visionProfileIdent"; "BOAPPVIS2"; \
	"visionProfileName"; "BO Test - Commercial side"; \
	"visions"; New collection:C1472("customerService"; "salesAndQuotes"; "accounting")))

$people.push(New object:C1471(\
	"code"; "BOAPP3"; \
	"firstName"; "Carla"; \
	"lastName"; "Outsider"; \
	"login"; "boapp3"; \
	"inProfile"; False:C215; \
	"temporaryPassword"; False:C215; \
	"inactive"; False:C215; \
	"asDesigner"; False:C215; \
	"visionProfileIdent"; "BOAPPVIS3"; \
	"visionProfileName"; "BO Test - Shop floor"; \
	"visions"; New collection:C1472("production"; "housekeeping"; "qualityAssurance")))

$people.push(New object:C1471(\
	"code"; "BOAPP4"; \
	"firstName"; "Dario"; \
	"lastName"; "Tempo"; \
	"login"; "boapp4"; \
	"inProfile"; True:C214; \
	"temporaryPassword"; True:C214; \
	"inactive"; False:C215; \
	"asDesigner"; True:C214; \
	"visionProfileIdent"; "BOAPPVIS4"; \
	"visionProfileName"; "BO Test - Everything"; \
	"visions"; $allVisionIdents))

$nextCodeID:=Num:C11(ds:C1482.Staff.all().max("codeID"))+1
$hash:=Generate password hash:C1533($testPassword; cs:C1710.sfw_passwordManager.me.hashOptions)

For each ($person; $people)

	$visions:=$person.visions

	//---that person's vision profile, rewritten every run so the lists above win
	$eVisionProfile:=_testData_profile($person.visionProfileIdent; $person.visionProfileName; $visions; $tag)
	If ($eVisionProfile=Null:C1517)
		$report.push($person.code+": VISION PROFILE FAILED")
		continue
	End if

	//---the person, reused when already there
	$created:=False:C215
	$eStaff:=ds:C1482.Staff.query("code = :1"; $person.code).first()

	If ($eStaff#Null:C1517)
		$eUser:=$eStaff.user
		If ($eUser=Null:C1517)
			$report.push($person.code+": staff row has no account, skipped")
			continue
		End if

		//without a barcode the scan route cannot find this person at all
		If ($eStaff.moreData=Null:C1517)
			$eStaff.moreData:=New object:C1471()
		End if
		If (String:C10($eStaff.moreData.barcodeData)="")
			$eStaff.moreData.barcodeData:=String:C10($eStaff.codeID; "0000000000")
			$eStaff.save()
		End if
	Else
		$created:=True:C214

		//---the ACCOUNT
		$eUser:=ds:C1482.sfw_User.new()
		$eUser.UUID:=Generate UUID:C1066
		$eUser.login:=_uniqueLogin($person.login)
		$eUser.firstName:=$person.firstName
		$eUser.lastName:=$person.lastName
		$eUser.isInactive:=$person.inactive

		//the hash the login form verifies, which is also what Util_Authorizer checks
		$eUser.accesses:=New object:C1471
		$eUser.accesses.password:=New object:C1471
		$eUser.accesses.password.hash:=$hash
		$eUser.accesses.password.temporary:=$person.temporaryPassword
		$eUser.accesses.password.lastChange:=cs:C1710.sfw_stmp.me.now()
		If ($person.temporaryPassword)
			$eUser.accesses.password.temporaryPassword:=$testPassword
			$eUser.accesses.password.lastReset:=cs:C1710.sfw_stmp.me.now()
		End if

		$eUser.moreData:=New object:C1471("createdBy"; $tag; "createdAt"; cs:C1710.sfw_stmp.me.now())

		$result:=$eUser.save()
		If (Not:C34($result.success))
			$report.push($person.code+": ACCOUNT SAVE FAILED")
			continue
		End if

		//---the PERSON
		$eStaff:=ds:C1482.Staff.new()
		$eStaff.UUID:=Generate UUID:C1066
		$eStaff.UUID_User:=$eUser.UUID
		$eStaff.code:=$person.code
		$eStaff.codeID:=$nextCodeID
		$nextCodeID:=$nextCodeID+1
		$eStaff.firstName:=$person.firstName
		$eStaff.lastName:=$person.lastName
		$eStaff.inactive:=$person.inactive
		$eStaff.terminated:=False:C215
		$eStaff.stmpCreation:=cs:C1710.sfw_stmp.me.now()
		$eStaff.contactDetails:=New object:C1471("communications"; New collection:C1472())

		//the scanner looks the person up on this exact attribute. Set here rather than
		//left to StaffEntity.loadAfterCreation, which only runs for panel-created rows.
		$eStaff.moreData:=New object:C1471(\
			"createdBy"; $tag; \
			"createdAt"; cs:C1710.sfw_stmp.me.now(); \
			"login"; $eUser.login; \
			"barcodeData"; String:C10($eStaff.codeID; "0000000000"))

		$result:=$eStaff.save()
		If (Not:C34($result.success))
			$report.push($person.code+": STAFF SAVE FAILED")
			continue
		End if
	End if

	//---memberships, topped up on every run
	If ($person.inProfile)
		_ensureUserInscription($eUser; $eApproverProfile; $tag)
	End if
	_ensureUserInscription($eUser; $eVisionProfile; $tag)

	//---designer access. The computed setter also creates the Designer inscription,
	//   so it must run on a saved account.
	If ($person.asDesigner) && (Not:C34(Bool:C1537($eUser.asDesigner)))
		$eUser.asDesigner:=True:C214
		$eUser.save()
	End if

	$report.push($person.code+($created ? " created" : " updated")\
		+" - login "+$eUser.login\
		+", barcode "+String:C10($eStaff.moreData.barcodeData)\
		+($person.inProfile ? ", BO Approver" : ", NOT a BO Approver")\
		+($person.temporaryPassword ? ", temporary password" : "")\
		+($person.asDesigner ? ", designer" : "")\
		+" | visions: "+$visions.join(", "))

End for each

ALERT:C41("Test data for BO approvers"+"\r\r"\
	+"Password for all of them: "+$testPassword+"\r\r"\
	+$report.join("\r\r"))
