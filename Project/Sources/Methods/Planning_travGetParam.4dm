//%attributes = {}
#DECLARE($step : 4D:C1709.Entity; $searchKey : Text)->$value : Text

var $item : Object
var $key : Text

$value:="N/A"
$searchKey:=Lowercase:C13($searchKey)

If ($step.parametricMeasurements#Null:C1517) && ($step.parametricMeasurements.items#Null:C1517)
	For each ($item; $step.parametricMeasurements.items)
		$key:=Lowercase:C13(String:C10($item.key))
		If ($key=$searchKey) | (Position:C15($searchKey; $key; 1)>0)
			If (String:C10($item.value)#"")
				$value:=String:C10($item.value)
				return 
			End if 
		End if 
	End for each 
End if 

If ($step.properties#Null:C1517) && ($step.properties.items#Null:C1517)
	For each ($item; $step.properties.items)
		$key:=Lowercase:C13(String:C10($item.name))
		If ($key=$searchKey) | (Position:C15($searchKey; $key; 1)>0)
			If (String:C10($item.value)#"")
				$value:=String:C10($item.value)
				return 
			End if 
		End if 
	End for each 
End if 
