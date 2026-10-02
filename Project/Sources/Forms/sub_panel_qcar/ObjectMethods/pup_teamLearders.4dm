
If (FORM Event:C1606.code=On Clicked:K2:4) && (sfw_checkIsInModification)
	OBJECT GET COORDINATES:C663(*; "pup_teamLearders"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Current window:K27:6)
	$name:=_ga_pickStaffName($l; $b; String:C10(Form:C1466.correctiveActionReport.teamLearders))
	If (OK=1)
		Form:C1466.correctiveActionReport.teamLearders:=$name
		OBJECT SET TITLE:C194(*; "pup_teamLearders"; $name)
		CALL SUBFORM CONTAINER:C1086(-2000)
	End if 
End if 
