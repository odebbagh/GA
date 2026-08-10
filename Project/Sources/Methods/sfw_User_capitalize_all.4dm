//%attributes = {}
var $eUser : cs:C1710.sfw_UserEntity

For each ($eUser; ds:C1482.sfw_User.all())
	$eUser.firstName:=cs:C1710.sfw_string.me.stringCapitalize($eUser.firstName)
	$eUser.lastName:=cs:C1710.sfw_string.me.stringCapitalize($eUser.lastName)
	$info:=$eUser.save()
End for each 