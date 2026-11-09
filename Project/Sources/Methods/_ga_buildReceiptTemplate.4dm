//%attributes = {}

/*
Method Name : _ga_buildReceiptTemplate
Purpose     : Generates Resources/4DWriteProPrintTemplates/receiptPrintTemplate.4wp and
              installs it as the BUY_RECEIPT document model - the legacy
              "Material-Receipt and Transfer-Slip", [wwwDialogs] form InventoryReceipt.
              BOReceiving_printReceipt prints it for both flavours: MaterialReceipt (no lot
              table) and InventoryReceipt (the lot table in place of the Lots@ marker).

READ THIS FIRST
  Like _ga_buildBuyOrderTemplate, this only SEEDS the model. Run it once; from then on
  edit BUY_RECEIPT in Document Management > Models. The print reads the model, not this
  file, and re-running this method asks before replacing what you laid out there.

LAYOUT - the legacy form, top to bottom
  letterhead      address on the left, certifications on the right
  title           {{title}}, centred
  barcode strip   the part-number barcode with its caption, Order ID on the right
  ordered strip   Order # / Vendor / Description of Ordered Material / Qty-in /Units
  thick rule
  Lots@           replaced by the lot table on an inventory receipt, emptied otherwise
  thick rule
  transfer strip  Received By / Date-in / Internal-Job# / Transferred To, with the blank
                  band legacy left between the captions and the values
  {{pageFooter}}

ONE WIDTH FOR EVERYTHING
  Every table - the borderless ones, the grids, the two thick rules, and the lot table
  the print inserts - is sized by _wpFitColumns to the same outer width, so their right
  edges line up. Borderless tables draw the same border in white; the thick rules are
  one-cell tables with a 2pt bottom border rather than paragraph borders, which spanned
  the whole text column and stuck out past the tables.

PLACEHOLDERS
  Every value is a {{token}} filled by _wpFill; the names are the $context keys listed in
  BOReceiving_printReceipt. {{barcode}} is the exception: it is a picture, so the print
  method replaces it itself before _wpFill runs.

WHAT STILL NEEDS THE EDITOR
  The logo and the ISO badge are images: "[ LOGO HERE ]" and "[ ISO BADGE HERE ]" mark
  where to drop them.
*/

var $doc : Object
var $range : Object
var $table : Object
var $row : Object
var $column : Object
var $cells : Object
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $modelFolder : cs:C1710.sfw_DocumentFolderEntity
var $modelFolders : cs:C1710.sfw_DocumentFolderSelection
var $installed : Collection
var $i : Integer

$folder:=Folder(fk resources folder).folder("4DWriteProPrintTemplates")
If (Not($folder.exists))
	$folder.create()
End if
$file:=$folder.file("receiptPrintTemplate.4wp")

If ($file.exists)
	If (Not(cs.sfw_dialog.me.confirm("receiptPrintTemplate.4wp exists. Overwrite it?"+Char(Carriage return)\
		+"The BUY_RECEIPT model is only replaced if you confirm that separately."; "Overwrite"; "CANCEL")))
		return
	End if
End if

$doc:=WP New("")

//---same page setup as the buy order: US Letter portrait, 1cm page margins, 9pt Arial.
//   wk page margin, NOT wk margin - see _ga_buildBuyOrderTemplate.
WP SET ATTRIBUTES($doc; wk layout unit; wk unit cm)
WP SET ATTRIBUTES($doc; wk font family; "Arial")
WP SET ATTRIBUTES($doc; wk font size; 9)
WP SET ATTRIBUTES($doc; wk text color; "#000000")
WP SET ATTRIBUTES($doc; wk page width; "21.59cm")
WP SET ATTRIBUTES($doc; wk page height; "27.94cm")
WP SET ATTRIBUTES($doc; wk page orientation; wk portrait)
WP SET ATTRIBUTES($doc; wk page margin left; "1cm")
WP SET ATTRIBUTES($doc; wk page margin right; "1cm")
WP SET ATTRIBUTES($doc; wk page margin top; "1cm")
WP SET ATTRIBUTES($doc; wk page margin bottom; "1cm")

// ============================================================
// letterhead - two borderless columns
// ============================================================

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; \
	"[ LOGO HERE ]"+Char(Carriage return)\
	+"44061 Old Warm Spring Blvd."+Char(Carriage return)\
	+"Fremont CA 94538"+Char(Carriage return)\
	+"Tel: 408-956-1010"+Char(Carriage return)\
	+"Fax: 408-956-1212"+Char(Carriage return)\
	+"SRGH26835753"; \
	"[ ISO BADGE HERE ]"+Char(Carriage return)\
	+"ISO 9001 Certified"+Char(Carriage return)\
	+"DLA QML Listed"+Char(Carriage return)\
	+"DLA Commercial Lab Suitability"+Char(Carriage return)\
	+"ITAR Registered")
_wpFitColumns($table; New collection(11; 7.4); "#FFFFFF")
WP SET ATTRIBUTES($table; wk font size; 10)

_wpLine($doc; ""; 9; False)

// ============================================================
// title
// ============================================================

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; "{{title}}")
_wpFitColumns($table; New collection(1); "#FFFFFF")
$column:=WP Table get columns($table; 1)
WP SET ATTRIBUTES($column; wk text align; wk center)
WP SET ATTRIBUTES($table; wk font size; 12; wk font bold; True)

