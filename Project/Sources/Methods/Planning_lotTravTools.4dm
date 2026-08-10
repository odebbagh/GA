//%attributes = {}
#DECLARE($step : 4D:C1709.Entity)->$result : Object

var $lines : Collection
var $tool : Object
var $toolDate : Text
var $toolText : Text

$result:=New object:C1471("hasTools"; False:C215; "toolsBlock"; "")

If ($step=Null:C1517) || ($step.tools=Null:C1517) || ($step.tools.items=Null:C1517)
	return $result
End if 

$lines:=New collection:C1472()
For each ($tool; $step.tools.items)
	If (String:C10($tool.toolName)#"")
		$toolDate:=Planning_travFmtDate($tool.toolDate)
		If ($toolDate="")
			$toolText:=Planning_travSanitizeText(String:C10($tool.toolName))
		Else 
			$toolText:=Planning_travSanitizeText(String:C10($tool.toolName)+" *"+$toolDate)
		End if 
		$lines.push($toolText)
	End if 
End for each 

If ($lines.length>0)
	$result.hasTools:=True:C214
	$result.toolsBlock:=Planning_travSanitizeText("Tools *Cal Due Date:\r"+$lines.join("\r"))
End if 
