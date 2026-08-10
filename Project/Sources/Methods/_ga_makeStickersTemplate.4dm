//%attributes = {}

/*
Cal Stickers Template

*/
If (True:C214)
	var $formulaStrings : Collection
	var $context; $options : Object
	var $wpDoc : Object
	var $formulaString : Text
	$wpDoc:=WP New:C1317()
	$context:=New object:C1471()
	$options:=New object:C1471()
	$formulaStrings:=New collection:C1472("String(This.data[0].assignedID)"; \
		"String(This.data[0].model)"; \
		"String(This.data[0].serialNumber)"; \
		"String(This.data[0].lastCalDate)"; \
		"String(This.data[0].nextCalDate));")
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/equipmentSticker.4wp")
	
	$options.anchoredTextAreas:="anchored"  //inline"
	
	$template:=WP Import document:C1318($file.platformPath; $options)
	
	WP SET ATTRIBUTES:C1342($template; wk layout unit:K81:78; wk unit cm:K81:135)
	
	
	For ($i; 0; WP Get elements:C1550($template; wk type text box:K81:372).length-1)
		
		$textbox:=WP Get elements:C1550($template; wk type text box:K81:372)[$i]
		WP SET ATTRIBUTES:C1342($textbox; wk anchor horizontal align:K81:237; wk left:K81:95)
		$formulas:=WP Get formulas:C1702($textbox)
		
		For ($j; 0; $formulas.length-1)
			
			var $myFormula : Object
			//$formulaString:=Replace string($formulaStrings[$j]; "0"; String($i))
			
			Case of 
					
				: ($j=0)
					$myFormula:=Formula:C1597(String:C10(This:C1470.data[$i].assignedID))
					
				: ($j=1)
					$myFormula:=Formula:C1597(String:C10(This:C1470.data[$i].model))
					
				: ($j=2)
					$myFormula:=Formula:C1597(String:C10(This:C1470.data[$i].serialNumber))
					
				: ($j=3)
					$myFormula:=Formula:C1597(String:C10(This:C1470.data[$i].lastCalDate))
					
				: ($j=4)
					$myFormula:=Formula:C1597(String:C10(This:C1470.data[$i].tech))
					
				: ($j=5)
					$myFormula:=Formula:C1597(String:C10(This:C1470.data[$i].nextCalDate))
					
			End case 
			
			WP INSERT FORMULA:C1703($formulas[$j].range; $myFormula; wk replace:K81:177)
			
		End for 
		
		
		$formulas:=WP Get formulas:C1702($textbox)
		
		$hor_first:=0
		$hor_second:=6.8
		$hor_third:=13.6
		
		Case of 
				
			: ($i=0) | ($i=3) | ($i=6) | ($i=9) | ($i=12) | ($i=15) | ($i=18)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor horizontal offset:K81:236; $hor_first)
				
			: ($i=1) | ($i=4) | ($i=7) | ($i=10) | ($i=13) | ($i=16) | ($i=19)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor horizontal offset:K81:236; $hor_second)
				
			: ($i=2) | ($i=5) | ($i=8) | ($i=11) | ($i=14) | ($i=17) | ($i=20)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor horizontal offset:K81:236; $hor_third)
				
		End case 
		
		$ver_1:=1
		$ver_2:=5
		$ver_3:=9
		$ver_4:=13
		$ver_5:=17
		$ver_6:=21
		$ver_7:=25
		
		Case of 
				
			: ($i=0) | ($i=1) | ($i=2)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor vertical offset:K81:238; $ver_1)
				
			: ($i=3) | ($i=4) | ($i=5)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor vertical offset:K81:238; $ver_2)
				
			: ($i=6) | ($i=7) | ($i=8)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor vertical offset:K81:238; $ver_3)
				
			: ($i=9) | ($i=10) | ($i=11)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor vertical offset:K81:238; $ver_4)
				
			: ($i=12) | ($i=13) | ($i=14)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor vertical offset:K81:238; $ver_5)
				
			: ($i=15) | ($i=16) | ($i=17)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor vertical offset:K81:238; $ver_6)
				
			: ($i=18) | ($i=19) | ($i=20)
				
				WP SET ATTRIBUTES:C1342($textbox; wk anchor vertical offset:K81:238; $ver_7)
				
		End case 
		
	End for 
	
	WP COMPUTE FORMULAS:C1707($template)
	WP EXPORT DOCUMENT:C1337($template; $file.platformPath; wk 4wp:K81:4)
	
	SET PRINT PREVIEW:C364(True:C214)
	WP PRINT:C1343($template; wk recompute expressions:K81:311)
	
End if 


