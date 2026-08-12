//%attributes = {}
// _import_userProfiles
// Creates the application's default user profiles in sfw_UserProfile: the departments
// plus the functional roles carried over from the legacy 4D application, where access
// was driven by password-system groups (User in group / subr_access) rather than by a
// profile table. Each profile is also given its allowed visions.
//
// Legacy group -> profile mapping. Groups already created in code are NOT repeated here
// (goldenAltos_definition._profiles_definition and sfw_userManager create them):
//   administrators      -> admin      (already created by sfw_userManager)
//   designer            -> designer   (already created by sfw_userManager)
//   qa_manager          -> qm         (already created, "Quality Manager")
//   ship&recv           -> sr         (already created, "Shipper & receiver")
// Legacy groups that are web-portal roles for external parties, deliberately skipped:
//   customers, suppliers
// Legacy group whose meaning could not be established, deliberately skipped:
//   su
//
// Where a profile corresponds to a legacy group, moreData.legacyGroup records it so the
// old menu-access matrix can be traced (and users migrated) later.
//
// The visions granted per profile follow where the entries actually live in this
// application, not the legacy menu names. Worth knowing: the customerService vision
// carries the core manufacturing data (jobs, lots, planning, purchase orders, PO lines,
// inventories, bins, receiver) as well as the commercial data (customers, contacts,
// invoices), so any profile that needs lots or inventory is also granted the commercial
// entries. Splitting that vision would be the way to tighten it.
//
// The records are created here rather than through
// ds.sfw_UserProfile.getAndCreateIfNotExist(), because that helper is wrapped in
// If (Application type # 4D Remote mode): from a 4D Remote client it silently does
// nothing, and it also ignores the result of its own save. The fields set below are
// exactly the ones it sets (UUID, ident, name, moreData.autoCreation).
//
// Idempotent, and deliberately does NOT truncate the table: profiles are referenced by
// sfw_UserInscription (the user-to-profile links) and by hardcoded profile checks
// (Staff_isInUserProfile, allowedProfiles). On an existing profile the visions are only
// written when moreData.allowedVisions is still empty, so permissions already adjusted
// by hand in the Profiles panel are never overwritten.

var $profiles : Collection
var $profile : Object
var $eProfile : cs:C1710.sfw_UserProfileEntity
var $result : Object
var $created : Integer
var $updated : Integer
var $existing : Integer
var $failed : Integer
var $errors : Text
var $needsVisions : Boolean

// Departments
$profiles:=New collection:C1472(\
	New object:C1471("ident"; "en"; "name"; "Engineering"; \
	"visions"; New collection:C1472("housekeeping"; "production")); \
	New object:C1471("ident"; "pr"; "name"; "Production"; \
	"visions"; New collection:C1472("production"; "customerService")); \
	New object:C1471("ident"; "qa"; "name"; "Quality Assurance"; "legacy"; "qa"; \
	"visions"; New collection:C1472("qualityAssurance")); \
	New object:C1471("ident"; "op"; "name"; "Operator"; \
	"visions"; New collection:C1472("production")); \
	New object:C1471("ident"; "cs"; "name"; "Customer Service"; "legacy"; "customer service"; \
	"visions"; New collection:C1472("customerService"; "salesAndQuotes")); \
	New object:C1471("ident"; "pu"; "name"; "Purchasing"; "legacy"; "buyers"; \
	"visions"; New collection:C1472("buying")); \
	New object:C1471("ident"; "sa"; "name"; "Sales"; \
	"visions"; New collection:C1472("salesAndQuotes"; "customerService")); \
	New object:C1471("ident"; "ma"; "name"; "Maintenance"; \
	"visions"; New collection:C1472("qualityAssurance")); \
	New object:C1471("ident"; "mk"; "name"; "Marketing"; \
	"visions"; New collection:C1472("salesAndQuotes")); \
	New object:C1471("ident"; "rc"; "name"; "Receiving"; "legacy"; "ship&recv"; \
	"visions"; New collection:C1472("receiving")); \
	New object:C1471("ident"; "sh"; "name"; "Shipping"; "legacy"; "ship&recv"; \
	"visions"; New collection:C1472("receiving"))\
	)

