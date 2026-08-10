//%attributes = {}

var $cell : Object
var $columnHeaderLine : cs:C1710.dfd_LineEntity
var $dtAreaLeft; $divDetailsLeft; $maxDtCols; $dtColW; $dtLeft; $dtWidth; $partTableW : Integer
var $headerLine : cs:C1710.dfd_LineEntity
var $infoLine : cs:C1710.dfd_LineEntity
var $lineItem : Object
var $lineRef : Object
var $namePrefix : Text
var $nextOrder : Integer
var $objects : Collection
var $okCount : Integer
var $partTableCols : Collection
var $partRowLine : cs:C1710.dfd_LineEntity
var $procCols : Collection
var $res : Object
var $stepH : Integer
var $stepLine : cs:C1710.dfd_LineEntity
var $template : cs:C1710.dfd_TemplateEntity
var $templateName : Text
var $typeLine : Object

$namePrefix:="Lot Traveller"
$templateName:=$namePrefix+" Template"
$okCount:=0

// A4 landscape = 842px wide; content area = page width minus left/right margins
$pageMargin:=15
$pageContentW:=842-$pageMargin-$pageMargin  // 812
$scale:=$pageContentW/1000

// -------------------------------
// Header line
// -------------------------------
$headerLine:=ds:C1482.dfd_Line.query("name = :1"; $namePrefix+" - Header").first()
If ($headerLine=Null:C1517)	
	$headerLine:=ds:C1482.dfd_Line.new()
End if 

$headerLine.name:=$namePrefix+" - Header"
$headerLine.calculs:=New object:C1471("rules"; New collection:C1472())
$headerLine.variableItems:=New object:C1471("tags"; New collection:C1472())
$headerLine.moreData:=New object:C1471()
$headerLine.objectsForm:=New object:C1471("objects"; New collection:C1472())

