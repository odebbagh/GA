Class extends Entity


Function get flag()->$pict : Picture
	
	
Function get creatorName()->$name : Text
	$name:="🙍🏻‍♂️ "+This:C1470.userCreator.fullName
	
Function get assignedName()->$name : Text
	var $eUser : cs:C1710.sfw_UserEntity
	var $eProfile : cs:C1710.sfw_UserProfileEntity
	
	$eUser:=ds:C1482.sfw_User.get(This:C1470.UUID_targetAssigned)
	If ($eUser#Null:C1517)
		$name:="🙍🏻‍♂️ "+$eUser.fullName
	Else 
		$eProfile:=ds:C1482.sfw_UserProfile.get(This:C1470.UUID_targetAssigned)
		$name:="👫 "+$eProfile.name
	End if 
	
	