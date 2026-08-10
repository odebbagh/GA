

$rebuildForm:=False:C215
$collection:=["type"; "contact"; "comment"]

If (Form:C1466#Null:C1517)
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			$rebuildForm:=True:C214
			
			
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			$rebuildForm:=True:C214
			
		: (FORM Event:C1606.objectName="communication_item_type")
			$rebuildForm:=True:C214
			
	End case 
	
	If ($rebuildForm)
		
		If (Form:C1466.communication=Null:C1517)
			Form:C1466.communication:=New object:C1471
			Form:C1466.communication.type:="Phone"
		End if 
		$contactType:=Form:C1466.communication.type || "all"
		$isInModification:=sfw_checkIsInModification && (Not:C34(Bool:C1537(Form:C1466.readOnly)))
		OBJECT SET VISIBLE:C603(*; "communication_item_@"; False:C215)
		
		For each ($item; $collection)
			If ($item="type")
				$objectName:="communication_item_type"
				
				OBJECT SET VISIBLE:C603(*; $objectName; True:C214)
				If ($isInModification)
					OBJECT SET FORMAT:C236(*; $objectName; $contactType+";#image/skin/contactType/"+$contactType+".png;0;3;1;1;8;0;0;0;1;0;1")
				Else 
					OBJECT SET FORMAT:C236(*; $objectName; $contactType+";#image/skin/contactType/"+$contactType+".png;0;3;1;1;0;0;0;0;0;0;1")
				End if 
			Else 
				$objectName:="communication_item_"+$item
				OBJECT SET VISIBLE:C603(*; $objectName; True:C214)
				OBJECT SET PLACEHOLDER:C1295(*; $objectName; $item)
				OBJECT SET ENTERABLE:C238(*; $objectName; $isInModification)
				If ($isInModification)
					$runValidationRules:=True:C214
					OBJECT SET RGB COLORS:C628(*; $objectName; "black"; Background color:K23:2)
					OBJECT SET BORDER STYLE:C1262(*; $objectName; Border System:K42:33)
				Else 
					$runValidationRules:=False:C215
					OBJECT SET RGB COLORS:C628(*; $objectName; 0x00333333; Background color none:K23:10)
					OBJECT SET BORDER STYLE:C1262(*; $objectName; Border None:K42:27)
				End if 
			End if 
		End for each 
		
		
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
End if 