$lineItem:=New object:C1471("name"; "rect_header"; "order"; 1; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 0; "width"; $pageContentW; "height"; 132; "fill"; "white"; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
$headerLine.objectsForm.objects.push($lineItem)

$gaLogoH:=Round:C94(42*$scale; 0)
$gaLogoW:=Round:C94($gaLogoH*(120/58); 0)

$lineItem:=New object:C1471("name"; "gaLogo"; "order"; 2; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 6; "left"; 10; "width"; $gaLogoW; "height"; $gaLogoH; "picture"; "/RESOURCES/image/lotTraveller/golden_altos_logo.png"; "pictureFormat"; "proportionalCenter"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "addressLine1"; "order"; 3; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 50; "left"; 10; "width"; Round:C94(250*$scale; 0); "height"; 11; "text"; "44061 Old Warm Springs Blvd"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "addressLine2"; "order"; 4; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 62; "left"; 10; "width"; Round:C94(250*$scale; 0); "height"; 11; "text"; "Fremont, CA 94538"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "addressLine3"; "order"; 5; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 74; "left"; 10; "width"; Round:C94(250*$scale; 0); "height"; 11; "text"; "Tel: (408) 956-1010"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "lotTravelerTitle"; "order"; 6; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 108; "left"; 10; "width"; Round:C94(200*$scale; 0); "height"; 18; "text"; "Lot Traveler"; "fontFamily"; "Helvetica"; "fontSize"; 12; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "jobBarcodePic"; "order"; 7; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 6; "left"; Round:C94(270*$scale; 0); "width"; Round:C94(325*$scale; 0); "height"; 26; "text"; "##jobBarcodePic##"; "dataSourceTypeHint"; "picture"; "pictureFormat"; "proportionalCenter"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "jobBarcodeLabel"; "order"; 8; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 32; "left"; Round:C94(270*$scale; 0); "width"; Round:C94(325*$scale; 0); "height"; 10; "text"; "##jobBarcodeLabel##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "travellerBarcodePic"; "order"; 9; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 46; "left"; Round:C94(270*$scale; 0); "width"; Round:C94(325*$scale; 0); "height"; 26; "text"; "##travellerBarcodePic##"; "dataSourceTypeHint"; "picture"; "pictureFormat"; "proportionalCenter"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "travellerBarcodeLabel"; "order"; 10; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 72; "left"; Round:C94(270*$scale; 0); "width"; Round:C94(325*$scale; 0); "height"; 10; "text"; "##travellerBarcodeLabel##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "isoLogo"; "order"; 11; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 10; "left"; Round:C94(688*$scale; 0); "width"; Round:C94(50*$scale; 0); "height"; Round:C94(50*$scale; 0); "picture"; "/RESOURCES/image/lotTraveller/iso_9001_badge.png"; "pictureFormat"; "proportionalCenter"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "certLine1"; "order"; 12; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 10; "left"; Round:C94(744*$scale; 0); "width"; $pageContentW-Round:C94(744*$scale; 0); "height"; 11; "text"; "ISO 9001 Certified"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "certLine2"; "order"; 13; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 24; "left"; Round:C94(744*$scale; 0); "width"; $pageContentW-Round:C94(744*$scale; 0); "height"; 11; "text"; "DLA QML Listed"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "certLine3"; "order"; 14; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 38; "left"; Round:C94(744*$scale; 0); "width"; $pageContentW-Round:C94(744*$scale; 0); "height"; 11; "text"; "DLA Commercial Lab Suitability"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "certLine4"; "order"; 15; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 52; "left"; Round:C94(744*$scale; 0); "width"; $pageContentW-Round:C94(744*$scale; 0); "height"; 11; "text"; "ITAR Registered"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$headerLine.objectsForm.objects.push($lineItem)

$res:=$headerLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Lot info banner (ETP - every page)
// -------------------------------
$infoLine:=ds:C1482.dfd_Line.query("name = :1"; $namePrefix+" - Info").first()
If ($infoLine=Null:C1517)
	$infoLine:=ds:C1482.dfd_Line.new()
End if 

$infoLine.name:=$namePrefix+" - Info"
$infoLine.calculs:=New object:C1471("rules"; New collection:C1472())
$infoLine.variableItems:=New object:C1471("tags"; New collection:C1472())
$infoLine.moreData:=New object:C1471()
$infoLine.objectsForm:=New object:C1471("objects"; New collection:C1472())

$esdW:=Round:C94(68*$scale; 0)
$esdRightInset:=10  // keep logo inside the box border
$esdLeft:=$pageContentW-$esdW-$esdRightInset
$infoTextW:=$esdLeft-20

$lineItem:=New object:C1471("name"; "infoOuterRect"; "order"; 1; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 0; "width"; $pageContentW; "height"; 78; "fill"; "white"; "stroke"; "#000000"; "strokeWidth"; 1))
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "infoGreyBar"; "order"; 2; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 0; "width"; 10; "height"; 78; "fill"; "#808080"; "stroke"; "#808080"; "strokeWidth"; 1))
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "infoRow1"; "order"; 3; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 6; "left"; 16; "width"; $infoTextW; "height"; 12; "text"; "##infoRow1##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "infoRow2"; "order"; 4; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 20; "left"; 16; "width"; $infoTextW; "height"; 12; "text"; "##infoRow2##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "infoRow3"; "order"; 5; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 34; "left"; 16; "width"; $infoTextW; "height"; 12; "text"; "##infoRow3##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "infoRow4"; "order"; 6; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 48; "left"; 16; "width"; $infoTextW; "height"; 12; "text"; "##infoRow4##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471("name"; "esdLogo"; "order"; 99; "properties"; New object:C1471("type"; "input"; "_origineType"; "input"; "top"; 6; "left"; $esdLeft; "width"; $esdW; "height"; 66; "dataSource"; "##esdLogoPic##"; "dataSourceTypeHint"; "picture"; "pictureFormat"; "proportionalCenter"; "borderStyle"; "none"; "fill"; "transparent"; "enterable"; False:C215; "focusable"; False:C215))
$infoLine.objectsForm.objects.push($lineItem)

$res:=$infoLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Column header line
// -------------------------------
$columnHeaderLine:=ds:C1482.dfd_Line.query("name = :1"; $namePrefix+" - Column Header").first()
If ($columnHeaderLine=Null:C1517)
	$columnHeaderLine:=ds:C1482.dfd_Line.new()
