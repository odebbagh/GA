cs:C1710.panel_stepTemplate.me.formMethod()

If (Form:C1466.situation.mode="add")
	If (Form:C1466.current_item.templateNumber=0)
		C_COLLECTION:C1488($numbers)
		C_LONGINT:C283($next)
		
		$numbers:=ds:C1482.StepTemplate.all().orderBy("templateNumber asc").extract("templateNumber")
		$numbers:=$numbers.orderBy("asc")
		$next:=1
		For each ($num; $numbers)
			$next:=$num+1
		End for each 
		Form:C1466.current_item.templateNumber:=$next
	End if 
End if 