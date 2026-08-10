//%attributes = {}
#DECLARE($parameters : Object; $targetWidth : Integer; $targetHeight : Integer)->$base64 : Text

var $barcodePicture : Picture
var $blob : Blob
var $generated : Text
var $scaled : Picture

$base64:=""
$generated:=_ga_generateBarCodeBase64($parameters)

If ($generated#"")
	BASE64 DECODE:C896($generated; $blob)
	BLOB TO PICTURE:C682($blob; $barcodePicture)
	$scaled:=Planning_travScaleBarcode($barcodePicture; $targetWidth; $targetHeight)
	$base64:=Planning_travPicToBase64($scaled)
End if 
