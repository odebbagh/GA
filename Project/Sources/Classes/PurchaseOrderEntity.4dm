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
	
	
	// a PO entered on a quote fills the PO and job of the quote's leads (ga_sales), at creation and
	// at each save (the quote or the jobs may be added later); inside the PO's transaction
local Function afterCreation()
	cs:C1710.ga_sales.me.syncLeadsFromPurchaseOrder(This:C1470)
	This:C1470._applyQuoteStatus("0"*32)

local Function afterSave()
	If (Bool:C1537(Form:C1466.info.success))
		cs:C1710.ga_sales.me.syncLeadsFromPurchaseOrder(This:C1470)
		// current_clone is still the PO as it was before this edit (sfw makes a new one after afterSave)
		This:C1470._applyQuoteStatus((Form:C1466.current_clone=Null:C1517) ? ("0"*32) : Form:C1466.current_clone.UUID_Quote)
	End if

	// a PO entered on a quote closes it as won, Received Order (ga_quoteStatus, the client,
	// October 2026); $previousQuoteUUID: the quote before the save. What happened is shown
local Function _applyQuoteStatus($previousQuoteUUID : Text)
	var $result : Object
	$result:=cs:C1710.ga_quoteStatus.me.onPurchaseOrderSaved(This:C1470; $previousQuoteUUID)
	If ($result.messages.length>0)
		cs:C1710.sfw_dialog.me.info($result.messages.join("\r"))
	End if

	// a deleted PO leaves its quote as it is: a message when the quote was won and has no PO left
local Function beforeDelete()
	var $result : Object
	$result:=cs:C1710.ga_quoteStatus.me.onPurchaseOrderRemoved(This:C1470.UUID_Quote; This:C1470.UUID)
	If ($result.messages.length>0)
		cs:C1710.sfw_dialog.me.info($result.messages.join("\r"))
	End if


local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470._initPoNumber()

	// Default the log date to today on creation
	This:C1470.logDate:=Current date:C33(*)
	
local Function _initPoNumber()
	//If (This.poNumber=0)
	//This.poNumber:=ds.PurchaseOrder.all().max("poNumber")+1
	//End if 