Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.currentPassword:=""
		Form:C1466.newPassword:=""
		Form:C1466.newPasswordBis:=""
		Form:C1466.checkCurrentPassword:=""
		Form:C1466.checkNewPassword:=""
		Form:C1466.checkNewPasswordBis:=""
		Form:C1466.isValidatable:=False:C215
		OBJECT SET FONT:C164(*; "input@Password@"; "%password")
		
End case 


OBJECT SET ENABLED:C1123(*; "bSave"; Form:C1466.isValidatable)