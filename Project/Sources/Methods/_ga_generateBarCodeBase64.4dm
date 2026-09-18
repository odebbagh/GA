//%attributes = {}

/*
_ga_generateBarCodeBase64($parameters) : generate the barcode and return the
raw base64 text (for dfd templates / HTML img embedding).

Same input contract as _ga_generateBarCode (which returns the picture):
$parameters -> object with:
    - barcodeData : data to encode (usually moreData.barcodeData of the record)
    - text        : optional text to display under the barcode

Engine switch lives in cs.Util_BarcodeGenerator._useLegacyWebArea
*/

#DECLARE($parameters : Object)->$base64Data : Text

$base64Data:=cs:C1710.Util_BarcodeGenerator.me.generateBase64($parameters)
