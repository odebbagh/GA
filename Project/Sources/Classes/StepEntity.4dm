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
	var $specLink : 4D:C1709.Entity
	var $names : Collection
	
	$names:=New collection:C1472()
	For each ($specLink; This:C1470.StepSpecifications)
		If ($specLink.specification#Null:C1517)
			If (String:C10($specLink.specification.spec)#"")
				$names.push(String:C10($specLink.specification.spec))
			End if 
		End if 
	End for each 
	$label:=$names.join(", ")

