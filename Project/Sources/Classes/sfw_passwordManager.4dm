property hashOptions : Object
property authorizedChars : Object
property passwordLength : Integer

shared singleton Class constructor
	
	This:C1470.authorizedChars:=New shared object:C1526
	This:C1470.authorizedChars.lowercase:="abcdefghijklmnopqrstuvwxyz"
	This:C1470.authorizedChars.upercase:="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	This:C1470.authorizedChars.special:="!#$%&*+-=?^_~@"
	This:C1470.authorizedChars.digit:="0123456789"
	This:C1470.passwordLength:=cs:C1710.sfw_definition.me.globalParameters.users.passwordLength
	This:C1470.hashOptions:=New shared object:C1526("algorithm"; "bcrypt"; "cost"; 10)
	
	
Function generateTemporaryPassword()->$password : Text
	$allCharacters:=OB Values:C1718(This:C1470.authorizedChars).join("")
	
	$password:=""
	For ($i; 1; This:C1470.passwordLength)
		// Générer un index aléatoire entre 1 et la longueur du pool
		$randomIndex:=(Random:C100%Length:C16($allCharacters))+1
		$password+=Substring:C12($allCharacters; $randomIndex; 1)
	End for 
	
Function ckeckPasswordRules($password : Text)->$result : Object
	
	$result:=New object:C1471
	$regex:="^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*["+This:C1470.authorizedChars.special+"]).{"+String:C10(This:C1470.passwordLength)+",}$"
	$result.success:=Match regex:C1019($regex; $password)
	
	
Function askForNewPassword($eUser : cs:C1710.sfw_UserEntity)->$result : Object
	
	$result:=New object:C1471
	$form:=New object:C1471
	$message:=ds:C1482.sfw_readXliff("user.password.message.rules")
	PROCESS 4D TAGS:C816($message; $message)
	$form.message:=$message
	$form.user:=$eUser
	
	$result.sucess:=False:C215
	
	If (Is Windows:C1573)
		$refWindow:=Open form window:C675("sfw_user_newPassword"; Modal form dialog box:K39:7)
	Else 
		$refWindow:=Open form window:C675("sfw_user_newPassword"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_user_newPassword"; $form)
	CLOSE WINDOW:C154($refWindow)
	
	If (ok=1)
		$result.success:=True:C214
		$result.hash:=Generate password hash:C1533($form.newPassword; This:C1470.hashOptions)
	End if 
	
	
	
Function newPasswordFormCheckPasswords()->$correct : Boolean
	Form:C1466.isValidatable:=True:C214
	Form:C1466.error:=""
	Case of 
		: (Form:C1466.currentPassword="")
			Form:C1466.isValidatable:=False:C215
		: (Verify password hash:C1534(Form:C1466.currentPassword; String:C10(Form:C1466.user.accesses.password.hash))=False:C215)
			Form:C1466.error+="Your current password is incorrect.\r"
			Form:C1466.checkCurrentPassword:="❌"
			Form:C1466.isValidatable:=False:C215
		Else 
			Form:C1466.checkCurrentPassword:="✅"
	End case 
	
	Case of 
		: (Form:C1466.newPassword="") && (Form:C1466.newPasswordBis="")
			Form:C1466.checkNewPassword:=""
			Form:C1466.checkNewPasswordBis:=""
			Form:C1466.isValidatable:=False:C215
			
		: (Form:C1466.newPassword#Form:C1466.newPasswordBis)
			Form:C1466.error+="The new passwords do not match.\r"
			Form:C1466.checkNewPasswordBis:="❌"
			Form:C1466.isValidatable:=False:C215
			
		: (Form:C1466.newPassword#"") && (Form:C1466.newPasswordBis#"") && (This:C1470.ckeckPasswordRules(Form:C1466.newPassword).success=False:C215)
			Form:C1466.error+="The new password does not comply with the security rules."
			Form:C1466.checkNewPassword:="❌"
			Form:C1466.checkNewPasswordBis:="❌"
			Form:C1466.isValidatable:=False:C215
			GOTO OBJECT:C206(*; "inputNewPassword")
			
		Else 
			// ok
			Form:C1466.checkNewPassword:="✅"
			Form:C1466.checkNewPasswordBis:="✅"
			
	End case 
	
	
Function newPasswordFormMethod()
	