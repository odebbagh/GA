Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4) & (sfw_checkIsInModification)
		
		$col:=New collection:C1472()
		$lb_teamMembers:=New collection:C1472()
		$lb_teamMembers:=Split string:C1554(Form:C1466.correctiveActionReport.teamMembers; "\n"; sk ignore empty strings:K86:1+sk ignore empty strings:K86:1)
		
		$allStaffs:=ds:C1482.Staff.all()
		
		For each ($staff; $allStaffs)
			$object:=New object:C1471(\
				"selected"; $lb_teamMembers.indexOf($staff.fullName)#-1; \
				"role"; $staff.staffRoles.length>0 ? $staff.staffRoles[0].role.name : ""; \
				"fullName"; $staff.fullName\
				)
			$col.push($object)
		End for each 
		
		var $function : 4D:C1709.Function
		$function:=Formula:C1597($1.value.role:=($2.indexOf($1.value.fullName)#-1))
		$form:=New object:C1471(\
			"lb_items"; $col; \
			"allData"; ds:C1482.Staff.all()\
			)
		
		$winRef:=Open form window:C675("_ga_staffsAsTeamMember"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
		DIALOG:C40("_ga_staffsAsTeamMember"; $form)
		
		//$answer:=cs.sfw_dialog.me.request("Enter Disposition value"; Form.current_item.moreData.disposition; "Save"; "Cancel"; "trimSpace")
		
		//If ($answer.ok) & ($answer.answer#"")
		If (OK=1)
			Form:C1466.correctiveActionReport.teamMembers:=$form.lb_items.filter(Formula:C1597($1.value.selected=True:C214)).extract("fullName").join("\n")
			
			//If (Form.correctiveActionReport.teamMembers="")
			//Form.correctiveActionReport.teamMembers:=$form.teamMemberName  //$answer.answer
			//Else 
			//Form.correctiveActionReport.teamMembers:=Form.correctiveActionReport.teamMembers+Char(Carriage return)+$form.teamMemberName  //$answer.answer
			//End if 
			
		End if 
		//End if 
	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		SET CURSOR:C469(Choose:C955(sfw_checkIsInModification; 9000; 9019))
		
End case 