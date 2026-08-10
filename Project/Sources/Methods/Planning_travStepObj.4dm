//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$stepData : Object

var $qtyIn; $qtyOut; $rejects; $dateTimeIn; $dateTimeOut : Text
var $toolsText; $hp1; $lp1; $waferThickness; $glassivated; $probed; $inked; $silicon; $others : Text
var $description; $orderDisplay; $outOperator; $spec : Text
var $dtList : Object
var $hasPartTable : Boolean
var $partColCount : Integer
var $partRows : Collection
var $partHdr1; $partHdr2; $partHdr3; $partHdr4; $partHdr5 : Text
var $visibleCol1; $visibleCol2; $visibleCol3; $visibleCol4; $visibleCol5 : Boolean
var $stepDef : cs:C1710.StepEntity
var $tool : Object
var $toolParts : Collection
var $toolDate : Text

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

$spec:=Planning_travGetSpec($step)
If ($spec#"")
	If ($description#"")
		$description:=$description+" / Spec: "+$spec
	Else 
		$description:="Spec: "+$spec
	End if 
End if 

$description:=Planning_travSanitizeText($description)
$orderDisplay:=Planning_travSanitizeText($orderDisplay)

$qtyIn:=Planning_travSanitizeText(String:C10($step.qtyIn))
$qtyOut:=Planning_travSanitizeText(String:C10($step.qtyOut))
$rejects:=Planning_travSanitizeText(String:C10($step.rejects))
If ($rejects="0") && ($step.qtyRejects#0)
	$rejects:=Planning_travSanitizeText(String:C10($step.qtyRejects))
End if 

$dateTimeIn:=Planning_travFmtDateTime($step.dateIn; $step.timeIn)
$dateTimeOut:=Planning_travFmtDateTime($step.dateOut; $step.timeOut)
$dateTimeIn:=Planning_travSanitizeText($dateTimeIn)
$dateTimeOut:=Planning_travSanitizeText($dateTimeOut)

$outOperator:=String:C10($step.outOperator)
If ($outOperator="")
	$outOperator:=String:C10($step.inOperator)
End if 
$outOperator:=Planning_travSanitizeText($outOperator)

$toolParts:=New collection:C1472()
If ($step.tools#Null:C1517) && ($step.tools.items#Null:C1517)
	For each ($tool; $step.tools.items)
		If (String:C10($tool.toolName)#"")
			$toolDate:=Planning_travFmtDate($tool.toolDate)
			If ($toolDate="")
				$toolParts.push(String:C10($tool.toolName))
			Else 
				$toolParts.push(String:C10($tool.toolName)+" *"+$toolDate)
			End if 
		End if 
	End for each 
End if 
$toolsText:=Planning_travSanitizeText($toolParts.join("  "))

$hp1:=Planning_travGetParam($step; "Hp-1")
$lp1:=Planning_travGetParam($step; "LP-1")
$waferThickness:=Planning_travGetParam($step; "Wafer Thickness")
$glassivated:=Planning_travGetParam($step; "Glassivated")
$probed:=Planning_travGetParam($step; "Probed")
$inked:=Planning_travGetParam($step; "Inked")
$silicon:=Planning_travGetParam($step; "Silicon")
$others:=Planning_travGetParam($step; "Others")

If ($hp1="N/A")
	$hp1:=""
End if 
If ($lp1="N/A")
	$lp1:=""
End if 
If ($waferThickness="N/A")
	$waferThickness:=""
End if 
If ($glassivated="N/A")
	$glassivated:=""
End if 
If ($probed="N/A")
	$probed:=""
End if 
If ($inked="N/A")
	$inked:=""
End if 
If ($silicon="N/A")
	$silicon:=""
End if 
If ($others="N/A")
	$others:=""
End if 

$hp1:=Planning_travSanitizeText($hp1)
$lp1:=Planning_travSanitizeText($lp1)
$waferThickness:=Planning_travSanitizeText($waferThickness)
$glassivated:=Planning_travSanitizeText($glassivated)
$probed:=Planning_travSanitizeText($probed)
$inked:=Planning_travSanitizeText($inked)
$silicon:=Planning_travSanitizeText($silicon)
$others:=Planning_travSanitizeText($others)

// Data table — same structure as panel_punch_in.loadDataTable / buildDataTableList
$hasPartTable:=False:C215
$partColCount:=0
$partRows:=New collection:C1472()
$partBlockHeight:=0
$partSideTop:=88  // sync with __seed_planLotTraveller $stepH
$partSideBottom:=88
$partTableLeft:=Round:C94(318*(812/1000); 0)
$partHdr1:=""
$partHdr2:=""
$partHdr3:=""
$partHdr4:=""
$partHdr5:=""
$visibleCol1:=False:C215
$visibleCol2:=False:C215
$visibleCol3:=False:C215
$visibleCol4:=False:C215
$visibleCol5:=False:C215

$dtList:=$step.buildDataTableList(True:C214)
If ($dtList.hasTable)
	$hasPartTable:=True:C214
	$partColCount:=$dtList.colCount
	$partHdr1:=Planning_travSanitizeText(String:C10($dtList.hdr1))
	$partHdr2:=Planning_travSanitizeText(String:C10($dtList.hdr2))
	$partHdr3:=Planning_travSanitizeText(String:C10($dtList.hdr3))
	$partHdr4:=Planning_travSanitizeText(String:C10($dtList.hdr4))
	$partHdr5:=Planning_travSanitizeText(String:C10($dtList.hdr5))
	$visibleCol1:=Bool:C1537($dtList.visibleCol1)
	$visibleCol2:=Bool:C1537($dtList.visibleCol2)
	$visibleCol3:=Bool:C1537($dtList.visibleCol3)
	$visibleCol4:=Bool:C1537($dtList.visibleCol4)
	$visibleCol5:=Bool:C1537($dtList.visibleCol5)
	// Header row + data rows — stacked via CRS partRows in the PDF template
	$partRows:=$dtList.rows
	$partBlockHeight:=$partRows.length*14
	$partSideTop:=88
	$partSideBottom:=$partSideTop+$partBlockHeight
	$partTableLeft:=Round:C94(318*(812/1000); 0)
End if 

$stepData:=New object:C1471(\
"stepOrder"; $orderDisplay; \
"stepDescription"; $description; \
"qtyIn"; $qtyIn; \
"dateTimeIn"; $dateTimeIn; \
"rejects"; $rejects; \
"qtyOut"; $qtyOut; \
"dateTimeOut"; $dateTimeOut; \
"oper"; $outOperator; \
"toolsText"; $toolsText; \
"hp1"; $hp1; \
"lp1"; $lp1; \
"waferThickness"; $waferThickness; \
"glassivated"; $glassivated; \
"probed"; $probed; \
"inked"; $inked; \
"silicon"; $silicon; \
"others"; $others; \
"hasPartTable"; $hasPartTable; \
"partColCount"; $partColCount; \
"visibleCol1"; $visibleCol1; \
"visibleCol2"; $visibleCol2; \
"visibleCol3"; $visibleCol3; \
"visibleCol4"; $visibleCol4; \
"visibleCol5"; $visibleCol5; \
"showCol1"; $visibleCol1; \
"showCol2"; $visibleCol2; \
"showCol3"; $visibleCol3; \
"showCol4"; $visibleCol4; \
"showCol5"; $visibleCol5; \
"partHdr1"; $partHdr1; \
"partHdr2"; $partHdr2; \
"partHdr3"; $partHdr3; \
"partHdr4"; $partHdr4; \
"partHdr5"; $partHdr5; \
"partBlockHeight"; $partBlockHeight; \
"partSideTop"; $partSideTop; \
"partSideBottom"; $partSideBottom; \
"partTableLeft"; $partTableLeft; \
"partRows"; $partRows\
)
