//%attributes = {}
// _ensureUserInscription($eUser; $eProfile; $tag) -> Boolean
// Makes sure the user holds the profile, by creating the [sfw_UserInscription] row
// when it is not already there. That join is what userInscriptions.userProfile.ident
// reads, so it is what both the profile check and the vision list actually see.
// Idempotent: running it again on an existing membership does nothing.

#DECLARE($eUser : cs:C1710.sfw_UserEntity; $eProfile : cs:C1710.sfw_UserProfileEntity; $tag : Text)->$done : Boolean

var $eInscription : cs:C1710.sfw_UserInscriptionEntity
var $result : Object

$done:=False:C215

If ($eUser=Null:C1517) || ($eProfile=Null:C1517)
	return
End if

$eInscription:=ds:C1482.sfw_UserInscription.query("UUID_User = :1 and UUID_UserProfile = :2"; $eUser.UUID; $eProfile.UUID).first()

If ($eInscription#Null:C1517)
	$done:=True:C214
	return
End if

$eInscription:=ds:C1482.sfw_UserInscription.new()
$eInscription.UUID:=Generate UUID:C1066
$eInscription.UUID_User:=$eUser.UUID
$eInscription.UUID_UserProfile:=$eProfile.UUID
$eInscription.stmp_given:=cs:C1710.sfw_stmp.me.now()
$eInscription.moreData:=New object:C1471("createdBy"; $tag)

$result:=$eInscription.save()
$done:=$result.success
