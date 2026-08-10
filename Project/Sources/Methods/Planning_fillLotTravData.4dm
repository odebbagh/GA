//%attributes = {}
#DECLARE($lot : 4D:C1709.Entity)->$data : Object

var $col : Collection
var $customerName : Text
var $difference : Integer
var $job : cs:C1710.JobEntity
var $jobBarcode : Text
var $jobBarcodeData : Text
var $lotBarcode : Text
var $lotBarcodeData : Text
var $lotNumber : Text
var $parameters : Object
var $poLine : Object
var $poNumber : Text
var $step : cs:C1710.LotStepEntity
var $stepData : Object
var $stepMaxHeight : Integer
var $steps : cs:C1710.LotStepSelection
var $stepsData : Collection

If ($lot=Null:C1517)
	return Null:C1517
End if 

$lotNumber:=String:C10($lot.number)
$customerName:=""
$poNumber:=Planning_travSanitizeText(String:C10($lot.poNumber))

$job:=$lot.job
If ($job#Null:C1517)
	If ($job.customer#Null:C1517)
		$customerName:=Planning_travSanitizeText(String:C10($job.customer.name))
	End if 
	If ($poNumber="") && ($job.purchaseOrderLines#Null:C1517)
		$poLine:=$job.purchaseOrderLines.first()
		If ($poLine#Null:C1517) && ($poLine.purchaseOrder#Null:C1517)
			$poNumber:=Planning_travSanitizeText(String:C10($poLine.purchaseOrder.poNumber))
		End if 
	End if 
	$jobBarcode:=""
	If ($job.moreData#Null:C1517) && ($job.moreData.barcodeData#Null:C1517) && (String:C10($job.moreData.barcodeData)#"")
		$jobBarcodeData:=String:C10($job.moreData.barcodeData)
	Else 
		$jobBarcodeData:=String:C10($job.jobNumber)
	End if 
	If ($jobBarcodeData#"")
		$parameters:=New object:C1471("barcodeData"; $jobBarcodeData; "text"; "")
		$jobBarcode:=Planning_travBarcodeBase64($parameters; 120; 24)
	End if 
Else 
	$jobBarcode:=""
End if 

If ($customerName="")
	$customerName:=Planning_travSanitizeText(String:C10($lot.customer))
End if 

$lotBarcode:=""
If ($lot.moreData#Null:C1517) && ($lot.moreData.barcodeData#Null:C1517) && (String:C10($lot.moreData.barcodeData)#"")
	$lotBarcodeData:=String:C10($lot.moreData.barcodeData)
Else 
	$lotBarcodeData:=$lotNumber
End if 
If ($lotBarcodeData#"")
	$parameters:=New object:C1471("barcodeData"; $lotBarcodeData; "text"; "")
	$lotBarcode:=Planning_travBarcodeBase64($parameters; 120; 24)
End if 

$steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; $lot.UUID).orderBy("order asc")
$stepsData:=New collection:C1472()

For each ($step; $steps)
	$stepData:=Planning_lotTravStepData($step)
	
	// Keep minimum description height for LT - Step layout rules.
	$col:=Split string:C1554($stepData.description; "\n")
	$stepMaxHeight:=($col.length*10)+5
	If ($stepMaxHeight<85)
		$difference:=85-$stepMaxHeight
		$difference:=Int:C8($difference/10)+1
		$stepData.description:=$stepData.description+("\n"*$difference)
	End if 
	
	$stepsData.push($stepData)
End for each 

$data:=New object:C1471(\
"lotNumber"; Planning_travSanitizeText($lotNumber); \
"lotBarcode"; $lotBarcode; \
"customerName"; $customerName; \
"PONumber"; $poNumber; \
"customerLotNumber"; Planning_travSanitizeText(String:C10($lot.customerLotNumber)); \
"dateCode"; Planning_travSanitizeText(String:C10($lot.dateCode)); \
"dateIn"; Planning_travFmtDate($lot.dateIn); \
"jobNumber"; Planning_travSanitizeText(String:C10(Choose:C955($job#Null:C1517; $job.jobNumber; 0))); \
"jobBarcode"; $jobBarcode; \
"process"; Planning_travSanitizeText(String:C10($lot.process)); \
"devide"; Planning_travSanitizeText(String:C10($lot.device)); \
"package"; Planning_travSanitizeText(String:C10($lot.packageType)); \
"originalCount"; Planning_travSanitizeText(String:C10($lot.original)); \
"steps"; $stepsData\
)

If ($data.customerLotNumber="")
	$data.customerLotNumber:=Planning_travSanitizeText(String:C10($lot.altDevNumber))
End if 
