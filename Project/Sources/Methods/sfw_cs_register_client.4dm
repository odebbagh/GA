//%attributes = {}
var $uuid : Text

If (Storage:C1525.register=Null:C1517)
	If (Application type:C494=4D Remote mode:K5:5)
		$uuid:=Generate UUID:C1066
	Else 
		$uuid:=""
	End if 
	Use (Storage:C1525)
		Storage:C1525.register:=New shared object:C1526("uuid"; $uuid)
	End use 
End if 
If (String:C10(Storage:C1525.register.uuid)#"")
	REGISTER CLIENT:C648(Storage:C1525.register.uuid)
End if 

