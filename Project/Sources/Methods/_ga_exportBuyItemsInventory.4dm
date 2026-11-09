//%attributes = {}

/*
Method Name : _ga_exportBuyItemsInventory
Purpose     : The inventory buy-items report, as an .xlsx - legacy's BuyItemsSpreadSheet
              report ("ALL inventory buy-items whether received or not"), plus the seven
              columns the client asked for.

HOW IT IS BUILT
  Through cs.ExcelDataExporter, the same offscreen 4D View Pro component the other twelve
  exports in this application use. Legacy built its spreadsheet from the on-screen Area
  List Pro grid and pushed it out with ALPtoXL_ByRow; the View Pro class reproduces that
  almost point for point - merged title row, bold headers on yellow, booleans as Y/N,
  a summed footer, auto column widths, then .xlsx and open.

GRAIN - ONE ROW PER BUY LINE
  Legacy's report was a [BUY_ITEMS] report, so one row per line, and the three variants
  included lines that were never received. That is kept. A row is a LINE, not a lot.

  The lot columns therefore aggregate: availableQtyTotal sums, lot numbers, IQA numbers
  and expiry dates are joined distinct, and an IQA flag reads "Partial" when the lots
  disagree. lotCount is exported next to them so an aggregated row is obvious.

THE THREE LEGACY VARIANTS
  Same pop-up, same filters: all inventory lines, received between two dates, or never
  received. Division / supplier / part number filters come from the selection on screen
  rather than from the pickers legacy had on its form.

ONE LEGACY COLUMN CANNOT BE REPRODUCED
  The legacy grid had "$disc", which was [BUY_ITEMS]Discount - a line-level discount
  AMOUNT. _export_vendors never exported it (nor Discount_rate); the only discount value
  that crossed is Ddays. So the column here is "Disc. days", which is a different number
  and is labelled as such rather than pretending to be the old one. Showing the amount
  would mean extending the legacy export and re-importing.

COLUMNS THE CLIENT ASKED FOR
  Avail Qty, Part #, IQA Done, IQA Pass, IQA #, Vendor Lot, Exp date - all present, all
  single-segment attributes on BuyingOrderLineEntity.

  IQA VALUES NEED AN IMPORT RE-RUN. Legacy exports IQADone / IQAPass / IQA_Number and
  they are already in imports/inventory_export.json, but _import_inventory used to drop
  them. It now carries them into moreData.legacy, so re-run it or those three columns
  come out empty.
*/

var $lines : cs:C1710.BuyingOrderLineSelection
var $mapping : Collection
var $templateFile : 4D:C1709.File
var $offscreen : cs:C1710.ExcelDataExporter
var $excelSheet : Object
var $title; $fileName; $sheetName; $destinationFolderPath; $destinationFileName : Text
var $startDate; $stopDate : Date
var $choice : Integer
var $answer : Object
var $destinationFolder : 4D:C1709.Folder

$templateFile:=Folder(fk resources folder).file("excelTemplates/excelExportTemplate.xlsx")
If (Not($templateFile.exists))
	cs.sfw_dialog.me.alert("The Excel template is missing:"+Char(Carriage return)+$templateFile.platformPath)
	return
End if

$lines:=Form.sfw.lb_items
If ($lines=Null) || ($lines.length=0)
	cs.sfw_dialog.me.alert(ds.sfw_readXliff("No items in the list to Export"))
	return
End if

//---legacy Invisible Button1: the same three variants, in the same order
$choice:=Pop up menu("ALL inventory buy-items whether received or not;"\
	+"Inventory buy-items received between two dates;"\
	+"ALL inventory purchases NOT received")

If ($choice<=0)
	return
End if

//---legacy narrowed to Inventory=True. The equivalent here is the line's inventory flag.
$lines:=$lines.query("inventory = :1"; True)

Case of
	: ($choice=1)
		$title:="ALL inventory buy-items whether received or not"

	: ($choice=2)
		//---sfw_dialog has no date picker, so the dates are typed and parsed. An
		//   unparseable entry gives 00/00/00, which is caught below rather than
		//   silently exporting everything.
		$answer:=cs.sfw_dialog.me.request("Received FROM (dd/mm/yyyy):"; String(Current date-30; System date short))
		If (Not($answer.ok))
			return
		End if
		$startDate:=Date($answer.answer)

		$answer:=cs.sfw_dialog.me.request("Received TO (dd/mm/yyyy):"; String(Current date; System date short))
		If (Not($answer.ok))
			return
		End if
		$stopDate:=Date($answer.answer)

		If ($startDate=!00-00-00!) || ($stopDate=!00-00-00!)
			cs.sfw_dialog.me.alert("Those dates could not be read. Use the short date format shown in the field.")
			return
		End if

		$lines:=$lines.query("dateIn >= :1 and dateIn <= :2"; $startDate; $stopDate)
		$title:="Inventory buy-items recvd. between "+String($startDate; System date short)\
			+" and "+String($stopDate; System date short)

	Else
		$lines:=$lines.query("dateIn = :1"; !00-00-00!)
		$title:="ALL inventory purchases NOT received"
