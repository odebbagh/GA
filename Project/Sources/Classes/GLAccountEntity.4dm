Class extends Entity

	// Legacy [CHART_OF_AC]FullAccountName turned out to hold the account CODE, not a
	// name - it is identical to GLAC on all 404 rows, and the readable part lives in
	// Description. So neither column on its own is usable as a picker label, and this
	// builds the one people actually recognise: "1036-0 - INVENTORIES".
Function get label()->$label : Text
	var $description : Text
	$label:=String:C10(This:C1470.glac)
	$description:=String:C10(This:C1470.description)
	If ($description#"")
		$label:=($label="") ? $description : $label+" - "+$description
	End if

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.label
