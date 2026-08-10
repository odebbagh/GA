$rebuildForm:=False:C215

If (Form:C1466#Null:C1517)
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			$rebuildForm:=True:C214
			
			
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			$rebuildForm:=True:C214
			
		: (FORM Event:C1606.objectName="address_item_country")
			$rebuildForm:=True:C214
			
	End case 
	
	If ($rebuildForm)
		ds:C1482.sfw_Country.cacheLoad()
		
		OBJECT GET SUBFORM CONTAINER SIZE:C1148($width_subform; $height_subform)
		
		OBJECT SET COORDINATES:C1248(*; "address_bkgd"; 0; 0; $width_subform; $height_subform)
		If (Form:C1466.contactDetails=Null:C1517)
			Form:C1466.contactDetails:=New object:C1471
		End if 
		If (Form:C1466.contactDetails.addresses=Null:C1517)
			Form:C1466.contactDetails.addresses:=New collection:C1472
		End if 
		If (Form:C1466.contactDetails.addresses.length=0)
			Form:C1466.contactDetails.addresses.push(New object:C1471)
		End if 
		If (Form:C1466.contactDetails.addresses[0].detail=Null:C1517)
			Form:C1466.contactDetails.addresses[0].detail:=New object:C1471
		End if 
		If (Form:C1466.contactDetails.addresses[0].detail.country=Null:C1517)
			Form:C1466.contactDetails.addresses[0].detail.country:="fr"
		End if 
		$countryCode:=Form:C1466.contactDetails.addresses[0].detail.country
		$countryColl:=Storage:C1525.cache.sfw_country.query("iso_code_2 = :1"; $countryCode)
		If ($countryColl.length>0)
			$countryDefinition:=$countryColl[0]
		Else 
			$countryColl:=Storage:C1525.cache.sfw_country.query("iso_code_2 = :1"; "fr")
			$countryDefinition:=$countryColl[0]
		End if 
		$countryName:=$countryDefinition.name
		Form:C1466.contactDetailsTemplate:=$countryDefinition.address_format.template
		OBJECT SET VISIBLE:C603(*; "address_item_@"; False:C215)
		$i_item:=0
		$top:=24
		$horizontalGapItem:=10
		$verticalGapItem:=8
		$height_Item:=17
		$height_country:=23
		$left_initial:=12
		$width_area:=$width_subform-($left_initial*2)
		$isInModification:=sfw_checkIsInModification
		For each ($line; Form:C1466.contactDetailsTemplate.lines)
			$left:=$left_initial
			$width_item:=($width_area-($horizontalGapItem*($line.items.length)))/$line.items.length
			For each ($item; $line.items)
				$i_item:=$i_item+1
				If ($item="country")
					$objectName:="address_item_country"
					OBJECT SET COORDINATES:C1248(*; $objectName; $left+1-(3*Num:C11($isInModification)); $top-1; $left+$width_item+1; $top-1+$height_country)
					OBJECT SET VISIBLE:C603(*; $objectName; True:C214)
					If ($isInModification)
						OBJECT SET FORMAT:C236(*; $objectName; $countryName+";#image/flags/tiny/"+$countryCode+".png;0;3;1;1;8;0;0;0;1;0;1")
					Else 
						OBJECT SET FORMAT:C236(*; $objectName; $countryName+";#image/flags/tiny/"+$countryCode+".png;0;3;1;1;0;0;0;0;0;0;1")
					End if 
					
				Else 
					$objectName:="address_item_"+$item
					OBJECT SET COORDINATES:C1248(*; $objectName; $left; $top; $left+$width_item; $top+$height_Item)
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
				$left:=$left+$width_item+$horizontalGapItem
			End for each 
			$top:=$top+$height_Item+$verticalGapItem
		End for each 
	End if 
	
	
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
End if 
