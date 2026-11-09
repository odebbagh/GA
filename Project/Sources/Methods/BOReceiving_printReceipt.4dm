//%attributes = {}

/*
Method Name : BOReceiving_printReceipt
Purpose     : Prints the receipt for the current buy line - legacy InventoryReceipt and
              MaterialReceipt, which both render the [wwwDialogs] form "InventoryReceipt".

WHY ONE METHOD FOR BOTH
  Legacy had two methods against one form: InventoryReceipt filled the lot table from the
  stock the receipt created, MaterialReceipt declared the arrays empty so the same form
  printed with no table. The flavour follows the line, so one method decides it here.

THE TEMPLATE
  The BUY_RECEIPT document model, seeded by _ga_buildReceiptTemplate from
  Resources/4DWriteProPrintTemplates/receiptPrintTemplate.4wp. Same recipe as the buy
  order: static layout, {{key}} placeholders filled by _wpFill, and one marker paragraph
  where the lot table goes.

  DATA CONTEXT KEYS

    $context.title          "Material-Receipt and Transfer-Slip"
    $context.orderId        legacy "Order ID" - the line's legacy sequence number
    $context.partNumber     the line's part number - printed as the barcode AND as the
                            "Part Number:" caption under it. Legacy Variable4:
                            BarCodeWithZint(->barcodeDeviceNum; "Code128B"; Part_num; "Part Number")
    {{barcode}}             not a context key: it is a picture, so this method replaces
                            the placeholder itself before _wpFill runs

    the ordered-material strip:
    $context.orderNumber    BO number
    $context.itemNumber     item number, "1" or "1.1"
    $context.vendor
    $context.description
    $context.qtyIn          quantity received
    $context.units

    the transfer strip:
    $context.receivedBy     the receiver's name
    $context.receivedByCode the receiver's employee code - what legacy printed (Recd_by)
    $context.dateIn
    $context.jobNumber
    $context.transferredTo  ALWAYS EMPTY - legacy printed the label with no field under
                            it, as a blank for someone to write in by hand

    reconciliation:
    $context.reconError     "****" when the stock does not tie back to the buy line,
                            "" otherwise. Legacy printed exactly this marker.
    $context.lotTotalQty    sum of the lots' received quantity
    $context.lotTotalValue  sum of their value
    $context.lineTotal      the buy line's own total, for comparison

    $context.pageFooter

  MARKER PARAGRAPH
    A paragraph whose text is exactly   Lots@   is replaced by the lot table. On a
    non-inventory line the marker is simply removed, which is how MaterialReceipt
    printed the same form with no table.

  LOT TABLE COLUMNS - the nine values InventoryReceiptArray("insert";...) took:
    Part # | Stock # | Lot # | Qty | Original Qty | Date In | Currency | Unit Cost | Value

THE RECONCILIATION CHECK
  Legacy:
      totalapprov := Sum([Inventory]Current_Actual_Value)
      tempamt     := Sum([Inventory]Qty_in_Stock)
      If (totalapprov # [BUY_ITEMS]Line_total) | (tempamt # [BUY_ITEMS]Qtyin) -> "****"
  Reproduced, with one correction: it sums initialQty rather than qtyInStock. qtyInStock
  is what is LEFT on the shelf, so on any receipt whose stock has since been consumed the
  legacy test compared a depleted figure against the ordered quantity and printed "****"
  on a receipt that was perfectly correct.
*/

var $line : cs:C1710.BuyingOrderLineEntity
var $lots : cs:C1710.InventorySelection
var $lot : cs:C1710.InventoryEntity
var $context : Object
var $file : 4D:C1709.File
var $template; $range; $table; $row; $paragraph : Object
var $model : cs:C1710.sfw_DocumentModelEntity
var $currency : Text
var $lotQty; $lotValue; $received : Real
var $barcode : Picture
var $barcodeRange : Object

$line:=Form:C1466.current_item
If ($line=Null:C1517)
	cs:C1710.sfw_dialog.me.info("Open a buy item first.")
	return
End if

//---Same arrangement as BuyingOrders_printBuyOrder: the template is the document model
//   named BUY_RECEIPT, editable in Document Management > Models. The Resources file is
//   only the seed, used when no model has been created yet.
$model:=ds:C1482.sfw_DocumentModel.query("name = :1"; "BUY_RECEIPT").first()

