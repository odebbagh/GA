$menu:=Create menu:C408

For ($duration; 1; 8)
	$label:=String:C10($duration*15; "### mn")
	APPEND MENU ITEM:C411($menu; $label)
	SET MENU ITEM PARAMETER:C1004($menu; -1; String:C10($duration*15*60))
	If (Form:C1466.period.element.min=($duration*15*60))
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for 
$ref:=Dynamic pop up menu:C1006($menu)

RELEASE MENU:C978($menu)

$Attribute:=Form:C1466.period.name
Case of 
	: ($ref="")
	Else 
		$minDuration:=Num:C11($ref)
		Form:C1466.schedule[$Attribute].min:=$minDuration
		sfw_subpanel_schedule_draw($Attribute)
		CALL SUBFORM CONTAINER:C1086(-98001)
		
End case 
