//%attributes = {}

// Purpose: Open the entry list item matching the scanned moreData.barcodeData (exact ORDA query).
// Parameters: none — uses Form.sfw.entry.dataclass and Util_ScannerManager.communicateWithScanner()
// Returns: nothing
// modified by 4D/PS [2026-september-18]

var $scanResult : Object
var $barcodeData : Text
var $dataclass : Text
var $matches : 4D.EntitySelection

$scanResult:=cs:C1710.Util_ScannerManager.me.communicateWithScanner()

If ($scanResult.cancelled) || ($scanResult.manualEntry)
	return
End if

$barcodeData:=$scanResult.barcodeData
If ($barcodeData="")
	return
End if

If (Form:C1466.sfw=Null:C1517) || (Form:C1466.sfw.entry=Null:C1517) || (Form:C1466.sfw.entry.dataclass=Null:C1517)
	return
End if

$dataclass:=Form:C1466.sfw.entry.dataclass
$matches:=ds:C1482[$dataclass].query("moreData.barcodeData = :1"; $barcodeData)

Case of
	: ($matches.length=0)
		cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Error"; "No Records Found for the Barcode Scanned"))
		
	: ($matches.length>1)
		cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Error"; "Multiples Records Found for the Barcode Scanned"))
		
Else
	Form:C1466.sfw.searchbox:=$barcodeData
	Form:C1466.sfw.searchHighlightParts:=New collection:C1472($barcodeData)
	Form:C1466.sfw.lb_items:=$matches.copy()
	Form:C1466.sfw.lb_items_sort()
	Form:C1466.sfw.lb_items_counter_format()
	
	If (Form:C1466.sfw.view.displayType="listbox")
		Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items
		LISTBOX SELECT ROW:C912(*; "lb_items"; 1; lk replace selection:K53:1)
		Form:C1466.current_item:=Form:C1466.sfw.lb_items[0]
		Form:C1466.sfw.lb_items_selectionChange()
	Else
		Form:C1466.sfw.lb_items_search()
	End if
End case