If ($model#Null:C1517)
	//---a copy, so filling the template cannot touch the stored model
	$template:=OB Copy:C1225($model.area)
Else
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/receiptPrintTemplate.4wp")
	If (Not:C34($file.exists))
		cs:C1710.sfw_dialog.me.alert("No document model named \"BUY_RECEIPT\" and no template file either.\r\rCreate the template, then run _ga_installBuyOrderModel.")
		return
	End if
	$template:=WP Import document:C1318($file.platformPath)
End if
$context:=New object:C1471()
$currency:=($line.buyingOrder#Null:C1517) ? String:C10($line.buyingOrder.currency) : ""

$context.title:="Material-Receipt and Transfer-Slip"
$context.orderId:=String:C10(Num:C11($line.legacySeqNum))
$context.partNumber:=$line.partNumberDisplay

//---the ordered-material strip
$context.orderNumber:=String:C10($line.orderNumber)
$context.itemNumber:=$line.displayNumber
$context.vendor:=($line.buyingOrder#Null:C1517) && ($line.buyingOrder.supplier#Null:C1517) ? String:C10($line.buyingOrder.supplier.name) : ""
$context.description:=String:C10($line.description)
$context.qtyIn:=$line.qtyReceivedDisplay
$context.units:=String:C10($line.units)

//---the transfer strip. transferredTo is deliberately blank: legacy printed the label
//   with nothing under it, to be filled in by hand.
$context.receivedBy:=($line.receiver#Null:C1517) ? String:C10($line.receiver.fullName) : ""
$context.receivedByCode:=($line.receiver#Null:C1517) ? String:C10($line.receiver.code) : ""
$context.dateIn:=$line.dateIn
$context.jobNumber:=($line.job#Null:C1517) ? String:C10($line.job.jobNumber) : String:C10(Num:C11($line.jobNumber))
$context.transferredTo:=""

//---the lot table, for inventory lines only
$lotQty:=0
$lotValue:=0

$range:=Null:C1517
For each ($paragraph; WP Get elements:C1550($template; wk type paragraph))
	If (WP Get text:C1575($paragraph)="Lots@")
		$range:=WP Paragraph range:C1346($paragraph)
	End if
End for each

If (Bool:C1537($line.inventory))
	$lots:=ds:C1482.Inventory.query("UUID_BuyingOrderLine = :1"; String:C10($line.UUID)).orderBy("inventoryID")

	If ($range#Null:C1517)
		$table:=WP Insert table:C1473($range; wk replace; wk include in range)
		$row:=WP Table append row:C1474($table; "Part #"; "Stock #"; "Lot #"; "Qty"; "Original Qty"; "Date In"; "Currency"; "Unit Cost"; "Value")

		For each ($lot; $lots)
			$row:=WP Table append row:C1474($table; \
				$lot.partNumberDisplay; \
				String:C10($lot.stockNum); \
				String:C10($lot.partLotNumber); \
				String:C10(Num:C11($lot.qtyInStock); "###,##0"); \
				String:C10(Num:C11($lot.initialQty); "###,##0"); \
				_boDate($lot.dateIn); \
				String:C10($lot.currency); \
				_boMoney(Num:C11($lot.unitCost); $currency); \
				_boMoney(Num:C11($lot.actualValue); $currency))

			$lotQty:=$lotQty+Num:C11($lot.initialQty)
			$lotValue:=$lotValue+Num:C11($lot.actualValue)
		End for each

		_boSizeReceiptColumns($table)
	End if
Else
	//---MaterialReceipt: the same form with no lot table
	If ($range#Null:C1517)
		WP SET TEXT:C1574($range; ""; wk replace)
	End if
End if

//---reconciliation, legacy's "****"
$received:=$line.qtyReceivedDisplay
$context.lotTotalQty:=$lotQty
$context.lotTotalValue:=_boMoney($lotValue; $currency)
$context.lineTotal:=_boMoney(Num:C11($line.lineTotal); $currency)

$context.reconError:=""
If (Bool:C1537($line.inventory))
	If ($lotValue#Num:C11($line.lineTotal)) | ($lotQty#$received)
		$context.reconError:="****"
	End if
End if

$context.pageFooter:="Receipt - buy order "+String:C10($line.orderNumber)+" item "+$line.displayNumber

//---the barcode is a picture, so it cannot go through _wpFill. Encoded from the part
//   number as legacy did; a line with no part number, or a value the encoder rejects,
//   simply prints without one.
If ($context.partNumber#"")
	$barcode:=_ga_generateBarCode(New object:C1471("barcodeData"; $context.partNumber))
	$barcode:=Planning_travScaleBarcode($barcode; 280; 45)
End if
For each ($barcodeRange; WP Find all($template; "{{barcode}}"; wk case insensitive))
	If (Picture size($barcode)>0)
		WP Insert picture:C1437($barcodeRange; $barcode; wk replace)
	Else
		WP SET TEXT:C1574($barcodeRange; ""; wk replace)
	End if
End for each

_wpFill($template; $context)

PRINT SETTINGS:C106(2)
If (OK=1)
	WP PRINT:C1343($template; *)
End if