End if 

$columnHeaderLine.name:=$namePrefix+" - Column Header"
$columnHeaderLine.calculs:=New object:C1471("rules"; New collection:C1472())
$columnHeaderLine.variableItems:=New object:C1471("tags"; New collection:C1472())
$columnHeaderLine.moreData:=New object:C1471()
$columnHeaderLine.objectsForm:=New object:C1471("objects"; New collection:C1472())

$colDetailsLeft:=Round:C94(318*$scale; 0)
$colDetailsW:=$pageContentW-$colDetailsLeft

$lineItem:=New object:C1471(\
"name"; "colHeaderRect"; \
"order"; 1; \
"properties"; New object:C1471(\
"type"; "rectangle"; "_origineType"; "rectangle"; \
"top"; 0; "left"; 0; "width"; $pageContentW; "height"; 24; \
"fill"; "#ebeff5"; "stroke"; "#aeb4bb"; "strokeWidth"; 1\
)\
)
$columnHeaderLine.objectsForm.objects.push($lineItem)

For each ($typeLine; New collection:C1472(\
New object:C1471("name"; "step"; "left"; Round:C94(8*$scale; 0); "width"; Round:C94(50*$scale; 0); "text"; "Step"); \
New object:C1471("name"; "desc"; "left"; Round:C94(66*$scale; 0); "width"; Round:C94(244*$scale; 0); "text"; "Description"); \
New object:C1471("name"; "details"; "left"; $colDetailsLeft; "width"; $colDetailsW; "text"; "Step Details")\
))
	$lineItem:=New object:C1471(\
		"name"; "h_"+$typeLine.name; \
		"order"; $columnHeaderLine.objectsForm.objects.length+1; \
		"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 5; "left"; $typeLine.left; "width"; $typeLine.width; "height"; 14; \
		"text"; $typeLine.text; \
		"fontFamily"; "Helvetica"; "fontSize"; 9; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
		)\
		)
	$columnHeaderLine.objectsForm.objects.push($lineItem)
End for each 

$res:=$columnHeaderLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Step line (CR / steps) - table layout
// -------------------------------
$stepH:=88  // last content row (Silicon/Others) ends at top 76 + height 12
$stepLine:=ds:C1482.dfd_Line.query("name = :1"; $namePrefix+" - Step").first()
If ($stepLine=Null:C1517)
	$stepLine:=ds:C1482.dfd_Line.new()
End if 

$stepLine.name:=$namePrefix+" - Step"
$stepLine.calculs:=New object:C1471("rules"; New collection:C1472())
$stepLine.variableItems:=New object:C1471("tags"; New collection:C1472())
$stepLine.moreData:=New object:C1471()
$stepLine.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$stepLine.objectsForm.objects
$nextOrder:=1

$divStepLeft:=Round:C94(58*$scale; 0)
$divDetailsLeft:=Round:C94(318*$scale; 0)
$partTableLeft:=$divDetailsLeft
$descCellW:=$divDetailsLeft-$divStepLeft
$detailsLeft:=$partTableLeft

