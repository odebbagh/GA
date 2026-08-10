//%attributes = {}
#DECLARE($resourcePath : Text)->$base64 : Text

var $esdFile : 4D:C1709.File
var $picture : Picture

$base64:=""
$esdFile:=Folder:C1567(fk resources folder:K87:11).file($resourcePath)
If ($esdFile.exists)
	READ PICTURE FILE:C678($esdFile.platformPath; $picture)
	$base64:=Planning_travPicToBase64($picture)
End if 
