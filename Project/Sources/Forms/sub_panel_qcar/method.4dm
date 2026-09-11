If (Form:C1466#Null:C1517)
	var $rebuildForm : Boolean
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			$rebuildForm:=True:C214
			//Form.lb_teamMembers:=New collection()
			//$lb_teamMembers:=Split string(Form.correctiveActionReport.teamMembers; "\n"; sk ignore empty strings+sk ignore empty strings)
			//Form.lb_teamMembers:=ds.Staff.query("fullName in :1"; $lb_teamMembers).extract("fullName"; "role")
			
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			//$lb_teamMembers:=Split string(Form.correctiveActionReport.teamMembers; "\n"; sk ignore empty strings+sk ignore empty strings)
			//Form.lb_teamMembers:=ds.Staff.query("fullName in :1"; $lb_teamMembers).extract("fullName"; "role")
			
			$rebuildForm:=True:C214
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			CALL SUBFORM CONTAINER:C1086(-2000)
	End case 
	
	If ($rebuildForm)
		$isInModification:=sfw_checkIsInModification
		
		OBJECT SET ENTERABLE:C238(*; "entryField_@"; $isInModification)
		OBJECT SET ENTERABLE:C238(*; "entryField_othersText"; (Form:C1466.correctiveActionReport.others) & ($isInModification))
		
		//$lb_teamMembers:=Split string(Form.correctiveActionReport.teamMembers; "\n"; sk ignore empty strings+sk ignore empty strings)
		//Form.lb_teamMembers:=ds.Staff.query("fullName in :1"; $lb_teamMembers).extract("fullName"; "role")
		
		If ($isInModification)
			OBJECT SET RGB COLORS:C628(*; "entryField_@"; "black"; "white")
		Else 
			OBJECT SET RGB COLORS:C628(*; "entryField_@"; "black"; "transparent")
		End if 
	End if 
	
End if 