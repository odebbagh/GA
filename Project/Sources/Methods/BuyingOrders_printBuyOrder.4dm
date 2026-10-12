//%attributes = {}

/*
Method Name : BuyingOrders_printBuyOrder
Purpose     : Prints the selected buy order(s) from the Buying > Buying Orders list.

A FAITHFUL PORT of legacy Company_PO_WP + BuyOrderPrintJob. Every field below exists on
the legacy form; nothing has been added or dropped. Where legacy computed something in an
object method (RequistionOrOrder, SubrBuyOrderAddr, Field11, Variable13) that computation
is reproduced here.

DATA CONTEXT KEYS - put these in the template as formulas:

  IDENTITY / TITLE
    $context.potitle          "Purchase Order" or "Purchase Requisition"
    $context.title            "This is a requisition and NOT a Purchase Order", else ""
    $context.poNumber         SEQ_NUM
    $context.issueDate        ISSUE_DATE, label "Issue date"
    $context.isRequisition    Boolean - drives the red title and the requisition picture

  ISSUED TO  (group box "Issued to:")
    $context.vendorBlock      SubrBuyOrderAddr: vendor name, then address lines 1-3,
                              then "state   zip", then country - one per line

  SHIP TO  (group box "Ship to")
    $context.shipTo           ShippingAddr

  BILL TO  (group box "Bill to")
    $context.billTo1          legacy <>GBilladd1 - your own company address, line 1
    $context.billTo2          legacy <>GBilladd2 - line 2

  ATTENTION  (labels "Attn:", "Fax:", "Tel:")
    $context.attentionTo
    $context.attentionFax
    $context.attentionTel

  TERMS STRIP  (headers "Payment Terms", "Ship Via", "Delivery Terms")
    $context.discount         Discount
    $context.discountDays     DDAYS
    $context.netDays          NetDays
    $context.shipVia
    $context.fob              printed under "Delivery Terms"

  TOTALS
    $context.currencyNote     "Note: All currency amounts specified in <currency>"
    $context.currency
    $context.total            T_Amt

  FOOTER
    $context.addTerms         Add_terms
    $context.requestor        "Requestor:<name>"
    $context.buyer            "Buyer:<name>"
    $context.buyerContact     legacy BuyersCode, rewritten by Field11 into
                              "Tel: ...\rFax: ...\rEmail: ..." from the buyer's record
    $context.approverText     "Approved by:" or "To be approved by:"
    $context.approver1
    $context.approverText2
    $context.approver2
    $context.showApprover1    False when Approver1 = Approver2, as legacy hid the
                              duplicate row on a non-requisition order
    $context.pageFooter       "Purchase Order#:<n>           Page:" - the page number is
                              a Write Pro page-number field in the template, not here

TEMPLATE ELEMENTS (all optional - each deletion is guarded)
    picture   "requisitionPicture"   shown only when the order is a requisition
    text box  "pendingApproval"      shown only when a chosen line has checkFlag set

MARKER PARAGRAPH
    A paragraph whose text is exactly   Tabl@   is replaced by the line table.

LINE TABLE - two layouts, exactly as PL_SetHeaders/PL_SetWidths declare them. Which one
is used follows the legacy housekeeping switch "ShowPartNumberNotOrderDate", read here
from Setting. Widths are the legacy pixel widths converted at 96dpi.

  Part-number layout (switch ON)
    Item# | Description | Part-Number | Units | Qty | Unit price | Tax | Line total | Date reqd
    35      150           65            40      45    60           40    64           46

  Order-date layout (switch OFF, the default)
    Item# | Description | Units | Qty | Unit price | Tax | Line total | Order date | Date reqd
    33      155           36      45    60           45    64          55           55

  Both end with a break row: "Total" in column 1, and the sums of the Tax and Line total
  columns (PL_SetBrkText).

TERMS
    Not a context key. terms / termsCriticalMaterials / termsCriticalService are Write Pro
    documents and print as their own pages after the PO, inside the same printing job -
    the way BuyOrderPrintJob appended BuyOrderTermsWP.

BUY_ORDER MODEL PLACEHOLDERS - the names the model in Document Management uses
    {{purchaseOrderNumber}}   SEQ_NUM
    {{issueDate}}             ISSUE_DATE as text, System date abbreviated - legacy printed
                              "mer. 11 mars 2020", not the short date
    {{vendorBlock}}           SubrBuyOrderAddr, then three blank lines and the Attn: / Fax: /
                              Tel: lines legacy printed at the foot of "Issued to:"
    {{payTerms}}              legacy Discount "### %;;" + DDAYS "in #####;;" + NetDays
                              "Net #####" side by side: "Net 30", or "2 % in 10 Net 30"
    {{delTerms}}              FOB, printed under "Delivery Terms"
    {{totalTax}}              sum of the lines' tax
  The older keys (poNumber, netDays, fob, attentionTo...) are still filled.

DATA-BOUND LINE TABLE - the alternative to the Tabl@ marker
    The document data context carries This.lines: one object per line, every value
    already formatted as legacy printed it. A table in the model whose datasource is
    This.lines repeats its first row after the headers once per line; its cells read
    This.item.<key>:
        itemNumber  description  partNumber  units  qty  unitPrice  tax  lineTotal
        orderDate   requiredDate
    The context also carries every {{key}} above, so a formula can read This.total,
    This.totalTax, This.currency and so on.

NOT DONE HERE
    The PDF-and-email path (subr_auto_email). WP EXPORT DOCUMENT with wk pdf is the one
    line that would add it.
*/

