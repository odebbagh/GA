var $isInModification : Boolean

$isInModification:=sfw_checkIsInModification

If ($isInModification)
	$menu:=Create menu:C408
	$menuItems:=["Alpha"; "Text"; "Date"; "Boolean"; "Integer"; "Real"; "Imap"; "Smtp"]
	
	For each ($item; $menuItems)
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("setting.type."+Lowercase:C14($item); $item); *)
		
		SET MENU ITEM ICON:C984($menu; -1; "path:/RESOURCES/StructureEditor/"+$item+".png")
		SET MENU ITEM PARAMETER:C1004($menu; -1; $item)
		If ($item=Form:C1466.type)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if 
	End for each 
	$choose:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	
	
	Case of 
		: ($choose="")
			
		Else 
			Form:C1466.type:=$choose
	End case 
End if 

