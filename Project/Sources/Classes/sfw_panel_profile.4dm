property hl_settings : Object
property hl_icon_document : Object

singleton Class constructor
	//It's a singleton class
	This:C1470.hl_settings:=New object:C1471
	This:C1470.hl_settings.visionsOrder:="label"
	This:C1470.hl_settings.entriesOrder:="label"
	This:C1470.hl_settings.entriesGroupByVisions:=False:C215
	This:C1470.hl_icon_document:=New object:C1471
	For each ($type; Split string:C1554("users;user;visions;visions-prohibition;visions-disabled;vision;vision-prohibition;vision-disabled;entries;entries-prohibition;entries-disabled;entry;entry-prohibition;entry-disabled;add;edit;delete;database;pageTab;view;itemAction;listAction;filter;pr"+"ojection"; ";"))
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/image/hl/"+$type+".png")
		READ PICTURE FILE:C678($file.platformPath; $pict)
		This:C1470.hl_icon_document[$type]:=$pict
	End for each 
	
	
Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of 
			: (FORM Get current page:C276(*)=1)
				// add load functions
				This:C1470.load_hl_permissions()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
	
	
Function redrawAndSetVisible()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$verticalMargin:=3
	
	Case of 
		: (FORM Get current page:C276(*)=1)  // team members
			OBJECT GET COORDINATES:C663(*; "bAction_hl_permissions"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bAction_hl_permissions"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)
			
			OBJECT GET COORDINATES:C663(*; "bkgd_hl_permissions"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "hl_permissions"; $g+1; $h; $d-2; $heightSubform-$verticalMargin-$heightButton-$verticalMargin)
			OBJECT SET COORDINATES:C1248(*; "bkgd_hl_permissions"; $g; $h; $d; $heightSubform)
			
			OBJECT GET COORDINATES:C663(*; "bkgd_hl_entryPermissions"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bkgd_hl_entryPermissions"; $g; $h; $widthSubform; $heightSubform)
			OBJECT SET COORDINATES:C1248(*; "hl_entryPermissions"; $g+1; $h+2; $widthSubform-2; $heightSubform-$verticalMargin-$heightButton-$verticalMargin)
			OBJECT SET COORDINATES:C1248(*; "bAction_hl_entryPermissions"; $g+5; $heightSubform-$verticalMargin-$heightButton; $g+85; $heightSubform-$verticalMargin)
			
			
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
	$nb_users:=0
	For each ($eUserInscription; ds:C1482.sfw_UserInscription.query("UUID_UserProfile = :1"; Form:C1466.current_item.UUID))
		If ($eUserInscription.user#Null:C1517)
			$nb_users+=1
			Form:C1466.hl_permissions_refCounter+=1
			APPEND TO LIST:C376($lh_userInscriptions; $eUserInscription.user.fullName; Form:C1466.hl_permissions_refCounter)
			SET LIST ITEM PARAMETER:C986($lh_userInscriptions; Form:C1466.hl_permissions_refCounter; "kind"; "userInscription")
			SET LIST ITEM PARAMETER:C986($lh_userInscriptions; Form:C1466.hl_permissions_refCounter; "key"; $eUserInscription.getKey())
			$pict:=This:C1470.hl_icon_document["user"]
			SET LIST ITEM ICON:C950($lh_userInscriptions; Form:C1466.hl_permissions_refCounter; $pict)
		End if 
	End for each 
	If ($nb_users>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; "Registered users"; Form:C1466.hl_permissions_refCounter; $lh_userInscriptions; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "inscriptedUsers")
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_users))
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["users"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	
	$lh_visions:=New list:C375
	$lh_allowedVisions:=New list:C375
	$lh_notAllowedVisions:=New list:C375
	$lh_restrictedVisions:=New list:C375
	$nb_allowedVisions:=0
	$nb_notAllowedVisions:=0
	$nb_restrictedVisions:=0
	For each ($vision; cs:C1710.sfw_definition.me.visions.query("label # :1"; "-").orderBy(This:C1470.hl_settings.visionsOrder))
		Case of 
			: ($vision.allowedProfiles=Null:C1517)
			: ($vision.allowedProfiles.indexOf(Form:C1466.current_item.ident)>=0)
				$nb_allowedVisions+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_allowedVisions; $vision.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; "kind"; "vision")
				SET LIST ITEM PARAMETER:C986($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; "key"; $vision.ident)
				SET LIST ITEM PROPERTIES:C386($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; False:C215; Plain:K14:1; 0; 0x00C00000)
				$pict:=This:C1470.hl_icon_document["vision"]
				SET LIST ITEM ICON:C950($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="vision") && (Form:C1466.hl_permissions_current_item.key=$vision.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
				
			: (Form:C1466.current_item.moreData.allowedVisions#Null:C1517) && (Form:C1466.current_item.moreData.allowedVisions.indexOf($vision.ident)>=0)
				$nb_allowedVisions+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_allowedVisions; $vision.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; "kind"; "vision")
				SET LIST ITEM PARAMETER:C986($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; "key"; $vision.ident)
				SET LIST ITEM PROPERTIES:C386($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; False:C215; Plain:K14:1; 0; 0x0080)
				$pict:=This:C1470.hl_icon_document["vision"]
				SET LIST ITEM ICON:C950($lh_allowedVisions; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="vision") && (Form:C1466.hl_permissions_current_item.key=$vision.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
				
			: (Form:C1466.current_item.moreData.restrictVisions#Null:C1517) && (Form:C1466.current_item.moreData.restrictVisions.indexOf($vision.ident)>=0)
				$nb_restrictedVisions+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_restrictedVisions; $vision.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_restrictedVisions; Form:C1466.hl_permissions_refCounter; "kind"; "vision")
				SET LIST ITEM PARAMETER:C986($lh_restrictedVisions; Form:C1466.hl_permissions_refCounter; "key"; $vision.ident)
				SET LIST ITEM PROPERTIES:C386($lh_restrictedVisions; Form:C1466.hl_permissions_refCounter; False:C215; Plain:K14:1; 0; 0x00FF0000)
				$pict:=This:C1470.hl_icon_document["vision-prohibition"]
				SET LIST ITEM ICON:C950($lh_restrictedVisions; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="vision") && (Form:C1466.hl_permissions_current_item.key=$vision.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
				
			: ($vision.allowedProfiles.indexOf(Form:C1466.current_item.ident)=-1)
				$nb_notAllowedVisions+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_notAllowedVisions; $vision.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_notAllowedVisions; Form:C1466.hl_permissions_refCounter; "kind"; "vision")
				SET LIST ITEM PARAMETER:C986($lh_notAllowedVisions; Form:C1466.hl_permissions_refCounter; "key"; $vision.ident)
				$pict:=This:C1470.hl_icon_document["vision-disabled"]
				SET LIST ITEM ICON:C950($lh_notAllowedVisions; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="vision") && (Form:C1466.hl_permissions_current_item.key=$vision.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
				
		End case 
	End for each 
	If ($nb_allowedVisions>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_visions; "Allowed visions for this profile"; Form:C1466.hl_permissions_refCounter; $lh_allowedVisions; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; "kind"; "allowedVisions")
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_allowedVisions))
		SET LIST ITEM PROPERTIES:C386($lh_visions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["visions"]
		SET LIST ITEM ICON:C950($lh_visions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	If ($nb_notAllowedVisions>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_visions; "Not allowed visions by this profile"; Form:C1466.hl_permissions_refCounter; $lh_notAllowedVisions; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; "kind"; "notAllowedVisions")
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_notAllowedVisions))
		SET LIST ITEM PROPERTIES:C386($lh_visions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["visions-disabled"]
		SET LIST ITEM ICON:C950($lh_visions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	If ($nb_restrictedVisions>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_visions; "Prohibited visions for this profile"; Form:C1466.hl_permissions_refCounter; $lh_restrictedVisions; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; "kind"; "prohibitedVisions")
		SET LIST ITEM PARAMETER:C986($lh_visions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_restrictedVisions))
		SET LIST ITEM PROPERTIES:C386($lh_visions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["visions-prohibition"]
		SET LIST ITEM ICON:C950($lh_visions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	If ($nb_allowedVisions>0) || ($nb_notAllowedVisions>0) || ($nb_restrictedVisions>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; "Visions"; Form:C1466.hl_permissions_refCounter; $lh_visions; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "visions")
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_allowedVisions+$nb_notAllowedVisions+$nb_restrictedVisions))
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["visions"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	
	$entries:=cs:C1710.sfw_definition.me.entries.query("not(label in :1)"; [""; "-"]).orderBy(This:C1470.hl_settings.entriesOrder)
	$lh_entries:=New list:C375
	$lh_allowedEntries:=New list:C375
	$lh_notAllowedEntries:=New list:C375
	$lh_restrictedEntries:=New list:C375
	$nb_allowedEntries:=0
	$nb_notAllowedEntries:=0
	$nb_restrictedEntries:=0
	For each ($entry; $entries)
		Case of 
			: ($entry.allowedProfiles=Null:C1517)
			: ($entry.allowedProfiles.indexOf(Form:C1466.current_item.ident)>=0)
				$nb_allowedEntries+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_allowedEntries; $entry.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; "kind"; "entry")
				SET LIST ITEM PARAMETER:C986($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; "key"; $entry.ident)
				SET LIST ITEM PROPERTIES:C386($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; False:C215; Plain:K14:1; 0; 0x00C00000)
				$pict:=This:C1470.hl_icon_document["entry"]
				SET LIST ITEM ICON:C950($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="entry") && (Form:C1466.hl_permissions_current_item.key=$entry.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
			: (Form:C1466.current_item.moreData.allowedEntries#Null:C1517) && (Form:C1466.current_item.moreData.allowedEntries.indexOf($entry.ident)>=0)
				$nb_allowedEntries+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_allowedEntries; $entry.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; "kind"; "entry")
				SET LIST ITEM PARAMETER:C986($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; "key"; $entry.ident)
				SET LIST ITEM PROPERTIES:C386($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; False:C215; Plain:K14:1; 0; 0x0080)
				$pict:=This:C1470.hl_icon_document["entry"]
				SET LIST ITEM ICON:C950($lh_allowedEntries; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="entry") && (Form:C1466.hl_permissions_current_item.key=$entry.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
				
			: (Form:C1466.current_item.moreData.restrictEntries#Null:C1517) && (Form:C1466.current_item.moreData.restrictEntries.indexOf($entry.ident)>=0)
				$nb_restrictedEntries+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_restrictedEntries; $entry.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_restrictedEntries; Form:C1466.hl_permissions_refCounter; "kind"; "entry")
				SET LIST ITEM PARAMETER:C986($lh_restrictedEntries; Form:C1466.hl_permissions_refCounter; "key"; $entry.ident)
				SET LIST ITEM PROPERTIES:C386($lh_restrictedEntries; Form:C1466.hl_permissions_refCounter; False:C215; Plain:K14:1; 0; 0x00FF0000)
				$pict:=This:C1470.hl_icon_document["entry-prohibition"]
				SET LIST ITEM ICON:C950($lh_restrictedEntries; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="entry") && (Form:C1466.hl_permissions_current_item.key=$entry.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
				
			: ($entry.allowedProfiles.indexOf(Form:C1466.current_item.ident)=-1)
				$nb_notAllowedEntries+=1
				Form:C1466.hl_permissions_refCounter+=1
				APPEND TO LIST:C376($lh_notAllowedEntries; $entry.label; Form:C1466.hl_permissions_refCounter)
				SET LIST ITEM PARAMETER:C986($lh_notAllowedEntries; Form:C1466.hl_permissions_refCounter; "kind"; "entry")
				SET LIST ITEM PARAMETER:C986($lh_notAllowedEntries; Form:C1466.hl_permissions_refCounter; "key"; $entry.ident)
				$pict:=This:C1470.hl_icon_document["entry-disabled"]
				SET LIST ITEM ICON:C950($lh_notAllowedEntries; Form:C1466.hl_permissions_refCounter; $pict)
				If (Form:C1466.hl_permissions_current_item.kind="entry") && (Form:C1466.hl_permissions_current_item.key=$entry.ident)
					Form:C1466.hl_permissions_current_item.refToSelect:=Form:C1466.hl_permissions_refCounter
				End if 
				
		End case 
	End for each 
	
	If ($nb_allowedEntries>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_entries; "Allowed entries for this profile"; Form:C1466.hl_permissions_refCounter; $lh_allowedEntries; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; "kind"; "allowedEntries")
		SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_allowedEntries))
		SET LIST ITEM PROPERTIES:C386($lh_entries; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["entries"]
		SET LIST ITEM ICON:C950($lh_entries; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	If ($nb_notAllowedEntries>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_entries; "Not allowed entries by this profile"; Form:C1466.hl_permissions_refCounter; $lh_notAllowedEntries; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; "kind"; "notAllowedEntries")
		SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_notAllowedEntries))
		SET LIST ITEM PROPERTIES:C386($lh_entries; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["entries-disabled"]
		SET LIST ITEM ICON:C950($lh_entries; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	If ($nb_restrictedEntries>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376($lh_entries; "Prohibited entries for this profile"; Form:C1466.hl_permissions_refCounter; $lh_restrictedEntries; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; "kind"; "prohibitedEntries")
		SET LIST ITEM PARAMETER:C986($lh_entries; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_restrictedEntries))
		SET LIST ITEM PROPERTIES:C386($lh_entries; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["entries-prohibition"]
		SET LIST ITEM ICON:C950($lh_entries; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	If ($nb_allowedEntries>0) || ($nb_notAllowedEntries>0) || ($nb_restrictedEntries>0)
		Form:C1466.hl_permissions_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_permissions; "Entries"; Form:C1466.hl_permissions_refCounter; $lh_entries; True:C214)  //XLIFF
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; "kind"; "entries")
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; Additional text:K28:7; String:C10($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
		SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; False:C215; Bold:K14:2)
		$pict:=This:C1470.hl_icon_document["entries"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_permissions; Form:C1466.hl_permissions_refCounter; $pict)
	End if 
	
	If (Form:C1466.hl_permissions_current_item.refToSelect#0)
		SELECT LIST ITEMS BY REFERENCE:C630(Form:C1466.hl_permissions; Form:C1466.hl_permissions_current_item.refToSelect)
	Else 
		This:C1470._hideLhDetails()
	End if 
	
	
Function hl_permissions($option : Integer)
	var $kind : Text
	var $key : Text
	
	Case of 
		: (FORM Event:C1606.code=On Selection Change:K2:29) || ($option=1)
			
			GET LIST ITEM:C378(Form:C1466.hl_permissions; *; $refItem; $textItem)
			Form:C1466.hl_permissions_current_item:=New object:C1471
			Form:C1466.hl_permissions_current_item.ref:=$refItem
			Form:C1466.hl_permissions_current_item.text:=$textItem
			GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $refItem; "kind"; $kind)
			Form:C1466.hl_permissions_current_item.kind:=$kind
			GET LIST ITEM PARAMETER:C985(Form:C1466.hl_permissions; $refItem; "key"; $key)
			Form:C1466.hl_permissions_current_item.key:=$key
			
			This:C1470._hideLhDetails($kind)
			Case of 
				: ($kind="userInscription")
					Form:C1466.hl_permissions_current_item.userInscription:=ds:C1482.sfw_UserInscription.get($key)
					OBJECT SET VISIBLE:C603(*; "@wariningInscription@"; Form:C1466.hl_permissions_current_item.userInscription.moreData.autoCreation#Null:C1517)
					OBJECT SET VISIBLE:C603(*; "@bUnregisterUser@"; Form:C1466.sfw.checkIsInModification() && (Form:C1466.hl_permissions_current_item.userInscription.moreData.autoCreation=Null:C1517))
					
				: ($kind="vision")
					Form:C1466.hl_permissions_current_item.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; $key).first()
					$authorizedByCode:=Form:C1466.hl_permissions_current_item.vision.allowedProfiles.indexOf(Form:C1466.current_item.ident)>=0
					OBJECT SET VISIBLE:C603(*; "@warningVisionAllowedByCode@"; $authorizedByCode)
					Form:C1466.bVisionAllowAccess:=0
					Form:C1466.bVisionNotAllowAccess:=0
					Form:C1466.bVisionRestrictAccess:=0
					Case of 
						: (Form:C1466.current_item.moreData=Null:C1517)
							Form:C1466.bVisionNotAllowAccess:=1
						: (Form:C1466.current_item.moreData.allowedVisions=Null:C1517) && (Form:C1466.current_item.moreData.restrictVisions=Null:C1517)
							Form:C1466.bVisionNotAllowAccess:=1
						: (Form:C1466.current_item.moreData.allowedVisions#Null:C1517) && (Form:C1466.current_item.moreData.allowedVisions.indexOf($key)#-1)
							Form:C1466.bVisionAllowAccess:=1
						: (Form:C1466.current_item.moreData.restrictVisions#Null:C1517) && (Form:C1466.current_item.moreData.restrictVisions.indexOf($key)#-1)
							Form:C1466.bVisionRestrictAccess:=1
						Else 
							Form:C1466.bVisionNotAllowAccess:=1
					End case 
					
					OBJECT SET VISIBLE:C603(*; "@bVisionAllowAccess@"; Not:C34($authorizedByCode))
					OBJECT SET VISIBLE:C603(*; "@bVisionNotAllowAccess@"; Not:C34($authorizedByCode))
					OBJECT SET VISIBLE:C603(*; "@bVisionRestrict@"; Not:C34($authorizedByCode))
					OBJECT SET ENABLED:C1123(*; "@bVisionAllowAccess@"; Form:C1466.sfw.checkIsInModification())
					OBJECT SET ENABLED:C1123(*; "@bVisionNotAllowAccess@"; Form:C1466.sfw.checkIsInModification())
					OBJECT SET ENABLED:C1123(*; "@bVisionRestrictAccess@"; Form:C1466.sfw.checkIsInModification())
					
				: ($kind="entry")
					Form:C1466.hl_permissions_current_item.entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; $key).first()
					$authorizedByCode:=Form:C1466.hl_permissions_current_item.entry.allowedProfiles.indexOf(Form:C1466.current_item.ident)>=0
					OBJECT SET VISIBLE:C603(*; "@warningEntryAllowedByCode@"; $authorizedByCode)
					Form:C1466.bEntryAllowAccess:=0
					Form:C1466.bEntryNotAllowAccess:=0
					Form:C1466.bEntryRestrictAccess:=0
					Case of 
						: (Form:C1466.current_item.moreData=Null:C1517)
							Form:C1466.bEntryNotAllowAccess:=1
						: (Form:C1466.current_item.moreData.allowedEntries=Null:C1517) && (Form:C1466.current_item.moreData.restrictEntries=Null:C1517)
							Form:C1466.bEntryNotAllowAccess:=1
						: (Form:C1466.current_item.moreData.allowedEntries#Null:C1517) && (Form:C1466.current_item.moreData.allowedEntries.indexOf($key)#-1)
							Form:C1466.bEntryAllowAccess:=1
						: (Form:C1466.current_item.moreData.restrictEntries#Null:C1517) && (Form:C1466.current_item.moreData.restrictEntries.indexOf($key)#-1)
							Form:C1466.bEntryRestrictAccess:=1
						Else 
							Form:C1466.bEntryNotAllowAccess:=1
					End case 
					
					OBJECT SET VISIBLE:C603(*; "@bEntryAllowAccess@"; Not:C34($authorizedByCode))
					OBJECT SET VISIBLE:C603(*; "@bEntryNotAllowAccess@"; Not:C34($authorizedByCode))
					OBJECT SET VISIBLE:C603(*; "@bEntryRestrict@"; Not:C34($authorizedByCode))
					OBJECT SET VISIBLE:C603(*; "@bkgd_hl_entryPermissions@"; Not:C34($authorizedByCode))
					OBJECT SET VISIBLE:C603(*; "@hl_entryPermissions@"; Not:C34($authorizedByCode) && (Form:C1466.bEntryAllowAccess=1))
					OBJECT SET VISIBLE:C603(*; "@bAction_hl_entryPermissions@"; Not:C34($authorizedByCode))
					OBJECT SET ENABLED:C1123(*; "@bEntryAllowAccess@"; Form:C1466.sfw.checkIsInModification())
					OBJECT SET ENABLED:C1123(*; "@bEntryNotAllowAccess@"; Form:C1466.sfw.checkIsInModification())
					OBJECT SET ENABLED:C1123(*; "@bEntryRestrictAccess@"; Form:C1466.sfw.checkIsInModification())
					
					This:C1470.load_hl_entryPermissions()
			End case 
			
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 || Contextual click:C713)
			This:C1470.bAction_hl_permissions()
			
	End case 
	
Function _hideLhDetails($kind : Text)
	
	$visible:=(Count parameters:C259>0) && ($kind="userInscription")
	OBJECT SET VISIBLE:C603(*; "@userFullName@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@inscriptionSince@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@givenBy@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@wariningInscription@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bUnregisterUser@"; $visible)
	$visible:=(Count parameters:C259>0) && ($kind="vision")
	OBJECT SET VISIBLE:C603(*; "@visionLabel@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@warningVisionAllowedByCode@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bVisionAllowAccess@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bVisionNotAllowAccess@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bVisionRestrictAccess@"; $visible)
	$visible:=(Count parameters:C259>0) && ($kind="entry")
	OBJECT SET VISIBLE:C603(*; "@entryLabel@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@warningEntryAllowedByCode@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bEntryAllowAccess@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bEntryNotAllowAccess@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bEntryRestrictAccess@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@line_entry@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@hl_entryPermissions@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bAction_hl_entryPermissions@"; $visible)
	OBJECT SET VISIBLE:C603(*; "@bkgd_hl_entryPermissions@"; $visible)
	
Function bAction_hl_permissions()
	
	var $eInscription : cs:C1710.sfw_UserInscriptionEntity
	
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	
	If (Form:C1466.sfw.checkIsInModification())
		$refMenuAdd:=Create menu:C408
		$refMenus.push($refMenuAdd)
		$letters:=Split string:C1554("abcdefghijklmnopqrstuvwxyz"; "")
		For each ($letter; $letters)
			$uuidRegisterdUsers:=ds:C1482.sfw_UserInscription.query("UUID_UserProfile = :1"; Form:C1466.current_item.UUID).user.UUID
			$esUsers:=ds:C1482.sfw_User.query("firstName = :1 and not(UUID in :2)"; $letter+"@"; $uuidRegisterdUsers)
			If ($esUsers.length>0)
				$refMenuLetter:=Create menu:C408
				$refMenus.push($refMenuLetter)
				For each ($eUser; $esUsers)
					APPEND MENU ITEM:C411($refMenuLetter; $eUser.fullName; *)
					SET MENU ITEM PARAMETER:C1004($refMenuLetter; -1; "--registerUser:"+$eUser.UUID)
				End for each 
				APPEND MENU ITEM:C411($refMenuAdd; Uppercase:C13($letter); $refMenuLetter; *)
			End if 
		End for each 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("user.registerauser"); $refMenuAdd; *)  //okXLIFF
	Else 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("user.registerauser"); *)  //okXLIFF
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("user.unregisteruser"); *)  //okXLIFF
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--unregister")
	If (Form:C1466.sfw.checkIsntInModification()) || (Num:C11(Form:C1466.hl_permissions_current_item.ref)=0) || (Form:C1466.hl_permissions_current_item.kind#"userInscription") || (Form:C1466.hl_permissions_current_item.userInscription.moreData.autoCreation#Null:C1517)
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	If (Form:C1466.hl_permissions_current_item.kind="@vision@")
		APPEND MENU ITEM:C411($refMenu; "-")
		$refMenuOrder:=Create menu:C408
		$refMenus.push($refMenuOrder)
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
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("user.ordervisions"); $refMenuOrder)  //okXLIFF
	End if 
	
	If (Form:C1466.hl_permissions_current_item.kind="@entr@")
		APPEND MENU ITEM:C411($refMenu; "-")
		$refMenuOrder:=Create menu:C408
		$refMenus.push($refMenuOrder)
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
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("user.orderentries"); $refMenuOrder; *)  //okXLIFF
		//APPEND MENU ITEM($refMenu; ds.sfw_readXliff("user.groupbyvisions"); *)  //okXLIFF
		//If (This.hl_settings.entriesGroupByVisions)
		//SET MENU ITEM MARK($refMenu; -1; Char(18))
		//End if 
		//SET MENU ITEM PARAMETER($refMenu; -1; "--entriesGroupByVisions")
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choose="--registerUser:@")
			$UUIDUser:=Split string:C1554($choose; ":").pop()
			$eInscription:=ds:C1482.sfw_UserInscription.new()
			$eInscription.UUID:=Generate UUID:C1066
			$eInscription.UUID_User:=$UUIDUser
			$eInscription.UUID_UserProfile:=Form:C1466.current_item.UUID
			$eInscription.UUID_whoHasGiven:=cs:C1710.sfw_userManager.me.info.UUID
			$eInscription.stmp_given:=cs:C1710.sfw_stmp.me.now()
			$eInscription.moreData:=New object:C1471
			$info:=$eInscription.save()
			If ($info.success)
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			End if 
			This:C1470.load_hl_permissions()
			
		: ($choose="--unregister")
			This:C1470._unregisterUser()
			
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
	
Function bUnregisterUser()
	This:C1470._unregisterUser()
	
Function _unregisterUser
	If (cs:C1710.sfw_dialog.me.confirm("Are you sure to unregister the current user?"))  //XLIFF
		$eInscription:=ds:C1482.sfw_UserInscription.get(Form:C1466.hl_permissions_current_item.key)
		If ($eInscription#Null:C1517)
			$info:=$eInscription.drop()
			If ($info.success)
				This:C1470.load_hl_permissions()
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			End if 
		End if 
		
	End if 
	
	
Function bVisionAllowAccess()
	var $reload : Boolean:=False:C215
	If (Form:C1466.current_item.moreData=Null:C1517)
		Form:C1466.current_item.moreData:=New object:C1471
	End if 
	If (Form:C1466.current_item.moreData.allowedVisions=Null:C1517)
		Form:C1466.current_item.moreData.allowedVisions:=New collection:C1472
	End if 
	$key:=Form:C1466.hl_permissions_current_item.key
	If (Form:C1466.current_item.moreData.allowedVisions.indexOf($key)=-1)
		Form:C1466.current_item.moreData.allowedVisions.push($key)
		$reload:=True:C214
		If (Form:C1466.current_item.moreData.restrictVisions#Null:C1517)
			$index:=Form:C1466.current_item.moreData.restrictVisions.indexOf($key)
			If ($index#-1)
				Form:C1466.current_item.moreData.restrictVisions.remove($index)
				If (Form:C1466.current_item.moreData.restrictVisions.length=0)
					Form:C1466.current_item.moreData.restrictVisions:=Null:C1517
				End if 
			End if 
		End if 
	End if 
	If ($reload)
		This:C1470.load_hl_permissions(1)
	End if 
	
Function bVisionNotAllowAccess()
	var $reload : Boolean:=False:C215
	If (Form:C1466.current_item.moreData=Null:C1517)
		Form:C1466.current_item.moreData:=New object:C1471
	End if 
	$key:=Form:C1466.hl_permissions_current_item.key
	If (Form:C1466.current_item.moreData.allowedVisions#Null:C1517)
		$index:=Form:C1466.current_item.moreData.allowedVisions.indexOf($key)
		If ($index#-1)
			Form:C1466.current_item.moreData.allowedVisions.remove($index)
			$reload:=True:C214
			If (Form:C1466.current_item.moreData.allowedVisions.length=0)
				Form:C1466.current_item.moreData.allowedVisions:=Null:C1517
			End if 
		End if 
	End if 
	If (Form:C1466.current_item.moreData.restrictVisions#Null:C1517)
		$index:=Form:C1466.current_item.moreData.restrictVisions.indexOf($key)
		If ($index#-1)
			Form:C1466.current_item.moreData.restrictVisions.remove($index)
			$reload:=True:C214
			If (Form:C1466.current_item.moreData.restrictVisions.length=0)
				Form:C1466.current_item.moreData.restrictVisions:=Null:C1517
			End if 
		End if 
	End if 
	If ($reload)
		This:C1470.load_hl_permissions(1)
	End if 
	
Function bVisionRestrictAccess()
	var $reload : Boolean:=False:C215
	If (Form:C1466.current_item.moreData=Null:C1517)
		Form:C1466.current_item.moreData:=New object:C1471
	End if 
	If (Form:C1466.current_item.moreData.restrictVisions=Null:C1517)
		Form:C1466.current_item.moreData.restrictVisions:=New collection:C1472
	End if 
	$key:=Form:C1466.hl_permissions_current_item.key
	If (Form:C1466.current_item.moreData.restrictVisions.indexOf($key)=-1)
		Form:C1466.current_item.moreData.restrictVisions.push($key)
		$reload:=True:C214
		If (Form:C1466.current_item.moreData.allowedVisions#Null:C1517)
			$index:=Form:C1466.current_item.moreData.allowedVisions.indexOf($key)
			If ($index#-1)
				Form:C1466.current_item.moreData.allowedVisions.remove($index)
				If (Form:C1466.current_item.moreData.allowedVisions.length=0)
					Form:C1466.current_item.moreData.allowedVisions:=Null:C1517
				End if 
			End if 
		End if 
	End if 
	If ($reload)
		This:C1470.load_hl_permissions(1)
	End if 
	
	
	
Function bEntryAllowAccess()
	var $reload : Boolean:=False:C215
	If (Form:C1466.current_item.moreData=Null:C1517)
		Form:C1466.current_item.moreData:=New object:C1471
	End if 
	If (Form:C1466.current_item.moreData.allowedEntries=Null:C1517)
		Form:C1466.current_item.moreData.allowedEntries:=New collection:C1472
	End if 
	$key:=Form:C1466.hl_permissions_current_item.key
	If (Form:C1466.current_item.moreData.allowedEntries.indexOf($key)=-1)
		Form:C1466.current_item.moreData.allowedEntries.push($key)
		$reload:=True:C214
		If (Form:C1466.current_item.moreData.restrictEntries#Null:C1517)
			$index:=Form:C1466.current_item.moreData.restrictEntries.indexOf($key)
			If ($index#-1)
				Form:C1466.current_item.moreData.restrictEntries.remove($index)
				If (Form:C1466.current_item.moreData.restrictEntries.length=0)
					Form:C1466.current_item.moreData.restrictEntries:=Null:C1517
				End if 
			End if 
		End if 
	End if 
	If ($reload)
		This:C1470.load_hl_permissions(1)
		This:C1470.hl_permissions(1)
	End if 
	
Function bEntryNotAllowAccess()
	var $reload : Boolean:=False:C215
	If (Form:C1466.current_item.moreData=Null:C1517)
		Form:C1466.current_item.moreData.allowedVisions:=New object:C1471
	End if 
	$key:=Form:C1466.hl_permissions_current_item.key
	If (Form:C1466.current_item.moreData.allowedEntries#Null:C1517)
		$index:=Form:C1466.current_item.moreData.allowedEntries.indexOf($key)
		If ($index#-1)
			Form:C1466.current_item.moreData.allowedEntries.remove($index)
			$reload:=True:C214
			If (Form:C1466.current_item.moreData.allowedEntries.length=0)
				Form:C1466.current_item.moreData.allowedEntries:=Null:C1517
			End if 
		End if 
	End if 
	If (Form:C1466.current_item.moreData.restrictEntries#Null:C1517)
		$index:=Form:C1466.current_item.moreData.restrictEntries.indexOf($key)
		If ($index#-1)
			Form:C1466.current_item.moreData.restrictEntries.remove($index)
			$reload:=True:C214
			If (Form:C1466.current_item.moreData.restrictEntries.length=0)
				Form:C1466.current_item.moreData.restrictEntries:=Null:C1517
			End if 
		End if 
	End if 
	If ($reload)
		This:C1470.load_hl_permissions(1)
		This:C1470.hl_permissions(1)
	End if 
	
Function bEntryRestrictAccess()
	var $reload : Boolean:=False:C215
	If (Form:C1466.current_item.moreData=Null:C1517)
		Form:C1466.current_item.moreData:=New object:C1471
	End if 
	If (Form:C1466.current_item.moreData.restrictEntries=Null:C1517)
		Form:C1466.current_item.moreData.restrictEntries:=New collection:C1472
	End if 
	$key:=Form:C1466.hl_permissions_current_item.key
	If (Form:C1466.current_item.moreData.restrictEntries.indexOf($key)=-1)
		Form:C1466.current_item.moreData.restrictEntries.push($key)
		$reload:=True:C214
		If (Form:C1466.current_item.moreData.allowedEntries#Null:C1517)
			$index:=Form:C1466.current_item.moreData.allowedEntries.indexOf($key)
			If ($index#-1)
				Form:C1466.current_item.moreData.allowedEntries.remove($index)
				If (Form:C1466.current_item.moreData.allowedEntries.length=0)
					Form:C1466.current_item.moreData.allowedEntries:=Null:C1517
				End if 
			End if 
		End if 
	End if 
	If ($reload)
		This:C1470.load_hl_permissions(1)
		This:C1470.hl_permissions(1)
	End if 
	
	
Function load_hl_entryPermissions($option : Integer)
	
	If (Form:C1466.hl_entryPermissions#Null:C1517) && (Is a list:C621(Form:C1466.hl_entryPermissions))
		CLEAR LIST:C377(Form:C1466.hl_entryPermissions; *)
	End if 
	Form:C1466.hl_entryPermissions:=New list:C375
	Form:C1466.hl_entryPermissions_refCounter:=0
	
	
	$lh_mainActions:=New list:C375
	
	For ($i; 1; 3)
		
		Case of 
			: ($i=1)
				$title:="Edit an item"
				$kind:="editItem"
				$suffixe:="ForModification"
				$pict:=This:C1470.hl_icon_document["edit"]
			: ($i=2)
				$title:="Add an item"
				$kind:="addItem"
				$suffixe:="ForCreation"
				$pict:=This:C1470.hl_icon_document["add"]
			: ($i=3)
				$title:="Delete an item"
				$kind:="delItem"
				$suffixe:="ForDeletion"
				$pict:=This:C1470.hl_icon_document["delete"]
		End case 
		
		Case of 
			: (Form:C1466.current_item.moreData["allowedEntries"+$suffixe]#Null:C1517) && (Form:C1466.current_item.moreData["allowedEntries"+$suffixe].indexOf(Form:C1466.hl_permissions_current_item.entry.ident)#-1)
				$permissionCase:=1
			: (Form:C1466.current_item.moreData["prohibitEntries"+$suffixe]#Null:C1517) && (Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].indexOf(Form:C1466.hl_permissions_current_item.entry.ident)#-1)
				$permissionCase:=3
			: (Form:C1466.hl_permissions_current_item.entry["allowedEntries"+$suffixe].length=0)
				$permissionCase:=2
			: (Form:C1466.hl_permissions_current_item.entry["allowedEntries"+$suffixe]#Null:C1517) && (Form:C1466.hl_permissions_current_item.entry["allowedEntries"+$suffixe].indexOf(Form:C1466.current_item.ident)>=0)
				$permissionCase:=1
			Else 
				$permissionCase:=2
		End case 
		
		Form:C1466.hl_entryPermissions_refCounter+=1
		APPEND TO LIST:C376($lh_mainActions; $title; Form:C1466.hl_entryPermissions_refCounter)
		SET LIST ITEM PARAMETER:C986($lh_mainActions; Form:C1466.hl_entryPermissions_refCounter; "kind"; $kind)
		This:C1470._hl_entryPermissions_AdditionalText($lh_mainActions; Form:C1466.hl_entryPermissions_refCounter; $permissionCase)
		SET LIST ITEM ICON:C950($lh_mainActions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	End for 
	
	Form:C1466.hl_entryPermissions_refCounter+=1
	APPEND TO LIST:C376(Form:C1466.hl_entryPermissions; "Main actions"; Form:C1466.hl_entryPermissions_refCounter; $lh_mainActions; True:C214)  //XLIFF
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; "kind"; "entries")
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; Additional text; String($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
	SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; False:C215; Bold:K14:2)
	$pict:=This:C1470.hl_icon_document["database"]
	SET LIST ITEM ICON:C950(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	
	
	$lh_views:=New list:C375
	$pict:=This:C1470.hl_icon_document["view"]
	For each ($view; Form:C1466.hl_permissions_current_item.entry.views)
		Form:C1466.hl_entryPermissions_refCounter+=1
		APPEND TO LIST:C376($lh_views; $view.label; Form:C1466.hl_entryPermissions_refCounter)
		//This._hl_entryPermissions_AdditionalText($lh_views; Form.hl_entryPermissions_refCounter; Random%3+1)
		SET LIST ITEM ICON:C950($lh_views; Form:C1466.hl_entryPermissions_refCounter; $pict)
	End for each 
	Form:C1466.hl_entryPermissions_refCounter+=1
	APPEND TO LIST:C376(Form:C1466.hl_entryPermissions; "Views"; Form:C1466.hl_entryPermissions_refCounter; $lh_views; True:C214)  //XLIFF
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; "kind"; "entries")
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; Additional text; String($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
	SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; False:C215; Bold:K14:2)
	SET LIST ITEM ICON:C950(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	
	
	$lh_pages:=New list:C375
	$pict:=This:C1470.hl_icon_document["pageTab"]
	For each ($page; Form:C1466.hl_permissions_current_item.entry.panel.pages)
		Form:C1466.hl_entryPermissions_refCounter+=1
		APPEND TO LIST:C376($lh_pages; $page.label; Form:C1466.hl_entryPermissions_refCounter)
		//This._hl_entryPermissions_AdditionalText($lh_pages; Form.hl_entryPermissions_refCounter; Random%3+1)
		SET LIST ITEM ICON:C950($lh_pages; Form:C1466.hl_entryPermissions_refCounter; $pict)
	End for each 
	Form:C1466.hl_entryPermissions_refCounter+=1
	APPEND TO LIST:C376(Form:C1466.hl_entryPermissions; "Pages"; Form:C1466.hl_entryPermissions_refCounter; $lh_pages; True:C214)  //XLIFF
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; "kind"; "entries")
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; Additional text; String($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
	SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; False:C215; Bold:K14:2)
	SET LIST ITEM ICON:C950(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	
	
	$lh_listActions:=New list:C375
	Form:C1466.hl_entryPermissions_refCounter+=1
	APPEND TO LIST:C376(Form:C1466.hl_entryPermissions; "List actions"; Form:C1466.hl_entryPermissions_refCounter; $lh_listActions; True:C214)  //XLIFF
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; "kind"; "entries")
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; Additional text; String($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
	SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; False:C215; Bold:K14:2)
	$pict:=This:C1470.hl_icon_document["listAction"]
	SET LIST ITEM ICON:C950(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	
	$lh_projections:=New list:C375
	Form:C1466.hl_entryPermissions_refCounter+=1
	APPEND TO LIST:C376(Form:C1466.hl_entryPermissions; "Projections"; Form:C1466.hl_entryPermissions_refCounter; $lh_projections; True:C214)  //XLIFF
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; "kind"; "entries")
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; Additional text; String($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
	SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; False:C215; Bold:K14:2)
	$pict:=This:C1470.hl_icon_document["projection"]
	SET LIST ITEM ICON:C950(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	
	$lh_itemActions:=New list:C375
	Form:C1466.hl_entryPermissions_refCounter+=1
	APPEND TO LIST:C376(Form:C1466.hl_entryPermissions; "Item actions"; Form:C1466.hl_entryPermissions_refCounter; $lh_itemActions; True:C214)  //XLIFF
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; "kind"; "entries")
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; Additional text; String($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
	SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; False:C215; Bold:K14:2)
	$pict:=This:C1470.hl_icon_document["itemAction"]
	SET LIST ITEM ICON:C950(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	
	$lh_filters:=New list:C375
	Form:C1466.hl_entryPermissions_refCounter+=1
	APPEND TO LIST:C376(Form:C1466.hl_entryPermissions; "Filters"; Form:C1466.hl_entryPermissions_refCounter; $lh_filters; True:C214)  //XLIFF
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; "kind"; "entries")
	//SET LIST ITEM PARAMETER(Form.hl_entryPermissions; Form.hl_entryPermissions_refCounter; Additional text; String($nb_allowedEntries+$nb_notAllowedEntries+$nb_restrictedEntries))
	SET LIST ITEM PROPERTIES:C386(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; False:C215; Bold:K14:2)
	$pict:=This:C1470.hl_icon_document["filter"]
	SET LIST ITEM ICON:C950(Form:C1466.hl_entryPermissions; Form:C1466.hl_entryPermissions_refCounter; $pict)
	
	
Function _hl_entryPermissions_AdditionalText($list : Integer; $item : Integer; $level : Integer)
	Case of 
		: ($level=1)
			$authorisation:="allowed to users of this profile"
		: ($level=2)
			$authorisation:="not allowed to users by the registration to this profile"
		: ($level=3)
			$authorisation:="prohibited to users of this profile "
	End case 
	SET LIST ITEM PARAMETER:C986($list; $item; Additional text:K28:7; $authorisation)
	
	
Function hl_entryPermissions()
	
	Case of 
		: (FORM Event:C1606.code=On Selection Change:K2:29)
			GET LIST ITEM:C378(Form:C1466.hl_entryPermissions; *; $refItem; $textItem)
			Form:C1466.hl_entryPermissions_current_item:=New object:C1471
			Form:C1466.hl_entryPermissions_current_item.ref:=$refItem
			Form:C1466.hl_entryPermissions_current_item.text:=$textItem
			GET LIST ITEM PARAMETER:C985(Form:C1466.hl_entryPermissions; $refItem; "kind"; $kind)
			Form:C1466.hl_entryPermissions_current_item.kind:=$kind
			GET LIST ITEM PARAMETER:C985(Form:C1466.hl_entryPermissions; $refItem; "key"; $key)
			Form:C1466.hl_entryPermissions_current_item.key:=$key
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712 || Contextual click:C713)
			This:C1470.bAction_hl_entryPermissions()
			
	End case 
	
Function bAction_hl_entryPermissions()
	
	
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	
	For ($i; 1; 3)
		Case of 
			: ($i=1)
				$suffixe:="Edit"
				$title:="edition"
				$kind:="editItem"
			: ($i=2)
				$suffixe:="Add"
				$title:="creation"
				$kind:="addItem"
			: ($i=3)
				$suffixe:="Del"
				$title:="deletion"
				$kind:="delItem"
		End case 
		$disable:=Form:C1466.sfw.checkIsntInModification()
		If (Form:C1466.hl_entryPermissions_current_item.kind=$kind)
			APPEND MENU ITEM:C411($refMenu; "allow "+$title; *)  //XLIFF
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "allow"+$suffixe)
			If ($disable)
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			APPEND MENU ITEM:C411($refMenu; "do not allow "+$title; *)  //XLIFF
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "notAllow"+$suffixe)
			If ($disable)
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			APPEND MENU ITEM:C411($refMenu; "prohibited "+$title; *)  //XLIFF
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "prohibit"+$suffixe)
			If ($disable)
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
		End if 
	End for 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	
	For ($i; 1; 3)
		Case of 
			: ($i=1)
				$parameter:=["allowEdit"; "notAllowEdit"; "prohibitEdit"]
				$suffixe:="ForModification"
			: ($i=2)
				$parameter:=["allowAdd"; "notAllowAdd"; "prohibitAdd"]
				$suffixe:="ForCreation"
			: ($i=3)
				$parameter:=["allowDel"; "notAllowDel"; "prohibitDel"]
				$suffixe:="ForDeletion"
		End case 
		Case of 
			: ($choose=$parameter[0])
				If (Form:C1466.current_item.moreData["allowedEntries"+$suffixe]=Null:C1517)
					Form:C1466.current_item.moreData["allowedEntries"+$suffixe]:=New collection:C1472
				End if 
				Form:C1466.current_item.moreData["allowedEntries"+$suffixe].push(Form:C1466.hl_permissions_current_item.entry.ident)
				If (Form:C1466.current_item.moreData["prohibitEntries"+$suffixe]#Null:C1517)
					$index:=Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].indexOf(Form:C1466.hl_permissions_current_item.entry.ident)
					If ($index>=0)
						Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].remove($index)
						If (Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].length=0)
							Form:C1466.current_item.moreData["prohibitEntries"+$suffixe]:=Null:C1517
						End if 
					End if 
				End if 
				This:C1470.load_hl_entryPermissions(1)
				
			: ($choose=$parameter[1])
				If (Form:C1466.current_item.moreData["allowedEntries"+$suffixe]#Null:C1517)
					$index:=Form:C1466.current_item.moreData["allowedEntries"+$suffixe].indexOf(Form:C1466.hl_permissions_current_item.entry.ident)
					If ($index>=0)
						Form:C1466.current_item.moreData["allowedEntries"+$suffixe].remove($index)
						If (Form:C1466.current_item.moreData["allowedEntries"+$suffixe].length=0)
							Form:C1466.current_item.moreData["allowedEntries"+$suffixe]:=Null:C1517
						End if 
					End if 
				End if 
				If (Form:C1466.current_item.moreData["prohibitEntries"+$suffixe]#Null:C1517)
					$index:=Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].indexOf(Form:C1466.hl_permissions_current_item.entry.ident)
					If ($index>=0)
						Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].remove($index)
						If (Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].length=0)
							Form:C1466.current_item.moreData["prohibitEntries"+$suffixe]:=Null:C1517
						End if 
					End if 
				End if 
				This:C1470.load_hl_entryPermissions(1)
				
			: ($choose=$parameter[2])
				If (Form:C1466.current_item.moreData["prohibitEntries"+$suffixe]=Null:C1517)
					Form:C1466.current_item.moreData["prohibitEntries"+$suffixe]:=New collection:C1472
				End if 
				Form:C1466.current_item.moreData["prohibitEntries"+$suffixe].push(Form:C1466.hl_permissions_current_item.entry.ident)
				If (Form:C1466.current_item.moreData["allowedEntries"+$suffixe]#Null:C1517)
					$index:=Form:C1466.current_item.moreData["allowedEntries"+$suffixe].indexOf(Form:C1466.hl_permissions_current_item.entry.ident)
					If ($index>=0)
						Form:C1466.current_item.moreData["allowedEntries"+$suffixe].remove($index)
						If (Form:C1466.current_item.moreData["allowedEntries"+$suffixe].length=0)
							Form:C1466.current_item.moreData["allowedEntries"+$suffixe]:=Null:C1517
						End if 
					End if 
				End if 
				This:C1470.load_hl_entryPermissions(1)
				
		End case 
	End for 