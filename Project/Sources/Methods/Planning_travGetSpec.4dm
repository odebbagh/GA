//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$specText : Text

var $item : Object
var $parts : Collection
var $revision : Text
var $spec : Text
var $specificationEntity : cs:C1710.SpecificationEntity

$specText:=""
$parts:=New collection:C1472()

If ($step.specificationControl#Null:C1517) && ($step.specificationControl.items#Null:C1517) && ($step.specificationControl.items.length>0)
	For each ($item; $step.specificationControl.items)
		$spec:=String:C10($item.spec)
		If ($spec#"")
			$revision:=String:C10($item.revision)
			If ($revision="") && ($item.UUID_Specification#Null:C1517)
				$specificationEntity:=ds:C1482.Specification.get($item.UUID_Specification)
				If ($specificationEntity#Null:C1517)
					$revision:=String:C10($specificationEntity.revision)
				End if 
			End if 
			If ($revision#"")
				$parts.push($spec+" ("+$revision+")")
			Else 
				$parts.push($spec)
			End if 
		End if 
	End for each 
	If ($parts.length>0)
		$specText:=$parts.join(", ")
	End if 
End if 
