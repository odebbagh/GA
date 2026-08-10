

$formData:=New object:C1471("display"; New object:C1471)
If (Form:C1466.hostSource#Null:C1517)
	$formData.display.date:=Formula from string:C1601(Replace string:C233(Form:C1466.hostSource; "Form."; "Form.hostForm.")).call()
	$formData.display.datesToHighlight:=[{date: $formData.display.date; color: "red"; colorText: "white"}]
End if 
$refWindow:=Open form window:C675("sfw_calendar"; Pop up form window:K39:11; Form:C1466.hostCoordinates.left; Form:C1466.hostCoordinates.bottom)
DIALOG:C40("sfw_calendar"; $formData)
CLOSE WINDOW:C154($refWindow)
If (ok=1)
	$parts:=Split string:C1554(Replace string:C233(Form:C1466.hostSource; "Form."; "Form.hostForm."); ".")
	$lastAttribute:=$parts.pop()
	$sourcePart:=$parts.shift()
	$source:=Form:C1466
	For each ($part; $parts)
		$source:=$source[$part]
	End for each 
	$source[$lastAttribute]:=$formData.display.date
End if 