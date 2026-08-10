//%attributes = {}

var $doc : cs:C1710.dfd_DocumentEntity
var $headerLine : cs:C1710.dfd_LineEntity
var $infoLine : cs:C1710.dfd_LineEntity
var $tableHeaderLine : cs:C1710.dfd_LineEntity
var $tableRowLine : cs:C1710.dfd_LineEntity
var $lineItem : Object
var $lineRef : Object
var $namePrefix : Text
var $okCount : Integer
var $res : Object
var $sampleData : Object
var $template : cs:C1710.dfd_TemplateEntity
var $typeLine : Object

$namePrefix:="ZZ Sample Lot Traveler"
$okCount:=0

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

$lineItem:=New object:C1471(\
	"name"; "rect_header"; \
	"order"; 1; \
	"properties"; New object:C1471(\
		"type"; "rectangle"; "_origineType"; "rectangle"; \
		"top"; 0; "left"; 0; "width"; 1000; "height"; 108; \
		"fill"; "white"; "stroke"; "#b8b8b8"; "strokeWidth"; 1\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "title"; \
	"order"; 2; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 8; "left"; 10; "width"; 600; "height"; 24; \
		"text"; "Lot Traveler"; \
		"fontFamily"; "Helvetica"; "fontSize"; 18; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "customerLabel"; \
	"order"; 3; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 38; "left"; 10; "width"; 110; "height"; 14; \
		"text"; "Customer:"; \
		"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "customerValue"; \
	"order"; 4; \
	"properties"; New object:C1471(\
		"type"; "input"; "_origineType"; "input"; \
		"top"; 38; "left"; 124; "width"; 520; "height"; 14; \
		"dataSource"; "##customer##"; "fontFamily"; "Helvetica"; "fontSize"; 10; \
		"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
		"enterable"; False:C215; "dataSourceTypeHint"; "text"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "lotLabel"; \
	"order"; 5; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 56; "left"; 10; "width"; 110; "height"; 14; \
		"text"; "Lot Traveler No:"; \
		"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "lotValue"; \
	"order"; 6; \
	"properties"; New object:C1471(\
		"type"; "input"; "_origineType"; "input"; \
		"top"; 56; "left"; 124; "width"; 250; "height"; 14; \
		"dataSource"; "##lotTravelerNo##"; "fontFamily"; "Helvetica"; "fontSize"; 10; \
		"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
		"enterable"; False:C215; "dataSourceTypeHint"; "text"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "dateInLabel"; \
	"order"; 7; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 74; "left"; 10; "width"; 50; "height"; 14; \
		"text"; "Date In:"; \
		"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "dateInValue"; \
	"order"; 8; \
	"properties"; New object:C1471(\
		"type"; "input"; "_origineType"; "input"; \
		"top"; 74; "left"; 66; "width"; 170; "height"; 14; \
		"dataSource"; "##dateIn##"; "fontFamily"; "Helvetica"; "fontSize"; 10; \
		"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
		"enterable"; False:C215; "dataSourceTypeHint"; "text"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "expectedOutLabel"; \
	"order"; 9; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 74; "left"; 250; "width"; 90; "height"; 14; \
		"text"; "Expected Out:"; \
		"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "expectedOutValue"; \
	"order"; 10; \
	"properties"; New object:C1471(\
		"type"; "input"; "_origineType"; "input"; \
		"top"; 74; "left"; 344; "width"; 170; "height"; 14; \
		"dataSource"; "##expectedOut##"; "fontFamily"; "Helvetica"; "fontSize"; 10; \
		"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
		"enterable"; False:C215; "dataSourceTypeHint"; "text"\
	)\
)
$headerLine.objectsForm.objects.push($lineItem)

$res:=$headerLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Info line
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

