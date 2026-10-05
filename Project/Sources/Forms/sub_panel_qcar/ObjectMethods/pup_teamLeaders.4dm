
If (FORM Event:C1606.code=On Clicked:K2:4) && (sfw_checkIsInModification)
	OBJECT GET COORDINATES:C663(*; "pup_teamLeaders"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	$current:=String:C10(Form:C1466.correctiveActionReport.teamLeaders)
	If ($current="")
		$current:=String:C10(Form:C1466.correctiveActionReport.teamLearders)
	End if 
	$name:=_ga_pickStaffName($l; $b; $current)
	If (OK=1)
		Form:C1466.correctiveActionReport.teamLeaders:=$name
		OBJECT SET TITLE:C194(*; "pup_teamLeaders"; $name)
		CALL SUBFORM CONTAINER:C1086(-2000)
	End if 
End if 
