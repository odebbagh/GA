property hpup_menus : Collection
property hpup_parentUUIDS : Collection

singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Case of 
		: (FORM Event:C1606.code=On Resize:K2:27)
			Case of 
				: (FORM Get current page:C276(*)=1)
					
				: (FORM Get current page:C276(*)=2)
					This:C1470.resizeObjectsPagePermissions()
			End case 
			
		Else 
			
			Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
			If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
			End if 
			If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
				Case of 
					: (FORM Get current page:C276(*)=1)
						// add load functions
					: (FORM Get current page:C276(*)=2)
						This:C1470.buildHLPermissions()
				End case 
			End if 
			If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
				This:C1470.redrawAndSetVisible()
			End if 
	End case 
	
	
Function drawPup_documentFolder()
	
	If (Form:C1466.current_item#Null:C1517)
		$documentFolderName:=Form:C1466.current_item.parentFolder.name || ds:C1482.sfw_readXliff("dfdTemplate.panel.rootfolder")
		Form:C1466.sfw.drawButtonPup("pup_documentFolder"; $documentFolderName; "")
	End if 
	
Function pup_documentFolder()
	If (Form:C1466.sfw.checkIsInModification())
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.documentFolder=Null:C1517)
			ds:C1482.sfw_DocumentFolder.cacheLoad(1)
		End if 
		
		This:C1470.hpup_menus:=New collection:C1472
		This:C1470.hpup_parentUUIDS:=New collection:C1472
		$menu:=This:C1470._hpup_documentFolder()
		
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.rootfolder"); *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--root")
		
		
		
		$choose:=Dynamic pop up menu:C1006($menu)
		For each ($menu; This:C1470.hpup_menus)
			RELEASE MENU:C978($menu)
		End for each 
		
		Case of 
			: ($choose="")
			: ($choose="-root")
				Form:C1466.current_item.UUID_ParentFolder:="00"*16
			Else 
				$eDocumentFolder:=ds:C1482.sfw_DocumentFolder.get($choose)
				Form:C1466.current_item.UUID_ParentFolder:=$eDocumentFolder.UUID
		End case 
	End if 
	
	This:C1470.drawPup_documentFolder()
	
Function _hpup_documentFolder($uuid_parent : Text)->$menu : Text
	var $parentFolder : Object
	var $parentFolders : Collection
	
	
	If (Count parameters:C259=0)
		$parentFolders:=Storage:C1525.cache.documentFolder.query("UUID_ParentFolder in :1"; [(16*"00"); (16*"20"); ""])
	Else 
		$parentFolders:=Storage:C1525.cache.documentFolder.query("UUID_ParentFolder = :1 order by name"; $uuid_parent)
		This:C1470.hpup_parentUUIDS.push($uuid_parent)
	End if 
	If ($parentFolders.length=0)
		$menu:=""
	Else 
		$menu:=Create menu:C408
		This:C1470.hpup_menus.push($menu)
		If (Count parameters:C259=0)
		Else 
			$folder:=Storage:C1525.cache.documentFolder.query("UUID=:1"; $uuid_parent).first()
			APPEND MENU ITEM:C411($menu; $folder.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $folder.UUID)
			APPEND MENU ITEM:C411($menu; "-")
		End if 
		For each ($parentFolder; $parentFolders)
			$subMenu:=This:C1470._hpup_documentFolder($parentFolder.UUID)
			If ($subMenu="")
				APPEND MENU ITEM:C411($menu; $parentFolder.name; *)
			Else 
				APPEND MENU ITEM:C411($menu; $parentFolder.name; $subMenu; *)
			End if 
			SET MENU ITEM PARAMETER:C1004($menu; -1; $parentFolder.UUID)
			If ($parentFolder.UUID=Form:C1466.current_item.UUID_ParentFolder)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			End if 
			If (This:C1470.hpup_parentUUIDS.indexOf(Form:C1466.current_item.UUID)#-1)
				DISABLE MENU ITEM:C150($menu; -1)
			End if 
		End for each 
	End if 
	If (Count parameters:C259=0)
	Else 
		$uuid:=This:C1470.hpup_parentUUIDS.pop()
	End if 
	
	
	
	
	
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	This:C1470.resizeObjectsPagePermissions()
	This:C1470.drawPup_documentFolder()
	OBJECT SET ENABLED:C1123(*; "cb_dontUpload"; Form:C1466.sfw.checkIsInModification())
	
	
	
	//mark:-permissions
	
Function resizeObjectsPagePermissions()
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubForm; $heightSubForm)
	$margin:=3
	OBJECT GET COORDINATES:C663(*; "bAction_permissions"; $btg; $bth; $btd; $btb)
	$btHeight:=$btb-$bth
	$btWidth:=$btd-$btg
	OBJECT GET COORDINATES:C663(*; "permissions_bkgd"; $g; $h; $d; $b)
	
	OBJECT SET COORDINATES:C1248(*; "permissions_bkgd"; -1; $h; $d; $heightSubForm+1)
	OBJECT SET COORDINATES:C1248(*; "bAction_permissions"; $margin; $heightSubForm-$btHeight-($margin*1); $margin+$btWidth; $heightSubForm-($margin*1))
	OBJECT SET COORDINATES:C1248(*; "hl_permissions"; 0; $h; $d-1; $heightSubForm-$btHeight-($margin*2))
	OBJECT SET COORDINATES:C1248(*; "hl_bkgd"; 0; $h; $d-1; $heightSubForm-$btHeight-($margin*2))
	
	
