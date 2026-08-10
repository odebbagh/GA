//%attributes = {}
var $qrImage : Picture
var $base64Image : Text
var $imageBlob : Blob
var $params:=New object:C1471

READ PICTURE FILE:C678(""; $qrImage; *)

PICTURE TO BLOB:C692($qrImage; $imageBlob; ".png")
BASE64 ENCODE:C895($imageBlob; $base64Image)

$base64Image:=_ga_urlEscape("data:image/png;base64,"+$base64Image)
$params.url:="file:///C:/Users/HP/Desktop/GoldenAltos/Resources/barCode_decoder.html?image="+$base64Image

//$params.base64Image:=$base64Image

// Add a callback method called on event
$params.onEvent:=Formula:C1597(_ga_qrBarCodeUtil("decoder"))

$data:=WA Run offscreen area:C1727($params)


ALERT:C41("Contenu du QR Code : "+$data)
