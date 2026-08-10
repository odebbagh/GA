Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		
		Case of 
			: (Application type:C494=4D Remote mode:K5:5)
				$format:="path:"+cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogo
			: (cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogoLocal#Null:C1517)
				$format:="path:"+cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogoLocal
			Else 
				$format:="path:"+cs:C1710.sfw_definition.me.globalParameters.panel.defaultLogo
		End case 
		
		
		
		OBJECT SET FORMAT:C236(*; "mainLogo"; $format)
		OBJECT GET COORDINATES:C663(*; "mainLogo"; $gMainLogo; $hMainLogo; $dMainLogo; $bMainLogo)
		OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubForm; $heightSubform)
		$widthMainLogo:=$dMainLogo-$gMainLogo
		$heightMainLogo:=$bMainLogo-$hMainLogo
		
		
		Case of 
			: (Storage:C1525.sfwDefinition.extras=Null:C1517)
			: (Storage:C1525.sfwDefinition.extras.sfw_panel_default=Null:C1517)
			Else 
				$file:=String:C10(Storage:C1525.sfwDefinition.extras.sfw_panel_default.file)
				$format:="path:/RESOURCES/"+$file
				OBJECT SET FORMAT:C236(*; "mainLogo"; $format)
				
				$width:=Num:C11(Storage:C1525.sfwDefinition.extras.sfw_panel_default.width)
				$height:=Num:C11(Storage:C1525.sfwDefinition.extras.sfw_panel_default.height)
				If ($width#0) & ($height#0)
					$widthMainLogo:=$width
					$heightMainLogo:=$height
				End if 
		End case 
		
		
		OBJECT SET COORDINATES:C1248(*; "mainLogo"; \
			($widthSubForm/2)-($widthMainLogo/2); \
			($heightSubform/2)-($heightMainLogo/2); \
			($widthSubForm/2)+($widthMainLogo/2); \
			($heightSubform/2)+($heightMainLogo/2))
		
End case 

