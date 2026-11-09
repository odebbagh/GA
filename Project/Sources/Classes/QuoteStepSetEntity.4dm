Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.code+" - "+This:C1470.name

	// a new set is active, last in the menu, with no step and no flow
local Function loadAfterCreation()
	This:C1470.active:=True:C214
	This:C1470.num:=Num:C11(ds:C1482.QuoteStepSet.all().max("num"))+1
	This:C1470.steps:=New object:C1471("UUIDs"; New collection:C1472)
	This:C1470.UUID_PriceFlow:="0"*32

local Function duplicateRecord()
	This:C1470.code:=This:C1470.code+"-COPY"
	This:C1470.num:=Num:C11(ds:C1482.QuoteStepSet.all().max("num"))+1

	// the Step UUIDs of the set, in order (an empty collection, never Null)
Function get stepUUIDs()->$UUIDs : Collection
	If (This:C1470.steps#Null:C1517) && (Value type:C1509(This:C1470.steps.UUIDs)=Is collection:K8:32)
		$UUIDs:=This:C1470.steps.UUIDs.copy()
	Else
		$UUIDs:=New collection:C1472
	End if

Function get stepCount()->$count : Integer
	$count:=This:C1470.stepUUIDs.length

	// a new list of steps (Step UUIDs, in order): steps is reassigned so ORDA sees the change
Function setSteps($UUIDs : Collection)
	This:C1470.steps:=New object:C1471("UUIDs"; $UUIDs.copy())

	// the rows of the panel's list: [{UUID; num; process; description; missing}] in the set's order;
	// a step deleted since is still listed (missing) so it can be removed
Function stepRows()->$rows : Collection
	var $UUID : Text
	var $step : cs:C1710.StepEntity
	var $num : Integer

	$rows:=New collection:C1472
	For each ($UUID; This:C1470.stepUUIDs)
		$num+=1
		$step:=ds:C1482.Step.get($UUID)
		If ($step=Null:C1517)
			$rows.push(New object:C1471("UUID"; $UUID; "num"; $num; "process"; ""; "description"; "(step deleted)"; "missing"; True:C214; "meta"; New object:C1471("stroke"; "#A0A0A0")))
		Else
			$rows.push(New object:C1471("UUID"; $UUID; "num"; $num; "process"; ($step.stepProcess=Null:C1517) ? "" : $step.stepProcess.name; \
				"description"; $step.description; "missing"; False:C215; "meta"; New object:C1471))
		End if
	End for each

Function get priceFlowText()->$text : Text
	If (This:C1470.priceFlow#Null:C1517)
		$text:=This:C1470.priceFlow.code+" - "+This:C1470.priceFlow.name
	End if
