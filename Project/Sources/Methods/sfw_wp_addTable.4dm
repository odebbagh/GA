//%attributes = {}
#DECLARE($WParea : Object;  ...  : Collection)


$range:=WP Text range:C1341($WParea; wk start text:K81:165; wk end text:K81:164)
$wpTable:=WP Insert table:C1473($range; wk append:K81:179; wk include in range:K81:180)


For ($objElement; 0; ${2}.length-1)
	
	$column:=WP Table insert columns:C1692($wpTable; $objElement+1; 1)
	
	$tabcell:=WP Table get columns:C1476($wpTable; $objElement+1)
	
	For each ($ob; ${2}[$objElement])
		
		Case of 
			: ($ob="text")
				WP SET TEXT:C1574($range; ${2}[$objElement][$ob]; wk append:K81:179)
				
			: ($ob="styleSheet")
				$styleSheet:=sfw_wp_addStyleSheet(${2}[$objElement][$ob])
				WP SET ATTRIBUTES:C1342($tabcell; wk style sheet:K81:63; $styleSheet)
				
			Else 
				
				WP SELECT:C1348($WParea; $tabcell)
				
				If ($ob="textAlign")
					
					WP SET ATTRIBUTES:C1342($tabcell; wk text align:K81:49; ${2}[$objElement][$ob])
					
				Else 
					INVOKE ACTION:C1439("column/"+$ob+"?value="+String:C10(${2}[$objElement][$ob]))
				End if 
				
				
		End case 
		
		
	End for each 
	
	
End for 

