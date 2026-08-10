property colors : Collection


shared singleton Class constructor
	
	This:C1470.load()
	
shared Function load()
	var $file : 4D:C1709.File
	var $pict : Picture
	
	$file:=File:C1566("/RESOURCES/sfw/colors/colors.json"; fk posix path:K87:1)
	If ($file.exists)
		$json:=JSON Parse:C1218($file.getText())
		This:C1470.colors:=$json.colors.copy(ck shared:K85:29)
		For each ($color; This:C1470.colors)
			$file:=File:C1566("/RESOURCES/sfw/colors/"+$color.name+".png"; fk posix path:K87:1)
			If (Not:C34($file.exists))
				$svg:=SVG_New(22; 22)  // SVG_New(24; 24)
				$rect:=SVG_New_rect($svg; 0; 0; 22; 22; 6; 6; $color.name; $color.name; 1)
				SVG EXPORT TO PICTURE:C1017($svg; $pict; Copy XML data source:K45:17)
				SVG_CLEAR($svg)
				PICTURE TO BLOB:C692($pict; $blob; ".png")
				$file.setContent($blob)
			Else 
				READ PICTURE FILE:C678($file.platformPath; $pict)
			End if 
			Use ($color)
				$color.picture:=$pict
				$color.rgb:=Formula from string:C1601("0x"+Substring:C12($color.hex; 2)).call()
			End use 
		End for each 
		For each ($color; This:C1470.colors)
			$file:=File:C1566("/RESOURCES/sfw/colors/"+$color.name+"-circle.png"; fk posix path:K87:1)
			If (Not:C34($file.exists))
				$svg:=SVG_New(22; 22)  // SVG_New(24; 24)
				$rect:=SVG_New_circle($svg; 11; 11; 6; $color.name; $color.name; 1)
				SVG EXPORT TO PICTURE:C1017($svg; $pict; Copy XML data source:K45:17)
				SVG_CLEAR($svg)
				PICTURE TO BLOB:C692($pict; $blob; ".png")
				$file.setContent($blob)
			Else 
				READ PICTURE FILE:C678($file.platformPath; $pict)
			End if 
			Use ($color)
				$color.pictureCircle:=$pict
			End use 
		End for each 
	End if 
	
shared Function getColorPictureByColor($color : Text)->$pict : Picture
	$colorName:=cs:C1710.sfw_htmlColor.me.getName($color)
	$oColor:=This:C1470.colors.query("name = :1"; $colorName).first()
	If ($oColor#Null:C1517)
		$pict:=$oColor.picture
	End if 
	
shared Function getColorPictureByName($colorName : Text)->$pict : Picture
	$oColor:=This:C1470.colors.query("name = :1"; $colorName).first()
	If ($oColor#Null:C1517)
		$pict:=$oColor.picture
	End if 
	
shared Function getName($hex : Text)->$name : Text
	
	$indices:=This:C1470.colors.indices("hex = :1"; $hex)
	If ($indices.length>0)
		$name:=This:C1470.colors[$indices[0]].name
	End if 
	
shared Function deployPup($hex : Text)->$color : Object
	If (Form:C1466.sfw.checkIsInModification())
		
		$lastDominant:=""
		$menusToRelease:=New collection:C1472
		$menu:=This:C1470.buildMenu($menusToRelease)
		
		$choose:=Dynamic pop up menu:C1006($menu; $hex)
		For each ($menuToRelease; $menusToRelease)
			RELEASE MENU:C978($menuToRelease)
		End for each 
		
		Case of 
			: ($choose="")
				$color:=This:C1470.colors.query("hex = :1"; $hex).first()
			Else 
				$indices:=This:C1470.colors.indices("hex = :1"; $choose)
				If ($indices.length>0)
					$color:=This:C1470.colors[$indices[0]]
				Else 
					$color:=New object:C1471
				End if 
		End case 
	Else 
		$indices:=This:C1470.colors.indices("hex = :1"; $hex)
		If ($indices.length>0)
			$color:=This:C1470.colors[$indices[0]]
		Else 
			$color:=New object:C1471
		End if 
	End if 
	
	
	
Function buildMenu($menusToRelease : Collection)->$menu : Text
	$menu:=Create menu:C408
	$menusToRelease.push($menu)
	If (Shift down:C543)
		$dominantes:=This:C1470.colors.distinct("dominant")
		For each ($dominant; $dominantes)
			$subMenu:=Create menu:C408
			$menusToRelease.push($subMenu)
			For each ($color; This:C1470.colors)
				If ($color.dominant=$dominant)
					APPEND MENU ITEM:C411($subMenu; $color.name; *)
					SET MENU ITEM ICON:C984($subMenu; -1; "path:/RESOURCES/sfw/colors/"+$color.name+".png")
					SET MENU ITEM PARAMETER:C1004($subMenu; -1; $color.hex)
					If ($color.hex=$hex)
						SET MENU ITEM MARK:C208($subMenu; -1; Char:C90(18))
						If (Is Windows:C1573)
							SET MENU ITEM STYLE:C425($subMenu; -1; Bold:K14:2)
						End if 
					End if 
				End if 
			End for each 
			APPEND MENU ITEM:C411($menu; $dominant; $subMenu; *)
			SET MENU ITEM ICON:C984($menu; -1; "path:/RESOURCES/sfw/colors/"+$dominant+".png")
			
		End for each 
	Else 
		For each ($color; This:C1470.colors)
			If ($lastDominant#$color.dominant)
				APPEND MENU ITEM:C411($menu; "-")
				APPEND MENU ITEM:C411($menu; $color.dominant; *)
				DISABLE MENU ITEM:C150($menu; -1)
				$lastDominant:=$color.dominant
			End if 
			APPEND MENU ITEM:C411($menu; $color.name; *)
			SET MENU ITEM ICON:C984($menu; -1; "path:/RESOURCES/sfw/colors/"+$color.name+".png")
			SET MENU ITEM PARAMETER:C1004($menu; -1; $color.hex)
			If ($color.hex=$hex)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			End if 
		End for each 
	End if 
	
	
Function getLuminence($color : Text)->$luminence : Real
	
	If ($color="#@")
	Else 
		$indices:=This:C1470.colors.indices("name = :1"; $color)
		If ($indices.length>0)
			$color:=This:C1470.colors[$indices[0]].hex
		Else 
			$color:="#FF0000"
		End if 
	End if 
	$r:=Formula from string:C1601("0x"+Substring:C12($color; 2; 2)).call()
	$v:=Formula from string:C1601("0x"+Substring:C12($color; 4; 2)).call()
	$b:=Formula from string:C1601("0x"+Substring:C12($color; 6; 2)).call()
	$cmax:=$r/255
	If (($v/255)>$cmax)
		$cmax:=$v/255
	End if 
	If (($b/255)>$cmax)
		$cmax:=$b/255
	End if 
	$cmin:=$r/255
	If (($v/255)<$cmin)
		$cmin:=$v/255
	End if 
	If (($b/255)<$cmin)
		$cmin:=$b/255
	End if 
	$luminence:=($cmax+$cmin)/2
	
	