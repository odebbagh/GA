Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		var $certifications; $barcode : Picture
		var $bar; $Zint_Params : Object
		var $barcodeType : Text
		var $parameters : Object:=New object:C1471()
		
		//MARK: employee information
		Form:C1466.employee:=New object:C1471(\
			"firstName"; [Staff:135]firstName:4; \
			"lastName"; [Staff:135]lastName:5; \
			"code"; [Staff:135]code:10; \
			"barcodeData"; [Staff:135]moreData:11.barcodeData\
			)
		
		
		//MARK: employee certifications
		$svg:=SVG_New(180; 240; "Badge"; "Skills"; True:C214; Scaled to fit:K6:2)
		
		$v_pos:=0
		$h_pos:=1
		
		$textSpacing:=10
		
		$assignments:=ds:C1482.CertificationAssignment.query("UUID_Staff = :1"; [Staff:135]UUID:1)
		
		$BlankLines:=20-$assignments.length
		
		For each ($assignment; $assignments)
			SVG_New_textArea($svg; $assignment.certification.name; $h_pos; $v_pos; 130; 12; "Arial"; 9; Bold:K14:2; Align left:K42:2)
			SVG_New_textArea($svg; String:C10(cs:C1710.sfw_stmp.me.getDate($assignment.certificationDate); Internal date short:K1:7); $h_pos+130; $v_pos; 45; 12; "Arial"; 9; Bold:K14:2; Align right:K42:4)
			
			$v_pos:=$v_pos+$textSpacing
		End for each 
		
		Case of 
			: ($BlankLines>0)
				For ($i; 1; $BlankLines)
					SVG_New_textArea($svg; "xxxx"; $h_pos; $v_pos; 80; 20; "Times"; 9; Plain:K14:1; Align left:K42:2)
					$v_pos:=$v_pos+$textSpacing
				End for 
		End case 
		
		Form:C1466.certifications:=SVG_Export_to_picture($svg)
		SVG_CLEAR($svg)
		
		//MARK: barcode
		If (False:C215)  //using plugin
			$barcodeType:="Code39"
			
			$Zint_Params:=New object:C1471
			
			OB SET:C1220($Zint_Params; ZINT_FORMAT; ZINT_Format_SVG)
			OB SET:C1220($zint_params; ZINT_WHITE_SPACE; 5)
			
			
			OB SET:C1220($Zint_Params; ZINT_NO_TEXT; False:C215)
			OB SET:C1220($zint_params; ZINT_HEIGHT; 20)
			
			OB SET:C1220($Zint_Params; ZINT_TYPE; BARCODE_CODE39)
			
			$bar:=ZINT(Form:C1466.employee.code; $Zint_Params)
			
			$barcode:=$bar.image
			
		Else   //using offscreen webArea
			
			$parameters.data:=Form:C1466.employee.barcodeData
			$parameters.text:=""
			
			$barcode:=_ga_generateBarCode($parameters)
			
		End if 
		
		PICTURE PROPERTIES:C457($barcode; $PicWidth; $PicHeight)
		
		OBJECT GET COORDINATES:C663(*; "barcode"; $left; $top; $right; $bottom)
		
		$ObjectWidth:=($right-$left)
		$ObjectHeight:=($bottom-$top)
		
		If ($PicWidth>$ObjectWidth) & ($ObjectWidth#0)
			TRANSFORM PICTURE:C988($barcode; Scale:K61:2; $ObjectWidth/$PicWidth; $ObjectHeight/$PicHeight)
		End if 
		
		Form:C1466.barcode:=$barcode
		
End case 