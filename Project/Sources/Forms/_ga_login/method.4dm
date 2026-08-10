

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		var $logo : Picture
		var $logoFile : 4D:C1709.File
		var $path : Text
		
		Case of 
			: (Application type:C494=4D Remote mode:K5:5)
				$path:=(cs:C1710.sfw_definition.me.globalParameters.login.defaultLogo) ? cs:C1710.sfw_definition.me.globalParameters.login.defaultLogo : cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogo
				
			: (cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogoLocal#Null:C1517) || (cs:C1710.sfw_definition.me.globalParameters.login.defaultLogoLocal#Null:C1517)
				$path:=(cs:C1710.sfw_definition.me.globalParameters.login.defaultLogoLocal) ? cs:C1710.sfw_definition.me.globalParameters.login.defaultLogoLocal : cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogoLocal
				
			Else 
				$path:=(cs:C1710.sfw_definition.me.globalParameters.login.defaultLogo) ? cs:C1710.sfw_definition.me.globalParameters.login.defaultLogo : cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogo
		End case 
		
		$logoFile:=File:C1566($path; fk posix path:K87:1)
		
		If ($logoFile.exists)
			READ PICTURE FILE:C678($logoFile.platformPath; $logo)
		End if 
		Form:C1466.logo:=$logo
		
		Form:C1466.pup_users:=New object:C1471
		Form:C1466.pup_users.values:=New collection:C1472
		Form:C1466.pup_users.values:=Form:C1466.users.distinct("login")
		Form:C1466.pup_users.index:=-1
		Form:C1466.pup_users.currentValue:=ds:C1482.sfw_readXliff("user.login.select")
		Form:C1466.password:=""
		OBJECT SET FONT:C164(*; "input_password"; "%password")
		
		Form:C1466.storeAccess:=False:C215
End case 
OBJECT SET ENABLED:C1123(*; "btn_login"; (Form:C1466.password#"") && (Form:C1466.pup_users.index>=0))
OBJECT SET VISIBLE:C603(*; "bHelp"; False:C215)

/*
OBJECT SET VISIBLE(*; "bHelp"; False)

Case of 
: (FORM Event.code=On Load)
var $logo : Picture
var $logoFile : 4D.File
var $path : Text
var $failConnect : Integer

Case of 
: (Application type=4D Remote mode)
$path:=(cs.sfw_definition.me.globalParameters.login.defaultLogo) ? cs.sfw_definition.me.globalParameters.login.defaultLogo : cs.sfw_definition.me.globalParameters.panel.defaultLogo

: (cs.sfw_definition.me.globalParameters.panel.defaultLogoLocal#Null) || (cs.sfw_definition.me.globalParameters.login.defaultLogoLocal#Null)
$path:=(cs.sfw_definition.me.globalParameters.login.defaultLogoLocal) ? cs.sfw_definition.me.globalParameters.login.defaultLogoLocal : cs.sfw_definition.me.globalParameters.panel.defaultLogoLocal

Else 
$path:=(cs.sfw_definition.me.globalParameters.login.defaultLogo) ? cs.sfw_definition.me.globalParameters.login.defaultLogo : cs.sfw_definition.me.globalParameters.panel.defaultLogo
End case 

$logoFile:=File($path; fk posix path)

If ($logoFile.exists)
READ PICTURE FILE($logoFile.platformPath; $logo)
End if 
Form.logo:=$logo

Form.failedConnect:=$failConnect
Form.user:=""
Form.password:=""
OBJECT SET FONT(*; "input_password"; "%password")

Form.storeAccess:=False

OBJECT SET ENABLED(*; "input_user"; False)
//OBJECT SET ENABLED(*; "bOk"; (Form.password#"") && (Form.user#""))  // (Form.pup_users.index>=0))
OBJECT SET ENABLED(*; "input_password"; (Form.user#""))  //(Form.pup_users.index>=0)

//SET TIMER(1)

: (Form event code=On Timer)
/*
SET TIMER(0)

If (Form.user="")

$OK:=_ga_openScannerSerialPort

If ($OK=1)

$userFined:=False
While (Form.user="") | ($userFined=False)

RECEIVE BUFFER($data)

If (Length($data)>0)

Case of 

: (Substring($data; 23)="==")

$data:=Uppercase(_ga_UUID22To32($data))
Form.userEntity:=ds.sfw_User.query("UUID = :1"; $data).first()

Else 

Form.userEntity:=ds.sfw_User.query("login = :1"; $data).first()

End case 

If (Form.userEntity#Null)
Form.user:=Form.userEntity.login
SET TIMER(0)
SET CHANNEL(11)
$userFined:=True
Else 
Form.user:=""
$userFined:=False
//SET TIMER(30)
End if 

End if 

End while 

Else 

SET TIMER(30)
Form.failedConnect:=Form.failedConnect+1
If (Form.failedConnect>5)
ALERT("Erreur : failed to Connect to the Scanner!Restart the app.")
SET TIMER(0)
End if 

//ALERT("Erreur : failed Set channel!")
End if 



End if 
//SET TIMER(0)
*/
End case 

OBJECT SET ENABLED(*; "input_user"; False)
//OBJECT SET ENABLED(*; "bOk"; (Form.password#"") && (Form.user#""))  // (Form.pup_users.index>=0))
OBJECT SET ENABLED(*; "input_password"; (Form.user#""))  //(Form.pup_users.index>=0)

*/


