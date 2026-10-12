// Barcode image generator. Callers keep using _ga_generateBarCode / _ga_generateBarCodeBase64.
// Toggle in _useLegacyWebArea: False = Zint 3.5.7 ; True = existing Web Area / JsBarcode.
// Zint 3.5.7 reads option keys as strings (type, format, height). Check $bar.error before using image.

singleton Class constructor
	
	
Function generatePicture($parameters : Object)->$picture : Picture
	
	var $params : Object
	$params:=This:C1470._normalizedParams($parameters)
	
	If (This:C1470._useLegacyWebArea())
		$picture:=This:C1470._generatePictureWebArea($params)
	Else 
		$picture:=This:C1470._generatePictureZint($params)
	End if 
	
	
Function generateBase64($parameters : Object)->$base64 : Text
	
	var $params : Object
	$params:=This:C1470._normalizedParams($parameters)
	
	If (This:C1470._useLegacyWebArea())
		$base64:=This:C1470._generateBase64WebArea($params)
	Else 
		$base64:=This:C1470._generateBase64Zint($params)
	End if 
	
	
	// Change False to True to restore the previous Web Area / JsBarcode implementation.
Function _useLegacyWebArea()->$useLegacy : Boolean
	If (False:C215)
		$useLegacy:=True:C214
	Else 
		$useLegacy:=False:C215
	End if 
	
	
Function _normalizedParams($parameters : Object)->$params : Object
	$params:=New object:C1471("barcodeData"; ""; "text"; "")
	
	If ($parameters=Null:C1517)
		return 
	End if 
	
	If (Not:C34(Undefined:C82($parameters.barcodeData)))
		$params.barcodeData:=String:C10($parameters.barcodeData)
	End if 
	
	If ($params.barcodeData="") && (Not:C34(Undefined:C82($parameters.data)))
		$params.barcodeData:=String:C10($parameters.data)
	End if 
	
	If (Not:C34(Undefined:C82($parameters.text)))
		$params.text:=String:C10($parameters.text)
	End if 
	
	
	// Previous implementation (Web Area offscreen + JsBarcode). Kept intact.
Function _generatePictureWebArea($urlParams : Object)->$finalImage : Picture
	var $base64Full; $base64Data; $type : Text
	var $imageBlob : Blob
	var $offScreanParams; $template : Object
	var $templatePath : Text
	
	$offScreanParams:=New object:C1471
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
		
	End if 
	
	
	// Previous implementation (Web Area offscreen + JsBarcode). Kept intact.
Function _generateBase64WebArea($urlParams : Object)->$base64Data : Text
	var $base64Full; $type : Text
	var $offScreanParams; $template : Object
	var $templatePath : Text
	
	$offScreanParams:=New object:C1471
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
		
	End if 
	
	
Function _generatePictureZint($params : Object)->$picture : Picture
	var $bar; $zintParams : Object
	var $value; $text : Text
	var $width; $height : Integer
	
	// Encoded value is ALWAYS moreData.barcodeData. $params.text is display-only.
	$value:=String:C10($params.barcodeData)
	If ($value="")
		return 
	End if 
	
	$text:=String:C10($params.text)
	
	// Use string keys: $obj.type is the 4D Type command and does not set the property.
	$zintParams:=New object:C1471
	OB SET:C1220($zintParams; "type"; 8)  // BARCODE_CODE39
	OB SET:C1220($zintParams; "format"; 2)  // PNG - SVG often does not display in form picture widgets
	OB SET:C1220($zintParams; "white_space"; 2)
	OB SET:C1220($zintParams; "height"; 40)
	OB SET:C1220($zintParams; "scale"; 2)
	OB SET:C1220($zintParams; "no_text"; True:C214)
	
	$bar:=ZINT($value; $zintParams)
	
	If ($bar#Null:C1517)
		PICTURE PROPERTIES:C457($bar.image; $width; $height)
		If ($width>0) && ($height>0)
			$picture:=This:C1470._applyDisplayText($bar.image; $text)
			return 
		End if 
	End if 
	
	// Zint produced nothing: keep the UI working with the existing encoder.
	$picture:=This:C1470._generatePictureWebArea($params)
	
	
Function _generateBase64Zint($params : Object)->$base64 : Text
	var $picture : Picture
	var $blob : Blob
	var $width; $height : Integer
	
	$base64:=""
	$picture:=This:C1470._generatePictureZint($params)
	PICTURE PROPERTIES:C457($picture; $width; $height)
	If ($width>0) && ($height>0)
		PICTURE TO BLOB:C692($picture; $blob; ".png")
		BASE64 ENCODE:C895($blob; $base64)
	End if 
	
	
	// Draws $text under the barcode picture without changing the encoded payload.
Function _applyDisplayText($barcode : Picture; $text : Text)->$picture : Picture
	var $width; $height; $labelHeight : Integer
	var $svg : Text
	
	$picture:=$barcode
	If ($text="")
		return 
	End if 
	
	PICTURE PROPERTIES:C457($barcode; $width; $height)
	If ($width=0) | ($height=0)
		return 
	End if 
	
	$labelHeight:=18
	$svg:=SVG_New($width; $height+$labelHeight)
	SVG_New_embedded_image($svg; $barcode; 0; 0)
	SVG_New_text($svg; $text; $width/2; $height+1; "Arial"; 12; Plain:K14:1; Align center:K42:3; "black")
	SVG EXPORT TO PICTURE:C1017($svg; $picture)
	SVG_CLEAR($svg)
	