Function buildHLPermissions()
	var $eProfile : cs:C1710.sfw_UserProfileEntity
	var $esProfiles : cs:C1710.sfw_UserProfileSelection
	
	If (Form:C1466.hl_permissions#Null:C1517) && (Is a list:C621(Form:C1466.hl_permissions))
		CLEAR LIST:C377(Form:C1466.hl_permissions; *)
	End if 
	Form:C1466.hl_permissions:=New list:C375
	$refInList:=0
	$identProfiles:=Form:C1466.current_item.moreData.allowedProfiles || New collection:C1472
	$esProfiles:=ds:C1482.sfw_UserProfile.query("ident in :1 order by name"; $identProfiles)
	If ($esProfiles.length>0)
		$subList:=New list:C375
		For each ($eProfile; $esProfiles)
			$refInList+=1
			APPEND TO LIST:C376($subList; $eProfile.name; $refInList)
			SET LIST ITEM PARAMETER:C986($subList; $refInList; "profilIdent"; $eProfile.ident)
		End for each 
		$refInList+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("dfdTemplate.panel.profiles"); $refInList; $subList; True:C214)
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; $refInList; False:C215; Bold:K14:2)
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; $refInList; Additional text:K28:7; String:C10($esProfiles.length))
		
	End if 
	
	$entries:=New collection:C1472()
	If (Form:C1466.current_item.moreData.allowedEntries#Null:C1517)
		$entries:=cs:C1710.sfw_definition.me.entries.query("ident in :1"; Form:C1466.current_item.moreData.allowedEntries || New collection:C1472).extract("ident"; "ident"; "label"; "label").orderBy("label")
	End if 
	If ($entries.length>0)
		$subList:=New list:C375
		For each ($entry; $entries)
			$refInList+=1
			APPEND TO LIST:C376($subList; $entry.label; $refInList)
			SET LIST ITEM PARAMETER:C986($subList; $refInList; "entryIdent"; $entry.ident)
		End for each 
		$refInList+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("dfdTemplate.panel.entries"); $refInList; $subList; True:C214)
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; $refInList; False:C215; Bold:K14:2)
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; $refInList; Additional text:K28:7; String:C10($entries.length))
	End if 
	
	
