Form:C1466.sfw.searchBox()
If (Form:C1466.subset#Null:C1517)
	$formula:=Formula from string:C1601(Form:C1466.subset)
	$entitySelection:=$formula.call()
	Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.and($entitySelection)
End if 