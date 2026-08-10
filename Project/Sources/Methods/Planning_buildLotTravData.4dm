//%attributes = {}

#DECLARE($lot : 4D:C1709.Entity)->$data : Object

//Build Barcodes & labels

$lotBarcode:=_ga_generateBarCode($lot.moreData; String:C10($lot.number))
$jobBarcode:=_ga_generateBarCode($lot.job.moreData; String:C10($lot.job.jobNumber))

$lotNumber:=$lot.number
$jobNumber:=$lot.job.jobNumber
$customerName:=$lot.job.customer.name
$PONumber:=$lot.job.purchaseOrder.number
$dateIn:=$lot.dateIn
$altLotNumber:=$lot.altDevNumber
$dateCode:=$lot.dateCode

$steps:=New collection:C1472()

$dt2col:=New collection:C1472()

$dt2col.push(New object:C1471("col1"; "aaa"; "col2"; "bbb"))
$dt2col.push(New object:C1471("col1"; "ccc"; "col2"; "ddd"))
$dt2col.push(New object:C1471("col1"; "eee"; "col2"; "fff"))

$binningH:=New collection:C1472()

$binningH.push(New object:C1471("binningHeader"; "Binning"))

$dt2colH:=New collection:C1472()

$dt2colH.push(New object:C1471("col1"; "H1"; "col2"; "H2"; "dataTableLabel"; "Data Table"))

$bins:=New collection:C1472()

$bins.push(New object:C1471("leftBinTitle"; "Bin 1"; "leftBinValue"; 10; "centerBinTitle"; "Bin 2"; "centerBinValue"; 12; "rightBinTitle"; "Bin 3"; "rightBinValue"; 11))
$bins.push(New object:C1471("leftBinTitle"; "Bin 4"; "leftBinValue"; 1; "centerBinTitle"; "Bin 5"; "centerBinValue"; 121; "rightBinTitle"; "Bin 6"; "rightBinValue"; 18))
$bins.push(New object:C1471("leftBinTitle"; "Bin 7"; "leftBinValue"; 17; "centerBinTitle"; "Bin 8"; "centerBinValue"; 18; "rightBinTitle"; "Bin 9"; "rightBinValue"; 19))
$bins.push(New object:C1471("leftBinTitle"; "Bin 1"; "leftBinValue"; 10; "centerBinTitle"; "Bin 2"; "centerBinValue"; 12; "rightBinTitle"; "Bin 3"; "rightBinValue"; 11))
$bins.push(New object:C1471("leftBinTitle"; "Bin 4"; "leftBinValue"; 1; "centerBinTitle"; "Bin 5"; "centerBinValue"; 121; "rightBinTitle"; "Bin 6"; "rightBinValue"; 18))
$bins.push(New object:C1471("leftBinTitle"; "Bin 7"; "leftBinValue"; 17; "centerBinTitle"; "Bin 8"; "centerBinValue"; 18; "rightBinTitle"; "Bin 9"; "rightBinValue"; 19))

$steps.push(New object:C1471("order"; 1; "description"; "desc 1\n\n\n\n\n\n\n\n\n\n\n\r\n\romar debbagh"; "qtyIn"; 100; "dateIn"; "11/03/2023 13:00"; "rejects"; 0; "qtyOut"; 100; "dateOut"; "11/03/2023 15:06"; "operator"; 1587))
$steps.push(New object:C1471("order"; 2; "description"; "desc 2"; "qtyIn"; 45; "dateIn"; "11/06/2023 08:35"; "rejects"; 0; "qtyOut"; 45; "dateOut"; "11/06/2023 08:57"; "operator"; 1512; "binningH"; $binningH; "bins"; $bins; "dt2col"; $dt2col; "dt2colH"; $dt2colH))
$steps.push(New object:C1471("order"; 3; "description"; "desc 3"; "qtyIn"; 100; "dateIn"; "11/06/2023 14:15"; "rejects"; 0; "qtyOut"; 100; "dateOut"; "11/06/2023 20:15"; "operator"; 1587; "dt2col"; $dt2col; "dt2colH"; $dt2colH))
$steps.push(New object:C1471("order"; 1; "description"; "desc 1"; "qtyIn"; 100; "dateIn"; "11/03/2023 13:00"; "rejects"; 0; "qtyOut"; 100; "dateOut"; "11/03/2023 15:06"; "operator"; 1587))
$steps.push(New object:C1471("order"; 2; "description"; "desc 2"; "qtyIn"; 45; "dateIn"; "11/06/2023 08:35"; "rejects"; 0; "qtyOut"; 45; "dateOut"; "11/06/2023 08:57"; "operator"; 1512))
$steps.push(New object:C1471("order"; 3; "description"; "desc 3"; "qtyIn"; 100; "dateIn"; "11/06/2023 14:15"; "rejects"; 0; "qtyOut"; 100; "dateOut"; "11/06/2023 20:15"; "operator"; 1587))

For each ($step; $steps)
	$col:=Split string:C1554($step.description; "\n")
	$stepMaxHeight:=($col.length*10)+5
	If ($stepMaxHeight<85)
		$difference:=85-$stepMaxHeight
		$difference:=Int:C8($difference/10)+1
		$step.description:=$step.description+("\n"*$difference)
	End if 
End for each 

//[Lot]dateCode