End case

If ($lines.length=0)
	cs.sfw_dialog.me.alert("No inventory buy-items match that choice.")
	return
End if

$title:=$title+".  "+String($lines.length)+" line(s)."

//---Columns. Order follows the legacy grid, with the client's seven inserted next to the
//   receiving figures where they belong.
$mapping:=New collection(\
	New object("header"; "BO #"; "field"; "boNumber"; "footerOperation"; ""); \
	New object("header"; "Item#"; "field"; "displayNumber"; "footerOperation"; ""); \
	New object("header"; "Vendor"; "field"; "supplierName"; "footerOperation"; ""); \
	New object("header"; "Description"; "field"; "description"; "footerOperation"; ""); \
	New object("header"; "Part #"; "field"; "partNumberDisplay"; "footerOperation"; ""); \
	New object("header"; "Units"; "field"; "units"; "footerOperation"; ""); \
	New object("header"; "Qty"; "field"; "qtyOrderedEffective"; "footerOperation"; "sum"); \
	New object("header"; "Unit price"; "field"; "unitPrice"; "footerOperation"; ""); \
	New object("header"; "Disc. days"; "field"; "discountDaysDisplay"; "footerOperation"; ""); \
	New object("header"; "Line total"; "field"; "lineTotal"; "footerOperation"; "sum"); \
	New object("header"; "Conf. Date"; "field"; "confirmationDate"; "footerOperation"; ""); \
	New object("header"; "Inv#"; "field"; "invoiceNumberDisplay"; "footerOperation"; ""); \
	New object("header"; "Inv date"; "field"; "invoiceDateDisplay"; "footerOperation"; ""); \
	New object("header"; "Check#"; "field"; "checkNumber"; "footerOperation"; ""); \
	New object("header"; "p/p"; "field"; "partialPaymentDisplay"; "footerOperation"; ""); \
	New object("header"; "Date-in"; "field"; "dateIn"; "footerOperation"; ""); \
	New object("header"; "Qty-in"; "field"; "qtyReceivedDisplay"; "footerOperation"; "sum"); \
	New object("header"; "Avail Qty"; "field"; "availableQtyTotal"; "footerOperation"; "sum"); \
	New object("header"; "Lots"; "field"; "lotCount"; "footerOperation"; "sum"); \
	New object("header"; "IQA Done"; "field"; "iqaDoneDisplay"; "footerOperation"; ""); \
	New object("header"; "IQA Pass"; "field"; "iqaPassDisplay"; "footerOperation"; ""); \
	New object("header"; "IQA #"; "field"; "iqaNumberDisplay"; "footerOperation"; ""); \
	New object("header"; "Vendor Lot#"; "field"; "lotNumbersDisplay"; "footerOperation"; ""); \
	New object("header"; "Exp date"; "field"; "expirationDatesDisplay"; "footerOperation"; ""); \
	New object("header"; "Date paid"; "field"; "paidDate"; "footerOperation"; ""); \
	New object("header"; "$Amt paid"; "field"; "amountPaid"; "footerOperation"; "sum"); \
	New object("header"; "GL AC"; "field"; "glAccount"; "footerOperation"; ""); \
	New object("header"; "Disputed"; "field"; "disputedDisplay"; "footerOperation"; "")\
	)

$fileName:="BuyItemsInventory"
$sheetName:="Buy items"
//---Where the file lands: <Resources>/exportedData/BuyOrders/, matching the twelve
//   other _ga_export* methods. ExcelDataExporter creates the FILE but not the folder,
//   and only exportedData/Suppliers exists today, so the folder is created here first.
$destinationFolderPath:=Get 4D folder(Current resources folder)+"exportedData"+Folder separator+"BuyOrders"

$destinationFolder:=Folder(Convert path system to POSIX($destinationFolderPath))
If (Not($destinationFolder.exists))
	$destinationFolder.create()
End if
$destinationFileName:=$fileName+"_"+Replace string(String(Date(Timestamp)); "/"; "_")+".xlsx"

$offscreen:=cs.ExcelDataExporter.new($templateFile.platformPath; $mapping; $lines; \
	$destinationFileName; $destinationFolderPath; $title; $sheetName; True)
$excelSheet:=VP Run offscreen area($offscreen)