//%attributes = {}

/*
Method Name : _diagnose_boApprovers
Purpose     : Says exactly why the Approver 1/2 pickers come up empty.

selectApprover needs THREE things to line up, and the picker cannot tell you which one
is missing:

  1. a profile whose ident is BOAPPROVER1 / BOAPPROVER2
  2. sfw_User accounts inscribed in that profile
  3. a Staff record LINKED to that user (Staff.UUID_User), not terminated, not inactive

Adding users to a profile only covers 2. The picker lists STAFF, so a user with no Staff
record behind them - or a Staff record that is inactive - never appears.

Run it and read the report. Changes nothing.
*/

var $report : Text
var $profile : Object
var $profiles : cs:C1710.sfw_UserProfileSelection
var $user : Object
var $staff : cs:C1710.StaffEntity
var $staffs : cs:C1710.StaffSelection
var $slot : Integer
var $wanted : Text
var $idents : Collection
var $inProfile : Collection
var $linked : Collection
var $usable : Collection

$report:=""

//---1. what profiles actually exist
$report:=$report+"PROFILES IN THE DATABASE"+Char(Carriage return)
$profiles:=ds.sfw_UserProfile.all().orderBy("ident asc")
For each ($profile; $profiles)
	$report:=$report+"   ident="+String($profile.ident)+"   name="+String($profile.name)\
		+"   users="+String($profile.userInscriptions.length)+Char(Carriage return)
End for each
If ($profiles.length=0)
	$report:=$report+"   (none)"+Char(Carriage return)
End if

//---2. the two the picker looks for
For ($slot; 1; 2)
	$wanted:="BOAPPROVER"+String($slot)
	$report:=$report+Char(Carriage return)+"--- "+$wanted+" ---"+Char(Carriage return)

	$profile:=ds.sfw_UserProfile.query("ident = :1"; $wanted).first()
	If ($profile=Null)
		$report:=$report+"   NO PROFILE WITH THIS IDENT."+Char(Carriage return)
		$report:=$report+"   The picker matches on ident, not on the display name."+Char(Carriage return)
		continue
	End if

	$inProfile:=New collection()
	$linked:=New collection()
	$usable:=New collection()

	For each ($user; $profile.userInscriptions.user)
		$inProfile.push(String($user.name))
		$staffs:=ds.Staff.query("UUID_User = :1"; String($user.UUID))
		If ($staffs.length=0)
			continue
		End if
		$staff:=$staffs.first()
		$linked.push(String($staff.fullName))
		If (Not(Bool($staff.terminated))) && (Not(Bool($staff.inactive)))
			$usable.push(String($staff.fullName))
		End if
	End for each

	$report:=$report+"   users in profile      : "+String($inProfile.length)+"  "+$inProfile.join(", ")+Char(Carriage return)
	$report:=$report+"   of those, with Staff  : "+String($linked.length)+"  "+$linked.join(", ")+Char(Carriage return)
	$report:=$report+"   active -> IN PICKER   : "+String($usable.length)+"  "+$usable.join(", ")+Char(Carriage return)

	Case of
		: ($inProfile.length=0)
			$report:=$report+"   >> nobody is inscribed in this profile."+Char(Carriage return)
		: ($linked.length=0)
			$report:=$report+"   >> those users have NO Staff record (Staff.UUID_User is not set)."+Char(Carriage return)
			$report:=$report+"      The picker lists Staff, so link them in Administration > Staff."+Char(Carriage return)
		: ($usable.length=0)
			$report:=$report+"   >> their Staff records are terminated or inactive, so they are filtered out."+Char(Carriage return)
	End case
End for

//---3. what isInAnyProfile itself says, since that is the function the picker calls
$report:=$report+Char(Carriage return)+"CROSS-CHECK VIA Util_Authorizer.isInAnyProfile"+Char(Carriage return)
For each ($staff; ds.Staff.query("terminated = :1 and inactive = :2"; False; False))
	$idents:=New collection()
	For ($slot; 1; 2)
		If (cs.Util_Authorizer.me.isInAnyProfile($staff.user; New collection("BOAPPROVER"+String($slot))))
			$idents.push("BOAPPROVER"+String($slot))
		End if
	End for
	If ($idents.length>0)
		$report:=$report+"   "+String($staff.fullName)+" -> "+$idents.join(", ")+Char(Carriage return)
	End if
End for each

//---A dialog cannot be copied out of, so the report goes to a file as well as the
//   clipboard.
//
//   exportedData already exists (the Excel exports use it) and no sub-folder is created,
//   because 4D.Folder.create() is not relied on here for intermediate levels.
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $where : Text

$folder:=Folder(fk resources folder).folder("exportedData")
If (Not($folder.exists))
	$folder.create()
End if

$where:=""
If ($folder.exists)
	$file:=$folder.file("boApprovers.txt")
	$file.setText($report)
	If ($file.exists)
		$where:=$file.platformPath
	End if
End if

If ($where="")
	//---last resort: the user's own Documents folder, which is always writable
	$file:=Folder(fk documents folder).file("boApprovers.txt")
	$file.setText($report)
	$where:=$file.platformPath
End if

SET TEXT TO PASTEBOARD($report)

cs.sfw_dialog.me.info("Report written to:"+Char(Carriage return)+$where\
	+Char(Carriage return)+Char(Carriage return)+"It is also on the clipboard."\
	+Char(Carriage return)+Char(Carriage return)+$report)