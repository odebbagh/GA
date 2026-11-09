//%attributes = {}
// _uniqueLogin($wanted : Text) -> Text
// Returns $wanted, or $wanted_1 / $wanted_2... if that login is already taken.
// Same loop as sfw_UserEntity.setLogin, but usable before the entity exists.

#DECLARE($wanted : Text)->$login : Text

var $base : Text
var $suffix : Integer

$base:=$wanted
If ($base="")
	$base:="user"
End if

$login:=$base
$suffix:=0

While (ds:C1482.sfw_User.query("login = :1"; $login).first()#Null:C1517)
	$suffix:=$suffix+1
	$login:=$base+"_"+String:C10($suffix)
End while
