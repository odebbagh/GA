//%attributes = {}
// _seed_quoteStepSets
// The five standard step sets of the quotes (QuoteStepSet, Administration > Standard step sets) until
// Golden Altos sends their steps: Standard commercial, Advanced, Class S, Military, Environmental,
// each with its usual price flow when that flow exists (_demo_priceListData creates them).
// A set whose code already exists is left as it is, unless it was filled with demo steps
// (moreData.demo): "With demo steps" ticks a few priced steps in it so "Price from the price
// list..." can be tried; "Empty" leaves the new sets without steps, to fill by hand.
// Run it again at will: nothing typed by hand is changed.

var $withDemo : Boolean
var $defs; $demoSteps; $UUIDs : Collection
var $def : Object
var $set : cs:C1710.QuoteStepSetEntity
var $flow : cs:C1710.PriceFlowEntity
var $step : cs:C1710.StepEntity
var $created; $filled; $num : Integer

$withDemo:=cs:C1710.sfw_dialog.me.confirm("Create the five standard step sets of the quotes?\r(the sets already there are kept)\r\rWith demo steps: a few priced steps in each, to try the quote lines."; "With demo steps"; "Empty")

$defs:=New collection:C1472(\
New object:C1471("code"; "STD"; "name"; "Standard commercial"; "flow"; "COM"; "count"; 4); \
New object:C1471("code"; "ADV"; "name"; "Advanced"; "flow"; "COM"; "count"; 6); \
New object:C1471("code"; "CLASSS"; "name"; "Class S"; "flow"; "CLASSS"; "count"; 8); \
New object:C1471("code"; "MIL"; "name"; "Military"; "flow"; "MIL"; "count"; 6); \
New object:C1471("code"; "ENV"; "name"; "Environmental"; "flow"; "ENV"; "count"; 5))

// demo steps: steps whose process has a price in the Master Price List, one per process
$demoSteps:=New collection:C1472
If ($withDemo)
	For each ($step; ds:C1482.Step.query("stepProcess.priceListItems.active = :1"; True:C214).orderBy("description asc"))
		If ($demoSteps.query("process = :1"; $step.UUID_StepProcess).length=0)
			$demoSteps.push(New object:C1471("UUID"; $step.UUID; "process"; $step.UUID_StepProcess))
		End if
	End for each
End if

For each ($def; $defs)
	$num+=1
	$set:=ds:C1482.QuoteStepSet.query("code = :1"; $def.code).first()
	If ($set=Null:C1517)
		$set:=ds:C1482.QuoteStepSet.new()
		$set.code:=$def.code
		$set.name:=$def.name
		$set.num:=$num
		$set.active:=True:C214
		$set.steps:=New object:C1471("UUIDs"; New collection:C1472)
		$flow:=ds:C1482.PriceFlow.query("code = :1"; $def.flow).first()
		$set.UUID_PriceFlow:=($flow=Null:C1517) ? "0"*32 : $flow.UUID
		$set.moreData:=New object:C1471("demo"; $withDemo)
		$created+=1
	End if
	If ($withDemo) && ($set.moreData#Null:C1517) && Bool:C1537($set.moreData.demo)
		// a different slice of the priced steps for each set
		$UUIDs:=$demoSteps.slice(($num-1)*2; (($num-1)*2)+$def.count).extract("UUID")
		$set.setSteps($UUIDs)
		$filled+=1
	End if
	$set.save()
End for each

cs:C1710.sfw_dialog.me.info(String:C10($created)+" step set(s) created, "+String:C10($filled)+" filled with demo steps"+\
	Choose:C955($withDemo && ($demoSteps.length=0); " (no priced step: run _demo_priceListData first)"; "")+".")