var $orders : cs:C1710.BuyingOrderSelection
var $order : cs:C1710.BuyingOrderEntity
var $line : cs:C1710.BuyingOrderLineEntity
var $context : Object
var $file : 4D:C1709.File
var $template; $range; $table; $row; $paragraph; $element; $termsDoc : Object
var $model : cs:C1710.sfw_DocumentModelEntity
var $currency; $poTitle : Text
var $showPartNumber; $isRequisition : Boolean
var $totalTax; $totalLines : Real
var $lineRows : Collection
var $dataContext : Object
var $payTerms : Collection
var $rowsTax : Real

//---WHAT GETS PRINTED
// Legacy printed ONE order: Print_BuyorderNEW either took the number as $1 or prompted
// for it with ChooseBO. So the current item is the normal case here.
// Form.sfw.lb_items is NOT the selected rows - it is the whole displayed list, so using
// it unguarded would print every order on screen. It is still offered, because printing
// a filtered batch is useful, but only after saying how many.
If (Form:C1466.current_item#Null:C1517)
	$orders:=ds:C1482.BuyingOrder.query("UUID = :1"; String:C10(Form:C1466.current_item.UUID))
Else
	If (Form:C1466.sfw.lb_items.length=0)
		cs:C1710.sfw_dialog.me.info("Select a buy order to print.")
		return
	End if
	If (Form:C1466.sfw.lb_items.length>1)
		If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Print all "+String:C10(Form:C1466.sfw.lb_items.length)+" buy orders in this list?"; "Print"; "CANCEL")))
			return
		End if
	End if
	$orders:=Form:C1466.sfw.lb_items
End if

//---The template lives in [sfw_DocumentModel] under the name BUY_ORDER, so it can be
//   edited in Document Management > Models like CERT_TRAINING and RECV_TAG are. The
//   Resources file is only a fallback for a database where the model has not been
//   created yet.
$model:=ds:C1482.sfw_DocumentModel.query("name = :1"; "BUY_ORDER").first()

If ($model=Null:C1517)
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/buyOrderPrintTemplate.4wp")
	If (Not:C34($file.exists))
		cs:C1710.sfw_dialog.me.alert("No document model named \"BUY_ORDER\" and no template file either.\r\rRun _ga_installBuyOrderModel to create it.")
		return
	End if
End if

//---legacy AdminControlledHKOptions("ShowPartNumberNotOrderDate"). Absent = the
//   order-date layout, which is what the Else branch of Variable2 did.
$showPartNumber:=_boShowPartNumberColumn()


PRINT SETTINGS:C106(2)
If (OK#1)
	return
End if

//---one job for the whole selection, so each PO and its terms pages stay together
OPEN PRINTING JOB:C995

For each ($order; $orders)

	//---OB Copy, not $model.area directly: the loop fills the template in place, so every
	//   order needs its own document or the second one prints the first one's table and
	//   finds its {{tokens}} already replaced.
	$template:=($model#Null:C1517) ? OB Copy:C1225($model.area) : WP Import document:C1318($file.platformPath)
	$context:=New object:C1471()
	$currency:=String:C10($order.currency)
	$isRequisition:=$order.awaitingApproval

	//---Everything below now comes off the ENTITY as computed attributes, rather than
	//   from a shelf of _bo* helpers taking $order as an argument. The point is not
	//   tidiness: these are the names a Write Pro formula sees through the document data
	//   context, so the template can be extended in the editor without touching this
	//   method. See BuyingOrderEntity, "Printable / document attributes".
	$poTitle:=$order.orderTitle
	$context.potitle:=$poTitle
	$context.title:=$order.requisitionNotice
	$context.isRequisition:=$isRequisition
	$context.poNumber:=String:C10($order.boNumber)
	$context.purchaseOrderNumber:=String:C10($order.boNumber)
	//---text, not the date: legacy printed ISSUE_DATE abbreviated ("mer. 11 mars 2020"),
	//   and _wpFill would otherwise write it as the short date
	$context.issueDate:=($order.orderDate=!00-00-00!) ? "" : String:C10($order.orderDate; System date abbreviated)

	//---"Issued to:" held the vendor address at the top and Attn: / Fax: / Tel: at the foot
	//   of the box. The model has one placeholder for the box, so both go in it.
	$context.vendorBlock:=$order.vendorAddressBlock+(Char:C90(Carriage return:K15:38)*4)\
		+"Attn:    "+$order.attentionName+Char:C90(Carriage return:K15:38)\
		+"Fax:     "+$order.attentionFax+Char:C90(Carriage return:K15:38)\
		+"Tel:     "+$order.attentionTel

	//---shipTo is the legacy free text verbatim; billTo was printing empty because the
	//   old helper read a UUID_Division column that does not exist on this table
	$context.shipTo:=$order.shipToText
	$context.billTo1:=$order.billToText
	$context.billTo2:=""

	$context.attentionTo:=$order.attentionName
	$context.attentionFax:=$order.attentionFax
	$context.attentionTel:=$order.attentionTel

	//---terms strip
	$context.discount:=Num:C11($order.discount)
	$context.discountDays:=Num:C11($order.discountDays)
	$context.netDays:=Num:C11($order.netDays)
	$context.shipVia:=String:C10($order.shipVia)
	$context.fob:=String:C10($order.fob)

	//---Payment Terms, as the legacy strip printed three fields side by side:
	//   Discount "### %;;" and DDAYS "in #####;;" are blank at zero, then "Net #####"
	$payTerms:=New collection:C1472
	If (Num:C11($order.discount)#0)
		$payTerms.push(String:C10(Num:C11($order.discount))+" %")
	End if
	If (Num:C11($order.discountDays)#0)
		$payTerms.push("in "+String:C10(Num:C11($order.discountDays)))
	End if
	$payTerms.push("Net "+String:C10(Num:C11($order.netDays)))
	$context.payTerms:=$payTerms.join(" ")
	$context.delTerms:=String:C10($order.fob)

	//---the lines for a data-bound table in the model (datasource This.lines), formatted
	//   exactly as the Tabl@ table below formats them
	$lineRows:=New collection:C1472
	$rowsTax:=0
	For each ($line; $order.boLines.orderBy("number asc, splitLevel asc"))
		$lineRows.push(New object:C1471(\
			"itemNumber"; $line.displayNumber; \
			"description"; String:C10($line.description); \
			"partNumber"; $line.partNumberDisplay; \
			"units"; String:C10($line.units); \
			"qty"; String:C10(Num:C11($line.qtyOrderedEffective); "###,###,###.####"); \
			"unitPrice"; _boMoney(Num:C11($line.unitPrice); $currency); \
			"tax"; _boTax($line; $currency); \
			"lineTotal"; _boMoney(Num:C11($line.lineTotal); $currency); \
			"orderDate"; _boDate($line.orderDate); \
			"requiredDate"; _boDate($line.requiredDate)))
		$rowsTax:=$rowsTax+Num:C11($line.tax)
	End for each
	$context.totalTax:=_boMoney($rowsTax; $currency)

	//---footer
	$context.addTerms:=String:C10($order.moreData#Null:C1517 ? ($order.moreData.legacy#Null:C1517 ? $order.moreData.legacy.addTerms : "") : "")
	$context.requestor:="Requestor:"+$order.requestorName
	$context.buyer:="Buyer:"+$order.buyerName
	$context.buyerContact:=$order.buyerContactBlock

	//---approver names and captions. The legacy rules - the name rather than the
	//   signature, the moreData fallback for imported orders, and "To be approved by:"
	//   while a requisition is still unsigned - all live on the entity now.
	$context.approver1:=$order.approver1Name
	$context.approver2:=$order.approver2Name
	$context.approverText:=$order.approver1Caption
	$context.approverText2:=$order.approver2Caption
	//---legacy hid the first approver row when both approvers were the same person
	$context.showApprover1:=$isRequisition || (String:C10($order.UUID_Approver1)#String:C10($order.UUID_Approver2))

	$context.pageFooter:=$poTitle+"#:"+String:C10($order.boNumber)

	//---optional template elements
	$element:=WP Get element by ID:C1549($template; "requisitionPicture")
	If ($element#Null:C1517) && (Not:C34($isRequisition))
		WP DELETE TEXT BOX:C1798($element)
	End if
	$element:=WP Get element by ID:C1549($template; "pendingApproval")
	If ($element#Null:C1517)
		WP DELETE TEXT BOX:C1798($element)
	End if

	//---the line table replaces the marker paragraph
	$range:=Null:C1517
	For each ($paragraph; WP Get elements:C1550($template; wk type paragraph))
		If (WP Get text:C1575($paragraph)="Tabl@")
			$range:=WP Paragraph range:C1346($paragraph)
		End if
	End for each

	$totalTax:=0
	$totalLines:=0

	If ($range#Null:C1517)
		$table:=WP Insert table:C1473($range; wk replace; wk include in range)

		If ($showPartNumber)
			$row:=WP Table append row:C1474($table; "Item#"; "Description"; "Part-Number"; "Units"; "Qty"; "Unit price"; "Tax"; "Line total"; "Date reqd")
		Else
			$row:=WP Table append row:C1474($table; "Item#"; "Description"; "Units"; "Qty"; "Unit price"; "Tax"; "Line total"; "Order date"; "Date reqd")
		End if

		For each ($line; $order.boLines.orderBy("number asc, splitLevel asc"))
			If ($showPartNumber)
				$row:=WP Table append row:C1474($table; \
					$line.displayNumber; \
					String:C10($line.description); \
					$line.partNumberDisplay; \
					String:C10($line.units); \
					String:C10(Num:C11($line.qtyOrderedEffective); "###,###,###.####"); \
					_boMoney(Num:C11($line.unitPrice); $currency); \
					_boTax($line; $currency); \
					_boMoney(Num:C11($line.lineTotal); $currency); \
					_boDate($line.requiredDate))
			Else
				$row:=WP Table append row:C1474($table; \
					$line.displayNumber; \
					String:C10($line.description); \
					String:C10($line.units); \
					String:C10(Num:C11($line.qtyOrderedEffective); "###,###,###.####"); \
					_boMoney(Num:C11($line.unitPrice); $currency); \
					_boTax($line; $currency); \
					_boMoney(Num:C11($line.lineTotal); $currency); \
					_boDate($line.orderDate); \
					_boDate($line.requiredDate))
			End if
			$totalTax:=$totalTax+Num:C11($line.tax)
			$totalLines:=$totalLines+Num:C11($line.lineTotal)
		End for each

		//---PL_SetBrkText: "Total" in column 1, the sums under Tax and Line total
		If ($showPartNumber)
			$row:=WP Table append row:C1474($table; "Total"; ""; ""; ""; ""; ""; _boMoney($totalTax; $currency); _boMoney($totalLines; $currency); "")
		Else
			$row:=WP Table append row:C1474($table; "Total"; ""; ""; ""; ""; _boMoney($totalTax; $currency); _boMoney($totalLines; $currency); ""; "")
		End if

		_boSizeColumns($table; $showPartNumber)
	End if

	//---totals strip
	$context.currency:=$currency
	$context.currencyNote:="Note: All currency amounts specified in "+$currency
	$context.total:=_boMoney(Num:C11($order.lineItemsTotal); $currency)

	//---the data context, for formulas and a data-bound line table in the model. A copy
	//   carrying the lines: _wpFill writes every context key as text, and a collection
	//   has no text form.
	$dataContext:=OB Copy:C1225($context)
	$dataContext.lines:=$lineRows
	WP SET DATA CONTEXT:C1786($template; $dataContext)

	//---fill the {{key}} placeholders: plain text markers, typed straight into the model in
	//   the editor. Formulas (the data-bound line table) read the data context set above.
	_wpFill($template; $context)

	//---evaluate the formulas against the context - a data-bound table expands here
	WP COMPUTE FORMULAS($template)

	//---the settings dialog was answered once, above
	WP PRINT:C1343($template; *)

	//---then the quality terms page, as BuyOrderPrintJob appended [BUY_ORDERS]Buy_policy_.
	//
	//   ONE document, not three. Legacy held a single terms document per order: a new
	//   order got the default (<>Buy_policyWP, the [Formats] record "BuyOrderTerms") and
	//   the buyer could swap it for the CriticalMaterials or CriticalService wording from
	//   a pop-up. Printing all three is what put three copies of the terms on the end.
	//
	//   GA split that one field into three columns at import, so _boOrderTerms picks the
	//   one the order actually carries and falls back to the BUY_ORDER_TERMS model.
	$termsDoc:=_boOrderTerms($order)
	If ($termsDoc#Null:C1517)
		WP PRINT:C1343($termsDoc; *)
	End if
End for each

CLOSE PRINTING JOB:C996
