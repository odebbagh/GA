Class extends Entity

// ----------------------------------------------
// nameInWindowTitle
// ----------------------------------------------
local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=String(This.description)


Function get enabledPropertiesLabel()->$label : Text
	var $it : Object
	var $names : Collection
	
	$names:=New collection:C1472()
	If (This:C1470.stepProperties#Null:C1517)
		If (This:C1470.stepProperties.items#Null:C1517)
			For each ($it; This:C1470.stepProperties.items)
				If (Bool:C1537($it.enable))
					If (String:C10($it.name)#"")
						$names.push(String:C10($it.name))
					End if 
				End if 
			End for each 
		End if 
	End if 
	$label:=$names.join(", ")


Function get enabledSpecificationsLabel()->$label : Text
	// Control specifications only. GAF forms are Specification records too (isForm = True)
	// and are linked through the same StepSpecification table, but they are not specs.
	var $specLink : 4D:C1709.Entity
	var $names : Collection
	
	$names:=New collection:C1472()
	For each ($specLink; This:C1470.StepSpecifications)
		If ($specLink.specification#Null:C1517)
			If (Not:C34(Bool:C1537($specLink.specification.isForm))) && (String:C10($specLink.specification.spec)#"")
				$names.push(String:C10($specLink.specification.spec))
			End if 
		End if 
	End for each 
	$label:=$names.join(", ")
	
	
// ----------------------------------------------
// syncSpecifications
// Brings the two places a step keeps its specs in line with its StepSpecification links:
// - UUID_Specification, the primary spec (first spec by code, forms never qualify)
// - moreData.specificationControl, the list planning copies onto every new lot step, and
//   so what the traveller prints (panel_planning.createLotStepFromStepEntity)
// Without it, adding or removing a spec in Housekeeping changed the links but not the
// traveller. Items still linked keep their position and their enable flag; new ones are
// appended; each item takes the spec's current revision. Lot steps already created keep
// the copy they were given. The entity is modified but not saved: the caller saves it.
// local: it must change the caller's entity (the panel's current item), not a server copy.
// ----------------------------------------------
local Function syncSpecifications()
	var $link : 4D:C1709.Entity
	var $spec : 4D:C1709.Entity
	var $item : Object
	var $byUUID : Object
	var $order : Collection
	var $old : Collection
	var $items : Collection
	var $uuid : Text
	
	$byUUID:=New object:C1471
	$order:=New collection:C1472
	For each ($link; This:C1470.StepSpecifications.orderBy("specification.spec asc"))
		$spec:=$link.specification
		If ($spec#Null:C1517)
			If (Not:C34(Bool:C1537($spec.isForm))) && ($byUUID[$spec.UUID]=Null:C1517)
				$byUUID[$spec.UUID]:=$spec
				$order.push($spec.UUID)
			End if 
		End if 
	End for each 
	
	// primary spec
	If ($order.length>0)
		This:C1470.UUID_Specification:=$order[0]
	Else 
		This:C1470.UUID_Specification:=16*"00"
	End if 
	
	// traveller list: existing order first, then the newly linked specs
	$old:=New collection:C1472
	If (This:C1470.moreData#Null:C1517)
		If (This:C1470.moreData.specificationControl#Null:C1517)
			If (This:C1470.moreData.specificationControl.items#Null:C1517)
				$old:=This:C1470.moreData.specificationControl.items
			End if 
		End if 
	End if 
	
	$items:=New collection:C1472
	For each ($item; $old)
		$uuid:=String:C10($item.UUID_Specification)
		If ($byUUID[$uuid]#Null:C1517)
			$items.push(This:C1470._specificationControlItem($byUUID[$uuid]; ($item.enable=Null:C1517) || Bool:C1537($item.enable)))
			OB REMOVE:C1226($byUUID; $uuid)
		End if 
	End for each 
	For each ($uuid; $order)
		If ($byUUID[$uuid]#Null:C1517)
			$items.push(This:C1470._specificationControlItem($byUUID[$uuid]; True:C214))
		End if 
	End for each 
	
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	This:C1470.moreData.specificationControl:=New object:C1471("items"; $items)
	
	
// same item shape as _import_steps builds
local Function _specificationControlItem($spec : 4D:C1709.Entity; $enable : Boolean)->$item : Object
	var $fullTitle : Text
	
	$fullTitle:=String:C10($spec.title)
	If ($fullTitle="")
		$fullTitle:=String:C10($spec.spec)
	End if 
	$item:=New object:C1471(\
		"enable"; $enable; \
		"UUID_Specification"; $spec.UUID; \
		"fullTitle"; $fullTitle; \
		"spec"; String:C10($spec.spec); \
		"revision"; String:C10($spec.revision)\
		)