$lineItem:=New object:C1471("name"; "stepOuterRect"; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 0; "width"; $pageContentW; "height"; $stepH; "fill"; "white"; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "colDivStep"; "order"; $nextOrder; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; 0; "left"; $divStepLeft; "width"; 1; "height"; $stepH; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "colDivDetails"; "order"; $nextOrder; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; 0; "left"; $divDetailsLeft; "width"; 1; "height"; $stepH; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "cell_step"; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; 0; "width"; $divStepLeft; "height"; $stepH; "fill"; "transparent"; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "stepOrder"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 8; "left"; Round:C94(6*$scale; 0); "width"; Round:C94(46*$scale; 0); "height"; 14; "text"; "##this.stepOrder##"; "fontFamily"; "Helvetica"; "fontSize"; 9; "stroke"; "black"; "textAlign"; "center"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "cell_desc"; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; $divStepLeft; "width"; $descCellW; "height"; $stepH; "fill"; "transparent"; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "stepDescTxt"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 6; "left"; Round:C94(62*$scale; 0); "width"; Round:C94(252*$scale; 0); "height"; $stepH-6; "text"; "##this.stepDescription##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$procCols:=New collection:C1472(\
New object:C1471("name"; "qtyIn"; "left"; $partTableLeft; "width"; Round:C94(58*$scale; 0); "label"; "qty in"; "src"; "##this.qtyIn##"); \
New object:C1471("name"; "dateIn"; "left"; $partTableLeft+Round:C94(58*$scale; 0); "width"; Round:C94(90*$scale; 0); "label"; "date/time in"; "src"; "##this.dateTimeIn##"); \
New object:C1471("name"; "rejects"; "left"; $partTableLeft+Round:C94(148*$scale; 0); "width"; Round:C94(48*$scale; 0); "label"; "rejects"; "src"; "##this.rejects##"); \
New object:C1471("name"; "qtyOut"; "left"; $partTableLeft+Round:C94(196*$scale; 0); "width"; Round:C94(46*$scale; 0); "label"; "qty out"; "src"; "##this.qtyOut##"); \
New object:C1471("name"; "dateOut"; "left"; $partTableLeft+Round:C94(242*$scale; 0); "width"; Round:C94(88*$scale; 0); "label"; "date/time out"; "src"; "##this.dateTimeOut##"); \
New object:C1471("name"; "oper"; "left"; $partTableLeft+Round:C94(330*$scale; 0); "width"; Round:C94(50*$scale; 0); "label"; "oper"; "src"; "##this.oper##")\
)
For each ($cell; $procCols)
	$lineItem:=New object:C1471("name"; "proc_h_"+$cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 4; "left"; $cell.left; "width"; $cell.width; "height"; 13; "fill"; "#f0f0f0"; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	$lineItem:=New object:C1471("name"; "proc_hlbl_"+$cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 6; "left"; $cell.left+2; "width"; $cell.width-4; "height"; 10; "text"; $cell.label; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	$lineItem:=New object:C1471("name"; "proc_v_"+$cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 17; "left"; $cell.left; "width"; $cell.width; "height"; 13; "fill"; "white"; "stroke"; "#b8b8b8"; "strokeWidth"; 1))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	$lineItem:=New object:C1471("name"; "proc_val_"+$cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 19; "left"; $cell.left+2; "width"; $cell.width-4; "height"; 10; "text"; $cell.src; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
End for each 

$lineItem:=New object:C1471("name"; "toolsLabel"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 34; "left"; $detailsLeft; "width"; Round:C94(130*$scale; 0); "height"; 12; "text"; "Tools *Cal Due Date:"; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "toolsValue"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 34; "left"; Round:C94(456*$scale; 0); "width"; $pageContentW-Round:C94(456*$scale; 0); "height"; 12; "text"; "##this.toolsText##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "hpLpLabel"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 48; "left"; $detailsLeft; "width"; Round:C94(40*$scale; 0); "height"; 12; "text"; "Hp-1 *"; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "hp1Value"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 48; "left"; Round:C94(364*$scale; 0); "width"; Round:C94(80*$scale; 0); "height"; 12; "text"; "##this.hp1##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "lpLabel"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 48; "left"; Round:C94(450*$scale; 0); "width"; Round:C94(40*$scale; 0); "height"; 12; "text"; "LP-1 *"; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "lp1Value"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 48; "left"; Round:C94(490*$scale; 0); "width"; Round:C94(80*$scale; 0); "height"; 12; "text"; "##this.lp1##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "waferLabel"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 62; "left"; $detailsLeft; "width"; Round:C94(130*$scale; 0); "height"; 12; "text"; "Wafer Thickness in Mils:"; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "waferValue"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 62; "left"; Round:C94(456*$scale; 0); "width"; Round:C94(50*$scale; 0); "height"; 12; "text"; "##this.waferThickness##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

For each ($cell; New collection:C1472(\
New object:C1471("name"; "glassLabel"; "left"; Round:C94(512*$scale; 0); "text"; "Glassivated:"; "src"; ""); \
New object:C1471("name"; "glassValue"; "left"; Round:C94(578*$scale; 0); "text"; ""; "src"; "##this.glassivated##"); \
New object:C1471("name"; "probedLabel"; "left"; Round:C94(630*$scale; 0); "text"; "Probed:"; "src"; ""); \
New object:C1471("name"; "probedValue"; "left"; Round:C94(672*$scale; 0); "text"; ""; "src"; "##this.probed##"); \
New object:C1471("name"; "inkedLabel"; "left"; Round:C94(720*$scale; 0); "text"; "Inked:"; "src"; ""); \
New object:C1471("name"; "inkedValue"; "left"; Round:C94(756*$scale; 0); "text"; ""; "src"; "##this.inked##")\
))
	If ($cell.src="")
		$lineItem:=New object:C1471("name"; $cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 62; "left"; $cell.left; "width"; Round:C94(66*$scale; 0); "height"; 12; "text"; $cell.text; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
	Else 
		$lineItem:=New object:C1471("name"; $cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 62; "left"; $cell.left; "width"; Round:C94(50*$scale; 0); "height"; 12; "text"; $cell.src; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
	End if 
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
End for each 

$lineItem:=New object:C1471("name"; "siliconLabel"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 76; "left"; $detailsLeft; "width"; Round:C94(50*$scale; 0); "height"; 12; "text"; "Silicon:"; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "siliconValue"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 76; "left"; Round:C94(376*$scale; 0); "width"; Round:C94(200*$scale; 0); "height"; 12; "text"; "##this.silicon##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "othersLabel"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 76; "left"; Round:C94(582*$scale; 0); "width"; Round:C94(50*$scale; 0); "height"; 12; "text"; "Others:"; "fontFamily"; "Helvetica"; "fontSize"; 7; "fontWeight"; "bold"; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1
$lineItem:=New object:C1471("name"; "othersValue"; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 76; "left"; Round:C94(634*$scale; 0); "width"; $pageContentW-Round:C94(634*$scale; 0); "height"; 12; "text"; "##this.others##"; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

// One solid side panel for the whole data-table block (Step + Description columns)
$lineItem:=New object:C1471("name"; "partSideFill"; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; $stepH; "left"; 0; "width"; $divDetailsLeft; "height"; "##this.partBlockHeight##"; "fill"; "#ebeff5"; "stroke"; "transparent"; "strokeWidth"; 0; "visibility"; "##this.hasPartTable##"; "_ignoreForLineHeight"; True:C214))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "partSideBorderL"; "order"; $nextOrder; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $stepH; "left"; 0; "width"; 1; "height"; "##this.partBlockHeight##"; "stroke"; "#b8b8b8"; "strokeWidth"; 1; "visibility"; "##this.hasPartTable##"; "_ignoreForLineHeight"; True:C214))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "partSideBorderB"; "order"; $nextOrder; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; "##this.partSideBottom##"; "left"; 0; "width"; $divDetailsLeft; "height"; 1; "stroke"; "#b8b8b8"; "strokeWidth"; 1; "visibility"; "##this.hasPartTable##"; "_ignoreForLineHeight"; True:C214))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

$lineItem:=New object:C1471("name"; "partSideDiv"; "order"; $nextOrder; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; $stepH; "left"; $divDetailsLeft; "width"; 1; "height"; "##this.partBlockHeight##"; "stroke"; "#b8b8b8"; "strokeWidth"; 1; "visibility"; "##this.hasPartTable##"; "_ignoreForLineHeight"; True:C214))
$objects.push($lineItem)
$nextOrder:=$nextOrder+1

// Data table rows are rendered only via CRS partRows (stacked below step content)

$res:=$stepLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Part row line (CRS / partRows) — one stacked row per header/data entry
// Static geometry (left/width) — only visibility and cell text are dynamic tags
// -------------------------------
$partTableCols:=New collection:C1472()
$partTableLeft:=$divDetailsLeft
$partTableW:=$pageContentW-$partTableLeft
$maxDtCols:=5
$dtColW:=Round:C94($partTableW/$maxDtCols; 0)

For ($dtIdx; 1; $maxDtCols)
	$dtLeft:=$partTableLeft+(($dtIdx-1)*$dtColW)
	If ($dtIdx=$maxDtCols)
		$dtWidth:=$pageContentW-$dtLeft
	Else 
		$dtWidth:=$dtColW
	End if 
	$partTableCols.push(New object:C1471(\
"name"; "c"+String:C10($dtIdx); \
"left"; $dtLeft; \
"width"; $dtWidth; \
"textLeft"; $dtLeft+2; \
"textWidth"; $dtWidth-4; \
"src"; "##this.col_"+String:C10($dtIdx)+"##"; \
"colVis"; "##this.visibleCol"+String:C10($dtIdx)+"##"; \
"hdrVis"; "##this.headerCell"+String:C10($dtIdx)+"##")\
)
End for 

$partRowLine:=ds:C1482.dfd_Line.query("name = :1"; $namePrefix+" - Part Row").first()
If ($partRowLine=Null:C1517)
	$partRowLine:=ds:C1482.dfd_Line.new()
End if 

$partRowLine.name:=$namePrefix+" - Part Row"
$partRowLine.calculs:=New object:C1471("rules"; New collection:C1472())
$partRowLine.variableItems:=New object:C1471("tags"; New collection:C1472())
$partRowLine.moreData:=New object:C1471()
$partRowLine.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$partRowLine.objectsForm.objects
$nextOrder:=1

For each ($cell; $partTableCols)
	$lineItem:=New object:C1471("name"; "part_vbg_"+$cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; $cell.left; "width"; $cell.width; "height"; 14; "fill"; "white"; "stroke"; "#b8b8b8"; "strokeWidth"; 1; "visibility"; $cell.colVis))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	$lineItem:=New object:C1471("name"; "part_hbg_"+$cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "rectangle"; "_origineType"; "rectangle"; "top"; 0; "left"; $cell.left; "width"; $cell.width; "height"; 14; "fill"; "#f0f0f0"; "stroke"; "#b8b8b8"; "strokeWidth"; 1; "visibility"; $cell.hdrVis))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
	$lineItem:=New object:C1471("name"; "part_v_"+$cell.name; "order"; $nextOrder; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 2; "left"; $cell.textLeft; "width"; $cell.textWidth; "height"; 10; "text"; $cell.src; "fontFamily"; "Helvetica"; "fontSize"; 7; "stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"; "visibility"; $cell.colVis))
	$objects.push($lineItem)
	$nextOrder:=$nextOrder+1
