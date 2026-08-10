//%attributes = {}


/*
Method Name : _ga_printShipper
Author : Medard /4D PS
Date : 14-November-2025
Purpose : Print Shipper
*/

If (Form:C1466.current_item#Null:C1517)
	
	var $context : Object
	
	$context:=New object:C1471()
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/shipperPrintOutTemplate.4wp")
	$template:=WP Import document:C1318($file.platformPath)
	
	$customer:=ds:C1482.Customer.query("name =:1"; Form:C1466.current_item.customer.name).first()
	
	$shippingAddress:=$customer.contactDetails.addresses.query("type =:1"; "shipping").first()
	$shippingAddress.detail.state:=$shippingAddress.detail.state#Null:C1517 ? $shippingAddress.detail.state : ""
	$address:=$shippingAddress.detail.street_1+"\n"+$shippingAddress.detail.city+"\n"+\
		$shippingAddress.detail.state+" "+$shippingAddress.detail.postcode+"\n"+$shippingAddress.detail.country
	
	$context.address:=Form:C1466.current_item.dropShipCustomer+"\n"+$address
	$context.jobNumber:=Form:C1466.current_item.jobNumber
	$context.customerShipper:=Form:C1466.current_item.customerShipper#"" ? Form:C1466.current_item.customerShipper : "N/A"
	$context.poNumber:=Form:C1466.current_item.poNumber
	$context.deviceNumber:=Form:C1466.current_item.deviceNumber
	$context.shippers:=Form:C1466.current_item.shippers
	$context.customer:=Form:C1466.current_item.customer
	$context.altDeviceNumber:=Form:C1466.current_item.altDeviceNumber
	$context.carrier:=Form:C1466.current_item.carrier
	
	
	
	If ($customer#Null:C1517)
		$context.carrier:=$customer.customerCarrier.name
		$context.accountNumber:=$customer.accountNumber
	End if 
	
	WP SET DATA CONTEXT:C1786($template; $context)
	
	PRINT SETTINGS:C106(2)
	WP PRINT:C1343($template)
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "Select a job first"))
	
End if 
