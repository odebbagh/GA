//%attributes = {}

If (Form:C1466.current_lb_item#Null:C1517)
	C_COLLECTION:C1488($numbers)
	C_LONGINT:C283($next)
	$numbers:=ds:C1482.StepTemplate.all().orderBy("templateNumber asc").extract("templateNumber")
	$numbers:=$numbers.orderBy("asc")
	$next:=1
	For each ($num; $numbers)
		$next:=$num+1
	End for each 
	
	// Get current template
	var $source : cs:C1710.StepTemplateEntity
	$source:=Form:C1466.current_lb_item
	
	// Create new template
	var $new : cs:C1710.StepTemplateEntity
	$new:=ds:C1482.StepTemplate.new()
	
	// Copy fields
	$new.areas:=$source.areas
	$new.binning:=$source.binning
	$new.comment1:=$source.comment1
	$new.comment2:=$source.comment2
	$new.largeLayout_UUID:=$source.largeLayout_UUID
	$new.smallLayout_UUID:=$source.smallLayout_UUID
	$new.name:=$source.name+" (Copy)"
	$new.status:=$source.status
	$new.UUID_Division:=$source.UUID_Division
	$new.UUID_Operation:=$source.UUID_Operation
	$new.templateNumber:=$next
	
	// Save new template first
	$new.save()
	
	// Duplicate Steps
	var $steps : cs:C1710.StepSelection
	$steps:=$source.steps
	
	For each ($step; $steps)
		
		var $newStep : cs:C1710.StepEntity
		$newStep:=ds:C1482.Step.new()
		
		// Copy ALL needed fields
		$newStep.description:=$step.description
		$newStep.alert:=$step.alert
		$newStep.specification:=$step.specification
		$newStep.operationCode:=$step.operationCode
		$newStep.areas:=$step.areas
		$newStep.moreData:=$step.moreData
		
		// Link to new template
		$newStep.UUID_StepTemplate:=$new.UUID
		
		// Save
		$newStep.save()
		
	End for each 
	
	Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.copy().add($new)
	Form:C1466.sfw.lb_items_sort()
	$indexInEntitySelection:=$new.indexOf(Form:C1466.sfw.lb_items)
	Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items
	LISTBOX SELECT ROW:C912(*; "lb_items"; $indexInEntitySelection+1; lk replace selection:K53:1)
	Form:C1466.current_item:=Form:C1466.sfw.lb_items[$indexInEntitySelection]
	Form:C1466.situation.mode:="Modify"  //when we save a new item, we continue with the modify mode
	Form:C1466.sfw.lb_items_selectionChange()
Else 
	ALERT:C41("Select a Steptemplate to Duplicate")
End if 


