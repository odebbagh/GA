//%attributes = {}
// _export_userProfilePermissions
// Dumps, for every profile in sfw_UserProfile, the visions (toolbars) and entries
// (menu items) that profile can reach -> Resources/exports/userProfilePermissions_export.json
//
// Why a method is needed: the answer is only half in the source. Access is resolved
// from three inputs, and two of them are DATA in the .4DD, not code:
//
//   1. code       : vision.allowedProfiles / entry.allowedProfiles
//                   EMPTY = open to every profile. Non-empty = restricted to those idents.
//   2. data grant : profile.moreData.allowedVisions / .allowedEntries   (adds access)
//   3. data deny  : profile.moreData.restrictVisions / .restrictEntries (removes it, wins)
//
// The resolution below mirrors sfw_toolbar.pupVisions: code-allowed OR explicitly
// granted, then revoked if restricted. Note that at runtime a user gets the UNION of
// all the profiles they are inscribed to (sfw_UserInscription), so a user may see more
// than any single row here; this export is per profile, on purpose.
//
// Run on the server or in single-user mode.

var $records : Collection
var $profileRow : Object
var $visionsOut : Collection
var $entriesOut : Collection
var $eProfile : cs:C1710.sfw_UserProfileEntity
var $vision : Object
var $entry : Object
var $allowedVisions : Collection
var $allowedEntries : Collection
var $restrictVisions : Collection
var $restrictEntries : Collection
var $visible : Boolean
var $codeRestricted : Boolean
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()

For each ($eProfile; ds:C1482.sfw_UserProfile.all().orderBy("ident"))

	// the four data-driven lists, normalised so the code below never tests for null
	$allowedVisions:=New collection:C1472()
	$allowedEntries:=New collection:C1472()
	$restrictVisions:=New collection:C1472()
	$restrictEntries:=New collection:C1472()

	If ($eProfile.moreData#Null:C1517)
		$allowedVisions:=$eProfile.moreData.allowedVisions || New collection:C1472()
		$allowedEntries:=$eProfile.moreData.allowedEntries || New collection:C1472()
		$restrictVisions:=$eProfile.moreData.restrictVisions || New collection:C1472()
		$restrictEntries:=$eProfile.moreData.restrictEntries || New collection:C1472()
	End if

	//______________________ visions (toolbars)
	$visionsOut:=New collection:C1472()

	For each ($vision; cs:C1710.sfw_definition.me.visions.orderBy("displayOrder desc"))

		$codeRestricted:=False:C215
		If ($vision.allowedProfiles#Null:C1517)
			$codeRestricted:=($vision.allowedProfiles.length>0)
		End if

		If ($codeRestricted)
			$visible:=($vision.allowedProfiles.indexOf($eProfile.ident)#-1)
		Else
			$visible:=True:C214  // no code restriction -> open to every profile
		End if

		// an explicit grant on the profile record opens a code-restricted vision
		If (Not:C34($visible))
			$visible:=($allowedVisions.indexOf($vision.ident)#-1)
		End if

		// a restriction on the profile record always wins
		If ($visible) & ($restrictVisions.indexOf($vision.ident)#-1)
			$visible:=False:C215
		End if

		If ($visible)
			$visionsOut.push(New object:C1471(\
				"ident"; $vision.ident; \
				"label"; $vision.label; \
				"displayOrder"; $vision.displayOrder; \
				"openToAllProfiles"; Not:C34($codeRestricted)\
				))
		End if
	End for each

	//______________________ entries (menu items inside the toolbars)
	$entriesOut:=New collection:C1472()

	For each ($entry; cs:C1710.sfw_definition.me.entries.orderBy("displayOrder desc"))

		$codeRestricted:=False:C215
		If ($entry.allowedProfiles#Null:C1517)
			$codeRestricted:=($entry.allowedProfiles.length>0)
		End if

		If ($codeRestricted)
			$visible:=($entry.allowedProfiles.indexOf($eProfile.ident)#-1)
		Else
			$visible:=True:C214
		End if

		If (Not:C34($visible))
			$visible:=($allowedEntries.indexOf($entry.ident)#-1)
		End if

		If ($visible) & ($restrictEntries.indexOf($entry.ident)#-1)
			$visible:=False:C215
		End if

		// An entry is only reachable if at least one of the visions it belongs to is
		// itself reachable: the toolbar is the only way in.
		If ($visible)
			$visible:=False:C215
			If ($entry.visions#Null:C1517)
				For each ($visionIdent; $entry.visions) Until ($visible)
					$visible:=($visionsOut.query("ident = :1"; $visionIdent).length>0)
				End for each
			End if
		End if

		If ($visible)
			$entriesOut.push(New object:C1471(\
				"ident"; $entry.ident; \
				"label"; $entry.label; \
				"visions"; $entry.visions || New collection:C1472(); \
				"dataclass"; $entry.dataclass; \
				"displayOrder"; $entry.displayOrder; \
				"openToAllProfiles"; Not:C34($codeRestricted); \
				"canCreate"; _profilePermitted($entry.allowedProfilesForCreation; $eProfile.ident); \
				"canModify"; _profilePermitted($entry.allowedProfilesForModification; $eProfile.ident); \
				"canDelete"; _profilePermitted($entry.allowedProfilesForDeletion; $eProfile.ident)\
				))
		End if
	End for each

	$profileRow:=New object:C1471(\
		"ident"; $eProfile.ident; \
		"name"; $eProfile.name; \
		"visionCount"; $visionsOut.length; \
		"entryCount"; $entriesOut.length; \
		"visions"; $visionsOut; \
		"entries"; $entriesOut; \
		"rawPermissions"; New object:C1471(\
		"allowedVisions"; $allowedVisions; \
		"allowedEntries"; $allowedEntries; \
		"restrictVisions"; $restrictVisions; \
		"restrictEntries"; $restrictEntries\
		)\
		)

	$records.push($profileRow)
End for each

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if

$file:=$exportsFolder.file("userProfilePermissions_export.json")

If (Not:C34($file.exists))
	$file.create()
End if

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | profiles: "+String:C10($records.length))
