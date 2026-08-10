var $isInModification : Boolean



$contactTypes:=New collection:C1472()
$contactTypes.push({type: "Phone"})
$contactTypes.push({type: "Mobile"})
$contactTypes.push({type: "Mail"})
$contactTypes.push({type: "webSite"})
$contactTypes.push({type: "Fax"})

//$isInModification:=sfw_checkIsInModification
//If ($isInModification)
$menu:=Create menu:C408

For each ($type; $contactTypes)
	APPEND MENU ITEM:C411($menu; $type.type; *)
	SET MENU ITEM ICON:C984($menu; -1; "file:image/skin/contactType/"+$type.type+".png")
	SET MENU ITEM PARAMETER:C1004($menu; -1; $type.type)
	If ($type.type=Form:C1466.com.type)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for each 


$choose:=Dynamic pop up menu:C1006($menu)
RELEASE MENU:C978($menu)

Case of 
	: ($choose="")
		
	Else 
		Form:C1466.com.type:=$choose
		//READ PICTURE FILE("RESOURCES\\image\\skin\\contactType\\"+$choose+".png"; $Picture)
		//Form.com.icon:=$Picture
		Form:C1466.com.contact:=""
		Form:C1466.com.comment:=""
		
End case 
//End if 

OBJECT SET FORMAT:C236(*; "communication_item_type"; Form:C1466.com.type+";#image/skin/contactType/"+Form:C1466.com.type+".png;0;3;1;1;8;0;0;0;1;0;1")