$lineItem:=New object:C1471(\
	"name"; "rect_info"; \
	"order"; 1; \
	"properties"; New object:C1471(\
		"type"; "rectangle"; "_origineType"; "rectangle"; \
		"top"; 0; "left"; 0; "width"; 1000; "height"; 72; \
		"fill"; "#f8f8f8"; "stroke"; "#b8b8b8"; "strokeWidth"; 1\
	)\
)
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "processLabel"; \
	"order"; 2; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 8; "left"; 10; "width"; 70; "height"; 14; \
		"text"; "Process:"; \
		"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "processValue"; \
	"order"; 3; \
	"properties"; New object:C1471(\
		"type"; "input"; "_origineType"; "input"; \
		"top"; 8; "left"; 84; "width"; 890; "height"; 14; \
		"dataSource"; "##processText##"; "fontFamily"; "Helvetica"; "fontSize"; 10; \
		"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
		"enterable"; False:C215; "dataSourceTypeHint"; "text"\
	)\
)
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "specLabel"; \
	"order"; 4; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 26; "left"; 10; "width"; 70; "height"; 14; \
		"text"; "Spec:"; \
		"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "specValue"; \
	"order"; 5; \
	"properties"; New object:C1471(\
		"type"; "input"; "_origineType"; "input"; \
		"top"; 26; "left"; 84; "width"; 890; "height"; 14; \
		"dataSource"; "##specText##"; "fontFamily"; "Helvetica"; "fontSize"; 10; \
		"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
		"enterable"; False:C215; "dataSourceTypeHint"; "text"\
	)\
)
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "originalCountLabel"; \
	"order"; 6; \
	"properties"; New object:C1471(\
		"type"; "text"; "_origineType"; "text"; \
		"top"; 44; "left"; 10; "width"; 100; "height"; 14; \
		"text"; "Original Count:"; \
		"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
		"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
	)\
)
$infoLine.objectsForm.objects.push($lineItem)

$lineItem:=New object:C1471(\
	"name"; "originalCountValue"; \
	"order"; 7; \
	"properties"; New object:C1471(\
		"type"; "input"; "_origineType"; "input"; \
		"top"; 44; "left"; 116; "width"; 100; "height"; 14; \
		"dataSource"; "##originalCount##"; "fontFamily"; "Helvetica"; "fontSize"; 10; \
		"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
		"enterable"; False:C215; "dataSourceTypeHint"; "text"\
	)\
)
$infoLine.objectsForm.objects.push($lineItem)

$res:=$infoLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Table header line
// -------------------------------
$tableHeaderLine:=ds:C1482.dfd_Line.query("name = :1"; $namePrefix+" - Table Header").first()
If ($tableHeaderLine=Null:C1517)
	$tableHeaderLine:=ds:C1482.dfd_Line.new()
End if 

$tableHeaderLine.name:=$namePrefix+" - Table Header"
$tableHeaderLine.calculs:=New object:C1471("rules"; New collection:C1472())
$tableHeaderLine.variableItems:=New object:C1471("tags"; New collection:C1472())
$tableHeaderLine.moreData:=New object:C1471()
$tableHeaderLine.objectsForm:=New object:C1471("objects"; New collection:C1472())

$lineItem:=New object:C1471(\
	"name"; "tableHeaderRect"; \
	"order"; 1; \
	"properties"; New object:C1471(\
		"type"; "rectangle"; "_origineType"; "rectangle"; \
		"top"; 0; "left"; 0; "width"; 1000; "height"; 26; \
		"fill"; "#ebeff5"; "stroke"; "#aeb4bb"; "strokeWidth"; 1\
	)\
)
$tableHeaderLine.objectsForm.objects.push($lineItem)

For each ($typeLine; New collection:C1472(\
	New object:C1471("name"; "part"; "left"; 8; "width"; 190; "text"; "Part Number"); \
	New object:C1471("name"; "lot"; "left"; 206; "width"; 180; "text"; "Lot Number"); \
	New object:C1471("name"; "wafer"; "left"; 394; "width"; 180; "text"; "Wafer Number"); \
	New object:C1471("name"; "qty"; "left"; 582; "width"; 130; "text"; "Quantity"); \
	New object:C1471("name"; "comments"; "left"; 720; "width"; 270; "text"; "Comments")\
))
	$lineItem:=New object:C1471(\
		"name"; "h_"+$typeLine.name; \
		"order"; $tableHeaderLine.objectsForm.objects.length+1; \
		"properties"; New object:C1471(\
			"type"; "text"; "_origineType"; "text"; \
			"top"; 6; "left"; $typeLine.left; "width"; $typeLine.width; "height"; 14; \
			"text"; $typeLine.text; \
			"fontFamily"; "Helvetica"; "fontSize"; 10; "fontWeight"; "bold"; \
			"stroke"; "black"; "textAlign"; "left"; "fill"; "transparent"\
		)\
	)
	$tableHeaderLine.objectsForm.objects.push($lineItem)
End for each 

$res:=$tableHeaderLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Repeated row line (CR / rows)
// -------------------------------
$tableRowLine:=ds:C1482.dfd_Line.query("name = :1"; $namePrefix+" - Table Row").first()
If ($tableRowLine=Null:C1517)
	$tableRowLine:=ds:C1482.dfd_Line.new()
End if 

