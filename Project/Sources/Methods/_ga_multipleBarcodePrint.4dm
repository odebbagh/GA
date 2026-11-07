//%attributes = {}
/*
_ga_multipleBarcodePrint
Print one Code 39 (moreData.barcodeData) per page for every staff currently in the list.
Page size follows the printer selected in PRINT SETTINGS so the same job works on a
desktop printer or a badge / label printer.
*/

If (Form:C1466.sfw.lb_items.length=0)
	return 
End if 

PRINT SETTINGS:C106(2)
If (OK=0)
	return 
End if 

SET PRINT PREVIEW:C364(False:C215)

var $wp : Object
var $parameters : Object
var $barcode : Picture
var $paperWidth; $paperHeight; $margin; $usableWidth; $usableHeight; $scale : Real
var $picWidth; $picHeight : Integer
var $barcodeData; $label : Text
var $firstPage : Boolean

GET PRINTABLE AREA:C703($paperHeight; $paperWidth)
If ($paperWidth<=0) | ($paperHeight<=0)
	GET PRINT OPTION:C734(Paper option:K47:1; $paperWidth; $paperHeight)
End if 
If ($paperWidth<=0) | ($paperHeight<=0)
	$paperWidth:=612
	$paperHeight:=792
End if 

$margin:=8
$usableWidth:=$paperWidth-($margin*2)
$usableHeight:=$paperHeight-($margin*2)
If ($usableWidth<10)
	$usableWidth:=$paperWidth
End if 
If ($usableHeight<10)
	$usableHeight:=$paperHeight
End if 

$wp:=WP New:C1317()
WP SET ATTRIBUTES:C1342($wp; wk layout unit:K81:78; wk unit pt:K81:136)
WP SET ATTRIBUTES:C1342($wp; wk page width:K81:262; $paperWidth)
WP SET ATTRIBUTES:C1342($wp; wk page height:K81:263; $paperHeight)
WP SET ATTRIBUTES:C1342($wp; wk page margin left:K81:258; $margin)
WP SET ATTRIBUTES:C1342($wp; wk page margin right:K81:260; $margin)
WP SET ATTRIBUTES:C1342($wp; wk page margin top:K81:259; $margin)
WP SET ATTRIBUTES:C1342($wp; wk page margin bottom:K81:261; $margin)
WP SET ATTRIBUTES:C1342($wp; wk text align:K81:49; wk center:K81:99)

$parameters:=New object:C1471()
$firstPage:=True:C214

For each ($record; Form:C1466.sfw.lb_items)
	
	$barcodeData:=""
	If ($record.moreData#Null:C1517)
		$barcodeData:=String:C10($record.moreData.barcodeData)
	End if 
	If ($barcodeData="")
		continue 
	End if 
	
	$label:=String:C10($record.firstName)+" "+String:C10($record.lastName)
	$parameters.data:=$barcodeData
	$parameters.text:=$label
	$barcode:=_ga_generateBarCode($parameters)
	
	If (Picture size:C356($barcode)=0)
		continue 
	End if 
	
	PICTURE PROPERTIES:C457($barcode; $picWidth; $picHeight)
	If ($picWidth>0) && ($picHeight>0) && ($usableWidth>0) && ($usableHeight>0)
		$scale:=$usableWidth/$picWidth
		If (($picHeight*$scale)>$usableHeight)
			$scale:=$usableHeight/$picHeight
		End if 
		TRANSFORM PICTURE:C988($barcode; Scale:K61:2; $scale; $scale)
	End if 
	
	If (Not:C34($firstPage))
		WP INSERT BREAK:C1413($wp; wk page break:K81:188; wk append:K81:179)
	End if 
	$firstPage:=False:C215
	
	WP INSERT PICTURE:C1437($wp; $barcode; wk append:K81:179)
	
End for each 

If ($firstPage)
	cs:C1710.sfw_dialog.me.alert("No barcodeData found in the current list.")
	return 
End if 

WP PRINT:C1343($wp)

/* Plugin path kept for reference — encoding now goes through _ga_generateBarCode (Zint).
$Zint_Params:=New object
OB SET($Zint_Params; ZINT_FORMAT; ZINT_Format_SVG)
OB SET($zint_params; ZINT_WHITE_SPACE; 1)
OB SET($Zint_Params; ZINT_NO_TEXT; False)
OB SET($zint_params; ZINT_HEIGHT; 35)
OB SET($zint_params; ZINT_SCALE; 0.2)
OB SET($Zint_Params; ZINT_TYPE; BARCODE_CODE39)
$bar:=ZINT($parameters.data; $Zint_Params)
$barcode:=$bar.image
*/
