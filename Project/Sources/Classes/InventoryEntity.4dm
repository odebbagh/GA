Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:="INV: "+String:C10(This:C1470.inventoryID; "00000#")
	
// dateIn is a real Date field (not a stamp), the computed attribute only
// exists because the form binds dateIn_d
Function get dateIn_d()->$date : Date
	$date:=This:C1470.dateIn

Function set dateIn_d($date : Date)
	This:C1470.dateIn:=$date

// expirationDate is a numeric stamp (sfw_stmp), not a date: expirationDate_d is the date it stands
// for, shown in the form and set by its calendar button (00/00/00 = no expiration date)
Function get expirationDate_d()->$date : Date
	$date:=!00-00-00!
	If (Num:C11(This:C1470.expirationDate)#0)
		$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.expirationDate; True:C214)
	End if

Function set expirationDate_d($date : Date)
	This:C1470.expirationDate:=Choose:C955($date=!00-00-00!; 0; cs:C1710.sfw_stmp.me.build($date))


local Function afterSave()
	// Bin.isEmpty is computed live from linked inventories; just invalidate the bin cache so pickers refresh
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(This:C1470.UUID_Location)))
		// Invalidate bin cache so the picker reflects new occupancy status immediately
		If (Storage:C1525.cache#Null:C1517)
			Use (Storage:C1525.cache)
				Storage:C1525.cache.bins:=Null:C1517
			End use
		End if
	End if


// Customer / Vendor column of the list: the customer of customer material, the supplier text of
// bought stock (the legacy Vendor field held either)
Function get ownerName()->$name : Text
	$name:=""
	If (This:C1470.customer#Null:C1517)
		$name:=String:C10(This:C1470.customer.name)
	End if 
	If ($name="")
		$name:=String:C10(This:C1470.vendor)
	End if 
	
local Function beforeSave()
	// called by the framework before a Save from the panel: the legacy field (qtyInStock) and the value
	// follow the stock left (ga_stock)
	cs:C1710.ga_stock.me.syncFigures(This:C1470)
	
local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470.assignIdentity()
	
local Function assignIdentity()
	// the ID (the table's counter: never given twice), the code INV00001, the stock number the search
	// box looks in (new codes and legacy man_ numbers alike) and the barcode (the code). Only what is
	// missing; does not save. Called by every creation path (loadAfterCreation, afterCreation) and by
	// _fix_inventoryLegacy for the imported stock.
	If (This:C1470.inventoryID=0)
		This:C1470.inventoryID:=Sequence number:C244([Inventory:126])
	End if 
	If (This:C1470.code="")
		This:C1470.code:="INV"+String:C10(This:C1470.inventoryID; "00000#")
	End if 
	If (This:C1470.stockNum="")
		This:C1470.stockNum:=This:C1470.code
	End if 
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	If (String:C10(This:C1470.moreData.barcodeData)="")
		This:C1470.moreData.barcodeData:=This:C1470.code  // Generate Barcode (_ga_openBarCodeForm) reads it
		This:C1470.moreData:=This:C1470.moreData
	End if 
	
local Function afterCreation()
	// This callback is called after saving the new item
	
	// the stock starts at the quantity received (ga_stock: one stock figure, the value follows it)
	This:C1470.assignIdentity()
	This:C1470.availableQty:=This:C1470.initialQty
	cs:C1710.ga_stock.me.syncFigures(This:C1470)
	
	$res:=This:C1470.save()
	
	$pull:=ds:C1482.InventoryPull.new()
	
	$pull.date:=cs:C1710.sfw_stmp.me.now()
	$pull.type:="Initial Stock"
	$pull.qty:=This:C1470.initialQty
	$pull.remaining:=This:C1470.initialQty
	$pull.lotNumber:="N/A"
	$pull.statusIQA:=(String:C10(This:C1470.IQA_status)#"") ? This:C1470.IQA_status : "N/A"
	$pull.reason:="Receipt"
	$pull.cost:=Round:C94(This:C1470.initialQty*Num:C11(This:C1470.unitCost); 2)
	
	$pull.UUID_Inventory:=This:C1470.UUID
	
	// who received it, else who is logged in
	If (This:C1470.receiver#Null:C1517)
		$pull.performedBy:=String:C10(This:C1470.receiver.fullName)
	Else 
		$user_es:=ds:C1482.sfw_User.query("login = :1"; Current user:C182)
		$pull.performedBy:=($user_es.length>0) ? $user_es[0].fullName : ""
	End if 
	
	$res:=$pull.save()
	

	// ---- Which part this stock is -------------------------------------------
	// For anything received against a buy order, the authoritative source is the AML row
	// on the buy line: Inventory.partNumber is only the copy Update_inventoryNew made at
	// receipt, and it does not follow a later correction on the AML.
	// Manual stock (13,956 of the 14,718 legacy rows, the man_ prefix) has no buy line,
	// so there the stored text is all there is and stays the fallback.
	// No UUID_AML on [Inventory] by decision - buyingOrderLine.aml reaches it.
Function get partNumberDisplay()->$partNumber : Text
	$partNumber:=""
	If (This:C1470.buyingOrderLine#Null:C1517) && (This:C1470.buyingOrderLine.aml#Null:C1517)
		$partNumber:=String:C10(This:C1470.buyingOrderLine.aml.ourPartNum)
	End if
	If ($partNumber="")
		$partNumber:=String:C10(This:C1470.partNumber)
	End if

Function get vendorPartNumberDisplay()->$partNumber : Text
	$partNumber:=""
	If (This:C1470.buyingOrderLine#Null:C1517) && (This:C1470.buyingOrderLine.aml#Null:C1517)
		$partNumber:=String:C10(This:C1470.buyingOrderLine.aml.vendorPartnum)
	End if

	//mark:-IQA, for the buy-items report
	//
	// Legacy [Inventory] carried five IQA fields - IQADone, IQAPass, IQA_Number, IQADATE
	// and IQADoneBY. This table collapsed them into IQA_required and IQA_status, and
	// _import_inventory does not map the legacy five at all, so nothing arrives today.
	//
	// These read the live columns first and fall back to moreData.legacy, which
	// _import_inventory now carries. The "Display" suffix follows partNumberDisplay and
	// keeps the names clear of any real column added later - the mistake that made
	// glAccount ambiguous on BuyingOrderLine.

Function get iqaDoneDisplay()->$text : Text
	// "Y" / "N" / "" when nothing is recorded either way
	$text:=This._iqaFlag("IQADone")

Function get iqaPassDisplay()->$text : Text
	$text:=This._iqaFlag("IQAPass")

Function get iqaNumberDisplay()->$text : Text
	$text:=""
	If (This.moreData#Null) && (This.moreData.legacy#Null)
		$text:=String(This.moreData.legacy.iqaNumber)
	End if

local Function _iqaFlag($legacyKey : Text)->$text : Text
	var $value : Variant

	$text:=""

	//---live columns first. IQA_status is free text, so only an explicit pass/fail reads
	//   as an answer; anything else is left to the legacy value.
	If ($legacyKey="IQAPass") && (String(This.IQA_status)#"")
		Case of
			: (Position("pass"; Lowercase(String(This.IQA_status)))>0)
				$text:="Y"
				return
			: (Position("fail"; Lowercase(String(This.IQA_status)))>0)
				$text:="N"
				return
		End case
	End if

	If ($legacyKey="IQADone") && (String(This.IQA_status)#"")
		$text:="Y"
		return
	End if

	If (This.moreData=Null) || (This.moreData.legacy=Null)
		return
	End if

	$value:=($legacyKey="IQADone") ? This.moreData.legacy.iqaDone : This.moreData.legacy.iqaPass
	If ($value=Null)
		return
	End if

	$text:=Bool($value) ? "Y" : "N"