//%attributes = {}
// A barcode for the travellers, as base64 PNG. It is drawn sharp at the source - 3 pixels per bar,
// 72 pixels high, no quiet zone - and never stretched afterwards: stretching the 1-pixel bars of
// the encoder's default size to the template's box made them blurry and of uneven width. The
// template's picture box fits it. $targetWidth / $targetHeight are kept for the callers.
#DECLARE($parameters : Object; $targetWidth : Integer; $targetHeight : Integer)->$base64 : Text

$base64:=""
If ($parameters=Null:C1517)
	return 
End if 
$parameters.moduleWidth:=3
$parameters.height:=72
$parameters.margin:=0
$base64:=_ga_generateBarCodeBase64($parameters)
