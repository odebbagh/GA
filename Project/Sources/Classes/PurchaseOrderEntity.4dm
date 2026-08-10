Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String:C10(This:C1470.poNumber)
	
local Function rebuildAddress()->$address : Object
	Case of 
		: (Form:C1466.addressBilling=1)
			$type:="billing"
		: (Form:C1466.addressShipping=1)
			$type:="shipping"
	End case 
	
	If (This:C1470.address.addresses#Null:C1517)
		$address:=This:C1470.address.addresses.query("type = :1"; $type).first()
		Form:C1466.subFormAddress.address:=$address
	End if 
	Form:C1466.subFormAddress:=Form:C1466.subFormAddress
	
	
local Function afterCreation()
	
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initPoNumber()

	// Default the log date to today on creation
	This:C1470.logDate:=Current date:C33(*)
	
local Function _initPoNumber()
	//If (This.poNumber=0)
	//This.poNumber:=ds.PurchaseOrder.all().max("poNumber")+1
	//End if 