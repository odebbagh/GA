


$menusToRelease:=New collection:C1472
$mainMenu:=Create menu:C408
$menusToRelease.push($mainMenu)
For each ($vision; cs:C1710.sfw_definition.me.visions.orderBy("displayOrder desc"))
	If ($vision.allowedProfiles#Null:C1517) && ($vision.allowedProfiles.length>0)
		$displayVision:=False:C215
		For each ($authorizedProfile; cs:C1710.sfw_userManager.me.authorizedProfiles)
			$displayVision:=$displayVision || ($vision.allowedProfiles.indexOf($authorizedProfile)#-1)
		End for each 
	Else 
		$displayVision:=True:C214
	End if 
	If ($displayVision)
		$label:=ds:C1482.sfw_readXliff($vision.xliff; $vision.label)
		APPEND MENU ITEM:C411($mainMenu; $label)
		SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--tb:"+$vision.ident)
		If ($vision.icon#Null:C1517)
			SET MENU ITEM ICON:C984($mainMenu; -1; "Path:/RESOURCES/"+$vision.icon)
		End if 
		If (Form:C1466.currentTB=$vision.ident)
			SET MENU ITEM MARK:C208($mainMenu; -1; Char:C90(18))
		End if 
	End if 
End for each 

If (Right click:C712) && (Not:C34(Is compiled mode:C492)) && (cs:C1710.sfw_userManager.me.isDeveloper)
	APPEND MENU ITEM:C411($mainMenu; "-")
	$subMenu:=Create menu:C408
	$menusToRelease.push($subMenu)
	
	APPEND MENU ITEM:C411($subMenu; "Export the framework")
	SET MENU ITEM PARAMETER:C1004($subMenu; -1; "--sfw:export")
	APPEND MENU ITEM:C411($subMenu; "-")
	APPEND MENU ITEM:C411($subMenu; "Import the framework")
	SET MENU ITEM PARAMETER:C1004($subMenu; -1; "--sfw:import")
	
	APPEND MENU ITEM:C411($mainMenu; "Framework sfw"; $subMenu)
	
	
	APPEND MENU ITEM:C411($mainMenu; "Tracking")
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--debuglist")
	
	If (Application type:C494=4D Remote mode:K5:5)
		APPEND MENU ITEM:C411($mainMenu; "Reload project on server")
		SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--reload")
	End if 
	
End if 

OBJECT GET COORDINATES:C663(*; "pup_visions"; $left; $top; $right; $bottom)
$choose:=Dynamic pop up menu:C1006($mainMenu; ""; $left; $bottom)
For each ($menuToRelease; $menusToRelease)
	RELEASE MENU:C978($menuToRelease)
End for each 


Case of 
	: ($choose="--tb:@")
		$params:=Split string:C1554($choose; ":")
		Form:C1466.sfw.drawToolbar($params[1])
		
	: ($choose="--sfw:export")
		$sourceControler:=cs:C1710.sfw_sourceControler.new()
		$sourceControler.export()
		
	: ($choose="--sfw:import")
		$sourceControler:=cs:C1710.sfw_sourceControler.new()
		$sourceControler.import()
		
	: ($choose="--debuglist")
		//debugList_launch
		cs:C1710.sfw_tracker.me.open()
		
	: ($choose="--reload")
		ds:C1482.sfw_reloadProjectOnServer()
End case 

