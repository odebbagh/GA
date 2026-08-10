var $country : Object
var $isInModification : Boolean
var $last : Integer

$isInModification:=sfw_checkIsInModification

If ($isInModification)
	Form:C1466.address.detail.country:=cs:C1710.sfw_countryManager.me.get_pupMenu(Form:C1466.address.detail.country).iso_code_2
End if 

