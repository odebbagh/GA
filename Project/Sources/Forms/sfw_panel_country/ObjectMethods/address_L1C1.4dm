var $template : Object
var $line : Object
var $folder_itemType : 4D:C1709.Folder

If (sfw_checkIsInModification)
	
	$folder_itemType:=Folder:C1567("/RESOURCES/sfw/address/itemType/")
	$json_string:=$folder_itemType.file("itemType.json").getText()
	$obj_itemTypes:=JSON Parse:C1218($json_string)
	
	$template:=Form:C1466.current_item.address_format.template
	
	$name:=OBJECT Get name:C1087(Object current:K67:2)
	$titre_courant:=OBJECT Get title:C1068(*; $name)
	$menu:=Create menu:C408
	
	For each ($itemType; $obj_itemTypes.types)
		$kind:=$itemType.kind
		APPEND MENU ITEM:C411($menu; $kind)
		SET MENU ITEM ICON:C984($menu; -1; "file:"+"sfw/address/itemType/"+$itemType.icon)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $kind)
		If ($titre_courant=$kind)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		Else 
			$used:=False:C215
			For each ($line; $template.lines) Until ($used)
				$used:=($line.items.countValues($kind)>0)
			End for each 
			If ($used)
				DISABLE MENU ITEM:C150($menu; -1)
			End if 
		End if 
	End for each 
	
	If ($titre_courant#"-")
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("address.menu.erase"; "Erase"))
		SET MENU ITEM ICON:C984($menu; -1; "file:"+"sfw/address/itemType/eraser.png")
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--delete")
	End if 
	$choix:=Dynamic pop up menu:C1006($menu)
	
	RELEASE MENU:C978($menu)
	
	Case of 
		: ($choix="")
		: ($choix="--delete")
			OBJECT SET TITLE:C194(*; $name; "-")
			
		Else 
			OBJECT SET TITLE:C194(*; $name; $choix)
			
	End case 
	
	If ($choix#"")
		$lines:=New collection:C1472
		For ($ligne; 1; 7; 1)
			$items:=New collection:C1472
			For ($colonne; 1; 4; 1)
				$titre:=OBJECT Get title:C1068(*; "address_L"+String:C10($ligne)+"C"+String:C10($colonne))
				If ($titre#"-")
					$items.push($titre)
				End if 
			End for 
			If ($items.length>0)
				$lines.push(New object:C1471("items"; $items))
			End if 
		End for 
		$template.lines:=$lines
		Form:C1466.current_item.address_format.template:=$template
		
		sfw_country_tmpt_address
	End if 
End if 