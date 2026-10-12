// Credentials dialog used by cs.Util_Authorizer.
// Form.mode drives which single input is shown:
//   "code"     -> the user code, when the barcode could not be scanned
//   "password" -> the account password, masked

Case of

	: (FORM Event:C1606.code=On Load:K2:1)

		Case of
			: (Form:C1466.mode="password")
				Form:C1466.prompt:="Enter your password to confirm this approval:"
			Else
				Form:C1466.prompt:="Please enter your user code:"
		End case

		OBJECT SET VISIBLE:C603(*; "input_userCode"; (Form:C1466.mode#"password"))
		OBJECT SET VISIBLE:C603(*; "input_password"; (Form:C1466.mode="password"))
		OBJECT SET VISIBLE:C603(*; "label_who"; (String:C10(Form:C1466.whoName)#""))

		//the password must never be readable on screen, as on the login form
		OBJECT SET FONT:C164(*; "input_password"; "%password")

		cs:C1710.Util_Authorizer.me.credentialsFormRefresh()

		If (Form:C1466.mode="password")
			GOTO OBJECT:C206(*; "input_password")
		Else
			GOTO OBJECT:C206(*; "input_userCode")
		End if

	: (FORM Event:C1606.code=On Unload:K2:2)
		//nothing kept in memory beyond the form object the caller owns

End case
