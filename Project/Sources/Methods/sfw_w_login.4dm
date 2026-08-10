//%attributes = {}
//#Path {"path": "/login"}

#DECLARE($request : Object)->$result : Object
var $user : cs:C1710.PersonEntity
$result:=New object:C1471()


$login:=False:C215
If ($request.user.email#Null:C1517) & ($request.user.password#Null:C1517)
	$user:=ds:C1482.Person.query("email === :1"; $request.user.email).first()
	If ($user#Null:C1517)
		$login:=Verify password hash:C1534($request.user.password; $user.password)
	End if 
End if 

If ($login)
	$info:=New object:C1471("user"; $user.email)
	Session:C1714.setPrivileges($info)
	
	Use (Session:C1714.storage)
		Session:C1714.storage.user:=OB Copy:C1225($user.toObject(); ck shared:K85:29)
	End use 
	
	If (Session:C1714.storage.appointment#Null:C1517)
		WEB SEND HTTP REDIRECT:C659("/validate")
	Else 
		WEB SEND HTTP REDIRECT:C659("/home")
	End if 
Else 
	$result.view:="login.shtml"
End if 

