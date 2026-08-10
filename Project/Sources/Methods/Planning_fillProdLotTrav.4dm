//%attributes = {}
#DECLARE($lot : 4D:C1709.Entity)->$data : Object

var $custLotBcData : Text
var $customer : cs:C1710.CustomerEntity
var $customerName : Text
var $customerNumber : Text
var $customerSpec : Text
var $deviceBarcode : Text
var $job : cs:C1710.JobEntity
var $lotBarcode : Text
var $lotBarcodeData : Text
var $lotNumber : Text
var $parameters : Object
var $poLine : Object
var $poNumber : Text
var $step : cs:C1710.LotStepEntity
var $stepData : Object
var $steps : cs:C1710.LotStepSelection
var $stepsData : Collection

If ($lot=Null:C1517)
	return Null:C1517
End if 

$lotNumber:=String:C10($lot.number)
$customerName:=""
$customerNumber:=""
$customerSpec:=""
$poNumber:=Planning_travSanitizeText(String:C10($lot.poNumber))
$job:=$lot.job

If ($job#Null:C1517)
	If ($job.customer#Null:C1517)
		$customer:=$job.customer
		$customerName:=Planning_travSanitizeText(String:C10($customer.name))
		If (String:C10($customer.codeNumber)#"0")
			$customerNumber:=Planning_travSanitizeText(String:C10($customer.codeNumber))
		Else If (String:C10($customer.accountNumber)#"")
			$customerNumber:=Planning_travSanitizeText(String:C10($customer.accountNumber))
		Else If (String:C10($customer.accountNum)#"")
			$customerNumber:=Planning_travSanitizeText(String:C10($customer.accountNum))
		End if 
	End if 
	If ($poNumber="") && ($job.purchaseOrderLines#Null:C1517)
		$poLine:=$job.purchaseOrderLines.first()
		If ($poLine#Null:C1517) && ($poLine.purchaseOrder#Null:C1517)
			$poNumber:=Planning_travSanitizeText(String:C10($poLine.purchaseOrder.poNumber))
		End if 
	End if 
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

$deviceBarcode:=""
If (String:C10($lot.device)#"")
	$parameters:=New object:C1471("barcodeData"; String:C10($lot.device); "text"; "")
	$deviceBarcode:=Planning_travBarcodeBase64($parameters; 120; 24)
End if 

$steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; $lot.UUID).orderBy("order asc")
$stepsData:=New collection:C1472()

For each ($step; $steps)
	$stepData:=Planning_prodLotTravStep($step)
	
	If ($customerSpec="") && (String:C10($step.lotSpecs)#"")
		$customerSpec:=Planning_travSanitizeText(String:C10($step.lotSpecs))
	End if 
	
	$stepsData.push($stepData)
End for each 

$data:=New object:C1471(\
"lotNumber"; Planning_travSanitizeText($lotNumber); \
"lotBarcode"; $lotBarcode; \
"customerName"; $customerName; \
"customerNumber"; $customerNumber; \
"customerSpec"; $customerSpec; \
"PONumber"; $poNumber; \
"customerLotNumber"; Planning_travSanitizeText(String:C10($lot.customerLotNumber)); \
"customerLotBarcode"; ""; \
"deviceBarcode"; $deviceBarcode; \
"dateIn"; Planning_travFmtDate($lot.dateIn); \
"jobNumber"; Planning_travSanitizeText(String:C10(Choose:C955($job#Null:C1517; $job.jobNumber; 0))); \
"process"; Planning_travSanitizeText(String:C10($lot.process)); \
"devide"; Planning_travSanitizeText(String:C10($lot.device)); \
"package"; Planning_travSanitizeText(String:C10($lot.packageType)); \
"dpasRating"; Planning_travSanitizeText(String:C10($lot.prQualifier)); \
"originalCount"; Planning_travSanitizeText(String:C10($lot.original)); \
"steps"; $stepsData\
)

If ($data.customerLotNumber="")
	$data.customerLotNumber:=Planning_travSanitizeText(String:C10($lot.altDevNumber))
End if 

$custLotBcData:=$data.customerLotNumber
If ($custLotBcData#"")
	$parameters:=New object:C1471("barcodeData"; $custLotBcData; "text"; "")
	$data.customerLotBarcode:=Planning_travBarcodeBase64($parameters; 120; 24)
End if 

return $data
