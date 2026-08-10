property hl_settings : Object
property hl_icon_document : Object

singleton Class constructor
	//It's a singleton class
	This:C1470.hl_settings:=New object:C1471
	This:C1470.hl_settings.visionsOrder:="label"
	This:C1470.hl_settings.entriesOrder:="label"
	This:C1470.hl_settings.entriesGroupByVisions:=False:C215
	
	This:C1470.hl_icon_document:=New object:C1471
	For each ($type; Split string:C1554("profile;profiles;vision;visions;vision-prohibition;visions-prohibition;entry;entries;entry-prohibition;entries-prohibition"; ";"))
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/image/hl/"+$type+".png")
		READ PICTURE FILE:C678($file.platformPath; $pict)
		This:C1470.hl_icon_document[$type]:=$pict
	End for each 
	
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		Form:C1466.lb_inscriptions:=ds:C1482.sfw_UserInscription.query("UUID_User = :1"; Form:C1466.current_item.UUID)
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				// add load functions
				This:C1470.load_hl_permissions()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.canValidate:=(Form:C1466.current_item.firstName#"") && (Form:C1466.current_item.lastName#"")
		If (Form:C1466.current_item.login="") & (Form:C1466.canValidate)
			Form:C1466.current_item.setLogin()
		End if 
		
	End if 
	
	//Function drawPup_XXX()
	////This function updates the dropdown by displaying the name
	//Form.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form.current_item.xxxx=Null))
	
	
	//Function pup_XXX()
	////Create pop up menu
	//If (Form.sfw.checkIsInModification())
	//End if 
	//This.drawPup_XXX()
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	OBJECT SET ENABLED:C1123(*; "cb_asDesigner"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENABLED:C1123(*; "cb_isInactive"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENABLED:C1123(*; "btn_reset"; Form:C1466.sfw.checkIsInModification() && Not:C34(Form:C1466.situation.mode="add") && (Not:C34(Form:C1466.current_item.isInactive)))
	Form:C1466.sfw.redrawButtons()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$verticalMargin:=3
	
	Case of 
		: (FORM Get current page:C276(*)=1)  // team members
			OBJECT GET COORDINATES:C663(*; "bAction_hl_permissions"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bAction_hl_permissions"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)
			
			OBJECT GET COORDINATES:C663(*; "bkgd_hl_permissions"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "hl_permissions"; $g+1; $h+2; $d-1; $heightSubform-$verticalMargin-$heightButton-$verticalMargin)
			OBJECT SET COORDINATES:C1248(*; "bkgd_hl_permissions"; $g; $h; $d; $heightSubform+1)
			
	End case 
	
	
	
	
	//Function loadXXX()
	////Loads and initializes a list
	
Function bActionInscriptions()
	var $eProfile : cs:C1710.sfw_UserProfileEntity
	var $eInscription : cs:C1710.sfw_UserInscriptionEntity
	$menus:=New collection:C1472()
	$menu:=Create menu:C408
	$menus.push($menu)
	
	If (Form:C1466.sfw.checkIsInModification())
		$subMenuProfiles:=Create menu:C408
		$menus.push($subMenuProfiles)
		$uuids:=Form:C1466.lb_inscriptions.extract("UUID_UserProfile")
		$esProfiles:=ds:C1482.sfw_UserProfile.query("not(UUID in :1) order by name"; $uuids)
		For each ($eProfile; $esProfiles)
			APPEND MENU ITEM:C411($subMenuProfiles; $eProfile.name; *)
			SET MENU ITEM PARAMETER:C1004($subMenuProfiles; -1; "Profile:"+$eProfile.UUID)
		End for each 
		If ($esProfiles.length#0)
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.addProfile"; "Add a profile"); $subMenuProfiles; *)
		Else 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.addProfile"; "Add a profile"); *)
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.addProfile"; "Add a profile"); *)
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	If (Form:C1466.inscription#Null:C1517)
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.deleteProfile"; "Delete the profil")+" \""+Form:C1466.inscription.userProfile.name+"\""; *)  // add xliff
		If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.inscription.moreData.autoCreation=Null:C1517)
			SET MENU ITEM PARAMETER:C1004($menu; -1; "Delete:"+Form:C1466.inscription.UUID)
		Else 
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.deleteProfile"; "Delete the profil"); *)  // add xliff
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	$choose:=Dynamic pop up menu:C1006($menu)
	For each ($menu; $menus)
		RELEASE MENU:C978($menu)
	End for each 
	
	Case of 
		: ($choose="Profile:@")
			$UUIDProfile:=Split string:C1554($choose; ":").pop()
			$eInscription:=ds:C1482.sfw_UserInscription.new()
			$eInscription.UUID:=Generate UUID:C1066
			$eInscription.UUID_User:=Form:C1466.current_item.UUID
			$eInscription.UUID_UserProfile:=$UUIDProfile
			$eInscription.UUID_whoHasGiven:=cs:C1710.sfw_userManager.me.info.UUID
			$eInscription.stmp_given:=cs:C1710.sfw_stmp.me.now()
			$eInscription.moreData:=New object:C1471
			$info:=$eInscription.save()
			If ($info.success)
				Form:C1466.lb_inscriptions:=ds:C1482.sfw_UserInscription.query("UUID_User = :1"; Form:C1466.current_item.UUID)
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			End if 
			
		: ($choose="Delete:@")
			$UUIDInscription:=Split string:C1554($choose; ":").pop()
			$eInscription:=ds:C1482.sfw_UserInscription.get($UUIDInscription)
			If ($eInscription#Null:C1517)
				$info:=$eInscription.drop()
				If ($info.success)
					Form:C1466.lb_inscriptions:=ds:C1482.sfw_UserInscription.query("UUID_User = :1"; Form:C1466.current_item.UUID)
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
				End if 
			End if 
			
	End case 
	
	
Function load_hl_permissions($option : Integer)
	var $eUserInscription : cs:C1710.sfw_UserInscriptionEntity
	
	If (Count parameters:C259=0) || (Form:C1466.hl_permissions_current_item=Null:C1517)
		Form:C1466.hl_permissions_current_item:=New object:C1471
		Form:C1466.hl_permissions_current_item.ref:=0
		Form:C1466.hl_permissions_current_item.text:=""
		Form:C1466.hl_permissions_current_item.kind:=""
		Form:C1466.hl_permissions_current_item.key:=""
	End if 
	Form:C1466.hl_permissions_current_item.refToSelect:=0
	
	If (Form:C1466.hl_permissions#Null:C1517) && (Is a list:C621(Form:C1466.hl_permissions))
		CLEAR LIST:C377(Form:C1466.hl_permissions; *)
	End if 
	Form:C1466.hl_permissions:=New list:C375
	Form:C1466.hl_permissions_refCounter:=0
	$lh_userInscriptions:=New list:C375
	$nb_profiles:=0
	For each ($eUserInscription; ds:C1482.sfw_UserInscription.query("UUID_User = :1"; Form:C1466.current_item.UUID))
		If ($eUserInscription.user#Null:C1517)
			$nb_profiles+=1
			Form:C1466.hl_permissions_refCounter+=1
			APPEND TO LIST:C376($lh_userInscriptions; $eUserInscription.userProfile.name; Form:C1466.hl_permissions_refCounter)
			SET LIST ITEM PARAMETER:C986($lh_userInscriptions; Form:C1466.hl_permissions_refCounter; "kind"; "userInscription")
			SET LIST ITEM PARAMETER:C986($lh_userInscriptions; Form:C1466.hl_permissions_refCounter; "key"; $eUserInscription.getKey())
			If ($eUserInscription.moreData.autoCreation#Null:C1517)
				SET LIST ITEM PROPERTIES:C386($lh_userInscriptions; Form:C1466.hl_permissions_refCounter; False:C215; Plain:K14:1; 0; 0x00C00000)
			End if 
			$pict:=This:C1470.hl_icon_document["profile"]
			SET LIST ITEM ICON:C950($lh_userInscriptions; Form:C1466.hl_permissions_refCounter; $pict)
		End if 
	End for each 
	If ($nb_profiles>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("user.profileregistrations"); Form:C1466.hl_permissions_refCounter; $lh_userInscriptions; True:C214)  //okXLIFF
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "inscriptions")
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_profiles))
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["profiles"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	
	$esUserProfiles:=ds:C1482.sfw_UserInscription.query("UUID_User = :1"; Form:C1466.current_item.UUID).userProfile
	
	$visionsIdents:=New collection:C1472
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
			$visionsIdents.push($vision.ident)
		End if 
	End for each 
	$visionsIdents:=$visionsIdents.distinct()
	
	$lh_visions:=New list:C375
	$nb_visions:=0
	For each ($vision; cs:C1710.sfw_definition.me.visions.query("ident in :1 and label # :2"; $visionsIdents; "-").orderBy(This:C1470.hl_settings.visionsOrder))
		$nb_visions+=1
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_visions; $vision.label; Form:C1466.hl_permissions_refCounter)
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; "kind"; "vision")
		$pict:=This:C1470.hl_icon_document["vision"]
		SET LIST ITEM ICON:C950($lh_visions; Form:C1466.hl_permissions_refCounter; $pict)
	End for each 
	If ($nb_visions>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("user.availablevisons"); Form:C1466.hl_permissions_refCounter; $lh_visions; True:C214)  //okXLIFF
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "visions")
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_visions))
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["visions"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	$lh_visions:=New list:C375
	$nb_visions:=0
	For each ($vision; cs:C1710.sfw_definition.me.visions.query("(not(ident in :1)) and label # :2"; $visionsIdents; "-").orderBy(This:C1470.hl_settings.visionsOrder))
		$nb_visions+=1
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_visions; $vision.label; Form:C1466.hl_permissions_refCounter)
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; "kind"; "vision")
		$pict:=This:C1470.hl_icon_document["vision-prohibition"]
		SET LIST ITEM ICON:C950($lh_visions; Form:C1466.hl_permissions_refCounter; $pict)
	End for each 
	If ($nb_visions>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("user.unvailablevisons"); Form:C1466.hl_permissions_refCounter; $lh_visions; False:C215)  //okXLIFF
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "vision-prohibition")
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_visions))
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["visions-prohibition"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	
	
	$entriesIdents:=New collection:C1472
	For each ($entry; cs:C1710.sfw_definition.me.entries)
		If ($entry#Null:C1517) && ($entry.splitter=Null:C1517)
			If ($entry.allowedProfiles#Null:C1517) && ($entry.allowedProfiles.length>0)
				$displayEntry:=False:C215
				For each ($eUserProfile; $esUserProfiles) Until ($displayEntry)
					$displayEntry:=$displayEntry || ($entry.allowedProfiles.indexOf($eUserProfile.ident)#-1)
				End for each 
			Else 
				$displayEntry:=True:C214
			End if 
			If (Not:C34($displayEntry))
				For each ($eUserProfile; $esUserProfiles) Until ($displayEntry)
					If ($eUserProfile.moreData.allowedEntries#Null:C1517)
						$displayEntry:=$displayEntry || ($eUserProfile.moreData.allowedEntries.indexOf($entry.ident)#-1)
					End if 
				End for each 
			End if 
			If ($displayEntry)
				For each ($eUserProfile; $esUserProfiles) While ($displayEntry)
					If ($eUserProfile.moreData.restrictEntries#Null:C1517) && ($eUserProfile.moreData.restrictEntries.indexOf($entry.ident)#-1)
						$displayEntry:=False:C215
					End if 
				End for each 
			End if 
			If ($displayEntry)
				$displayEntry:=False:C215
				For each ($visionIdent; $entry.visions) Until ($displayEntry)
					$displayEntry:=($visionsIdents.indexOf($visionIdent)>=0)
				End for each 
			End if 
			If ($displayEntry)
				$entriesIdents.push($entry.ident)
			End if 
		End if 
	End for each 
	$entriesIdents:=$entriesIdents.distinct()
	
	
	If (This:C1470.hl_settings.entriesGroupByVisions)
		$lh_visions:=New list:C375
		$nb_visions:=0
		For each ($vision; cs:C1710.sfw_definition.me.visions.query("ident in :1 and label # :2"; $visionsIdents; "-").orderBy(This:C1470.hl_settings.visionsOrder))
			$lh_entries:=New list:C375
			$nb_entries:=0
			For each ($entry; cs:C1710.sfw_definition.me.entries.query("ident in :1"; $entriesIdents).orderBy(This:C1470.hl_settings.entriesOrder))
				If ($entry.label#"-") && ($entry.label#"") && ($entry.visions.indexOf($vision.ident)#-1)
					$nb_entries+=1
					Form:C1466.hl_permissions_refCounter+=1
					APPEND TO LIST:C376($lh_entries; $entry.label; Form:C1466.hl_permissions_refCounter)
					SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; "kind"; "entry")
					$pict:=This:C1470.hl_icon_document["entry"]
					SET LIST ITEM ICON:C950($lh_entries; Form:C1466.hl_permissions_refCounter; $pict)
				End if 
			End for each 
			If ($nb_entries>0)
				$nb_visions+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_visions; $vision.label; Form:C1466.hl_permissions_refCounter; $lh_entries; True:C214)  //XLIFF
				SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; "kind"; "vision")
				SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_entries))
				//SET LIST ITEM PROPERTIES($lh_visions; Form.hl_permissions_refCounter; False; Bold)
				$pict:=This:C1470.hl_icon_document["vision"]
				SET LIST ITEM ICON:C950($lh_visions; Form:C1466.hl_permissions_refCounter; $pict)
			End if 
		End for each 
		If ($nb_visions>0)
			Form:C1466.hl_permissions_refCounter+=1
			APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("user.availableentriesbyvis"); Form:C1466.hl_permissions_refCounter; $lh_visions; True:C214)  //okXLIFF
			SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "entriesByVisions")
			SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($entriesIdents.length)+"/"+String:C10($nb_visions))
			SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
			$pict:=This:C1470.hl_icon_document["entries"]
			SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
		End if 
	Else 
		$lh_entries:=New list:C375
		$nb_entries:=0
		For each ($entry; cs:C1710.sfw_definition.me.entries.query("ident in :1"; $entriesIdents).orderBy(This:C1470.hl_settings.entriesOrder))
			If ($entry.label#"-") && ($entry.label#"")
				$nb_entries+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_entries; $entry.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; "kind"; "entry")
				$pict:=This:C1470.hl_icon_document["entry"]
				SET LIST ITEM ICON:C950($lh_entries; Form:C1466.hl_permissions_refCounter; $pict)
			End if 
		End for each 
		If ($nb_entries>0)
			Form:C1466.hl_permissions_refCounter+=1
			APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("user.availableentries"); Form:C1466.hl_permissions_refCounter; $lh_entries; True:C214)  //okXLIFF
			SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "entries")
			SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_entries))
			SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
			$pict:=This:C1470.hl_icon_document["entries"]
			SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
		End if 
	End if 
	
	$lh_entries:=New list:C375
	$nb_entries:=0
	For each ($entry; cs:C1710.sfw_definition.me.entries.query("not(ident in :1)"; $entriesIdents).orderBy(This:C1470.hl_settings.entriesOrder))
		If ($entry.label#"-") && ($entry.label#"")
			$nb_entries+=1
			Form:C1466.hl_permissions_refCounter+=1
			APPEND TO LIST:C376($lh_entries; $entry.label; Form:C1466.hl_permissions_refCounter)
			SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; "kind"; "entry")
			$pict:=This:C1470.hl_icon_document["entry-prohibition"]
			SET LIST ITEM ICON:C950($lh_entries; Form:C1466.hl_permissions_refCounter; $pict)
		End if 
	End for each 
	If ($nb_entries>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; ds:C1482.sfw_readXliff("user.unavailableentries"); Form:C1466.hl_permissions_refCounter; $lh_entries; False:C215)  //okXLIFF
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "entries")
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_entries))
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["entries-prohibition"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	
	
Function hl_permissions()
	var $kind : Text
	var $key : Text
	
	Case of 
		: (FORM Event:C1606.code=On Selection Change:K2:29)
			
			GET LIST ITEM:C378(Form:C1466.hl_permissions; *; $refItem; $textItem)
			Form:C1466.hl_permissions_current_item:=New object:C1471
			Form:C1466.hl_permissions_current_item.ref:=$refItem
			Form:C1466.hl_permissions_current_item.text:=$textItem
			GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $refItem; "kind"; $kind)
			Form:C1466.hl_permissions_current_item.kind:=$kind
			GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $refItem; "key"; $key)
			Form:C1466.hl_permissions_current_item.key:=$key
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 || Contextual click:C713)
			This:C1470.bAction_hl_permissions()
	End case 
	
	
	