// Functional roles carried over from the legacy password-system groups
$profiles:=$profiles.concat(New collection:C1472(\
	New object:C1471("ident"; "ac"; "name"; "Accounting"; "legacy"; "accounting"; \
	"visions"; New collection:C1472("accounting")); \
	New object:C1471("ident"; "ic"; "name"; "Inventory Control"; "legacy"; "inventory_control"; \
	"visions"; New collection:C1472("customerService"; "receiving")); \
	New object:C1471("ident"; "pc"; "name"; "Production Control"; "legacy"; "pc"; \
	"visions"; New collection:C1472("production"; "customerService"; "housekeeping")); \
	New object:C1471("ident"; "pe"; "name"; "Personnel"; "legacy"; "personnel"; \
	"visions"; New collection:C1472("qualityAssurance")); \
	New object:C1471("ident"; "hk"; "name"; "Housekeeping"; "legacy"; "staff"; \
	"visions"; New collection:C1472("housekeeping")); \
	New object:C1471("ident"; "mo"; "name"; "Record Modifier"; "legacy"; "modifier"); \
	New object:C1471("ident"; "da"; "name"; "Division Administrator"; "legacy"; "div_admin"; \
	"visions"; New collection:C1472("administration")); \
	New object:C1471("ident"; "ia"; "name"; "Invoice Approver"; "legacy"; "invoiceapprovers"; \
	"visions"; New collection:C1472("accounting"; "customerService"))\
	))

$created:=0
$updated:=0
$existing:=0
$failed:=0
$errors:=""

For each ($profile; $profiles)
	$eProfile:=ds:C1482.sfw_UserProfile.query("ident = :1"; $profile.ident).first()

	If ($eProfile=Null:C1517)
		$eProfile:=ds:C1482.sfw_UserProfile.new()
		$eProfile.UUID:=Generate UUID:C1066
		$eProfile.ident:=$profile.ident
		$eProfile.name:=$profile.name
		$eProfile.moreData:=New object:C1471()
		$eProfile.moreData.autoCreation:=cs:C1710.sfw_stmp.me.now()
		If (String:C10($profile.legacy)#"")
			// keeps the trace back to the legacy password-system group
			$eProfile.moreData.legacyGroup:=String:C10($profile.legacy)
		End if
		If ($profile.visions#Null:C1517)
			$eProfile.moreData.allowedVisions:=$profile.visions.copy()
		End if

		$result:=$eProfile.save()

		If ($result.success)
			$created:=$created+1
		Else
			$failed:=$failed+1
			$errors:=$errors+"\r"+$profile.ident+": "+JSON Stringify:C1217($result)
		End if
	Else
		// existing profile: only fill the visions in when none have been set yet, so
		// anything adjusted by hand in the Profiles panel is left alone
		$needsVisions:=False:C215
		If ($profile.visions#Null:C1517)
			If ($eProfile.moreData=Null:C1517)
				$needsVisions:=True:C214
			Else
				If ($eProfile.moreData.allowedVisions=Null:C1517)
					$needsVisions:=True:C214
				Else
					$needsVisions:=($eProfile.moreData.allowedVisions.length=0)
				End if
			End if
		End if

		If ($needsVisions)
			If ($eProfile.moreData=Null:C1517)
				$eProfile.moreData:=New object:C1471()
			End if
			$eProfile.moreData.allowedVisions:=$profile.visions.copy()
			If (String:C10($profile.legacy)#"")
				$eProfile.moreData.legacyGroup:=String:C10($profile.legacy)
			End if

			$result:=$eProfile.save()

			If ($result.success)
				$updated:=$updated+1
			Else
				$failed:=$failed+1
				$errors:=$errors+"\r"+$profile.ident+": "+JSON Stringify:C1217($result)
			End if
		Else
			$existing:=$existing+1
		End if
	End if
End for each

If ($failed=0)
	ALERT:C41("Import termine - created: "+String:C10($created)+" | visions set on existing: "+String:C10($updated)+" | left untouched: "+String:C10($existing))
Else
	ALERT:C41("Import termine - created: "+String:C10($created)+" | visions set on existing: "+String:C10($updated)+" | left untouched: "+String:C10($existing)+" | failed: "+String:C10($failed)+$errors)
End if
