
Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4) & (sfw_checkIsInModification)
		
		$col:=New collection:C1472()
		$existing:=(Form:C1466.correctiveActionReport.teamMembers=Null:C1517) ? "" : String:C10(Form:C1466.correctiveActionReport.teamMembers)
		$currentNames:=Split string:C1554($existing; "\n"; sk ignore empty strings:K86:1)
		
		$allStaffs:=ds:C1482.Staff.all().orderBy("lastName, firstName")
		For each ($staff; $allStaffs)
			$col.push(New object:C1471(\
				"selected"; $currentNames.indexOf($staff.fullName)#-1; \
				"role"; String:C10($staff.role); \
				"fullName"; $staff.fullName\
				))
		End for each 
		
		$form:=New object:C1471(\
			"lb_items"; $col; \
			"allData"; $col; \
			"words"; ""\
			)
		
		$winRef:=Open form window:C675("_ga_staffsAsTeamMember"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
		DIALOG:C40("_ga_staffsAsTeamMember"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (OK=1)
			Form:C1466.lb_teamMembers:=$form.allData.query("selected = :1"; True:C214)
			Form:C1466.correctiveActionReport.teamMembers:=Form:C1466.lb_teamMembers.extract("fullName").join("\n")
			CALL SUBFORM CONTAINER:C1086(-2000)
		End if 
		
End case 
