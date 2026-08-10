singleton Class constructor
	//It's a singleton class
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				Form:C1466.lb_bomItems:=Form:C1466.current_item.bomitems
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	If (Form:C1466.current_item#Null:C1517)
		$color:=cs:C1710.sfw_htmlColor.me.getName(Form:C1466.current_item.color) || ""
		If ($color#"")
			Form:C1466.sfw.drawButtonPup("pup_color"; $color; "sfw/colors/"+$color+"-circle.png"; (Form:C1466.current_item.color=Null:C1517))
		Else 
			Form:C1466.sfw.drawButtonPup("pup_color"; "choice color"; "sfw/colors/colors.png"; (Form:C1466.current_item.color=Null:C1517))
		End if 
	End if 
	This:C1470.drawPup_division()
	
Function pup_division()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.divisions=Null:C1517)
			ds:C1482.Division.cacheLoad()
		End if 
		
		For each ($eDivision; Storage:C1525.cache.divisions)
			APPEND MENU ITEM:C411($menu; $eDivision.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eDivision.UUID)
			If ($eDivision.UUID=Form:C1466.current_item.UUID_Division)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				$eDivision:=ds:C1482.Division.get($choose)
				Form:C1466.current_item.UUID_Division:=$eDivision.UUID
		End case 
		
	End if 
	This:C1470.drawPup_division()
	
Function drawPup_division()
	If (Form:C1466.current_item#Null:C1517)
		$division:=ds:C1482.Division.query("UUID =:1"; Form:C1466.current_item.UUID_Division).first() || New object:C1471()
		$divisionName:=$division.name
		If ($divisionName=Null:C1517)
			$divisionName:=""
		End if 
		$color:=cs:C1710.sfw_htmlColor.me.getName($division.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_division"; $divisionName; $pathIcon; ($division=Null:C1517))
	End if 