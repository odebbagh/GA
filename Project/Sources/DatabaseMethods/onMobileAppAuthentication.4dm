#DECLARE($request : Object)->$response : Object

// $request // Informations provided by mobile application
$response:=New object:C1471  // Informations returned to mobile application

// Check user email
If ($request.email#Null:C1517)
	$user:=ds:C1482.Person.query("email = :1"; $request.email)
	If ($user.length=1)
		$response.success:=True:C214
		$response.userInfo:=New object:C1471(\
			"email"; $request.email; \
			"UUID"; $user.first().UUID; \
			"stmp"; cs:C1710.sfw_stmp.me.build(Current date:C33; ?00:00:00?))
	Else 
		$response.success:=False:C215
	End if 
Else 
	$response.success:=False:C215
End if 

// Optional message to display on mobile App.
If ($response.success)
	$response.statusText:=ds:C1482.sfw_readXliff("mobile.connected"; "You are successfully authenticated")
Else 
	$response.statusText:=ds:C1482.sfw_readXliff("mobile.notAuthorized"; "Sorry, you are not authorized to use this application")
End if 
