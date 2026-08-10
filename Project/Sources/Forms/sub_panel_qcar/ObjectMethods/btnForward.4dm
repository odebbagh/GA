Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4) & (sfw_checkIsInModification)
		$answer:=cs:C1710.sfw_dialog.me.request("Enter Disposition value"; Form:C1466.current_item.moreData.disposition; "Save"; "Cancel"; "trimSpace")
		
		If ($answer.ok) & ($answer.answer#"")
			If (Form:C1466.correctiveActionReport.teamMembers="")
				Form:C1466.correctiveActionReport.teamMembers:=$answer.answer
			Else 
				Form:C1466.correctiveActionReport.teamMembers:=Form:C1466.correctiveActionReport.teamMembers+Char:C90(Carriage return:K15:38)+$answer.answer
			End if 
		End if 
	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		SET CURSOR:C469(Choose:C955(sfw_checkIsInModification; 9000; 9019))
		
End case 