// ============================================================
// barcode strip - legacy printed the PART NUMBER as a barcode, captioned under it
// ============================================================

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; \
	"{{barcode}}"+Char(Carriage return)+"Part Number:{{partNumber}}"; \
	"Order ID:  {{orderId}}")
_wpFitColumns($table; New collection(11; 7.4); "#FFFFFF")
$column:=WP Table get columns($table; 1)
WP SET ATTRIBUTES($column; wk font size; 7)
$column:=WP Table get columns($table; 2)
WP SET ATTRIBUTES($column; wk text align; wk center)
WP SET ATTRIBUTES($column; wk font size; 10; wk font bold; True)

_wpLine($doc; ""; 9; False)

// ============================================================
// what was ordered - legacy Rectangle1 and its three dividers
// ============================================================
// Proportions of the legacy columns: 67 / 131 / 267 / 85 px.

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; "Order #:"; "Vendor :"; "Description of Ordered Material"; "Qty-in /Units :")
$row:=WP Table append row($table; \
	"{{orderNumber}}"+Char(Carriage return)+"Item#  {{itemNumber}}"; \
	"{{vendor}}"; \
	"{{description}}"; \
	"{{qtyIn}}"+Char(Carriage return)+"{{units}}")
_wpFitColumns($table; New collection(2.2; 4.4; 8.9; 2.9); "#000000")
$column:=WP Table get columns($table; 4)
WP SET ATTRIBUTES($column; wk text align; wk right)

_wpLine($doc; ""; 9; False)

// ============================================================
// the lot area, between two thick rules (legacy Line1 / Line11)
// ============================================================
// On an inventory receipt BOReceiving_printReceipt replaces the Lots@ paragraph with the
// lot table (sized by _boSizeReceiptColumns to the same width); on a material receipt it
// empties it, which brings the two rules together as the legacy MaterialReceipt printed.

For ($i; 1; 2)
	If ($i=2)
		_wpLine($doc; "Lots@"; 9; False)
	End if
	$range:=WP Text range($doc; wk end text; wk end text)
	$table:=WP Insert table($range; wk append; wk include in range)
	$row:=WP Table append row($table; "")
	_wpFitColumns($table; New collection(1); "#FFFFFF")
	$cells:=WP Table get cells($table)
	WP SET ATTRIBUTES($cells; wk border color bottom; "#000000")
	WP SET ATTRIBUTES($cells; wk border width bottom; "2pt")
	//---a rule, not a row: as thin as the text inside it allows
	WP SET ATTRIBUTES($table; wk font size; 2)
End for

_wpLine($doc; ""; 9; False)

// ============================================================
// transfer strip - legacy Rectangle2: captions, a blank band, then the values
// ============================================================
// Proportions of the legacy columns: 93 / 87 / 77 / 124 / 160 px. The fifth column has no
// caption on the legacy form either. Transferred To is always blank: it is written in by
// hand.

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; "Received By :"; "Date-in :"; "Internal-Job# :"; "Transferred To :"; "")
WP SET ATTRIBUTES($row; wk font bold; True)
$row:=WP Table append row($table; ""; ""; ""; ""; "")
$row:=WP Table append row($table; "{{receivedByCode}}"; "{{dateIn}}"; "{{jobNumber}}"; "{{transferredTo}}"; "")
WP SET ATTRIBUTES($row; wk font bold; True)
_wpFitColumns($table; New collection(3.1; 2.9; 2.5; 4.1; 5.2); "#000000")
WP SET ATTRIBUTES($table; wk font size; 10)

// ============================================================
// footer line - legacy vPage
// ============================================================

_wpLine($doc; ""; 9; False)
_wpLine($doc; "{{pageFooter}}"; 7; False)

WP EXPORT DOCUMENT($doc; $file.platformPath; wk 4wp)

// ============================================================
// install it as the BUY_RECEIPT model - same folder rule as _ga_installBuyOrderModel
// ============================================================

$modelFolder:=ds.sfw_DocumentFolder.query("name = :1"; "Documents management").first()
If ($modelFolder=Null)
	$modelFolders:=ds.sfw_DocumentFolder.all().orderBy("name asc")
	If ($modelFolders.length>0)
		$modelFolder:=$modelFolders.first()
	End if
End if

If ($modelFolder=Null)
	cs.sfw_dialog.me.alert("Template written to:"+Char(Carriage return)+$file.platformPath+Char(Carriage return)+Char(Carriage return)\
		+"but there is no document folder to put the BUY_RECEIPT model in. Create one in Document Management, then run _ga_installBuyOrderModel.")
	return
End if

$installed:=New collection()
_ga_installOneWPModel("BUY_RECEIPT"; "receiptPrintTemplate.4wp"; $modelFolder; $installed)

cs.sfw_dialog.me.info("Template written to:"+Char(Carriage return)+$file.platformPath+Char(Carriage return)+Char(Carriage return)\
	+(($installed.length>0) ? $installed.join(Char(Carriage return)) : "The BUY_RECEIPT model was left as it was.")+Char(Carriage return)+Char(Carriage return)\
	+"Finish it in Document Management > Models > BUY_RECEIPT: drop in the logo and the ISO badge.")
