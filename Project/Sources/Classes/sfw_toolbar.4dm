Class extends sfw_foundations


property vision : Object
property refMenus : Collection
property searchbox : Text

Class constructor()
	Super:C1705()
	
	
	
Function formMethod()
	
	var $framework : cs:C1710.sfw_toolbar
	
	$framework:=Form:C1466.sfw
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			Case of 
				: (Application type:C494=4D Remote mode:K5:5)
					$format:=";path:"+cs:C1710.sfw_definition.me.globalParameters.toolbar.visionsLogo+";;4;1;1;4;0;0;0;0;0;1;1"
				: (cs:C1710.sfw_definition.me.globalParameters.toolbar.visionsLogoLocal#Null:C1517)
					$format:=";path:"+cs:C1710.sfw_definition.me.globalParameters.toolbar.visionsLogoLocal+";;4;1;1;4;0;0;0;0;0;1;1"
				Else 
					$format:=";path:"+cs:C1710.sfw_definition.me.globalParameters.toolbar.visionsLogo+";;4;1;1;4;0;0;0;0;0;1;1"
			End case 
			
			OBJECT SET FORMAT:C236(*; "pup_visions"; $format)
			$framework.drawToolbar($framework.vision.ident)
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			Case of 
				: (String:C10(FORM Event:C1606.objectName)="bToolbar_@")
					$framework.pushEntryButton()
					
				: (String:C10(FORM Event:C1606.objectName)="bCurrentUSer")
					$framework.pushCurrentUserButton()
					
				: (String:C10(FORM Event:C1606.objectName)="bNotifications")
					$framework.pushbNotifications()
					
				: (String:C10(FORM Event:C1606.objectName)="bToDoList")
					$framework.pushbToDoList()
					
			End case 
			
		: (FORM Event:C1606.code=On Mouse Enter:K2:33) && (String:C10(FORM Event:C1606.objectName)="bToolbar_@") && (False:C215)
			Form:C1466.tb_pupwindow:=Form:C1466.tb_pupwindow || 0
			If (Form:C1466.tb_currentObjectName#FORM Event:C1606.objectName)
				CALL FORM:C1391(Form:C1466.tb_pupwindow; "sfw_toolbar_closeTBPup")
				Form:C1466.tb_currentObjectName:=FORM Event:C1606.objectName
				OBJECT GET COORDINATES:C663(*; FORM Event:C1606.objectName; $g; $h; $d; $b)
				CONVERT COORDINATES:C1365($g; $b; XY Current form:K27:5; XY Main window:K27:8)
				$gap:=3
				Form:C1466.tb_pupwindow:=Open form window:C675("sfw_entryTBPup"; Pop up form window:K39:11; $g; $b+$gap)
				DIALOG:C40("sfw_entryTBPup"; Form:C1466; *)
			End if 
			
		: (FORM Event:C1606.code=On Mouse Leave:K2:34) && (False:C215)
			Form:C1466.tb_pupwindow:=Form:C1466.tb_pupwindow || 0
			CALL FORM:C1391(Form:C1466.tb_pupwindow; "sfw_toolbar_closeTBPup")
			
	End case 
	OBJECT GET COORDINATES:C663(*; "bkgd_vision"; $left; $top; $right; $bottom)
	$rectHeight:=$bottom-$top
	
	OBJECT GET COORDINATES:C663(*; "pupVisions"; $leftP; $topP; $rightP; $bottomP)
	OBJECT GET BEST SIZE:C717(*; "pupVisions"; $bestWidth; $bestHeight; 112)
	$newTop:=($rectHeight-$bestHeight)/2+10
	
	OBJECT SET COORDINATES:C1248(*; "pupVisions"; $leftP; $newTop; $rightP; $newTop+$bestHeight)
	
	
	OBJECT SET FONT STYLE:C166(*; "pupVisions"; Bold:K14:2)
	$color:=Form:C1466.vision.toolbar.color
	OBJECT SET RGB COLORS:C628(*; "pupVisions"; $color; Background color none:K23:10)
	
	OBJECT SET VISIBLE:C603(*; "searchbox_cross"; (Form:C1466.sfw.searchbox#""))
	
Function init()
	
	var $color : Text
	
	$color:=This:C1470.vision.toolbar.color
	This:C1470.changeTopBarColor($color)
	
	
Function drawToolbar($identVision : Text)
	var $color : Text
	var $entry : cs:C1710.sfw_definitionEntry
	var $i : Integer
	var $iconNum : Integer
	var $format : Text
	var $icon : Picture
	var vToolBarIcon01; vToolBarIcon02; vToolBarIcon03; vToolBarIcon04; vToolBarIcon05; vToolBarIcon06; vToolBarIcon07; vToolBarIcon08; vToolBarIcon09; vToolBarIcon10 : Picture
	var vToolBarIcon11; vToolBarIcon12; vToolBarIcon13; vToolBarIcon14; vToolBarIcon15; vToolBarIcon16 : Picture
	var $iconFile : 4D:C1709.File
	var $eUserProfile : cs:C1710.sfw_UserProfileEntity
	var $esUserProfiles : cs:C1710.sfw_UserProfileSelection:=ds:C1482.sfw_UserProfile.query("ident in :1"; cs:C1710.sfw_userManager.me.authorizedProfiles)
	
	Form:C1466.currentTB:=$identVision
	
	Form:C1466.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; $identVision).orderBy("displayOrder desc")[0]
	
	$color:=Form:C1466.vision.toolbar.color
	
	OBJECT SET RGB COLORS:C628(*; "bkgd_toolbar"; $color; $color)
	
	Form:C1466.entries:=cs:C1710.sfw_definition.me.entries.query("visions[] = :1"; $identVision)
	
	
	$previousWasAnIcon:=False:C215
	Form:C1466.toolBarEntries:=New collection:C1472
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	$entriesToDisplay:=New collection:C1472
	$width_bToolbar_max:=0
	For each ($entry; Form:C1466.entries.query("toolBarGroup = null").orderBy("displayOrder desc"))
		If ($entry.splitter#Null:C1517)
			If ($previousWasAnIcon)
				$entriesToDisplay.push($entry)
				$previousWasAnIcon:=False:C215
			End if 
		Else 
			$displayEntry:=$entry.isDisplayable()
			
			If ($displayEntry)
				$entriesToDisplay.push($entry)
				If (cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsSameWidth)
					OBJECT SET TITLE:C194(*; "bToolbar_1"; ds:C1482.sfw_readXliff($entry.xliff; $entry.toolbarLabel))
					OBJECT GET BEST SIZE:C717(*; "bToolbar_1"; $width_bToolbar; $bestHight)
					If ($width_bToolbar>$width_bToolbar_max)
						$width_bToolbar_max:=$width_bToolbar
					End if 
				End if 
				$previousWasAnIcon:=True:C214
			End if 
		End if 
	End for each 
	
	
	Form:C1466.toolBarGroups:=New collection:C1472
	For each ($entry; Form:C1466.entries.query("toolBarGroup # null").orderBy("toolbar.displayOrder desc, displayOrder desc"))
		//If ($entry.allowedProfiles#Null) && ($entry.allowedProfiles.length>0)
		//$displayEntry:=False
		//For each ($authorizedProfile; $authorizedProfiles)
		//$displayEntry:=$displayEntry || ($entry.allowedProfiles.indexOf($authorizedProfile)#-1)
		//End for each 
		//Else 
		//$displayEntry:=True
		//End if 
		$displayEntry:=$entry.isDisplayable()
		
		If ($displayEntry)
			$identGroup:=$entry.toolBarGroup.ident
			$indices:=Form:C1466.toolBarGroups.query("ident = :1"; $identGroup)
			If ($indices.length=0)
				$group:=$entry.toolBarGroup
				Form:C1466.toolBarGroups.push($group)
				
				If (cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsSameWidth)
					OBJECT SET TITLE:C194(*; "bToolbar_1"; ds:C1482.sfw_readXliff($entry.xliff; $group.label))
					OBJECT GET BEST SIZE:C717(*; "bToolbar_1"; $width_bToolbar; $bestHight)
					If ($width_bToolbar>$width_bToolbar_max)
						$width_bToolbar_max:=$width_bToolbar
					End if 
				End if 
				
			End if 
		End if 
	End for each 
	
	
	$format:=OBJECT Get format:C894(*; "bToolbar_1")
	OBJECT GET COORDINATES:C663(*; "bToolbar_1"; $left_bToolbar_1; $top_bToolbar_1; $right_bToolbar_1; $bottom_bToolbar_1)
	OBJECT SET COORDINATES:C1248(*; "vSplitter_@"; 10000; 10000; 10000; 10000)
	$width_bToolbar_1:=$right_bToolbar_1-$left_bToolbar_1
	$offset_bToolBar:=$left_bToolbar_1
	$margin_bToolBar:=cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsMargin
	$iconNum:=1
	For each ($entry; $entriesToDisplay)
		If ($entry.splitter#Null:C1517)
			$offset_bToolBar+=$margin_bToolBar
			OBJECT SET COORDINATES:C1248(*; "vSplitter_"+String:C10($iconNum); $offset_bToolBar; $top_bToolbar_1-3; $offset_bToolBar; $bottom_bToolbar_1+3)
			$offset_bToolBar+=$margin_bToolBar
			
		Else 
			$iconFile:=Folder:C1567(fk resources folder:K87:11).file($entry.icon)
			READ PICTURE FILE:C678($iconFile.platformPath; $icon)
			$iconVariableName:="vToolBarIcon"+String:C10($iconNum; "00")
			
			If (Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsResize)=True:C214)
				(Get pointer:C304($iconVariableName))->:=$icon*0.75
			Else 
				(Get pointer:C304($iconVariableName))->:=$icon
			End if 
			
			OBJECT SET FORMAT:C236(*; "bToolbar_"+String:C10($iconNum); ds:C1482.sfw_readXliff($entry.xliff; $entry.toolbarLabel)+";"+$iconVariableName+";0;4;1;1;0;0;0;0;0;0;1;0")
			OBJECT SET VISIBLE:C603(*; "bToolbar_"+String:C10($iconNum); True:C214)
			OBJECT SET HELP TIP:C1181(*; "bToolbar_"+String:C10($iconNum); ds:C1482.sfw_readXliff($entry.xliff; $entry.label))
			Case of 
				: (cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsSameWidth)
					$width_bToolbar:=$width_bToolbar_max+10
				: (cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsAutoWidth)
					OBJECT GET BEST SIZE:C717(*; "bToolbar_"+String:C10($iconNum); $width_bToolbar; $bestHight)
				Else 
					$width_bToolbar:=$width_bToolbar_1
			End case 
			If ($width_bToolbar<$width_bToolbar_1)
				//$width_bToolbar:=$width_bToolbar_1
			End if 
			OBJECT SET COORDINATES:C1248(*; "bToolbar_"+String:C10($iconNum); $offset_bToolBar; $top_bToolbar_1; $offset_bToolBar+$width_bToolbar; $bottom_bToolbar_1)
			$offset_bToolBar+=$width_bToolbar+$margin_bToolBar
			$iconNum:=$iconNum+1
			Form:C1466.toolBarEntries.push($entry)
		End if 
	End for each 
	
	
	Form:C1466.toolBarGroups:=New collection:C1472
	For each ($entry; Form:C1466.entries.query("toolBarGroup # null").orderBy("toolbar.displayOrder desc, displayOrder desc"))
		If ($entry.allowedProfiles#Null:C1517) && ($entry.allowedProfiles.length>0)
			$displayEntry:=False:C215
			For each ($authorizedProfile; $authorizedProfiles)
				$displayEntry:=$displayEntry || ($entry.allowedProfiles.indexOf($authorizedProfile)#-1)
			End for each 
		Else 
			$displayEntry:=True:C214
		End if 
		If ($displayEntry)
			$identGroup:=$entry.toolBarGroup.ident
			$indices:=Form:C1466.toolBarGroups.query("ident = :1"; $identGroup)
			If ($indices.length=0)
				$group:=$entry.toolBarGroup
				Form:C1466.toolBarGroups.push($group)
				$iconFile:=Folder:C1567(fk resources folder:K87:11).file($group.icon)
				READ PICTURE FILE:C678($iconFile.platformPath; $icon)
				$iconVariableName:="vToolBarIcon"+String:C10($iconNum; "00")
				(Get pointer:C304($iconVariableName))->:=$icon*0.75
				OBJECT SET FORMAT:C236(*; "bToolbar_"+String:C10($iconNum); ds:C1482.sfw_readXliff($entry.xliff; $group.label)+";"+$iconVariableName+";0;4;1;1;0;0;0;0;1;0;1;0")
				OBJECT SET VISIBLE:C603(*; "bToolbar_"+String:C10($iconNum); True:C214)
				OBJECT SET HELP TIP:C1181(*; "bToolbar_"+String:C10($iconNum); ds:C1482.sfw_readXliff($group.xliff; $group.label))
				Case of 
					: (cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsSameWidth)
						$width_bToolbar:=$width_bToolbar_max
					: (cs:C1710.sfw_definition.me.globalParameters.toolbar.entryIconsAutoWidth)
						OBJECT GET BEST SIZE:C717(*; "bToolbar_"+String:C10($iconNum); $width_bToolbar; $bestHight)
					Else 
						$width_bToolbar:=$width_bToolbar_1
				End case 
				If ($width_bToolbar<$width_bToolbar_1)
					//$width_bToolbar:=$width_bToolbar_1
				End if 
				OBJECT SET COORDINATES:C1248(*; "bToolbar_"+String:C10($iconNum); $offset_bToolBar; $top_bToolbar_1; $offset_bToolBar+$width_bToolbar; $bottom_bToolbar_1)
				$offset_bToolBar+=$width_bToolbar+$margin_bToolBar
				$iconNum:=$iconNum+1
			End if 
		End if 
	End for each 
	
	For ($i; $iconNum; 16)
		OBJECT SET VISIBLE:C603(*; "bToolbar_"+String:C10($i); False:C215)
	End for 
	
	
	$format:=OBJECT Get format:C894(*; "pup_visions")
	Case of 
		: (Storage:C1525.sfwDefinition.extras=Null:C1517)
		: (Storage:C1525.sfwDefinition.extras.sfw_toolbar=Null:C1517)
		Else 
			$file:=String:C10(Storage:C1525.sfwDefinition.extras.sfw_toolbar.file)
			$format:=";path:/RESOURCES/"+$file+";;4;1;1;4;0;0;0;0;0;1"
			OBJECT SET FORMAT:C236(*; "pup_visions"; $format)
	End case 
	
	$lprog:=Get database localization:C1009(Current localization:K5:22)
	Case of 
		: ($lprog="EN")
			$iconFlag:="GB"
		Else 
			$iconFlag:=$lprog
	End case 
	$formatLangage:=";#sfw/flags/tiny/"+$iconFlag+".png;0;0;0;1;3;0;0;0;1;0;1"
	OBJECT SET FORMAT:C236(*; "bLangage"; $formatLangage)
	OBJECT SET VISIBLE:C603(*; "bLangage"; Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.toolbar.changeLanguage))
	
	
	If (String:C10(This:C1470.searchbox)#"")
		This:C1470.launchGlobalSearch()
	End if 
	
	$name:=cs:C1710.sfw_userManager.me.info.login
	OBJECT SET TITLE:C194(*; "bCurrentUSer"; $name)
	
	This:C1470.displayNotification()
	This:C1470.displayToDoList()
	
Function displayNotification()
	If (Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.notifications.activate))
		cs:C1710.sfw_notificationManager.me.setToolbarWindowRef(Current form window:C827)
		Form:C1466.notificationsCount:=cs:C1710.sfw_notificationManager.me.getNbNotifications()
		OBJECT SET VISIBLE:C603(*; "bNotifications"; True:C214)
		OBJECT SET VISIBLE:C603(*; "counterNotifications"; (Form:C1466.notificationsCount#"0"))
		OBJECT SET VISIBLE:C603(*; "bkgdNotifications"; (Form:C1466.notificationsCount#"0"))
	Else 
		OBJECT SET VISIBLE:C603(*; "@Notifications"; False:C215)
	End if 
	
Function displayToDoList()
	If (Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.todoList.activate))
		Form:C1466.todoListCount:=cs:C1710.sfw_todoListManager.me.getNbTodo()
		If (Form:C1466.todoListCount="!@")
			Form:C1466.todoListCount:=Substring:C12(Form:C1466.todoListCount; 2)
			OBJECT SET RGB COLORS:C628(*; "bkgdToDoList"; "red"; "red")
		Else 
			OBJECT SET RGB COLORS:C628(*; "bkgdToDoList"; "green"; "green")
		End if 
		OBJECT SET VISIBLE:C603(*; "bToDoList"; True:C214)
		OBJECT SET VISIBLE:C603(*; "counterToDoList"; (Form:C1466.todoListCount#"0"))
		OBJECT SET VISIBLE:C603(*; "bkgdToDoList"; (Form:C1466.todoListCount#"0"))
	Else 
		OBJECT SET VISIBLE:C603(*; "@ToDoList"; False:C215)
	End if 
	
Function pushEntryButton()
	
	var $formData : Object
	var $formEvent : Object
	var $iconNum : Integer
	var $refWindow : Integer
	
	
	If (Not:C34(Is compiled mode:C492))
		$identVision:=Form:C1466.vision.ident
		Form:C1466.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; $identVision).orderBy("displayOrder desc")[0]
		Form:C1466.entries:=cs:C1710.sfw_definition.me.entries.query("visions[] = :1 and splitter = null"; $identVision).orderBy("displayOrder desc")
	End if 
	
	$formEvent:=FORM Event:C1606
	$iconNum:=Num:C11(Substring:C12($formEvent.objectName; 10))
	
	$launch:=True:C214
	
	If ($iconNum<=Form:C1466.toolBarEntries.length)
		$entry:=Form:C1466.entries.query("toolBarGroup = null").orderBy("displayOrder desc")[$iconNum-1]
		Case of 
			: ($entry.launchingExpression#Null:C1517)
				$launch:=False:C215
				
				Formula from string:C1601($entry.launchingExpression).call()
				
			Else 
				$windows:=cs:C1710.sfw_window.me.windows.query("process.name = :1"; $entry.ident).orderBy("title")
				If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
					$favorites:=ds:C1482.sfw_Favorite.query("entryIdent = :1"; $entry.ident)
				Else 
					$favorites:=ds:C1482.sfw_Favorite.query("entryIdent = :1 and UUID_User = :2"; $entry.ident; cs:C1710.sfw_userManager.me.info.UUID)
				End if 
				If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
					$subscriptions:=ds:C1482.sfw_Subscription.query("entryIdent = :1"; $entry.ident)
				Else 
					$subscriptions:=ds:C1482.sfw_Subscription.query("entryIdent = :1 and UUID_User = :2"; $entry.ident; cs:C1710.sfw_userManager.me.info.UUID)
				End if 
				If ($windows.length>0) || ($favorites.length>0) || ($subscriptions.length>0)
					$launch:=False:C215
					$refMenu:=Create menu:C408
					
					For each ($window; $windows)
						APPEND MENU ITEM:C411($refMenu; $window.title; *)
						SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--window:"+String:C10($window.reference))
						SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/picto/applications.png")
					End for each 
					APPEND MENU ITEM:C411($refMenu; "-")
					APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.newMainWindow"; "New main window"))
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--newWindow")
					SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/picto/application-sidebar-list.png")
					
					If ($favorites.length>0)
						APPEND MENU ITEM:C411($refMenu; "-")
						APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.favorites"; "Favorites"))
						DISABLE MENU ITEM:C150($refMenu; -1)
						$favoriteItems:=ds:C1482[$entry.dataclass].query("UUID in :1 order by nameInWindowTitle"; $favorites.UUID_target)
						For each ($favorite; $favoriteItems)
							APPEND MENU ITEM:C411($refMenu; $favorite.nameInWindowTitle; *)
							SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--favorite:"+String:C10($favorite.UUID))
							SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/picto/star.png")
						End for each 
					End if 
					
					If ($subscriptions.length>0) && (cs:C1710.sfw_definition.me.globalParameters.notifications.activate)
						APPEND MENU ITEM:C411($refMenu; "-")
						APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.subcriptions"; "Subcriptions"))
						DISABLE MENU ITEM:C150($refMenu; -1)
						$subscriptedItems:=ds:C1482[$entry.dataclass].query("UUID in :1 order by nameInWindowTitle"; $subscriptions.UUID_target)
						For each ($subscriptedItem; $subscriptedItems)
							APPEND MENU ITEM:C411($refMenu; $subscriptedItem.nameInWindowTitle; *)
							SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--favorite:"+String:C10($subscriptedItem.UUID))
							SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/picto/bell.png")
						End for each 
					End if 
					
					
					OBJECT GET COORDINATES:C663(*; $formEvent.objectName; $left; $top; $right; $bottom)
					
					$choose:=Dynamic pop up menu:C1006($refMenu; ""; $left; $bottom)
					RELEASE MENU:C978($refMenu)
					
					Case of 
						: ($choose="")
							$launch:=False:C215
							
						: ($choose="--newWindow")
							$launch:=True:C214
							
						: ($choose="--window:@")
							$refWindow:=Num:C11(Split string:C1554($choose; ":").pop())
							$window:=cs:C1710.sfw_window.me.windows.query("process.name = :1 & reference = :2"; $entry.ident; $refWindow).first()
							BRING TO FRONT:C326($window.process.number)
							SHOW PROCESS:C325($window.process.number)
							
						: ($choose="--favorite:@")
							$uuid:=Split string:C1554($choose; ":").pop()
							$visionIdent:=Form:C1466.vision.ident
							$entryIdent:=$entry.ident
							$formData:=New object:C1471()
							$formData.sfw:=cs:C1710.sfw_item.new()
							$formData.sfw.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; $visionIdent).first()
							$formData.sfw.entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; $entryIdent).first()
							$formData.current_item:=ds:C1482[$entry.dataclass].get($uuid)
							$formData.sfw.openForm($formData)
					End case 
					
				End if 
		End case 
		
		
	Else 
		$numGroup:=$iconNum-Form:C1466.toolBarEntries.length
		$group:=Form:C1466.toolBarGroups[$numGroup-1]
		This:C1470.refMenus:=New collection:C1472
		$refMenu:=Create menu:C408
		This:C1470.refMenus.push($refMenu)
		For each ($entry; Form:C1466.entries.query("toolBarGroup.ident = :1"; $group.ident).orderBy("displayOrder desc"))
			
			$windows:=cs:C1710.sfw_window.me.windows.query("process.name = :1"; $entry.ident).orderBy("title")
			If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
				$favorites:=ds:C1482.sfw_Favorite.query("entryIdent = :1"; $entry.ident)
			Else 
				$favorites:=ds:C1482.sfw_Favorite.query("entryIdent = :1 and UUID_User = :2"; $entry.ident; cs:C1710.sfw_userManager.me.info.UUID)
			End if 
			If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
				$subscriptions:=ds:C1482.sfw_Subscription.query("entryIdent = :1"; $entry.ident)
			Else 
				$subscriptions:=ds:C1482.sfw_Subscription.query("entryIdent = :1 and UUID_User = :2"; $entry.ident; cs:C1710.sfw_userManager.me.info.UUID)
			End if 
			If ($windows.length>0) || ($favorites.length>0) || ($subscriptions.length>0)
				$refClassesMenu:=Create menu:C408
				This:C1470.refMenus.push($refClassesMenu)
				$launch:=False:C215
				
				For each ($window; $windows)
					APPEND MENU ITEM:C411($refClassesMenu; $window.title; *)
					SET MENU ITEM PARAMETER:C1004($refClassesMenu; -1; "--window:"+String:C10($window.reference))
					SET MENU ITEM ICON:C984($refClassesMenu; -1; "Path:/RESOURCES/sfw/image/picto/applications.png")
				End for each 
				
				APPEND MENU ITEM:C411($refClassesMenu; "-")
				APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.newMainWindow"; "New main window"))
				SET MENU ITEM PARAMETER:C1004($refClassesMenu; -1; "--newWindow:"+$entry.ident)
				SET MENU ITEM ICON:C984($refClassesMenu; -1; "Path:/RESOURCES/sfw/image/picto/application-sidebar-list.png")
				
				If ($favorites.length>0)
					APPEND MENU ITEM:C411($refClassesMenu; "-")
					APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.favorites"; "Favorites"))
					DISABLE MENU ITEM:C150($refClassesMenu; -1)
					$favoriteItems:=ds:C1482[$entry.dataclass].query("UUID in :1 order by nameInWindowTitle"; $favorites.UUID_target)
					For each ($favorite; $favoriteItems)
						APPEND MENU ITEM:C411($refClassesMenu; $favorite.nameInWindowTitle; *)
						SET MENU ITEM PARAMETER:C1004($refClassesMenu; -1; "--favorite:"+String:C10($favorite.UUID)+":"+$entry.ident)
						SET MENU ITEM ICON:C984($refClassesMenu; -1; "Path:/RESOURCES/sfw/image/picto/star.png")
					End for each 
				End if 
				
				If ($subscriptions.length>0) && (cs:C1710.sfw_definition.me.globalParameters.notifications.activate)
					APPEND MENU ITEM:C411($refClassesMenu; "-")
					APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.subscriptions"; "Subscriptions"))
					DISABLE MENU ITEM:C150($refClassesMenu; -1)
					$subscriptedItems:=ds:C1482[$entry.dataclass].query("UUID in :1 order by nameInWindowTitle"; $favorites.UUID_target)
					For each ($subscriptedItem; $subscriptedItems)
						APPEND MENU ITEM:C411($refClassesMenu; $subscriptedItem.nameInWindowTitle; *)
						SET MENU ITEM PARAMETER:C1004($refClassesMenu; -1; "--favorite:"+String:C10($subscriptedItem.UUID)+":"+$entry.ident)
						SET MENU ITEM ICON:C984($refClassesMenu; -1; "Path:/RESOURCES/sfw/image/picto/bell.png")
					End for each 
				End if 
				
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff($entry.xliff; $entry.toolbarLabel); $refClassesMenu; *)
			Else 
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff($entry.xliff; $entry.toolbarLabel); *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--newWindow:"+$entry.ident)
				
			End if 
			If ($entry.iconAlternative#"")
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/"+$entry.iconAlternative)
			Else 
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/"+$entry.icon)
			End if 
		End for each 
		
		OBJECT GET COORDINATES:C663(*; $formEvent.objectName; $left; $top; $right; $bottom)
		
		$choose:=Dynamic pop up menu:C1006($refMenu; ""; $left; $bottom)
		For each ($refMenu; This:C1470.refMenus)
			RELEASE MENU:C978($refMenu)
		End for each 
		
		
		
		Case of 
			: ($choose="")
				$launch:=False:C215
			: ($choose="--newWindow:@")
				$ident:=Substring:C12($choose; 13)
				$launch:=True:C214
				$entry:=Form:C1466.entries.query("ident = :1"; $ident).first()
				
			: ($choose="--window:@")
				$refWindow:=Num:C11(Split string:C1554($choose; ":").pop())
				$window:=cs:C1710.sfw_window.me.windows.query("reference = :1"; $refWindow).first()
				BRING TO FRONT:C326($window.process.number)
				SHOW PROCESS:C325($window.process.number)
				
			: ($choose="--favorite:@")
				$parts:=Split string:C1554($choose; ":")
				$entryIdent:=$parts.pop()
				$uuid:=$parts.pop()
				$visionIdent:=Form:C1466.vision.ident
				$formData:=New object:C1471()
				$formData.sfw:=cs:C1710.sfw_item.new()
				$formData.sfw.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; $visionIdent).first()
				$formData.sfw.entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; $entryIdent).first()
				$formData.current_item:=ds:C1482[$entry.dataclass].get($uuid)
				$formData.sfw.openForm($formData)
		End case 
	End if 
	
	If ($launch)
		$formData:=New object:C1471()
		
		Case of 
			: ($entry.wizard#Null:C1517)
				$formData.sfw:=cs:C1710.sfw_wizard.new()
			Else 
				$formData.sfw:=cs:C1710.sfw_main.new()
		End case 
		
		$formData.sfw.vision:=Form:C1466.vision
		$formData.sfw.entry:=$entry
		
		$formData.sfw.openForm($formData)
		
	Else 
		
	End if 
	
Function pushCurrentUserButton()
	This:C1470.refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	This:C1470.refMenus.push($refMenu)
	
	APPEND MENU ITEM:C411($refMenu; cs:C1710.sfw_userManager.me.info.login; *)
	DISABLE MENU ITEM:C150($refMenu; -1)
	APPEND MENU ITEM:C411($refMenu; "-")
	
	////mark: Store access in preferences
	//APPEND MENU ITEM($refMenu; ds.sfw_readXliff("toolbar.storeAccess"; "Store access in preferences..."); *)
	//SET MENU ITEM PARAMETER($refMenu; -1; "--storeAccess")
	//mark: Change my password
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.changePassword"; "Change my password..."); *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--changePassword")
	
	If (cs:C1710.sfw_userManager.me.info.asDesigner) && (Not:C34(Is compiled mode:C492))
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.onlyForDesigner"; "only for designer"))  // add xliff
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		$refClassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refClassesMenu)
		
		$classNames:=OB Keys:C1719(cs:C1710).orderBy()
		$classNamesDisplayed:=New collection:C1472
		ARRAY TEXT:C222($_paths; 0)
		METHOD GET PATHS:C1163(Path class:K72:19; $_paths)
		
		//mark: SFW user classes
		$refSFWUSerClassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refSFWUSerClassesMenu)
		For each ($className; $classNames)
			If ($className="sfw@")
				If (cs:C1710[$className].superclass.name="Object") || (cs:C1710[$className].superclass.name="sfw@")
					If (Find in array:C230($_paths; "[class]/"+$className)>0) && ($classNamesDisplayed.indexOf($className)=-1)
						$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/class.png")
						APPEND MENU ITEM:C411($refSFWUSerClassesMenu; $className; $refMenuFunction; *)
						SET MENU ITEM PARAMETER:C1004($refSFWUSerClassesMenu; -1; "--class:"+$className)
						SET MENU ITEM ICON:C984($refSFWUSerClassesMenu; -1; "file:sfw/image/menu/class.png")
						$classNamesDisplayed.push($className)
					End if 
				End if 
			End if 
		End for each 
		APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.sfwUserClasses"; "SFW user classes"); $refSFWUSerClassesMenu; *)
		SET MENU ITEM ICON:C984($refClassesMenu; -1; "file:sfw/image/menu/class.png")
		
		//mark: SFW data classes
		$refSFWDataclassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refSFWDataclassesMenu)
		For each ($className; $classNames)
			If ($className="sfw@")
				If (cs:C1710[$className].superclass.name#"Object") && (cs:C1710[$className].superclass.name#"sfw@")
					If (Find in array:C230($_paths; "[class]/"+$className)>0) && ($classNamesDisplayed.indexOf($className)=-1)
						$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/extendDataclass.png")
						APPEND MENU ITEM:C411($refSFWDataclassesMenu; $className; $refMenuFunction; *)
						SET MENU ITEM PARAMETER:C1004($refSFWDataclassesMenu; -1; "--class:"+$className)
						SET MENU ITEM ICON:C984($refSFWDataclassesMenu; -1; "file:sfw/image/menu/extendDataclass.png")
						$classNamesDisplayed.push($className)
					End if 
				End if 
			End if 
		End for each 
		APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.sfwSataclasses"; "SFW dataclasses"); $refSFWDataclassesMenu; *)
		SET MENU ITEM ICON:C984($refClassesMenu; -1; "file:sfw/image/menu/extendDataclass.png")
		
		//mark: Project definition classes
		$refSFWDefinitionclassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refSFWDefinitionclassesMenu)
		For each ($className; [Storage:C1525.definitionClass.name; Storage:C1525.definitionClass.globalParametersName])
			$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/puzzle.png")
			APPEND MENU ITEM:C411($refSFWDefinitionclassesMenu; $className; $refMenuFunction; *)
			SET MENU ITEM PARAMETER:C1004($refSFWDefinitionclassesMenu; -1; "--class:"+$className)
			SET MENU ITEM ICON:C984($refSFWDefinitionclassesMenu; -1; "file:sfw/image/menu/puzzle.png")
			$classNamesDisplayed.push($className)
		End for each 
		APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.projectDefinitionClass"; "Project definition class"); $refSFWDefinitionclassesMenu; *)
		SET MENU ITEM ICON:C984($refClassesMenu; -1; "file:sfw/image/menu/puzzle.png")
		
		//mark: Entry classes
		$refentryclassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refSFWDataclassesMenu)
		$entries:=cs:C1710.sfw_definition.me.entries.orderBy("dataclass")
		For each ($entry; $entries)
			For each ($suffix; [""; "Entity"; "Selection"])
				$className:=String:C10($entry.dataclass)+$suffix
				If ($className#"") && (cs:C1710[$className]#Null:C1517)
					If (Find in array:C230($_paths; "[class]/"+$className)>0) && ($classNamesDisplayed.indexOf($className)=-1)
						$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/entry.png")
						APPEND MENU ITEM:C411($refentryclassesMenu; $className; $refMenuFunction; *)
						SET MENU ITEM PARAMETER:C1004($refentryclassesMenu; -1; "--class:"+$className)
						SET MENU ITEM ICON:C984($refentryclassesMenu; -1; "file:sfw/image/menu/entry.png")
						$classNamesDisplayed.push($className)
					End if 
				End if 
			End for each 
		End for each 
		APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.entryClasses"; "Entry classes"); $refentryclassesMenu; *)
		SET MENU ITEM ICON:C984($refClassesMenu; -1; "file:sfw/image/menu/entry.png")
		
		//mark: Panel classes
		$refpanelclassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refSFWDataclassesMenu)
		$entries:=cs:C1710.sfw_definition.me.entries.orderBy("panel.name")
		For each ($entry; $entries)
			$className:=String:C10($entry.panel.name)
			If ($className#"") && (cs:C1710[$className]#Null:C1517)
				If (Find in array:C230($_paths; "[class]/"+$className)>0) && ($classNamesDisplayed.indexOf($className)=-1)
					$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/panel.png")
					APPEND MENU ITEM:C411($refpanelclassesMenu; $className; $refMenuFunction; *)
					SET MENU ITEM PARAMETER:C1004($refpanelclassesMenu; -1; "--class:"+$className)
					SET MENU ITEM ICON:C984($refpanelclassesMenu; -1; "file:sfw/image/menu/panel.png")
					$classNamesDisplayed.push($className)
				End if 
			End if 
		End for each 
		APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.panelClasses"; "Panel classes"); $refpanelclassesMenu; *)
		SET MENU ITEM ICON:C984($refClassesMenu; -1; "file:sfw/image/menu/panel.png")
		
		//mark: Other classes
		$refotherclassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refSFWDataclassesMenu)
		For each ($className; $classNames)
			If ($classNamesDisplayed.indexOf($className)=-1)
				If (cs:C1710[$className].superclass.name#"Object") && (cs:C1710[$className].superclass.name#"sfw@") && ($className#"DataStore")
					If (Find in array:C230($_paths; "[class]/"+$className)>0) && ($classNamesDisplayed.indexOf($className)=-1)
						$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/extendDataclass.png")
						APPEND MENU ITEM:C411($refotherclassesMenu; $className; $refMenuFunction; *)
						SET MENU ITEM PARAMETER:C1004($refotherclassesMenu; -1; "--class:"+$className)
						SET MENU ITEM ICON:C984($refotherclassesMenu; -1; "file:sfw/image/menu/extendDataclass.png")
						$classNamesDisplayed.push($className)
					End if 
				End if 
			End if 
		End for each 
		APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.otherDataclasses"; "Other dataclasses"); $refotherclassesMenu; *)
		SET MENU ITEM ICON:C984($refClassesMenu; -1; "file:sfw/image/menu/extendDataclass.png")
		
		$refotheruserclassesMenu:=Create menu:C408
		This:C1470.refMenus.push($refSFWDataclassesMenu)
		For each ($className; $classNames)
			If ($classNamesDisplayed.indexOf($className)=-1)
				Case of 
					: ($className="DataStore")
						If (Find in array:C230($_paths; "[class]/"+$className)>0) && ($classNamesDisplayed.indexOf($className)=-1)
							$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/datastore.png")
							APPEND MENU ITEM:C411($refotheruserclassesMenu; $className; $refMenuFunction; *)
							SET MENU ITEM PARAMETER:C1004($refotheruserclassesMenu; -1; "--class:"+$className)
							SET MENU ITEM ICON:C984($refotheruserclassesMenu; -1; "file:sfw/image/menu/datastore.png")
							$classNamesDisplayed.push($className)
						End if 
					: (cs:C1710[$className].superclass.name="Object")
						If (Find in array:C230($_paths; "[class]/"+$className)>0) && ($classNamesDisplayed.indexOf($className)=-1)
							$refMenuFunction:=This:C1470._menuFunction($className; "file:sfw/image/menu/class.png")
							APPEND MENU ITEM:C411($refotheruserclassesMenu; $className; $refMenuFunction; *)
							SET MENU ITEM PARAMETER:C1004($refotheruserclassesMenu; -1; "--class:"+$className)
							SET MENU ITEM ICON:C984($refotheruserclassesMenu; -1; "file:sfw/image/menu/class.png")
							$classNamesDisplayed.push($className)
						End if 
				End case 
			End if 
		End for each 
		APPEND MENU ITEM:C411($refClassesMenu; ds:C1482.sfw_readXliff("toolbar.otherDataclasses"; "Other dataclasses"); $refotheruserclassesMenu; *)
		SET MENU ITEM ICON:C984($refClassesMenu; -1; "file:sfw/image/menu/class.png")
		
		
		APPEND MENU ITEM:C411($refMenu; "Classes"; $refClassesMenu; *)
		SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/classes.png")
		
		//mark: Test Microsoft Office 365 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.testMOMail"; "Test Microsoft Office 365 : send mail"); *)
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--microsoftGraphSendMail")
		
		APPEND MENU ITEM:C411($refMenu; "-")
		$colorMenu:=cs:C1710.sfw_htmlColor.me.buildMenu(This:C1470.refMenus)
		
		//mark: Colors 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.colors"; "Colors"); $colorMenu; *)
		
		
	End if 
	
	OBJECT GET COORDINATES:C663(*; FORM Event:C1606.objectName; $left; $top; $right; $bottom)
	
	$choose:=Dynamic pop up menu:C1006($refMenu; ""; $left; $bottom)
	
	
	For each ($refMenu; This:C1470.refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	This:C1470.refMenus:=New collection:C1472
	
	Case of 
		: ($choose="")
		: ($choose="--storeAccess")
			cs:C1710.sfw_userManager.me.storeAccess()
			
		: ($choose="--class:@")
			$class:=Substring:C12($choose; 9)
			METHOD GET PATHS:C1163(Path class:K72:19; $_paths)
			$classParts:=Split string:C1554($class; "/")
			If (Find in array:C230($_paths; "[class]/"+$classParts[0])>0)
				METHOD OPEN PATH:C1213("[class]/"+$class)
			End if 
			If ($classParts[0]=$class)
				ARRAY TEXT:C222($_forms; 0)
				FORM GET NAMES:C1167($_forms)
				$form:=$class
				If (Find in array:C230($_forms; $form)>0)
					FORM EDIT:C1749($form)
				End if 
			End if 
			
		: ($choose="--microsoftGraphSendMail")
			If (String:C10(cs:C1710.sfw_userManager.me.info.email)#"")
				
				//$graphAPI:=cs.microsoftGraphAPI.new()
				//$token:=$graphAPI.getToken()
				//$OAuth2:=$graphAPI.oAuth2
				
				//$email:=New object
				
				//$recipients:=New collection
				//$recipients.push({emailAddress: {address: cs.sfw_userManager.me.info.email}})
				
				//$email.body:=New object()
				//$email.body.content:="This is a mail test from Kairos Application"
				//$email.body.contentType:="HTML"  // si HTML, mettre HTML
				//$email.toRecipients:=$recipients
				//$email.subject:="Kairos - Test email"
				
				//$status:=$graphAPI.sendMail($email)
				//If ($status.success=False)
				//cs.sfw_dialog.me.alert($status.statusText)
				//Else 
				//cs.sfw_dialog.me.info("The email has been sent!")
				//End if 
				
				$email:=New object:C1471
				
				$recipients:=New collection:C1472
				$recipients.push({emailAddress: {address: cs:C1710.sfw_userManager.me.info.email}})
				
				$email.body:=New object:C1471()
				$email.body.content:="This is a mail test from Kairos Application"
				$email.body.contentType:="HTML"  // si HTML, mettre HTML
				$email.toRecipients:=$recipients
				$email.subject:="Kairos - Test email"
				
				cs:C1710.sfw_eMailManager.me.sendAnEMail($email)
				
				
			End if 
		: ($choose="--changePassword")
			var $eUser : cs:C1710.sfw_UserEntity
			$eUser:=ds:C1482.sfw_User.query("login = :1"; Current user:C182).first()
			If ($eUser#Null:C1517)
				$eUser.askForNewPassword()
			End if 
			
		: ($choose="#@") && (Length:C16($choose)=7)
			var $color : Object
			$color:=cs:C1710.sfw_htmlColor.me.colors.query("hex = :1"; $choose).first()
			OB REMOVE:C1226($color; "picture")
			SET TEXT TO PASTEBOARD:C523(JSON Stringify:C1217($color; *))
			
		Else 
			
			
	End case 
	
	
Function _menuFunction($className : Text; $pathIcon : Text)->$refMenu : Text
	$refMenu:=Create menu:C408
	This:C1470.refMenus.push($refMenu)
	$memberFunctions:=OB Keys:C1719(cs:C1710[$className].__prototype).sort()
	APPEND MENU ITEM:C411($refMenu; $className; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--class:"+$className)
	SET MENU ITEM ICON:C984($refMenu; -1; $pathIcon)
	APPEND MENU ITEM:C411($refMenu; "-")
	For each ($memberFunction; $memberFunctions)
		APPEND MENU ITEM:C411($refMenu; $memberFunction; *)
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--class:"+$className+"/"+$memberFunction)
		Case of 
			: ($memberFunction="get @")
				SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/database--arrow.png")
			: ($memberFunction="set @")
				SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/database-import.png")
			: ($memberFunction="query @")
				SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/magnifier.png")
			: ($memberFunction="orderBy @")
				SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/sort.png")
			Else 
				SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/function.png")
		End case 
	End for each 
	
	
	
Function pushbNotifications()
	var $window : Object
	$window:=cs:C1710.sfw_window.me.windows.query("process.name = :1"; cs:C1710.sfw_notificationManager.me.notificationWorkerName).first()
	If ($window=Null:C1517)
		CALL WORKER:C1389(cs:C1710.sfw_notificationManager.me.notificationWorkerName; Formula:C1597(cs:C1710.sfw_notificationManager.me.openWizardNotifications()))
	End if 
	
	
Function pushbToDoList()
	var $window : Object
	$window:=cs:C1710.sfw_window.me.windows.query("process.name = :1"; cs:C1710.sfw_todoListManager.me.todoListWorkerName).first()
	If ($window=Null:C1517)
		CALL WORKER:C1389(cs:C1710.sfw_todoListManager.me.todoListWorkerName; Formula:C1597(cs:C1710.sfw_todoListManager.me.openWizardtodoList()))
	Else 
		BRING TO FRONT:C326($window.process.number)
	End if 
	
Function launchGlobalSearch()
	
	var $refWindow : Integer
	
	If (Storage:C1525.windows=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.windows:=New shared object:C1526
		End use 
	End if 
	
	$refWindow:=Num:C11(Storage:C1525.windows.globalSearch)
	Case of 
			
		: ($refWindow=0) & (Form:C1466.sfw.searchbox#"")
			$formData:=New object:C1471
			$formData.sfw:=cs:C1710.sfw_globalSearch.new()
			$formData.sfw.searchbox:=Form:C1466.sfw.searchbox
			$formData.limit:=Null:C1517
			
			GET WINDOW RECT:C443($left; $top; $right; $bottom; Current form window:C827)
			$refWindow:=Open form window:C675("sfw_globalSearch"; Plain form window:K39:10; On the right:K39:3; $bottom+Menu bar height:C440)
			Use (Storage:C1525.windows)
				Storage:C1525.windows.globalSearch:=$refWindow
			End use 
			DIALOG:C40("sfw_globalSearch"; $formData; *)
			CALL FORM:C1391($refWindow; "sfw_globalSearchManager"; "search"; Form:C1466.sfw.searchbox; Form:C1466.vision; Form:C1466.entries)
		: ($refWindow=0) & (Form:C1466.sfw.searchbox="")
		: ($refWindow#0) & (Form:C1466.sfw.searchbox="")
			CALL FORM:C1391($refWindow; "sfw_globalSearchManager"; "close")
		Else 
			SHOW WINDOW:C435($refWindow)
			CALL FORM:C1391($refWindow; "sfw_globalSearchManager"; "search"; Form:C1466.sfw.searchbox; Form:C1466.vision; Form:C1466.entries)
	End case 
	
	
	
Function pupVisions()
	var $eUserProfile : cs:C1710.sfw_UserProfileEntity
	var $esUserProfiles : cs:C1710.sfw_UserProfileSelection:=ds:C1482.sfw_UserProfile.query("ident in :1"; cs:C1710.sfw_userManager.me.authorizedProfiles)
	$menusToRelease:=New collection:C1472
	$mainMenu:=Create menu:C408
	$menusToRelease.push($mainMenu)
	For each ($vision; cs:C1710.sfw_definition.me.visions.orderBy("displayOrder desc"))
		If ($vision.allowedProfiles#Null:C1517) && ($vision.allowedProfiles.length>0)
			$displayVision:=False:C215
			For each ($eUserProfile; $esUserProfiles) Until ($displayVision)
				$displayVision:=$displayVision || ($vision.allowedProfiles.indexOf($eUserProfile.ident)#-1)
			End for each 
		Else 
			$displayVision:=True:C214
		End if 
		If (Not:C34($displayVision))
			For each ($eUserProfile; $esUserProfiles) Until ($displayVision)
				If ($eUserProfile.moreData.allowedVisions#Null:C1517)
					$displayVision:=$displayVision || ($eUserProfile.moreData.allowedVisions.indexOf($vision.ident)#-1)
				End if 
			End for each 
		End if 
		If ($displayVision)
			For each ($eUserProfile; $esUserProfiles) While ($displayVision)
				If ($eUserProfile.moreData.restrictVisions#Null:C1517) && ($eUserProfile.moreData.restrictVisions.indexOf($vision.ident)#-1)
					$displayVision:=False:C215
				End if 
			End for each 
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
	
	OBJECT GET COORDINATES:C663(*; "bkgd_vision"; $left; $top; $right; $bottom)
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
	
	
Function pupLogo()
	
	
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	
	$identFavoriteEntries:=ds:C1482.sfw_Favorite.getIdentFavoriteEntries()
	If ($identFavoriteEntries.length>0)
		$refSubMenuEntry:=Create menu:C408
		$refMenus.push($refSubMenuEntry)
		For each ($ident; $identFavoriteEntries)
			$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($ident)
			APPEND MENU ITEM:C411($refSubMenuEntry; $entry.label; *)
			SET MENU ITEM PARAMETER:C1004($refSubMenuEntry; -1; "--entry:"+$ident)
		End for each 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.favoriteEntries"; "Favorite entries"); $refSubMenuEntry; *)
	End if 
	If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
		$esFavorites:=ds:C1482.sfw_Favorite.query("UUID_target # null order by entryIdent")
	Else 
		$esFavorites:=ds:C1482.sfw_Favorite.query("UUID_target # null and UUID_User = :1 order by entryIdent"; cs:C1710.sfw_userManager.me.info.UUID)
	End if 
	If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
		$esSubscriptions:=ds:C1482.sfw_Subscription.query("UUID_target # null order by entryIdent")
	Else 
		$esSubscriptions:=ds:C1482.sfw_Subscription.query("UUID_target # null and UUID_User = :1 order by entryIdent"; cs:C1710.sfw_userManager.me.info.UUID)
	End if 
	If ($esFavorites.length>0)
		$refSubMenuFavorite:=Create menu:C408
		$refMenus.push($refSubMenuFavorite)
		For each ($eFavorite; $esFavorites)
			$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($eFavorite.entryIdent)
			$favoriteItems:=ds:C1482[$entry.dataclass].get($eFavorite.UUID_target)
			APPEND MENU ITEM:C411($refSubMenuFavorite; $entry.label+": "+$favoriteItems.nameInWindowTitle; *)
			SET MENU ITEM PARAMETER:C1004($refSubMenuFavorite; -1; "--favorite:"+String:C10($favoriteItems.UUID)+":"+$entry.ident)
			SET MENU ITEM ICON:C984($refSubMenuFavorite; -1; "Path:/RESOURCES/sfw/image/picto/star.png")
		End for each 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.favoriteItems"; "Favorite items"); $refSubMenuFavorite; *)
	End if 
	
	If ($esSubscriptions.length>0) && (cs:C1710.sfw_definition.me.globalParameters.notifications.activate)
		$refSubMenuSubscriptions:=Create menu:C408
		$refMenus.push($refSubMenuSubscriptions)
		For each ($eSubscription; $esSubscriptions)
			$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($eSubscription.entryIdent)
			$subscriptedItem:=ds:C1482[$entry.dataclass].get($eSubscription.UUID_target)
			APPEND MENU ITEM:C411($refSubMenuSubscriptions; $entry.label+": "+$subscriptedItem.nameInWindowTitle; *)
			SET MENU ITEM PARAMETER:C1004($refSubMenuSubscriptions; -1; "--favorite:"+String:C10($subscriptedItem.UUID)+":"+$entry.ident)
			SET MENU ITEM ICON:C984($refSubMenuSubscriptions; -1; "Path:/RESOURCES/sfw/image/picto/bell.png")
		End for each 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("toolbar.subscriptedItems"; "Subscripted items"); $refSubMenuSubscriptions; *)
	End if 
	
	OBJECT GET COORDINATES:C663(*; "bkgd_logo"; $g; $h; $d; $b)
	
	$choose:=Dynamic pop up menu:C1006($refMenu; ""; $g; $b)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choose="--entry:@")
			$ident:=Split string:C1554($choose; ":").pop()
			$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($ident)
			$visionIdent:=$entry.visions.first()
			$formData:=New object:C1471()
			Case of 
				: ($entry.wizard#Null:C1517)
					$formData.sfw:=cs:C1710.sfw_wizard.new()
				Else 
					$formData.sfw:=cs:C1710.sfw_main.new()
			End case 
			$formData.sfw.vision:=cs:C1710.sfw_definition.me.getVisionByIdent($visionIdent)
			$formData.sfw.entry:=$entry
			$formData.sfw.openForm($formData)
			
		: ($choose="--favorite:@")
			$parts:=Split string:C1554($choose; ":")
			$entryIdent:=$parts.pop()
			$uuid:=$parts.pop()
			$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($entryIdent)
			$visionIdent:=$entry.visions.first()
			$formData:=New object:C1471()
			$formData.sfw:=cs:C1710.sfw_item.new()
			$formData.sfw.vision:=cs:C1710.sfw_definition.me.getVisionByIdent($visionIdent)
			$formData.sfw.entry:=$entry
			$formData.current_item:=ds:C1482[$entry.dataclass].get($uuid)
			$formData.sfw.openForm($formData)
			
	End case 
	
	