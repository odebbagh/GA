//%attributes = {}

/*
Method Name : _ga_exportAllSupplierRatings
Author : Medard / 4D PS
Date : Apr 22, 2026
Purpose : Exports the aggregated monthly rating data for every supplier
          in the current view (Form.sfw.lb_items) into a single Excel file.
          Each row is prefixed with the supplier name.
          Called via Supplier.entryDefinition() setItemListAction.
*/

var $supplier_es : cs:C1710.SupplierSelection
var $supplier_e : cs:C1710.SupplierEntity
var $allData : Collection:=New collection:C1472()
var $ratingData : Collection
var $row : Object
var $mapping : Collection

$supplier_es:=Form:C1466.sfw.lb_items

If ($supplier_es.length=0)
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	return 
End if 

// Open a 4D Progress bar (built-in component).
// 80 % of the bar is reserved for data aggregation, 20 % for VP rendering.
$progressId:=Progress New
Progress SET TITLE($progressId; "Exporting Supplier Ratings")

// --- Phase 1: aggregate rating data for every supplier in the view ---
$total:=$supplier_es.length
$step:=0
For each ($supplier_e; $supplier_es)
	$step:=$step+1
	Progress SET MESSAGE($progressId; "Processing: "+$supplier_e.name)
	Progress SET PROGRESS($progressId; ($step/$total)*0.8)
	
	$ratingData:=$supplier_e.buildRatingData()
	// Stamp each row with the supplier name so it is identifiable in the export
	For each ($row; $ratingData)
		$row.supplierName:=$supplier_e.name
	End for each 
	$allData:=$allData.concat($ratingData)
End for each 

If ($allData.length=0)
	Progress QUIT($progressId)
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No rating data found for the selected suppliers"))
	return 
End if 

$mapping:=New collection:C1472(\
New object:C1471("header"; "Supplier"; "field"; "supplierName"; "footerOperation"; ""); \
New object:C1471("header"; "Date"; "field"; "date"; "footerOperation"; ""); \
New object:C1471("header"; "Year"; "field"; "year"; "footerOperation"; ""); \
New object:C1471("header"; "Month"; "field"; "month"; "footerOperation"; ""); \
New object:C1471("header"; "Quarter"; "field"; "quarter"; "footerOperation"; ""); \
New object:C1471("header"; "Receiving Total Lots"; "field"; "receivingTotalLots"; "footerOperation"; "sum"); \
New object:C1471("header"; "Receiving without NMNs"; "field"; "receivingWithoutNMNs"; "footerOperation"; "sum"); \
New object:C1471("header"; "Receiving % LAR"; "field"; "receivingLAR"; "footerOperation"; ""); \
New object:C1471("header"; "Functional Total Lots"; "field"; "functionalTotalLots"; "footerOperation"; "sum"); \
New object:C1471("header"; "Functional Without NMNs"; "field"; "functionalWithoutNMNs"; "footerOperation"; "sum"); \
New object:C1471("header"; "Functional % LAR"; "field"; "functionalLAR"; "footerOperation"; ""); \
New object:C1471("header"; "Delivery Total Lots"; "field"; "deliveryTotalLots"; "footerOperation"; "sum"); \
New object:C1471("header"; "Delivery Minor Delay w/in 10 days"; "field"; "deliveryMinorDelay"; "footerOperation"; "sum"); \
New object:C1471("header"; "Delivery Major Delay over 10 days"; "field"; "deliveryMajorDelay"; "footerOperation"; "sum"); \
New object:C1471("header"; "Delivery % LAR"; "field"; "deliveryLAR"; "footerOperation"; ""); \
New object:C1471("header"; "Composite % Over-all Rating"; "field"; "compositeOverAllRating"; "footerOperation"; ""); \
New object:C1471("header"; "ISO Certified"; "field"; "ISOCertified"; "footerOperation"; "")\
)

$viewLabel:=Form:C1466.sfw.view.label
If ($viewLabel="main") | ($viewLabel="Main view")
	$title:="All Suppliers Rating"
	$fileName:="AllSuppliersRating"
Else 
	$title:=$viewLabel+" — Rating"
	$fileName:=Replace string:C233($viewLabel; " "; "")+"_Rating"
End if 

$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"Suppliers"
$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
$sheetName:="Supplier Ratings"

// --- Phase 2: render and write the Excel file via ViewPro (offscreen) ---
// VP Run offscreen area is atomic — the bar stays at 80% during rendering, then jumps to 100%
Progress SET MESSAGE($progressId; "Generating Excel file…")
Progress SET PROGRESS($progressId; 0.8)
$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $allData; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
$excelSheet:=VP Run offscreen area($offscreen)

Progress SET PROGRESS($progressId; 1)
Progress QUIT($progressId)
