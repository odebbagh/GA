# sfw_passwordManager

The `sfw_passwordManager` class is designed to manage password-related functionalities within the application. It provides methods to generate temporary passwords, check password rules, and handle password change requests.

### Summary

| |
| -------- |
|[.askForNewPassword($eUser : cs.sfw_UserEntity) : Object](#-askfornewpassword-) <br> Prompts the user to enter a new password.|
|[.ckeckPasswordRules($password : Text) : Object](#-ckeckpasswordrules-) <br> Checks if the password complies with the security rules.|
|[.generateTemporaryPassword() : Text](#-generatetemporarypassword-) <br> Generates a temporary password.|
|[.newPasswordFormCheckPasswords() : Boolean](#-newpasswordformcheckpasswords-) <br> Checks the passwords entered in the new password form.|

<!--   askForNewPassword() *********************   -->
## .askForNewPassword()

### .askForNewPassword($eUser : cs.sfw_UserEntity) : Object

| Parameter    |  | Type | Description |
| ------------ | -- | ---- | ----------- |
| $eUser       | <img src="DocImages/arrowRight.png" height="25" align="center" /> | cs.sfw_UserEntity | The user entity for which the password is being changed. |
| $result      | <img src="DocImages/arrowLeft.png" height="25" align="center" /> | Object | The result object containing the success status and the hashed password. |

#### Description

Prompts the user to enter a new password.

#### Example
```4d
$eUser:=ds.sfw_UserEntity.get("userUUID")
$result:=cs.sfw_passwordManager.me.askForNewPassword($eUser)
```

<!--   ckeckPasswordRules() *********************   -->
## .ckeckPasswordRules()

### .ckeckPasswordRules($password : Text) : Object

| Parameter    |  | Type | Description |
| ------------ | -- | ---- | ----------- |
| $password    | <img src="DocImages/arrowRight.png" height="25" align="center" /> | Text | The password to check. |
| $result      | <img src="DocImages/arrowLeft.png" height="25" align="center" /> | Object | The result object containing the success status of the check. |

#### Description

Checks if the password complies with the security rules.

 Example####
```4d
$password:="MySecurePassword123!"
$result:=cs.sfw_passwordManager.me.ckeckPasswordRules($password)
```

<!--   generateTemporaryPassword() *********************   -->
## .generateTemporaryPassword()

### .generateTemporaryPassword() : Text

| Parameter    |  | Type | Description |
| ------------ | -- | ---- | ----------- |
| $password    | <img src="DocImages/arrowLeft.png" height="25" align="center" /> | Text | The generated temporary password. |

#### Description

Generates a temporary password.

#### Example
```4d
$password:=cs.sfw_passwordManager.me.generateTemporaryPassword()
```

<!--   newPasswordFormCheckPasswords() *********************   -->
## .newPasswordFormCheckPasswords()

### .newPasswordFormCheckPasswords() : Boolean

| Parameter    |  | Type | Description |
| ------------ | -- | ---- | ----------- |
| $correct     | <img src="DocImages/arrowLeft.png" height="25" align="center" /> | Boolean | The result indicating if the passwords are correct. |

#### Description

Checks the passwords entered in the new password form.

#### Example
```4d
$correct:=cs.sfw_passwordManager.me.newPasswordFormCheckPasswords()
```
```