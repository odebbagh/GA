//%attributes = {}

/*
Method Name : _ga_buildBuyOrderTemplate
Purpose     : Generates Resources/4DWriteProPrintTemplates/buyOrderPrintTemplate.4wp, the
              seed for the BUY_ORDER document model, laid out like the legacy
              Company_PO_WP print.

READ THIS FIRST
  This method only SEEDS the template. Run it once, then run _ga_installBuyOrderModel to
  load it into Document Management > Models as BUY_ORDER, and do all further layout work
  there in the Write Pro editor. BuyingOrders_printBuyOrder reads the model, not this
  file, so re-running this method afterwards achieves nothing except overwriting the seed.

PLACEHOLDERS, NOT FORMULAS
  Every value is written as a {{token}} and replaced at print time by _wpFill. An earlier
  version used WP INSERT FORMULA with This.<key>, which needed a data context the print
  no longer sets - those fields simply came out blank, which is why the bottom half of
  the page printed as empty lines. Anything added in the editor must use {{token}} too;
  the token names are the $context keys listed in BuyingOrders_printBuyOrder.

SECTIONS
  The legacy form drew 4D group boxes - a rectangle with its caption sitting on the top
  border. Write Pro has no group box, so each section here is a bordered table whose
  first row is the caption in bold. That puts the caption on a border line and gives the
  block a real outline, which is as close as the format gets.

WHAT STILL NEEDS THE EDITOR
  - the logo and the ISO badge are images: two tagged paragraphs are left for them
  - page headers and footers are section properties, not content. Add them in the editor
    and put {{pageFooter}} plus a page-number field in the footer.

  The QUALITY TERMS AND CONDITIONS pages are NOT part of this template. They are their
  own documents, printed after the order - see _ga_installBuyOrderModel.
*/

var $doc : Object
var $range : Object
var $table : Object
var $row : Object
var $column : Object
var $box : Object
var $folder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $i : Integer

$folder:=Folder(fk resources folder).folder("4DWriteProPrintTemplates")
If (Not($folder.exists))
	$folder.create()
End if
$file:=$folder.file("buyOrderPrintTemplate.4wp")

If ($file.exists)
	If (Not(cs.sfw_dialog.me.confirm("buyOrderPrintTemplate.4wp exists. Overwrite it?"+Char(Carriage return)\
		+"If you have already installed and edited the BUY_ORDER model, this does not touch it."; "Overwrite"; "CANCEL")))
		return
	End if
End if

$doc:=WP New("")

//---page setup and a sane base style. The default document is 12pt red serif, which is
//   what made the first attempt unreadable.
WP SET ATTRIBUTES($doc; wk layout unit; wk unit cm)
WP SET ATTRIBUTES($doc; wk font family; "Arial")
WP SET ATTRIBUTES($doc; wk font size; 9)
WP SET ATTRIBUTES($doc; wk text color; "#000000")

//---US Letter portrait, stated explicitly. Nothing set the paper size before, so the
//   document kept whatever default it was created with and the tables - sized in cm for
//   a Letter page - ran off the right edge.
WP SET ATTRIBUTES($doc; wk page width; "21.59cm")
WP SET ATTRIBUTES($doc; wk page height; "27.94cm")
WP SET ATTRIBUTES($doc; wk page orientation; wk portrait)

//---wk page margin, NOT wk margin. wk margin sets the element's own margin, which is why
//   the earlier version appeared to have no effect on the page at all.
WP SET ATTRIBUTES($doc; wk page margin left; "1cm")
WP SET ATTRIBUTES($doc; wk page margin right; "1cm")
WP SET ATTRIBUTES($doc; wk page margin top; "1cm")
WP SET ATTRIBUTES($doc; wk page margin bottom; "1cm")

//---Usable width is therefore 19.59cm. Every table below is laid out to 18.4cm of
//   content, leaving 1.2cm of slack for cell padding and borders, which Write Pro adds
//   ON TOP of the width you declare for a column. Do not push the totals to 19.5cm or
//   the tables will overflow again.

// ============================================================
// letterhead
// ============================================================

_wpLine($doc; "[ LOGO HERE ]"; 9; False)
_wpLine($doc; "44061 Old Warm Spring Blvd."; 9; False)
_wpLine($doc; "Fremont CA 94538"; 9; False)
_wpLine($doc; "Tel: 408-956-1010"; 9; False)
_wpLine($doc; "Fax: 408-956-1212"; 9; False)
_wpLine($doc; "SRGH26835753"; 9; False)
_wpLine($doc; "[ ISO BADGE HERE ]   ISO 9001 Certified   DLA QML Listed   DLA Commercial Lab Suitability   ITAR Registered"; 8; False)
_wpRule($doc)

// ============================================================
// the upper block: letterhead, title, and the three group boxes
// ============================================================
// These are ANCHORED TEXT BOXES, not table rows. A table cannot put a caption on the
// border line - a table caption is always a row inside the border, which is what made
// the earlier version look like a grid rather than like the legacy form. _wpGroupBox
// draws the rectangle and paints the caption over its top border.
//
// Positions are absolute, in cm from the top-left of the page, so the flowing text below
// has to be pushed clear of them - see the spacer further down.

//---left: the vendor, tall, matching the legacy proportions
_wpGroupBox($doc; "Issued to:"; 1.0; 4.0; 8.8; 5.2; 1.7; \
	"{{vendorBlock}}"+Char(Carriage return)+Char(Carriage return)\
	+"Attn:  {{attentionTo}}"+Char(Carriage return)\
	+"Fax:   {{attentionFax}}"+Char(Carriage return)\
	+"Tel:   {{attentionTel}}")

