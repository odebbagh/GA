//%attributes = {}
// _profilePermitted($allowedProfiles : Collection; $profileIdent : Text) -> Boolean
// Helper for _export_userProfilePermissions.
// Applies the framework's convention for the allowedProfilesFor<Action> lists:
// an EMPTY (or null) list means "no restriction", not "nobody".
// The sentinel "nothing" is used in the code (panel_job) to close an action to all.

#DECLARE($allowedProfiles : Collection; $profileIdent : Text)->$permitted : Boolean

$permitted:=True:C214

If ($allowedProfiles=Null:C1517)
	return
End if

If ($allowedProfiles.length=0)
	return
End if

$permitted:=($allowedProfiles.indexOf($profileIdent)#-1)