Function bAction_hl_permissions()
	
	var $eProfile : cs:C1710.sfw_UserProfileEntity
	var $eInscription : cs:C1710.sfw_UserInscriptionEntity
	$menus:=New collection:C1472()
	$menu:=Create menu:C408
	$menus.push($menu)
	
	If (Form:C1466.sfw.checkIsInModification())
		$subMenuProfiles:=Create menu:C408
		$menus.push($subMenuProfiles)
		$uuids:=Form:C1466.lb_inscriptions.extract("UUID_UserProfile")
		$esProfiles:=ds:C1482.sfw_UserProfile.query("not(UUID in :1) order by name"; $uuids)
		For each ($eProfile; $esProfiles)
			APPEND MENU ITEM:C411($subMenuProfiles; $eProfile.name; *)
			SET MENU ITEM PARAMETER:C1004($subMenuProfiles; -1; "Profile:"+$eProfile.UUID)
		End for each 
		If ($esProfiles.length#0)
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.addProfile"; "Add a profile"); $subMenuProfiles; *)
		Else 
			APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.addProfile"; "Add a profile"); *)
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.addProfile"; "Add a profile"); *)
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	If (Form:C1466.hl_permissions_current_item.kind="userInscription")
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.deleteProfile"; "Delete the profil")+" \""+Form:C1466.hl_permissions_current_item.text+"\""; *)  // add xliff
		$userInscription:=ds:C1482.sfw_UserInscription.get(Form:C1466.hl_permissions_current_item.key)
		If (Form:C1466.sfw.checkIsInModification()) && ($userInscription.moreData.autoCreation=Null:C1517)
			SET MENU ITEM PARAMETER:C1004($menu; -1; "Delete:"+$userInscription.UUID)
		Else 
			DISABLE MENU ITEM:C150($menu; -1)
		End if 
	Else 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("profil.deleteProfile"; "Delete the profil"); *)  // add xliff
		DISABLE MENU ITEM:C150($menu; -1)
	End if 
	
	If (Form:C1466.hl_permissions_current_item.kind="@vision@")
		APPEND MENU ITEM:C411($menu; "-")
		$refMenuOrder:=Create menu:C408
		$menus.push($refMenuOrder)
		APPEND MENU ITEM:C411($refMenuOrder; ds:C1482.sfw_readXliff("user.byname"); *)  //okXLIFF
		SET MENU ITEM PARAMETER:C1004($refMenuOrder; -1; "--visionOrderBy:label")
		If (This:C1470.hl_settings.visionsOrder="label")
			SET MENU ITEM MARK:C208($refMenuOrder; -1; Char:C90(18))
		End if 
		APPEND MENU ITEM:C411($refMenuOrder; ds:C1482.sfw_readXliff("user.byapplicationorder"); *)  //okXLIFF
		SET MENU ITEM PARAMETER:C1004($refMenuOrder; -1; "--visionOrderBy:displayOrder desc")
		If (This:C1470.hl_settings.visionsOrder="displayOrder desc")
			SET MENU ITEM MARK:C208($refMenuOrder; -1; Char:C90(18))
		End if 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("user.ordervisions"); $refMenuOrder)  //okXLIFF
	End if 
	If (Form:C1466.hl_permissions_current_item.kind="@entr@")
		APPEND MENU ITEM:C411($menu; "-")
		$refMenuOrder:=Create menu:C408
		$menus.push($refMenuOrder)
		APPEND MENU ITEM:C411($refMenuOrder; ds:C1482.sfw_readXliff("user.byname"); *)  //okXLIFF
		SET MENU ITEM PARAMETER:C1004($refMenuOrder; -1; "--entryOrderBy:label")
		If (This:C1470.hl_settings.entriesOrder="label")
			SET MENU ITEM MARK:C208($refMenuOrder; -1; Char:C90(18))
		End if 
		APPEND MENU ITEM:C411($refMenuOrder; ds:C1482.sfw_readXliff("user.byapplicationorder"); *)  //okXLIFF
		SET MENU ITEM PARAMETER:C1004($refMenuOrder; -1; "--entryOrderBy:displayOrder desc")
		If (This:C1470.hl_settings.entriesOrder="displayOrder desc")
			SET MENU ITEM MARK:C208($refMenuOrder; -1; Char:C90(18))
		End if 
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("user.orderentries"); $refMenuOrder; *)  //okXLIFF
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("user.groupbyvisions"); *)  //okXLIFF
		If (This:C1470.hl_settings.entriesGroupByVisions)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if 
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--entriesGroupByVisions")
	End if 
	
	$choose:=Dynamic pop up menu:C1006($menu)
	For each ($menu; $menus)
		RELEASE MENU:C978($menu)
	End for each 
	
	Case of 
		: ($choose="Profile:@")
			$UUIDProfile:=Split string:C1554($choose; ":").pop()
			$eInscription:=ds:C1482.sfw_UserInscription.new()
			$eInscription.UUID:=Generate UUID:C1066
			$eInscription.UUID_User:=Form:C1466.current_item.UUID
			$eInscription.UUID_UserProfile:=$UUIDProfile
			$eInscription.UUID_whoHasGiven:=cs:C1710.sfw_userManager.me.info.UUID
			$eInscription.stmp_given:=cs:C1710.sfw_stmp.me.now()
			$eInscription.moreData:=New object:C1471
			$info:=$eInscription.save()
			If ($info.success)
				This:C1470.load_hl_permissions()
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			End if 
			
		: ($choose="Delete:@")
			$UUIDInscription:=Split string:C1554($choose; ":").pop()
			$eInscription:=ds:C1482.sfw_UserInscription.get($UUIDInscription)
			If ($eInscription#Null:C1517)
				$info:=$eInscription.drop()
				If ($info.success)
					This:C1470.load_hl_permissions()
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
				End if 
			End if 
			
			
		: ($choose="--visionOrderBy:@")
			This:C1470.hl_settings.visionsOrder:=Split string:C1554($choose; ":").pop()
			This:C1470.load_hl_permissions(1)
			
		: ($choose="--entryOrderBy:@")
			This:C1470.hl_settings.entriesOrder:=Split string:C1554($choose; ":").pop()
			This:C1470.load_hl_permissions(1)
			
		: ($choose="--entriesGroupByVisions")
			This:C1470.hl_settings.entriesGroupByVisions:=Not:C34(This:C1470.hl_settings.entriesGroupByVisions)
			This:C1470.load_hl_permissions(1)
			
	End case 