$tableRowLine.name:=$namePrefix+" - Table Row"
$tableRowLine.calculs:=New object:C1471("rules"; New collection:C1472())
$tableRowLine.variableItems:=New object:C1471("tags"; New collection:C1472())
$tableRowLine.moreData:=New object:C1471()
$tableRowLine.objectsForm:=New object:C1471("objects"; New collection:C1472())

$lineItem:=New object:C1471(\
	"name"; "rowRect"; \
	"order"; 1; \
	"properties"; New object:C1471(\
		"type"; "rectangle"; "_origineType"; "rectangle"; \
		"top"; 0; "left"; 0; "width"; 1000; "height"; 22; \
		"fill"; "white"; "stroke"; "#d2d2d2"; "strokeWidth"; 1\
	)\
)
$tableRowLine.objectsForm.objects.push($lineItem)

For each ($typeLine; New collection:C1472(\
	New object:C1471("name"; "part"; "left"; 8; "width"; 190; "src"; "##partNumber##"); \
	New object:C1471("name"; "lot"; "left"; 206; "width"; 180; "src"; "##lotNumber##"); \
	New object:C1471("name"; "wafer"; "left"; 394; "width"; 180; "src"; "##waferNumber##"); \
	New object:C1471("name"; "qty"; "left"; 582; "width"; 130; "src"; "##quantity##"); \
	New object:C1471("name"; "comments"; "left"; 720; "width"; 270; "src"; "##comments##")\
))
	$lineItem:=New object:C1471(\
		"name"; "r_"+$typeLine.name; \
		"order"; $tableRowLine.objectsForm.objects.length+1; \
		"properties"; New object:C1471(\
			"type"; "input"; "_origineType"; "input"; \
			"top"; 4; "left"; $typeLine.left; "width"; $typeLine.width; "height"; 14; \
			"dataSource"; $typeLine.src; "fontFamily"; "Helvetica"; "fontSize"; 10; \
			"stroke"; "black"; "fill"; "transparent"; "borderStyle"; "none"; \
			"enterable"; False:C215; "dataSourceTypeHint"; "text"\
		)\
	)
	$tableRowLine.objectsForm.objects.push($lineItem)
End for each 

$res:=$tableRowLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Template assembly
// -------------------------------
$template:=ds:C1482.dfd_Template.query("name = :1"; $namePrefix+" Template").first()
If ($template=Null:C1517)
	$template:=ds:C1482.dfd_Template.new()
End if 

$template.name:=$namePrefix+" Template"
$template.calculs:=New object:C1471("rules"; New collection:C1472())
$template.moreData:=New object:C1471(\
	"settings"; New object:C1471(\
		"format"; "A4"; \
		"orientation"; "portrait"; \
		"printPreview"; True:C214\
	)\
)
$template.hierarchy:=New object:C1471("lines"; New collection:C1472())

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $headerLine.UUID; "typology"; "EPP")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $infoLine.UUID; "typology"; "LS")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $tableHeaderLine.UUID; "typology"; "LS")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471(\
	"kind"; "template_line"; \
	"UUID_entity"; $tableRowLine.UUID; \
	"typology"; "CR"; \
	"properties"; New collection:C1472(New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "rows"))\
)
$template.hierarchy.lines.push($lineRef)

$res:=$template.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

// -------------------------------
// Sample document instance
// -------------------------------
$sampleData:=New object:C1471(\
	"customer"; "Microchip Technology Inc."; \
	"lotTravelerNo"; "208617"; \
	"dateIn"; "1/20/2026"; \
	"expectedOut"; "1/27/2026"; \
	"processText"; "ASSY / CLASS B / Q  - Device: LX7720MFQ-Q"; \
	"specText"; "Spec: OC-68008 Rev: Q"; \
	"originalCount"; "443"; \
	"rows"; New collection:C1472(\
		New object:C1471("partNumber"; "LX7720_HV_V1R5"; "lotNumber"; "E71187"; "waferNumber"; "16-25"; "quantity"; "10"; "comments"; ""); \
		New object:C1471("partNumber"; "LX7720_LV_V1R2"; "lotNumber"; "U52622"; "waferNumber"; "3,10"; "quantity"; "2"; "comments"; ""); \
		New object:C1471("partNumber"; "P1"; "lotNumber"; ""; "waferNumber"; ""; "quantity"; ""; "comments"; "")\
	)\
)

$doc:=ds:C1482.dfd_Document.buildFromTemplate($namePrefix+" Document"; $template; $sampleData; "save"; New object:C1471())
If ($doc#Null:C1517)
	$okCount:=$okCount+1
End if 

ALERT:C41(String:C10($okCount)+" records/groups created or updated.\rTemplate: "+$template.name+"\rDocument: "+$doc.name)
