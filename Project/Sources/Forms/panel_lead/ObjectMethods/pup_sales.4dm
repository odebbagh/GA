
If (Form:C1466.sfw.checkIsInModification())
	$sales:=ds:C1482.Staff.query("department.name == :1"; "Sales")
	
	
	$menu:=Create menu:C408
	
	For each ($staff; $sales)
		APPEND MENU ITEM:C411($menu; $staff.fullName; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $staff.UUID+"-"+$staff.fullName)
		If ($staff.UUID=String:C10(Form:C1466.UUID_Staff))
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
	End for each 
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	
	If ($choice#"")
		$items:=Split string:C1554($choice; "-")
		Form:C1466.current_interaction.UUID_Staff:=$items[0]
		OBJECT SET TITLE:C194(*; "pup_sales"; $items[1])
		Form:C1466.current_interaction.save()
		cs:C1710.panel_lead.me._activate_save_cancel_button()
	End if 
End if 