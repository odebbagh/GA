# sfw_userManager

The `sfw_userManager` class is a shared singleton that provides functionality for managing user sessions and authentication within an application. This class ensures that all components of an application can handle user-related operations in a consistent and secure manner.

### Summary

| |
| -------- |
|[.authenticate(username : Text; password : Text) : Boolean](#-authenticate-) <br> Authenticates a user with the given username and password. |
|[.getCurrentUser() : Object](#-getcurrentuser-) <br> Retrieves the current authenticated user. |
|[.logout()](#-logout-) <br> Logs out the current user. |
|[.register(username : Text; password : Text; email : Text) : Boolean](#-register-) <br> Registers a new user with the given username, password, and email. |

<!--   authenticate() *********************   -->
## .authenticate()

### .authenticate(username : Text; password : Text) : Boolean

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| username  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The username of the user to authenticate |
| password  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The password of the user to authenticate |
| result  | Boolean  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | `True` if authentication is successful, `False` otherwise |

#### Description

The `.authenticate()` function authenticates a user with the given username and password. This function checks the provided credentials against the stored user data and returns `True` if the authentication is successful, `False` otherwise.

#### Example
```4d
$username:="john.doe"
$password:="password123"
$isAuthenticated:=cs.sfw_userManager.me.authenticate($username, $password) // True or False
```

<!--   getCurrentUser() *********************   -->
## .getCurrentUser()

### .getCurrentUser() : Object

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| result  | Object  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | The current authenticated user |

#### Description

The `.getCurrentUser()` function retrieves the current authenticated user. This function returns an object containing the details of the currently logged-in user.

#### Example
```4d
$currentUser:=cs.sfw_userManager.me.getCurrentUser()
```

<!--   logout() *********************   -->
## .logout()

### .logout()

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| result  | None  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | Logs out the current user |

#### Description

The `.logout()` function logs out the current user. This function clears the session data and ensures that the user is no longer authenticated.

#### Example
```4d
cs.sfw_userManager.me.logout()
```

<!--   register() *********************   -->
## .register()

### .register(username : Text; password : Text; email : Text) : Boolean

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| username  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The username for the new user |
| password  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The password for the new user |
| email  | Text  | <img src="DocImages/arrowRight.png"  height="25" align="center" /> | The email address for the new user |
| result  | Boolean  | <img src="DocImages/arrowLeft.png"  height="25" align="center" /> | `True` if registration is successful, `False` otherwise |

#### Description

The `.register()` function registers a new user with the given username, password, and email. This function adds the new user to the user database and returns `True` if the registration is successful, `False` otherwise.

#### Example
```4d
$username:="jane.doe"
$password:="securepassword"
$email:="jane.doe@example.com"
$isRegistered:=cs.sfw_userManager.me.register($username, $password, $email) // True or False
```