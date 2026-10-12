//%attributes = {}
// _fix_stepProperties
// Lot steps planned before this fix (and imported ones) can carry a property only as "enable"
// (from the step definition), which Planning does not show: a step could be NSP, QSR... without
// any tick in Planning. This gives every such property its "enabled" value from "enable", as new
// steps now get when they are planned. Properties already ticked or unticked in Planning keep
// their value. A step open somewhere else (locked) is skipped and counted. Safe to rerun.
#DECLARE()->$result : Object
var $step : 4D:C1709.Entity
var $item : Object
var $missing : Boolean
	
$result:=New object:C1471("checked"; 0; "fixed"; 0; "locked"; 0)
For each ($step; ds:C1482.LotStep.all())
	$result.checked:=$result.checked+1
	$missing:=False:C215
	If ($step.properties#Null:C1517)
		If ($step.properties.items#Null:C1517)
			For each ($item; $step.properties.items) Until ($missing)
				$missing:=($item.enabled=Null:C1517)
			End for each 
		End if 
	End if 
	If ($missing)
		$step.properties:=cs:C1710.ga_serialization.me.normalizedProperties($step.properties)
		If ($step.save().success)
			$result.fixed:=$result.fixed+1
		Else 
			$result.locked:=$result.locked+1
		End if 
	End if 
End for each 
ALERT:C41(String:C10($result.checked)+" lot step(s) checked, "+String:C10($result.fixed)+" fixed, "+String:C10($result.locked)+" locked and skipped.")
