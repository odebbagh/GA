//%attributes = {}

/*
_ga_generateBarCode($parameters) : generate the barcode 

$parameters -> is an object with two attrubutes :
    - data : data to encode. It is always moreData.barcode of the record
    - text : the text to display on the barcode. If you don't want a text to display you can ignore this attribute

*/

var $base64Full; $base64Data : Text
var $imageBlob : Blob
var $finalImage : Picture
var $text : Text:=""
var $offScreanParams:=New object:C1471
var $urlParams:=New object:C1471()
$urlParams:=$1
If (Undefined:C82($urlParams.text))
	$urlParams.text:=""
End if 
$type:="CODE39"

$template:=Folder:C1567(fk resources folder:K87:11).file("barCode_encoder.html")

If ($template.exists) & ($urlParams.barcodeData#"") & (Not:C34(Undefined:C82($urlParams.barcodeData)))
	
	$templatePath:=Convert path system to POSIX:C1106($template.platformPath)
	
	$offScreanParams.url:="file://"+$templatePath+"?type="+$type+"&value="+$urlParams.barcodeData+"&text="+String:C10($urlParams.text)
	
	$offScreanParams.onEvent:=Formula:C1597(_ga_qrBarCodeUtil("GenerateBarCode"))
	
	$base64Full:=WA Run offscreen area:C1727($offScreanParams)
	
	$base64Data:=Substring:C12($base64Full; Position:C15(","; $base64Full)+1)
	
	BASE64 DECODE:C896($base64Data; $imageBlob)
	
	BLOB TO PICTURE:C682($imageBlob; $finalImage)

	$0:=$finalImage

End if




