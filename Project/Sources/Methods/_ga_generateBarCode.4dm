//%attributes = {}

/*
_ga_generateBarCode($parameters) : generate the barcode 

$parameters -> is an object with two attrubutes :
    - data : data to encode. It is always moreData.barcode of the record
    - text : the text to display on the barcode. If you don't want a text to display you can ignore this attribute

Engine switch lives in cs.Util_BarcodeGenerator._useLegacyWebArea
*/

#DECLARE($parameters : Object)->$finalImage : Picture

$finalImage:=cs:C1710.Util_BarcodeGenerator.me.generatePicture($parameters)