//---right, above the boxes: the title and the order identity, no border
$box:=WP New text box($doc; 1)
WP SET ATTRIBUTES($box; wk margin left; "10.2cm")
WP SET ATTRIBUTES($box; wk margin top; "4.0cm")
WP SET ATTRIBUTES($box; wk width; "9.4cm")
WP SET ATTRIBUTES($box; wk height; "1.3cm")
WP SET ATTRIBUTES($box; wk border style; wk none)
WP SET ATTRIBUTES($box; wk padding; "0cm")
WP SET ATTRIBUTES($box; wk font family; "Arial")
WP SET ATTRIBUTES($box; wk text align; wk center)
WP SET TEXT($box; "{{potitle}}        {{poNumber}}"+Char(Carriage return)\
	+"Issue date {{issueDate}}"+Char(Carriage return)+"{{title}}"; wk append)
WP SET ATTRIBUTES($box; wk font size; 10)
WP SET ATTRIBUTES($box; wk font bold; True)

//---right: ship to, then bill to
_wpGroupBox($doc; "Ship to"; 10.2; 5.5; 9.4; 2.0; 1.4; "{{shipTo}}")
_wpGroupBox($doc; "Bill to"; 10.2; 7.7; 9.4; 1.5; 1.2; "{{billTo1}}"+Char(Carriage return)+"{{billTo2}}")

// ============================================================
// spacer - pushes the flowing content below the anchored boxes
// ============================================================
// The boxes above are anchored and take no room in the text flow, so without this the
// terms strip would print on top of them. The letterhead ends around 4cm and the lowest
// box ends at 9.2cm, so this fills the gap. Adjust the count in the editor if you move
// the boxes.

For ($i; 1; 13)
	_wpLine($doc; ""; 9; False)
End for

// ============================================================
// Payment Terms / Ship Via / Delivery Terms
// ============================================================
// Right-aligned and half width, sitting under the Bill to box as it does on the legacy
// form, rather than spanning the page.

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; "Payment Terms"; "Ship Via"; "Delivery Terms")
_wpCaptionRow($row)
$row:=WP Table append row($table; "{{netDays}}"; "{{shipVia}}"; "{{fob}}")

For ($i; 1; 3)
	$column:=WP Table get columns($table; $i)
	WP SET ATTRIBUTES($column; wk width; "3.0cm")
	WP SET ATTRIBUTES($column; wk text align; wk center)
End for
WP SET ATTRIBUTES($table; wk table align; wk right)
WP SET ATTRIBUTES($table; wk border style; wk solid)
WP SET ATTRIBUTES($table; wk border width; "0.5pt")
WP SET ATTRIBUTES($table; wk padding; "0.08cm")
// ============================================================
// the line table replaces this marker paragraph
// ============================================================

_wpLine($doc; ""; 9; False)
_wpLine($doc; "Tabl@"; 9; False)
_wpLine($doc; ""; 9; False)

// ============================================================
// totals
// ============================================================

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; "{{currencyNote}}"; "Total:   {{total}}")
$column:=WP Table get columns($table; 1)
WP SET ATTRIBUTES($column; wk width; "12.9cm")
$column:=WP Table get columns($table; 2)
WP SET ATTRIBUTES($column; wk width; "5.5cm")
WP SET ATTRIBUTES($column; wk text align; wk right)
WP SET ATTRIBUTES($table; wk border style; wk solid)
WP SET ATTRIBUTES($table; wk border width; "0.5pt")
WP SET ATTRIBUTES($table; wk padding; "0.08cm")

_wpLine($doc; ""; 9; False)

// ============================================================
// additional terms
// ============================================================

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; "Additional terms")
_wpCaptionRow($row)
$row:=WP Table append row($table; "{{addTerms}}")
$column:=WP Table get columns($table; 1)
WP SET ATTRIBUTES($column; wk width; "18.4cm")
WP SET ATTRIBUTES($table; wk border style; wk solid)
WP SET ATTRIBUTES($table; wk border width; "0.5pt")
WP SET ATTRIBUTES($table; wk padding; "0.08cm")

_wpLine($doc; ""; 9; False)

// ============================================================
// requestor / buyer and the two approver lines
// ============================================================

$range:=WP Text range($doc; wk end text; wk end text)
$table:=WP Insert table($range; wk append; wk include in range)
$row:=WP Table append row($table; "Ordered by"; "Approvals")
_wpCaptionRow($row)
$row:=WP Table append row($table; \
	"{{requestor}}"+Char(Carriage return)\
	+"{{buyer}}"+Char(Carriage return)\
	+"{{buyerContact}}"; \
	"{{approverText}} {{approver1}}"+Char(Carriage return)+Char(Carriage return)\
	+"{{approverText2}} {{approver2}}")

For ($i; 1; 2)
	$column:=WP Table get columns($table; $i)
	WP SET ATTRIBUTES($column; wk width; "9.2cm")
End for
WP SET ATTRIBUTES($table; wk border style; wk solid)
WP SET ATTRIBUTES($table; wk border width; "0.5pt")
WP SET ATTRIBUTES($table; wk padding; "0.08cm")

WP EXPORT DOCUMENT($doc; $file.platformPath; wk 4wp)

cs.sfw_dialog.me.info("Template written to:"+Char(Carriage return)+$file.platformPath+Char(Carriage return)+Char(Carriage return)\
	+"Now run _ga_installBuyOrderModel to load it into Document Management > Models as BUY_ORDER, "\
	+"and do the rest of the layout there: the logo, the ISO badge, and a page header and footer. "\
	+"The print reads the model, so there is no reason to run this method again.")