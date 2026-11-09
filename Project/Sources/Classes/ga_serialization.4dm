// ga_serialization
// The serial-number rules shared by Planning, Punch In / OUT and the merge, taken from the audit
// of the old database (3,016 serialized lots):
// - the SN table defaults to the lot's customer count; another number is allowed after a warning
//   (about 50 real lots serialize only part of their quantity);
// - only the steps marked SNA (all units) or SNF (fails only) carry a serial-number list, usually
//   one step per lot (the screening or test step);
// - on an SNA step, every unit entering is on the list: Qty In should equal the list (a warning
//   at punch-in, never a block, as 4% of real lots differ).
// The lot's own table (Lot.snTable) holds every unit with its overall result; a step's table
// (LotStep.snTable) holds the units that entered that step with their result there.
	
singleton Class constructor
	
Function hasProperty($lotStep : 4D:C1709.Entity; $propertyName : Text)->$enabled : Boolean
	// LotStep.properties is a copy of Step.stepProperties: items {name; enable} from the import,
	// and "enabled" once ticked or unticked in Planning (what the user sees there wins)
	var $item : Object
	
	$enabled:=False:C215
	If ($lotStep=Null:C1517)
		return 
	End if 
	If ($lotStep.properties=Null:C1517)
		return 
	End if 
	If ($lotStep.properties.items=Null:C1517)
		return 
	End if 
	For each ($item; $lotStep.properties.items)
		If (String:C10($item.name)=$propertyName)
			If ($item.enabled#Null:C1517)
				$enabled:=Bool:C1537($item.enabled)
			Else 
				$enabled:=Bool:C1537($item.enable)
			End if 
			return 
		End if 
	End for each 
	
Function normalizedProperties($properties : Object)->$result : Object
	// A step definition's properties carry "enable" (the import); Planning shows and edits
	// "enabled". A lot step gets both, "enabled" set from "enable" where it is missing, so what
	// Planning shows (Params, tick boxes) is what the rules use (NSP, QSR, SNA...).
	var $item : Object
	
	If ($properties=Null:C1517)
		return 
	End if 
	$result:=OB Copy:C1225($properties)
	If ($result.items=Null:C1517)
		return 
	End if 
	For each ($item; $result.items)
		If ($item.enabled=Null:C1517)
			$item.enabled:=Bool:C1537($item.enable)
		End if 
	End for each 
	
Function isSnStep($lotStep : 4D:C1709.Entity)->$isSnStep : Boolean
	// a step that records serial numbers: all units (SNA) or fails only (SNF)
	$isSnStep:=This:C1470.hasProperty($lotStep; "SNA") || This:C1470.hasProperty($lotStep; "SNF")
	
Function activeUnits($lot : 4D:C1709.Entity)->$units : Collection
	// the lot's units still in it: passed so far and not moved to a sublot
	var $unit : Object
	
	$units:=New collection:C1472
	If ($lot=Null:C1517)
		return 
	End if 
	If ($lot.snTable=Null:C1517)
		return 
	End if 
	If ($lot.snTable.items=Null:C1517)
		return 
	End if 
	For each ($unit; $lot.snTable.items)
		If (Bool:C1537($unit.pass)) && (Not:C34(Bool:C1537($unit.split_out)))
			$units.push($unit)
		End if 
	End for each 
	
Function stepUnitCount($lotStep : 4D:C1709.Entity)->$count : Integer
	// units on the step's list (they entered the step, whatever their result there)
	$count:=0
	If ($lotStep=Null:C1517)
		return 
	End if 
	If ($lotStep.snTable=Null:C1517)
		return 
	End if 
	If ($lotStep.snTable.items=Null:C1517)
		return 
	End if 
	$count:=$lotStep.snTable.items.length
	
Function syncStep($lot : 4D:C1709.Entity; $lotStep : 4D:C1709.Entity)->$changed : Boolean
	// Puts the right list on one step, without saving it:
	// - an SN step of a serialized lot keeps what it already recorded for the lot's units and
	//   gets the lot's active units it does not have yet;
	// - any other step has no list.
	var $items; $old : Collection
	var $unit : Object
	var $lotIds : Collection
	
	$old:=New collection:C1472
	If ($lotStep.snTable#Null:C1517)
		If ($lotStep.snTable.items#Null:C1517)
			$old:=$lotStep.snTable.items
		End if 
	End if 
	
	$items:=New collection:C1472
	If (This:C1470.isSnStep($lotStep)) && (Bool:C1537($lot.serialization))
		$lotIds:=New collection:C1472
		If ($lot.snTable#Null:C1517)
			If ($lot.snTable.items#Null:C1517)
				$lotIds:=$lot.snTable.items.extract("id")
			End if 
		End if 
		// what the step recorded, for units still in the lot's table
		For each ($unit; $old)
			If ($lotIds.indexOf($unit.id)#-1)
				$items.push($unit)
			End if 
		End for each 
		// the lot's active units the step does not have yet
		For each ($unit; This:C1470.activeUnits($lot))
			If ($items.query("id = :1"; $unit.id).length=0)
				$items.push(OB Copy:C1225($unit))
			End if 
		End for each 
		$items:=$items.orderBy("id asc")
	End if 
	
	$changed:=($items.extract("id").join(",")#$old.extract("id").join(","))
	If ($changed)
		$lotStep.snTable:=New object:C1471("items"; $items)
	End if 
	
Function syncAllSteps($lot : 4D:C1709.Entity)->$failed : Integer
	// syncStep on every step of the lot, saving the ones that changed; returns how many could not
	// be saved (record locked)
	var $lotStep : 4D:C1709.Entity
	
	$failed:=0
	For each ($lotStep; $lot.lotSteps)
		If (This:C1470.syncStep($lot; $lotStep))
			If (Not:C34($lotStep.save().success))
				$failed:=$failed+1
			End if 
		End if 
	End for each 
	
Function hasSnStep($lot : 4D:C1709.Entity)->$has : Boolean
	var $lotStep : 4D:C1709.Entity
	
	$has:=False:C215
	For each ($lotStep; $lot.lotSteps) Until ($has)
		$has:=This:C1470.isSnStep($lotStep)
	End for each 
	
