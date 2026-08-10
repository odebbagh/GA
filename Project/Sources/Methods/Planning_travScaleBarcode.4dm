//%attributes = {}
#DECLARE($picture : Picture; $targetWidth : Integer; $targetHeight : Integer)->$scaled : Picture

var $height : Integer
var $width : Integer

$scaled:=$picture
PICTURE PROPERTIES:C457($picture; $width; $height)
If ($width>0) && ($height>0) && ($targetWidth>0) && ($targetHeight>0)
	TRANSFORM PICTURE:C988($picture; Scale:K61:2; Num:C11($targetWidth)/Num:C11($width); Num:C11($targetHeight)/Num:C11($height))
	$scaled:=$picture
End if 
