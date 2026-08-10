//%attributes = {}

var $base64Full; $base64Data : Text
var $imageBlob : Blob
var $finalImage : Picture

var $params:=New object:C1471

$type:="text"
$data:=ds:C1482.Customer.all().first().UUID  //"My name is Medard"
$params.url:="file:///C:/Users/HP/Desktop/GoldenAltos/Resources/qr_encoder.html?type="+$type+"&data="+$data

// Add a callback method called on event
$params.onEvent:=Formula:C1597(_ga_qrBarCodeUtil("encoder"))

$base64Full:=WA Run offscreen area:C1727($params)

//Save QR image to file
$base64Data:=Substring:C12($base64Full; Position:C15(","; $base64Full)+1)

BASE64 DECODE:C896($base64Data; $imageBlob)

BLOB TO PICTURE:C682($imageBlob; $finalImage)

WRITE PICTURE FILE:C680("C:\\Users\\HP\\Desktop\\GoldenAltos\\resources\\QRCodes\\"+$data+".png"; $finalImage)

