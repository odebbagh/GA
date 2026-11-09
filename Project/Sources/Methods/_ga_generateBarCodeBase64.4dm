//%attributes = {}

/*
_ga_generateBarCodeBase64($parameters) : generate the barcode and return the
raw base64 text (for dfd templates / HTML img embedding).

Same input contract as _ga_generateBarCode (which returns the picture):
$parameters -> object with:
    - barcodeData : data to encode (usually moreData.barcodeData of the record)
    - text        : optional text to display under the barcode
    - moduleWidth, height, margin : optional sizes in pixels (bar width, bar height, quiet
      zone); the encoder's defaults (1, 80, 10) when absent

Without sizes: cs.Util_BarcodeGenerator (Zint; engine switch in _useLegacyWebArea).
With sizes (the traveller barcodes, Planning_travBarcodeBase64): the JsBarcode web area,
since Zint here draws one fixed size and the travellers are laid out for these bars.
*/

#DECLARE($parameters : Object)->$base64Data : Text

var $base64Full; $templatePath; $type : Text
var $offScreanParams; $urlParams : Object
var $template : 4D:C1709.File

If ($parameters=Null:C1517)
	return 
End if 

If (Num:C11($parameters.moduleWidth)=0) && (Num:C11($parameters.height)=0) && ($parameters.margin=Null:C1517)
	$base64Data:=cs:C1710.Util_BarcodeGenerator.me.generateBase64($parameters)
	return 
End if 

$urlParams:=$parameters
If (Undefined:C82($urlParams.text))
	$urlParams.text:=""
End if 
$type:="CODE39"

$template:=Folder:C1567(fk resources folder:K87:11).file("barCode_encoder.html")

If ($template.exists) && (Not:C34(Undefined:C82($urlParams.barcodeData))) && (String:C10($urlParams.barcodeData)#"")
	
	$templatePath:=Convert path system to POSIX:C1106($template.platformPath)
	
	$offScreanParams:=New object:C1471
	$offScreanParams.url:="file://"+$templatePath+"?type="+$type+"&value="+String:C10($urlParams.barcodeData)+"&text="+String:C10($urlParams.text)+Choose:C955(Num:C11($urlParams.moduleWidth)>0; "&w="+String:C10($urlParams.moduleWidth); "")+Choose:C955(Num:C11($urlParams.height)>0; "&h="+String:C10($urlParams.height); "")+Choose:C955($urlParams.margin#Null:C1517; "&m="+String:C10($urlParams.margin); "")  // optional sizes (moduleWidth, height, margin)
	
	$offScreanParams.onEvent:=Formula:C1597(_ga_qrBarCodeUtil("GenerateBarCode"))
	
	$base64Full:=WA Run offscreen area:C1727($offScreanParams)
	
	$base64Data:=Substring:C12($base64Full; Position:C15(","; $base64Full)+1)
	
End if 
