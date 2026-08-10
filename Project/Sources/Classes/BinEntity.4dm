Class extends Entity

// ----------------------------------------------
// nameInWindowTitle
// ----------------------------------------------
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String(This.binLocationPath)

// ----------------------------------------------
// isEmpty — computed live: a bin is empty when no linked inventory has stock
// ----------------------------------------------
local Function get isEmpty()->$isEmpty : Boolean
	$isEmpty:=(This.inventories.query("qtyInStock > :1"; 0).length=0)

// ----------------------------------------------
// inventoryNames — codes of the inventories currently stored in this bin
// ----------------------------------------------
local Function get inventoryNames()->$names : Text
	$names:=This.inventories.query("qtyInStock > :1"; 0).orderBy("code asc").code.join(", ")

// ----------------------------------------------
// loadAfterCreation — assign a scanner barcode value on creation, using the
// same counter-based scheme as the other tables (sfw_Counter, 10-digit padded)
// ----------------------------------------------
local Function loadAfterCreation()
	If (This.moreData=Null)
		This.moreData:=New object()
	End if
	This.moreData.barcodeData:=String(ds.sfw_Counter.getNextValue("Bin"); "0000000000")


