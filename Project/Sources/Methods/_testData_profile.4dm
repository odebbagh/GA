//%attributes = {}
// _testData_profile($ident; $name; $visions; $tag) -> sfw_UserProfileEntity
// Finds or creates a profile, and sets the visions it grants.
//
// $visions is the collection of vision idents to write into moreData.allowedVisions,
// which is what sfw_toolbar.pupVisions reads to decide what the holder of this profile
// can see. Pass Null to leave the vision list alone (a profile that only carries a
// right, such as BO Approver).
//
// Only ever touches profiles it created itself: a pre-existing profile that does not
// carry moreData.createdBy = $tag keeps its vision list untouched, so running the test
// data can never widen a real profile.

#DECLARE($ident : Text; $name : Text; $visions : Collection; $tag : Text)->$eProfile : cs:C1710.sfw_UserProfileEntity

var $result : Object
var $isOurs : Boolean

$eProfile:=ds:C1482.sfw_UserProfile.query("ident = :1"; $ident).first()

If ($eProfile=Null:C1517)
	$eProfile:=ds:C1482.sfw_UserProfile.new()
	$eProfile.UUID:=Generate UUID:C1066
	$eProfile.ident:=$ident
	$eProfile.name:=$name
	$eProfile.moreData:=New object:C1471("createdBy"; $tag; "autoCreation"; cs:C1710.sfw_stmp.me.now())
	$isOurs:=True:C214
Else
	If ($eProfile.moreData=Null:C1517)
		$eProfile.moreData:=New object:C1471()
	End if
	$isOurs:=(String:C10($eProfile.moreData.createdBy)=$tag)
End if

If ($visions#Null:C1517) && ($isOurs)
	$eProfile.moreData.allowedVisions:=$visions.copy()
End if

$result:=$eProfile.save()

If (Not:C34($result.success))
	$eProfile:=Null:C1517
End if
