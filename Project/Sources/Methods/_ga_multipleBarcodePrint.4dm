//%attributes = {}
/*
_ga_multipleBarcodePrint

*/


$start:=Current time:C178
If (Form:C1466.sfw.lb_items.length>0)
	var $wp : Object:=WP New:C1317()
	var $parameters : Object:=New object:C1471()
	
	//$width_us_letter_r:=10  //21.59
	//$height_us_letter_r:=10  //27.94
	
	//WP SET ATTRIBUTES($wp; wk layout unit; wk unit cm)
	
	//WP SET ATTRIBUTES($wp; wk page width; $width_us_letter_r; wk page height; $height_us_letter_r)  //; wk page orientation; wk portrait)
	
	WP SET ATTRIBUTES:C1342($wp; wk text align:K81:49; wk center:K81:99)
	
	$Zint_Params:=New object:C1471
	
	OB SET:C1220($Zint_Params; ZINT_FORMAT; ZINT_Format_SVG)
	OB SET:C1220($zint_params; ZINT_WHITE_SPACE; 1)
	
	
	OB SET:C1220($Zint_Params; ZINT_NO_TEXT; False:C215)
	OB SET:C1220($zint_params; ZINT_HEIGHT; 35)
	OB SET:C1220($zint_params; ZINT_SCALE; 0.2)
	OB SET:C1220($Zint_Params; ZINT_TYPE; BARCODE_CODE39)
	//OB SET($Zint_Params; ZINT_PRIMARY; $parameters.text)
	
	For each ($record; Form:C1466.sfw.lb_items)
		
		If (True:C214)
			
			$parameters.data:=$record.moreData.barcodeData
			
			$parameters.text:=$record.firstName+" "+$record.lastName
			
			$barcode:=_ga_generateBarCode($parameters)
			
		Else 
			
			$bar:=ZINT($parameters.data; $Zint_Params)
			$barcode:=$bar.image
			
		End if 
		
		//If (Picture size($barcode)>0)
		
		WP Insert picture:C1437($wp; $barcode; wk append:K81:179)
		
		//$paragraph:=WP Get elements($wp; wk type image)
		
		// Assuming $pictRef is a reference to your image element
		//WP SET ATTRIBUTES($paragraph[$paragraph.length-1]; wk image alternate text; "NOthing")
		
		WP Insert break:C1413($wp; wk page break:K81:188; wk append:K81:179)
		
		//Else 
		
		//End if 
		
	End for each 
	
	//PRINT SETTINGS
	SET PRINT PREVIEW:C364(True:C214)
	//OPEN PRINTING JOB
	WP PRINT:C1343($wp)
	//CLOSE PRINTING JOB
	
	$end:=Current time:C178()
	$time:=$end-$start
	
	ALERT:C41("The pronting took : "+String:C10($time))
	
Else 
	
End if 
