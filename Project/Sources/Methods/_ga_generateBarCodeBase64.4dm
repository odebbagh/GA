//%attributes = {}

/*
_ga_generateBarCodeBase64($parameters) : generate the barcode and return the
raw base64 text (for dfd templates / HTML img embedding).

Same input contract as _ga_generateBarCode (which returns the picture):
$parameters -> object with:
    - barcodeData : data to encode (usually moreData.barcodeData of the record)
    - text        : optional text to display under the barcode
*/

var $base64Full; $base64Data : Text
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

	$0:=$base64Data

End if
