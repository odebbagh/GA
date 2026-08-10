var $address : Object
var $isInModification : Boolean
var $last : Integer

$isInModification:=sfw_checkIsInModification

If ($isInModification)
	$countryCode:=Form:C1466.contactDetails.addresses[0].detail.country
	$menu:=Create menu:C408
	For each ($country; Storage:C1525.cache.sfw_country)
		APPEND MENU ITEM:C411($menu; $country.name; *)
		SET MENU ITEM ICON:C984($menu; -1; "file:image/flags/tiny/"+$country.iso_code_2+".png")
		SET MENU ITEM PARAMETER:C1004($menu; -1; $country.iso_code_2)
		If ($country.iso_code_2=$countryCode)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if 
	End for each 
	$choose:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	
	
	Case of 
		: ($choose="")
			
		Else 
			Form:C1466.contactDetails.addresses[0].detail.country:=$choose
	End case 
End if 

