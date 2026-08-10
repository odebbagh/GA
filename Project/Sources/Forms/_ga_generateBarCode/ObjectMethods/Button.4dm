

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		var $parameters : Object:=New object:C1471()
		$parameters.barcodeData:=Form:C1466.barcodeData
		$parameters.text:=Form:C1466.displayData & (Form:C1466.pup_fields.currentValue#"") ? Form:C1466.current_item[Form:C1466.pup_fields.currentValue] : ""
		
		Form:C1466.barCode:=_ga_generateBarCode($parameters)
		
End case 