Function bAction_permissions()
	
	GET LIST ITEM:C378(Form:C1466.hl_permissions; *; $itemRef; $itemText)
	$profilIdent:=""
	$entryIdent:=""
	If ($itemRef#0)
		GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $itemRef; "profilIdent"; $profilIdent)
		GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $itemRef; "entryIdent"; $entryIdent)
	End if 
	$menus:=New collection:C1472()
	$menu:=Create menu:C408
	$menus.push($menu)
	
	If (Form:C1466.sfw.checkIsInModification())
		$subMenuProfiles:=Create menu:C408
		$menus.push($subMenuProfiles)
		$profiles:=ds:C1482.sfw_UserProfile.query("not(ident in :1) order by name"; Form:C1466.current_item.moreData.allowedProfiles || New collection:C1472)
		For each ($profil; $profiles)
			APPEND MENU ITEM:C411($subMenuProfiles; $profil.name; *)
			SET MENU ITEM PARAMETER:C1004($subMenuProfiles; -1; "Profil:"+$profil.ident)
		End for each 
		If ($profiles.length#0)
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.addpr"); $subMenuProfiles; *)
		Else 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.addpr"); *)
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.addpr"); *)
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	
	If (Form:C1466.sfw.checkIsInModification())
		$subMenuEntries:=Create menu:C408
		$menus.push($subMenuEntries)
		$entries:=cs:C1710.sfw_definition.me.entries
		$colEntries:=New collection:C1472()
		For each ($entry; $entries)
			$e:=$colEntries.query("ident = :1"; $entry.ident)
			If ($e.length=0)
				$colEntries.push({ident: $entry.ident; label: $entry.label})
			End if 
		End for each 
		$colEntries:=$colEntries.orderBy("label")
		
		For each ($entry; $colEntries)
			APPEND MENU ITEM:C411($subMenuEntries; $entry.label; *)
			SET MENU ITEM PARAMETER:C1004($subMenuEntries; -1; "Entry:"+$entry.ident)
		End for each 
		If ($colEntries.length#0)
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.adde"); $subMenuEntries; *)
		Else 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.adde"); *)
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.adde"); *)
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("dfdTemplate.panel.delete"); *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "Delete")
	If (Form:C1466.sfw.checkIsInModification()) && (($profilIdent#"") || ($entryIdent#""))
	Else 
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($menu)
	For each ($menu; $menus)
		RELEASE MENU:C978($menu)
	End for each 
	
	Case of 
		: ($choose)="Profil:@"
			$profilIdent:=Split string:C1554($choose; ":").pop()
			If (Form:C1466.current_item.moreData.allowedProfiles=Null:C1517)
				Form:C1466.current_item.moreData.allowedProfiles:=New collection:C1472()
			End if 
			Form:C1466.current_item.moreData.allowedProfiles.push($profilIdent)
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
		: ($choose)="Entry:@"
			$entryIdent:=Split string:C1554($choose; ":").pop()
			
			If (Form:C1466.current_item.moreData.allowedEntries=Null:C1517)
				Form:C1466.current_item.moreData.allowedEntries:=New collection:C1472()
			End if 
			
			Form:C1466.current_item.moreData.allowedEntries.push($entryIdent)
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
			
		: ($choose="Delete") && ($profilIdent#"")
			
			$index:=Form:C1466.current_item.moreData.allowedProfiles.indexOf($profilIdent)
			If ($index>=0)
				Form:C1466.current_item.moreData.allowedProfiles.remove($index)
			End if 
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
		: ($choose="Delete") && ($entryIdent#"")
			
			$index:=Form:C1466.current_item.moreData.allowedEntries.indexOf($entryIdent)
			If ($index>=0)
				Form:C1466.current_item.moreData.allowedEntries.remove($index)
			End if 
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.buildHLPermissions()
			
	End case 
	
Function hl_permissions
	
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4) && ((Right click:C712) || (Contextual click:C713))
			This:C1470.bAction_permissions()
			
	End case 