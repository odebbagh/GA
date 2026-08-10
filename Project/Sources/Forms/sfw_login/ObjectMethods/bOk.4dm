var $esUsers : cs:C1710.sfw_UserSelection
var $eUser : cs:C1710.sfw_UserEntity


$esUsers:=ds:C1482.sfw_User.query("login = :1"; Form:C1466.pup_users.currentValue)
If ($esUsers.length=1)
	$eUser:=$esUsers.first()
	If (Verify password hash:C1534(Form:C1466.password; String:C10($eUser.accesses.password.hash)))
		If (Bool:C1537($eUser.accesses.asDesigner))
			CHANGE CURRENT USER:C289("Designer"; "")  //cs.sfw_definition.me.globalParameters.users.designerPassword)
		End if 
		SET USER ALIAS:C1666(Form:C1466.pup_users.currentValue)
		Form:C1466.currentUser:=$eUser
		cs:C1710.sfw_userManager.me.defineUser()
		ACCEPT:C269
	Else 
		Form:C1466.error:=Localized string:C991("user.login.message.error")
	End if 
	
Else 
	Form:C1466.error:="Unknown user"
End if 
GOTO OBJECT:C206(*; "input_password")