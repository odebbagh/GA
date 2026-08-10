//%attributes = {}
#DECLARE($picture : Picture)->$base64 : Text

var $blob : Blob
var $width; $height : Integer

$base64:=""
PICTURE PROPERTIES:C457($picture; $width; $height)
If ($width>0) && ($height>0)
	PICTURE TO BLOB:C692($picture; $blob; ".png")
	BASE64 ENCODE:C895($blob; $base64)
End if 
