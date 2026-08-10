$contacts:=Form:C1466.current_item.contacts()


$menu:=Create menu:C408

For each ($contact; $contacts)
	APPEND MENU ITEM:C411($menu; $contact.fullName+" - "+$contact.type; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $contact.UUID+"_"+$contact.fullName+" - "+$contact.type)
	If ($contact.UUID=String:C10(Form:C1466.UUID_Contact))
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		If (Is Windows:C1573)
			SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
		End if 
	End if 
End for each 
$choice:=Dynamic pop up menu:C1006($menu)
RELEASE MENU:C978($menu)

If ($choice#"")
	$items:=Split string:C1554($choice; "_")
	Form:C1466.UUID_Contact:=$items[0]
	OBJECT SET TITLE:C194(*; "pup_contact"; $items[1])
End if 