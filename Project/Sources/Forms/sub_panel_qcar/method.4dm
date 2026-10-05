If (Form:C1466#Null:C1517)
	var $rebuildForm : Boolean
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			$rebuildForm:=True:C214
			
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			$rebuildForm:=True:C214
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			CALL SUBFORM CONTAINER:C1086(-2000)
	End case 
	
	If ($rebuildForm)
		$isInModification:=sfw_checkIsInModification
		
		OBJECT SET ENTERABLE:C238(*; "entryField_@"; $isInModification)
		OBJECT SET ENTERABLE:C238(*; "entryField_othersText"; (Form:C1466.correctiveActionReport.others) & ($isInModification))
		cs:C1710.Util.me.lockDateInputs()
		OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; $isInModification)
		OBJECT SET ENABLED:C1123(*; "bActionTeam"; $isInModification)
		OBJECT SET ENABLED:C1123(*; "pup_teamLearders"; $isInModification)
		OBJECT SET ENABLED:C1123(*; "pup_supervisor"; $isInModification)
		
		$leader:=(Form:C1466.correctiveActionReport#Null:C1517) ? String:C10(Form:C1466.correctiveActionReport.teamLearders) : ""
		$supervisor:=(Form:C1466.correctiveActionReport#Null:C1517) ? String:C10(Form:C1466.correctiveActionReport.supervisor) : ""
		OBJECT SET TITLE:C194(*; "pup_teamLearders"; $leader)
		OBJECT SET TITLE:C194(*; "pup_supervisor"; $supervisor)
		
		Form:C1466.lb_teamMembers:=New collection:C1472()
		If (Form:C1466.correctiveActionReport#Null:C1517)
			$existing:=(Form:C1466.correctiveActionReport.teamMembers=Null:C1517) ? "" : String:C10(Form:C1466.correctiveActionReport.teamMembers)
			$names:=Split string:C1554($existing; "\n"; sk ignore empty strings:K86:1)
			For each ($name; $names)
				$staff:=ds:C1482.Staff.query("fullName = :1"; $name).first()
				Form:C1466.lb_teamMembers.push(New object:C1471(\
					"fullName"; $name; \
					"role"; ($staff#Null:C1517) ? String:C10($staff.role) : ""\
					))
			End for each 
		End if 
		
		If ($isInModification)
			OBJECT SET RGB COLORS:C628(*; "entryField_@"; "black"; "white")
		Else 
			OBJECT SET RGB COLORS:C628(*; "entryField_@"; "black"; "transparent")
		End if 
	End if 
	
End if 
