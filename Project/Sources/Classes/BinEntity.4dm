Class extends Entity

// ----------------------------------------------
// nameInWindowTitle
// ----------------------------------------------
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String(This.binLocationPath)

// ----------------------------------------------
// isEmpty — computed live: a bin is empty when no linked inventory has stock left (availableQty, the
// one stock figure - ga_stock). A bin may hold many materials: "not empty" is information, not a block
// ----------------------------------------------
local Function get isEmpty()->$isEmpty : Boolean
	$isEmpty:=(This.inventories.query("availableQty > :1"; 0).length=0)

// ----------------------------------------------
// inventoryNames — codes of the inventories currently stored in this bin
// ----------------------------------------------
local Function get inventoryNames()->$names : Text
	$names:=This.inventories.query("availableQty > :1"; 0).orderBy("code asc").code.join(", ")

// ----------------------------------------------
// assignBarcode - gives the bin a scanner barcode value when it has none yet, using the
// same counter-based scheme as the other tables (sfw_Counter, 10-digit padded). Called by
// every place that creates a bin: the Bins entry (loadAfterCreation below), the location
// picker (Util_binLocationPicker) and _import_warehouseBins. The caller saves.
// ----------------------------------------------
local Function assignBarcode()
	If (This.moreData=Null)
		This.moreData:=New object()
	End if
	If (String(This.moreData.barcodeData)="")
		This.moreData.barcodeData:=String(ds.sfw_Counter.getNextValue("Bin"); "0000000000")
	End if
	
// ----------------------------------------------
// loadAfterCreation - a bin created from the Bins entry
// ----------------------------------------------
local Function loadAfterCreation()
	This.assignBarcode()