$data:=New object:C1471(\
"lotNumber"; $lotNumber; \
"lotBarcode"; $lotBarcode; \
"customerName"; $customerName; \
"PONumber"; $PONumber; \
"customerLotNumber"; $altLotNumber; \
"dateCode"; $dateCode; \
"dateIn"; $dateIn; \
"jobNumber"; $jobNumber; \
"steps"; $steps; \
"jobBarcode"; $jobBarcode\
)

If (False:C215)
	//#DECLARE($lot : 4D.Entity)->$data : Object
	
	//var $barcodes : Object
	//var $customerLotNo : Text
	//var $dateInDisplay : Text
	//var $device : Text
	//var $esdLogoPic : Text
	//var $infoRow1 : Text
	//var $infoRow2 : Text
	//var $infoRow3 : Text
	//var $infoRow4 : Text
	//var $lotNumber : Text
	//var $packageType : Text
	//var $poNumber : Text
	//var $steps : cs.LotStepSelection
	//var $step : Object
	//var $stepsData : Collection
	//var $dateCode : Text
	
	//If ($lot=Null)
	//return Null
	//End if 
	
	//$lotNumber:=String($lot.lotNumber)
	//If ($lotNumber="")
	//$lotNumber:=String($lot.number)
	//End if 
	
	//$steps:=ds.LotStep.query("UUID_Lot = :1"; $lot.UUID).orderBy("order asc")
	//$stepsData:=New collection()
	
	//For each ($step; $steps)
	//$step:=ds.LotStep.get($step.UUID)
	//If ($step#Null)
	//$stepsData.push(Planning_travStepObj($step))
	//End if 
	//End for each 
	
	//$barcodes:=Planning_travBuildBarcodes($lot)
	
	//$dateInDisplay:=""
	//If ($lot.dateIn#!00-00-00!)
	//$dateInDisplay:=String($lot.dateIn; System date short)
	//End if 
	
	//$poNumber:=Planning_travSanitizeText(String($lot.poNumber))
	//$customerLotNo:=Planning_travSanitizeText(String($lot.customerLotNumber))
	//$device:=Planning_travSanitizeText(String($lot.device))
	//$packageType:=Planning_travSanitizeText(String($lot.packageType))
	//$dateCode:=Planning_travSanitizeText(String($lot.dateCode))
	
	//$infoRow1:="Customer: "+Planning_travSanitizeText(String($lot.customer))
	//If ($poNumber#"")
	//$infoRow1:=$infoRow1+"  P.O.#: "+$poNumber
	//End if 
	//If ($dateInDisplay#"")
	//$infoRow1:=$infoRow1+"  Date In: "+$dateInDisplay
	//End if 
	
	//$infoRow2:="NOTE: Our Lot Traveler No: "+String($lot.number)
	//If ($customerLotNo#"")
	//$infoRow2:=$infoRow2+" corresponds to Customer Lot No: "+$customerLotNo
	//End if 
	//$infoRow2:=Planning_travSanitizeText($infoRow2)
	
	//$infoRow3:=""
	//If (String($lot.process)#"")
	//$infoRow3:="Process: "+Planning_travSanitizeText(String($lot.process))
	//End if 
	//If ($device#"")
	//If ($infoRow3#"")
	//$infoRow3:=$infoRow3+"  Device: "+$device
	//Else 
	//$infoRow3:="Device: "+$device
	//End if 
	//End if 
	//If ($packageType#"")
	//If ($infoRow3#"")
	//$infoRow3:=$infoRow3+"  Package: "+$packageType
	//Else 
	//$infoRow3:="Package: "+$packageType
	//End if 
	//End if 
	//If ($dateCode#"")
	//If ($infoRow3#"")
	//$infoRow3:=$infoRow3+"  Date Code: "+$dateCode
	//Else 
	//$infoRow3:="Date Code: "+$dateCode
	//End if 
	//End if 
	//$infoRow3:=Planning_travSanitizeText($infoRow3)
	
	//$infoRow4:="Original Count: "+Planning_travSanitizeText(String($lot.original))
	
	//$esdLogoPic:=Planning_travLoadResPic("image/lotTraveller/esd_logo.png")
	
	//$data:=New object(\
		"lotNumber"; Planning_travSanitizeText($lotNumber); \
		"customer"; Planning_travSanitizeText(String($lot.customer)); \
		"lotTravelerNo"; Planning_travSanitizeText(String($lot.number)); \
		"dateIn"; Planning_travFmtDate($lot.dateIn); \
		"expectedOut"; Planning_travFmtDate($lot.commit); \
		"processText"; Planning_travSanitizeText(String($lot.process)); \
		"specText"; $device; \
		"originalCount"; Planning_travSanitizeText(String($lot.original)); \
		"infoRow1"; $infoRow1; \
		"infoRow2"; $infoRow2; \
		"infoRow3"; $infoRow3; \
		"infoRow4"; $infoRow4; \
		"esdLogoPic"; $esdLogoPic; \
		"jobBarcodePic"; $barcodes.jobBarcodePic; \
		"jobBarcodeLabel"; $barcodes.jobBarcodeLabel; \
		"travellerBarcodePic"; $barcodes.travellerBarcodePic; \
		"travellerBarcodeLabel"; $barcodes.travellerBarcodeLabel; \
		"steps"; $stepsData\
		)
	
End if 
