var $isInModification : Boolean

Case of 
		
	: (Form event code:C388=On Load:K2:1)
		$isInModification:=sfw_checkIsInModification
		OBJECT SET ENTERABLE:C238(*; "entryField_qty@"; $isInModification)
		
	: (Form event code:C388=On Bound Variable Change:K2:52)
		$isInModification:=sfw_checkIsInModification
		OBJECT SET ENTERABLE:C238(*; "entryField_qty@"; $isInModification)
		
End case 