$resize:=False:C215

If (Form:C1466#Null:C1517)
	
	Case of 
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			$resize:=True:C214
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			If (FORM Event:C1606.objectName="vTabBar_@")
				$format:=OBJECT Get format:C894(*; FORM Event:C1606.objectName)
				$params:=Split string:C1554($format; ";")
				$num:=Num:C11($params[0])
				CALL SUBFORM CONTAINER:C1086(-99000-$num)
			End if 
			
	End case 
	
	If ($resize)
		If (Form:C1466.currentPage=Null:C1517)
			Form:C1466.currentPage:=1
		End if 
		CALL SUBFORM CONTAINER:C1086(-99000-Form:C1466.currentPage)
		OBJECT SET VISIBLE:C603(*; "vTabBar_@"; False:C215)
		$i:=0
		$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
		
		For each ($button; Form:C1466.buttons)
			If ($button.allowedProfiles#Null:C1517) && ($button.allowedProfiles.length>0)
				$tabAllowed:=False:C215
				For each ($authorizedProfile; $authorizedProfiles)
					$tabAllowed:=$tabAllowed || ($button.allowedProfiles.indexOf($authorizedProfile)#-1)
				End for each 
			Else 
				$tabAllowed:=True:C214
			End if 
			If ($tabAllowed)
				$i:=$i+1
				$buttonName:="vTabBar_"+String:C10($i)
				OBJECT SET VISIBLE:C603(*; $buttonName; True:C214)
				If (Position:C15("/"; $button.pict)>0)
					$format:=String:C10($button.page)+";#"+$button.pict+";;4;0;1;8;;;;0;;4"
				Else 
					$format:=String:C10($button.page)+";#image/skin/rainbow/btn4states/"+$button.pict+";;4;0;1;8;;;;0;;4"
				End if 
				
				OBJECT SET FORMAT:C236(*; $buttonName; $format)
				If (Form:C1466.currentPage=$button.page)
					(OBJECT Get pointer:C1124(Object named:K67:5; $buttonName)->):=1
				End if 
				If ($button.label#Null:C1517)
					OBJECT SET HELP TIP:C1181(*; $buttonName; $button.label)
				End if 
			End if 
		End for each 
	End if 
	
End if 