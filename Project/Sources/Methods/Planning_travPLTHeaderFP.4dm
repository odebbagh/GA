//%attributes = {}
// PLT - Header First Page: logos, lot info, barcodes, column header.
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $colHdrLine : cs:C1710.dfd_LineEntity
var $hdrObj : Object
var $hdrOrder : Integer
var $lineItem : Object
var $merged : Collection
var $name : Text
var $objects : Collection
var $order : Integer
var $tags : Collection

$line:=ds:C1482.dfd_Line.query("name = :1"; "PLT - Header First Page").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="PLT - Header First Page"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects
$tags:=New collection:C1472()
$order:=1

$lineItem:=New object:C1471("name"; "picture_ga"; "order"; $order; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 10; "left"; 10; "width"; 120; "height"; 60; "pictureFormat"; "scaled"; "picture"; "/RESOURCES/image/modeles/GA_logo.png"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "picture_itar"; "order"; $order; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 10; "left"; 300; "width"; 120; "height"; 60; "pictureFormat"; "scaled"; "picture"; "/RESOURCES/image/modeles/itar.png"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "picture_esd"; "order"; $order; "properties"; New object:C1471("type"; "picture"; "_origineType"; "picture"; "top"; 15; "left"; 520; "width"; 45; "height"; 50; "pictureFormat"; "scaled"; "picture"; "/RESOURCES/image/modeles/esd.png"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "line_top"; "order"; $order; "properties"; New object:C1471("type"; "line"; "_origineType"; "line"; "top"; 80; "left"; 0; "width"; 574; "height"; 0))
$objects.push($lineItem)
$order:=$order+1

// Lot info block (full width).
$lineItem:=New object:C1471("name"; "lbl_customer"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 88; "left"; 0; "width"; 55; "height"; 10; "text"; "Customer:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_customer"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 88; "left"; 55; "width"; 150; "height"; 10; "text"; "##customerName##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "customerName"; "objects"; New collection:C1472("val_customer")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_po"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 88; "left"; 215; "width"; 35; "height"; 10; "text"; "P.O #:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_po"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 88; "left"; 250; "width"; 60; "height"; 10; "text"; "##PONumber##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "PONumber"; "objects"; New collection:C1472("val_po")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_dateIn"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 88; "left"; 320; "width"; 45; "height"; 10; "text"; "Date In:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_dateIn"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 88; "left"; 365; "width"; 80; "height"; 10; "text"; "##dateIn##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "dateIn"; "objects"; New collection:C1472("val_dateIn")))
$order:=$order+1

$lineItem:=New object:C1471("name"; "lbl_note"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 100; "left"; 0; "width"; 130; "height"; 10; "text"; "NOTE: Our Lot Traveler No:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_lotNum"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 100; "left"; 130; "width"; 60; "height"; 10; "text"; "##lotNumber##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_custLot"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 100; "left"; 195; "width"; 150; "height"; 10; "text"; "corresponds to Customer Lot No:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_custLot"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 100; "left"; 350; "width"; 120; "height"; 10; "text"; "##customerLotNumber##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "customerLotNumber"; "objects"; New collection:C1472("val_custLot")))
$order:=$order+1

$lineItem:=New object:C1471("name"; "lbl_process"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 112; "left"; 0; "width"; 45; "height"; 10; "text"; "Process:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_process"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 112; "left"; 45; "width"; 150; "height"; 10; "text"; "##process##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "process"; "objects"; New collection:C1472("val_process")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_device"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 112; "left"; 200; "width"; 40; "height"; 10; "text"; "Device:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_device"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 112; "left"; 240; "width"; 100; "height"; 10; "text"; "##devide##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_package"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 112; "left"; 350; "width"; 50; "height"; 10; "text"; "Package:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_package"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 112; "left"; 400; "width"; 80; "height"; 10; "text"; "##package##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "package"; "objects"; New collection:C1472("val_package")))
$order:=$order+1

$lineItem:=New object:C1471("name"; "lbl_custNum"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 124; "left"; 0; "width"; 60; "height"; 10; "text"; "Customer #:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_custNum"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 124; "left"; 60; "width"; 50; "height"; 10; "text"; "##customerNumber##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "customerNumber"; "objects"; New collection:C1472("val_custNum")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_custSpec"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 124; "left"; 120; "width"; 85; "height"; 10; "text"; "Customer Spec #:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_custSpec"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 124; "left"; 205; "width"; 120; "height"; 10; "text"; "##customerSpec##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "customerSpec"; "objects"; New collection:C1472("val_custSpec")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_dpas"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 124; "left"; 330; "width"; 65; "height"; 10; "text"; "DPAS Rating:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_dpas"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 124; "left"; 395; "width"; 50; "height"; 10; "text"; "##dpasRating##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "dpasRating"; "objects"; New collection:C1472("val_dpas")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_origCount"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 136; "left"; 0; "width"; 75; "height"; 10; "text"; "Original Count:"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_origCount"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 136; "left"; 75; "width"; 45; "height"; 10; "text"; "##originalCount##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "originalCount"; "objects"; New collection:C1472("val_origCount")))
$order:=$order+1

// Barcodes stacked vertically below lot info.
$lineItem:=New object:C1471("name"; "bc_lot"; "order"; $order; "properties"; New object:C1471("type"; "input"; "_origineType"; "dynPict"; "top"; 150; "left"; 0; "width"; 130; "height"; 24; "dataSource"; "##lotBarcode##"; "dataSourceTypeHint"; "picture"; "pictureFormat"; "scaled"; "borderStyle"; "none"; "fill"; "transparent"; "enterable"; False:C215; "focusable"; False:C215))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "lotBarcode"; "objects"; New collection:C1472("bc_lot")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_bc_lot"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 176; "left"; 0; "width"; 130; "height"; 10; "text"; "Lot Traveler No:"; "fontFamily"; "Helvetica"; "fontSize"; 7; "textAlign"; "center"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_bc_lot"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 186; "left"; 0; "width"; 130; "height"; 10; "text"; "##lotNumber##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"; "fontWeight"; "bold"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "lotNumber"; "objects"; New collection:C1472("val_bc_lot"; "val_lotNum")))
$order:=$order+1

$lineItem:=New object:C1471("name"; "bc_custLot"; "order"; $order; "properties"; New object:C1471("type"; "input"; "_origineType"; "dynPict"; "top"; 200; "left"; 0; "width"; 130; "height"; 24; "dataSource"; "##customerLotBarcode##"; "dataSourceTypeHint"; "picture"; "pictureFormat"; "scaled"; "borderStyle"; "none"; "fill"; "transparent"; "enterable"; False:C215; "focusable"; False:C215))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "customerLotBarcode"; "objects"; New collection:C1472("bc_custLot")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_bc_custLot"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 226; "left"; 0; "width"; 130; "height"; 10; "text"; "Customer Lot No:"; "fontFamily"; "Helvetica"; "fontSize"; 7; "textAlign"; "center"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_bc_custLot"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 236; "left"; 0; "width"; 130; "height"; 10; "text"; "##customerLotNumber##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"; "fontWeight"; "bold"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "customerLotNumber"; "objects"; New collection:C1472("val_bc_custLot"; "val_custLot")))
$order:=$order+1

$lineItem:=New object:C1471("name"; "bc_device"; "order"; $order; "properties"; New object:C1471("type"; "input"; "_origineType"; "dynPict"; "top"; 250; "left"; 0; "width"; 130; "height"; 24; "dataSource"; "##deviceBarcode##"; "dataSourceTypeHint"; "picture"; "pictureFormat"; "scaled"; "borderStyle"; "none"; "fill"; "transparent"; "enterable"; False:C215; "focusable"; False:C215))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "deviceBarcode"; "objects"; New collection:C1472("bc_device")))
$order:=$order+1
$lineItem:=New object:C1471("name"; "lbl_bc_device"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 276; "left"; 0; "width"; 130; "height"; 10; "text"; "Device:"; "fontFamily"; "Helvetica"; "fontSize"; 7; "textAlign"; "center"))
$objects.push($lineItem)
$order:=$order+1
$lineItem:=New object:C1471("name"; "val_bc_device"; "order"; $order; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 286; "left"; 0; "width"; 130; "height"; 10; "text"; "##devide##"; "fontFamily"; "Helvetica"; "fontSize"; 8; "textAlign"; "center"; "fontWeight"; "bold"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "devide"; "objects"; New collection:C1472("val_bc_device"; "val_device")))
$order:=$order+1

// Column header band below barcodes.
$colHdrLine:=Planning_travPLTColHdr(302)
For each ($hdrObj; $colHdrLine.objectsForm.objects)
	$hdrOrder:=$hdrObj.order+$order
	$name:=$hdrObj.name
	$lineItem:=New object:C1471("name"; $name; "order"; $hdrOrder; "properties"; OB Copy:C1225($hdrObj.properties))
	$objects.push($lineItem)
End for each 

$line.variableItems:=New object:C1471("tags"; $tags)

return $line