End for each 

$res:=$partRowLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Template assembly
// -------------------------------
$template:=ds:C1482.dfd_Template.query("name = :1"; $templateName).first()
If ($template=Null:C1517)
	$template:=ds:C1482.dfd_Template.new()
End if 

$template.name:=$templateName
$template.calculs:=New object:C1471("rules"; New collection:C1472())
$template.moreData:=New object:C1471(\
"settings"; New object:C1471(\
"format"; "A4"; \
"orientation"; "landscape"; \
"margin_top"; $pageMargin; \
"margin_bottom"; $pageMargin; \
"margin_left"; $pageMargin; \
"margin_right"; $pageMargin; \
"printPreview"; False:C215\
)\
)
$template.hierarchy:=New object:C1471("lines"; New collection:C1472())

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $headerLine.UUID; "typology"; "EPP")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $infoLine.UUID; "typology"; "ETP")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $columnHeaderLine.UUID; "typology"; "LS")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $stepLine.UUID; \
"typology"; "CR"; \
"properties"; New collection:C1472(New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"))\
)
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $partRowLine.UUID; \
"typology"; "CRS"; \
"properties"; New collection:C1472(\
New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"); \
New object:C1471("name"; "sub collection"; "kind"; "subcollectionSource"; "value"; "partRows"); \
New object:C1471("name"; "group with main"; "kind"; "groupWithMain"; "value"; "true")\
)\
)
$template.hierarchy.lines.push($lineRef)

$res:=$template.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

ALERT:C41(String:C10($okCount)+" records/groups created or updated.\rTemplate: "+$templateName)
