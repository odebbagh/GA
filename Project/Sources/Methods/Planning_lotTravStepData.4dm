//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$stepData : Object

var $binning : Object
var $dataTable : Object
var $dateTimeIn : Text
var $dateTimeOut : Text
var $description : Text
var $operator : Text
var $orderDisplay : Text
var $rejects : Text
var $stepDef : cs:C1710.StepEntity
var $tools : Object

$orderDisplay:=String:C10($step.order; "##0.00")
$description:=String:C10($step.description)

If ($description="") && (String:C10($step.UUID_Step)#"")
	$stepDef:=ds:C1482.Step.get($step.UUID_Step)
	If ($stepDef#Null:C1517)
		$description:=String:C10($stepDef.description)
		If ($description="")
			$description:=String:C10($stepDef.operationCode)
		End if 
		If ($description="")
			$description:=String:C10($stepDef.areas)
		End if 
	End if 
End if 

If ($description="")
	$description:=String:C10($step.area)
End if 

If ($description="")
	$description:=String:C10($step.alert)
End if 

$description:=Planning_travSanitizeText($description)
$orderDisplay:=Planning_travSanitizeText($orderDisplay)

$rejects:=Planning_travSanitizeText(String:C10($step.rejects))
If ($rejects="0") && ($step.qtyRejects#0)
	$rejects:=Planning_travSanitizeText(String:C10($step.qtyRejects))
End if 

$dateTimeIn:=Planning_travFmtDateTime($step.dateIn; $step.timeIn)
$dateTimeOut:=Planning_travFmtDateTime($step.dateOut; $step.timeOut)

$operator:=String:C10($step.outOperator)
If ($operator="")
	$operator:=String:C10($step.inOperator)
End if 
$operator:=Planning_travSanitizeText($operator)

$stepData:=New object:C1471(\
"order"; $orderDisplay; \
"description"; $description; \
"qtyIn"; Planning_travSanitizeText(String:C10($step.qtyIn)); \
"dateIn"; $dateTimeIn; \
"rejects"; $rejects; \
"qtyOut"; Planning_travSanitizeText(String:C10($step.qtyOut)); \
"dateOut"; $dateTimeOut; \
"operator"; $operator; \
"dtColCount"; 0; \
"qaSignoff"; (((String:C10($step.approvedBy)#"") && Not:C34(Bool:C1537($step.qaRejected))) ? "visible" : "hidden")\
)

$dataTable:=Planning_lotTravDataTable($step)
If ($dataTable.colCount>0)
	$stepData.dtColCount:=$dataTable.colCount
	$stepData[$dataTable.rowsKey]:=$dataTable.rows
	$stepData[$dataTable.headerKey]:=$dataTable.header
End if 

$binning:=Planning_lotTravBinning($step)
If ($binning.hasBinning)
	$stepData.binningH:=$binning.binningH
	$stepData.bins:=$binning.bins
End if 

$tools:=Planning_lotTravTools($step)
If ($tools.hasTools)
	$stepData.hasTools:=True:C214
	$stepData.toolsBlock:=$tools.toolsBlock
End if 
