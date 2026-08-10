Case of 
	: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
		If (sfw_checkIsInModification)
			OBJECT GET COORDINATES:C663(*; "Field_teamMembers"; $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Screen:K27:7)
			CONVERT COORDINATES:C1365($r; $t; XY Current form:K27:5; XY Screen:K27:7)
			
			$form:=New object:C1471(\
				"member"; ""\
				)
			
			$winRef:=Open form window:C675("selectTeamMembers"; Pop up form window:K39:11; $l; $t-20)
			DIALOG:C40("selectTeamMembers"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (ok=1) & ($form.member#"")
				If (Form:C1466.correctiveActionReport.teamMembers="")
					Form:C1466.correctiveActionReport.teamMembers:=$form.member
				Else 
					Form:C1466.correctiveActionReport.teamMembers:=Form:C1466.correctiveActionReport.teamMembers+Char:C90(Carriage return:K15:38)+$form.member
				End if 
			End if 
		End if 
		
	: (FORM Event:C1606.code=On Mouse Move:K2:35) & (sfw_checkIsInModification)
		SET CURSOR:C469(9000)
End case 