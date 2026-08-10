
$refmenus:=New collection:C1472()
$menu:=Create menu:C408
$refmenus.push($menu)
Case of 
	: (Form:C1466.period.kind="Y")
		$yearToday:=Year of:C25(Current date:C33)
		For ($year; $yearToday-3; $yearToday+10)
			APPEND MENU ITEM:C411($menu; String:C10($year))
			SET MENU ITEM PARAMETER:C1004($menu; -1; String:C10($year))
			If (String:C10($year)=Form:C1466.period.name)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			Else 
				If (Form:C1466.schedule[String:C10($year)]#Null:C1517)
					DISABLE MENU ITEM:C150($menu; -1)
				End if 
			End if 
		End for 
		
	: (Form:C1466.period.kind="Q")
		$yearToday:=Year of:C25(Current date:C33)
		For ($year; $yearToday-3; $yearToday+10)
			$submenu:=Create menu:C408
			$refmenus.push($submenu)
			For ($q; 1; 4)
				APPEND MENU ITEM:C411($submenu; "Q"+String:C10($q))
				$periodname:=String:C10($year)+"Q"+String:C10($q)
				SET MENU ITEM PARAMETER:C1004($submenu; -1; $periodname)
				If ($periodname=Form:C1466.period.name)
					SET MENU ITEM MARK:C208($submenu; -1; Char:C90(18))
				Else 
					If (Form:C1466.schedule[$periodname]#Null:C1517)
						DISABLE MENU ITEM:C150($submenu; -1)
					End if 
				End if 
			End for 
			APPEND MENU ITEM:C411($menu; String:C10($year); $submenu)
		End for 
		
	: (Form:C1466.period.kind="M")
		$yearToday:=Year of:C25(Current date:C33)
		For ($year; $yearToday-3; $yearToday+10)
			$submenu:=Create menu:C408
			$refmenus.push($submenu)
			$m:=0
			For each ($month; Form:C1466.months)
				$m:=$m+1
				APPEND MENU ITEM:C411($submenu; $month)
				$periodname:=String:C10($year)+String:C10($m; "00")
				SET MENU ITEM PARAMETER:C1004($submenu; -1; $periodname)
				If ($periodname=Form:C1466.period.name)
					SET MENU ITEM MARK:C208($submenu; -1; Char:C90(18))
				Else 
					If (Form:C1466.schedule[$periodname]#Null:C1517)
						DISABLE MENU ITEM:C150($submenu; -1)
					End if 
				End if 
			End for each 
			APPEND MENU ITEM:C411($menu; String:C10($year); $submenu)
		End for 
		
End case 


$newAttribute:=Dynamic pop up menu:C1006($menu)

For each ($menu; $refmenus)
	RELEASE MENU:C978($menu)
End for each 

Case of 
	: ($newAttribute="")
	: ($newAttribute#"")
		$oldAttribute:=Form:C1466.period.name
		$objectTransfert:=OB Copy:C1225(Form:C1466.schedule[$oldAttribute])
		OB REMOVE:C1226(Form:C1466.schedule; $oldAttribute)
		Form:C1466.schedule[$newAttribute]:=$objectTransfert
		sfw_subpanel_schedule_draw($newAttribute)
		CALL SUBFORM CONTAINER:C1086(-98001)
		
End case 
