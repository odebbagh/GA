//%attributes = {}
// LotHoldForm_holdLocation($lot) -> "Step 3 - Die Attach"
// Where the lot stands, for the "Lot on hold at" of a new NCMN (GAF-1014) and the
// "Location / Process" of a new ISSNF (GAF-1514): the step punched in and not out yet, else the
// next step to run, else the last step. Empty when the lot has no steps.
#DECLARE($lot : 4D:C1709.Entity)->$location : Text

var $step : 4D:C1709.Entity
var $steps : 4D:C1709.EntitySelection
var $stepDef : 4D:C1709.Entity
var $description : Text

$location:=""
If ($lot=Null:C1517)
	return
End if
$steps:=$lot.lotSteps
If ($steps=Null:C1517) || ($steps.length=0)
	return
End if

$step:=$steps.query("dateIn # :1 AND dateOut = :1"; !00-00-00!).orderBy("order asc").first()
If ($step=Null:C1517)
	$step:=$steps.query("dateOut = :1"; !00-00-00!).orderBy("order asc").first()
End if
If ($step=Null:C1517)
	$step:=$steps.orderBy("order desc").first()
End if

$description:=String:C10($step.description)
If ($description="") && ($step.UUID_Step#"")
	$stepDef:=ds:C1482.Step.get($step.UUID_Step)
	If ($stepDef#Null:C1517)
		$description:=String:C10($stepDef.description)
	End if
End if
If ($description="")
	$description:=String:C10($step.area)
End if

// one line: a step description can run over several
$description:=Replace string:C233(Replace string:C233($description; Char:C90(Carriage return:K15:38); " "); Char:C90(Line feed:K15:40); " ")

If ($step.order=Int:C8($step.order))
	$location:="Step "+String:C10($step.order)
Else
	$location:="Step "+String:C10($step.order; "##0.0#")
End if
If ($description#"")
	$location:=$location+" - "+$description
End if
