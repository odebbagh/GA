singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary to refresh
		This:C1470.loadLocation()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadLotSteps()
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadLotHolds()
			: (FORM Get current page:C276(*)=4)
				This:C1470.loadLotSerialization()
			: (FORM Get current page:C276(*)=5)
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	
	This:C1470.updatePanelTabLabels()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Case of 
		: (FORM Get current page:C276(*)=1)
		: (FORM Get current page:C276(*)=2)
			If (Form:C1466.stepRow#Null:C1517)
				This:C1470.showDetailsForm()
			Else 
				This:C1470.hideDetailsForm()
			End if 
		: (FORM Get current page:C276(*)=3)
			
			$heightButton:=21
			$spaceButton:=5
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd3"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd3"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
			OBJECT GET COORDINATES:C663(*; "lb_lotHolds"; $g_lb; $h_lb; $d_lb; $b_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_lotHolds"; $g_lb; $h_lb; $widthSubform; $heightSubform-($heightButton+$spaceButton))
			OBJECT GET COORDINATES:C663(*; "bActionLotHolds"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
			OBJECT SET COORDINATES:C1248(*; "bActionLotHolds"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
		: (FORM Get current page:C276(*)=4)
			If (Form:C1466.snItem#Null:C1517)
				This:C1470.showSerializationDF()
			Else 
				This:C1470.hideSerializationDF()
			End if 
	End case 
	
Function updatePanelTabLabels()
	
	var $stepCount : Integer
	var $holdCount : Integer
	$stepCount:=0
	$holdCount:=0
	If (Form:C1466.current_item#Null:C1517)
		$stepCount:=ds:C1482.LotStep.query("UUID_Lot = :1"; Form:C1466.current_item.UUID).length
		If (Form:C1466.current_item.lotHold#Null:C1517) && (Form:C1466.current_item.lotHold.items#Null:C1517)
			For each ($holdItem; Form:C1466.current_item.lotHold.items)
				If (($holdItem.action="on") || (String:C10($holdItem.holdAction)="Hold ON"))
					$holdCount:=$holdCount+1
				End if 
			End for each 
		End if 
	End if 
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Step ["+String:C10($stepCount)+"]"
		Form:C1466.sfw.entry.panel.pages[2].label:="Lot Holds ["+String:C10($holdCount)+"]"
	End use 
	Form:C1466.sfw.drawHTab()
	
Function loadAllTabs()
	
	This:C1470.loadLotSteps()
	
Function loadLotSteps()
	
	Form:C1466.lb_steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; Form:C1466.current_item.UUID).orderBy("order asc")
	
	$currentStep_es:=Form:C1466.lb_steps.query("qtyOut = 0 AND dateOut = :1"; !00-00-00!).orderBy("order asc")
	If ($currentStep_es.length>0)
		$currentStep:=$currentStep_es.first()
		Form:C1466.location:=String:C10($currentStep.order)+" of "+String:C10(Form:C1466.lb_steps.length)+" : "+$currentStep.description
		Form:C1466.stepsRowMeta:=New collection:C1472()
		For each ($step; Form:C1466.lb_steps)
			If ($currentStep#Null:C1517) && ($step.UUID=$currentStep.UUID)
				Form:C1466.stepsRowMeta.push(New object:C1471("fill"; "#90EE90"))
			Else 
				Form:C1466.stepsRowMeta.push(New object:C1471())
			End if 
		End for each 
	Else 
		Form:C1466.location:=""
	End if 
	
	This:C1470.loadLocation()
	This:C1470.updatePanelTabLabels()
	
Function loadLocation()
	
	$steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; Form:C1466.current_item.UUID).orderBy("order asc")
	$cs_es:=$steps.query("qtyOut = 0 AND dateOut = :1"; !00-00-00!).orderBy("order asc")
	Form:C1466.locCurrentArea:=""
	Form:C1466.locNextArea:=""
	If ($cs_es.length>0)
		$cs:=$cs_es.first()
		Form:C1466.location:=String:C10($cs.order)+" of "+String:C10($steps.length)+" : "+$cs.description
		If ($cs.step#Null:C1517) && ($cs.step.stepArea#Null:C1517)
			Form:C1466.locCurrentArea:=String:C10($cs.step.stepArea.name)
		End if 
		$nextStep:=$steps.query("order = :1"; $cs.order+1).first()
		If ($nextStep#Null:C1517) && ($nextStep.step#Null:C1517) && ($nextStep.step.stepArea#Null:C1517)
			Form:C1466.locNextArea:=String:C10($nextStep.step.stepArea.name)
		End if 
	Else 
		Form:C1466.location:=""
	End if 
	
Function showDetailsForm()
	
	$dfWidth:=300
	$reorderBtnsWidth:=26
	$dfLabelsWidth:=80
	$spacer:=5
	
	OBJECT SET VISIBLE:C603(*; "df_@"; True:C214)
	OBJECT SET ENABLED:C1123(*; "btn_@"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENABLED:C1123(*; "df_steps_@"; Form:C1466.sfw.checkIsInModification())
	// Keep the properties listbox always interactive — it live-saves via stepRow.save() on each change
	OBJECT SET ENABLED:C1123(*; "df_steps_entry_control_params"; True:C214)
	Form:C1466.paramsMetaInfo:=New object:C1471("disabled"; Not:C34(Form:C1466.sfw.checkIsInModification()))
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $left; $up; $right; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "lb_steps"; $left; $up; $widthSubform-$reorderBtnsWidth-$dfWidth; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $left_lb; $up_lb; $right_lb; $down_lb)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_first"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_first"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_up"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_up"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_down"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_down"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_last"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_last"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_delete_row"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_delete_row"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	FORM GET OBJECTS:C898($_objects; $_variables; $_pages; Form current page:K67:6)
	
	For ($i; 1; Size of array:C274($_objects))
		If ($_objects{$i}="df_steps_label_@")
			OBJECT GET COORDINATES:C663(*; $_objects{$i}; $left; $up; $right; $down)
			OBJECT SET COORDINATES:C1248(*; $_objects{$i}; $right_lb+$spacer+$reorderBtnsWidth+$spacer; $up; $right_lb+$spacer+$reorderBtnsWidth+$spacer+$dfLabelsWidth; $down)
			OBJECT GET COORDINATES:C663(*; $_objects{$i}; $left; $up; $right; $down)
			OBJECT GET COORDINATES:C663(*; Replace string:C233($_objects{$i}; "label"; "entry"); $right_entry; $up_entry; $left_entry; $down_entry)
			OBJECT SET COORDINATES:C1248(*; Replace string:C233($_objects{$i}; "label"; "entry"); $right+$spacer; $up; $widthSubform-$spacer; $down_entry)
			If ($_objects{$i}="df_steps_label_control_params")
				OBJECT SET COORDINATES:C1248(*; "df_steps_entry_control_params"; $right+$spacer; $up; $widthSubform-$spacer; $heightSubform)
			End if 
		End if 
	End for 
	
	OBJECT GET COORDINATES:C663(*; "bActionSteps"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "bActionSteps"; $left; $heightSubform-$spacer-($down-$up); $right; $heightSubform-$spacer)
	
Function hideDetailsForm()
	
	$reorderBtnsWidth:=26
	$spacer:=5
	
	OBJECT SET VISIBLE:C603(*; "df_@"; False:C215)
	OBJECT SET ENABLED:C1123(*; "btn_@"; Form:C1466.sfw.checkIsInModification())
	Form:C1466.paramsMetaInfo:=New object:C1471("disabled"; Not:C34(Form:C1466.sfw.checkIsInModification()))
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $left; $up; $right; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "lb_steps"; $left; $up; $widthSubform-$reorderBtnsWidth-10; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $left_lb; $up_lb; $right_lb; $down_lb)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_first"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_first"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_up"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_up"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_down"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_down"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_last"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_move_last"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "btn_delete_row"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "btn_delete_row"; $right_lb+$spacer; $up; $right_lb+$reorderBtnsWidth+$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "bActionSteps"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "bActionSteps"; $left; $heightSubform-$spacer-($down-$up); $right; $heightSubform-$spacer)
	
Function btnReOrderSteps($target : Text)
	
	$currentStep:=Form:C1466.stepRow.order
	$steps:=Form:C1466.lb_steps
	
	Case of 
		: ($target="first")
			If ($currentStep=1)
				return 
			End if 
			$targetStep:=1
			For each ($step; $steps)
				If ($step.order<$currentStep)
					$step.order+=1
					$step.save()
				End if 
			End for each 
			Form:C1466.stepRow.order:=1
			Form:C1466.stepRow.save()
			
		: ($target="last")
			If ($currentStep=$steps.length)
				return 
			End if 
			$targetStep:=$steps.length
			For each ($step; $steps)
				If ($step.order>$currentStep)
					$step.order-=1
					$step.save()
				End if 
			End for each 
			Form:C1466.stepRow.order:=$steps.length
			Form:C1466.stepRow.save()
			
		: ($target="up")
			If ($currentStep=1)
				return 
			End if 
			$targetStep:=$currentStep-1
			$stepToSwap:=$steps.query("order = :1"; $currentStep-1).first()
			$stepToSwap.order:=$currentStep
			Form:C1466.stepRow.order:=$currentStep-1
			$stepToSwap.save()
			Form:C1466.stepRow.save()
			
		: ($target="down")
			If ($currentStep=$steps.length)
				return 
			End if 
			$targetStep:=$currentStep+1
			$stepToSwap:=$steps.query("order = :1"; $currentStep+1).first()
			$stepToSwap.order:=$currentStep
			Form:C1466.stepRow.order:=$currentStep+1
			$stepToSwap.save()
			Form:C1466.stepRow.save()
			
	End case 
	
	This:C1470.loadLotSteps()
	LISTBOX SELECT ROW:C912(*; "lb_steps"; $targetStep)
	
Function btnDeleteStep()
	
	$currentStep:=Form:C1466.stepRow.order
	$steps:=Form:C1466.lb_steps
	
	Form:C1466.stepRow.drop()
	
	For each ($step; $steps)
		If ($step.order>$currentStep)
			$step.order-=1
			$step.save()
		End if 
	End for each 
	
	This:C1470.loadLotSteps()
	
Function bActionSteps()
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Add Step")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add_single_step")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	APPEND MENU ITEM:C411($refMenu; "Add Step from Step File")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_stepfile")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
		DISABLE MENU ITEM:C150($refMenu; -2)
	End if

	APPEND MENU ITEM:C411($refMenu; "-")
	APPEND MENU ITEM:C411($refMenu; "Split Lot...")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--split_lot")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if
	APPEND MENU ITEM:C411($refMenu; "-")

	APPEND MENU ITEM:C411($refMenu; "Print Lot Traveller")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--print_lot_traveller")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/dfd/image/icon/document-pdf.png")
	APPEND MENU ITEM:C411($refMenu; "Print Production Lot Traveller")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--print_prod_lot_traveller")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/dfd/image/icon/document-pdf.png")
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	Case of
		: ($choose="--add_single_step")
			This:C1470.addSingleStep()
		: ($choose="--split_lot")
			This:C1470.splitLot()
		: ($choose="--print_lot_traveller")
			This:C1470.printLotTraveller()
		: ($choose="--print_prod_lot_traveller")
			This:C1470.printProdLotTraveller()
		: ($choose="--create_from_stepfile")
			
			$customer:=Form:C1466.current_item.job.customer
			If ($customer=Null:C1517)
				$customer:=Form:C1466.current_item.job.purchaseOrder.customer
			End if 
			
			$form:=New object:C1471("lotInfo"; New object:C1471("customer"; $customer))
			
			$winRef:=Open form window:C675("createFromStepFile"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createFromStepFile"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				
				If (($form.stepFile.stepsDefinition#Null:C1517) & ($form.stepFile.stepsDefinition.items#Null:C1517) & ($form.stepFile.stepsDefinition.items.length>0))
					
					var $proceed : Boolean
					$proceed:=True:C214
					$length:=Form:C1466.lb_steps.length
					
					If ($form.mode="replace")
						If (Not:C34(This:C1470.checkLotStepsUnlockedForReplace()))
							$proceed:=False:C215
						Else 
							$notDropped:=Form:C1466.current_item.lotSteps.drop()
							If ($notDropped.length>0)
								For each ($step; $notDropped)
									$step.unlock()
								End for each 
								cs:C1710.sfw_dialog.me.alert("One or more step records are locked. Please free the records before replacing steps.")
								$proceed:=False:C215
							Else 
								$length:=0
							End if 
						End if 
					End if 
					
					If ($proceed)
						For each ($item; $form.stepFile.stepsDefinition.items)
							$hasStep:=False:C215
							
							// Preferred lookup from imported UUID link in step definition.
							$step_es:=ds:C1482.Step.query("UUID = :1"; $item.UUID_Step)
							If ($step_es.length>0)
								$step_e:=ds:C1482.Step.query("UUID = :1"; $item.UUID_Step).first()
							Else 
								$step_e:=New object:C1471()
							End if 
							$hasStep:=($step_e.UUID#Null:C1517)
							
							// Backward-compatible fallback for legacy rows with only step_template.
							If (Not:C34($hasStep))
								$stepTemplateNum:=Num:C11($item.step_template)
								If ($stepTemplateNum>0)
									$stepTemplate_e:=ds:C1482.StepTemplate.query("templateNumber = :1"; $stepTemplateNum).first()
									If ($stepTemplate_e#Null:C1517)
										$step_e:=ds:C1482.Step.query("UUID_StepTemplate = :1"; $stepTemplate_e.UUID).first()
										$hasStep:=($step_e#Null:C1517)
									End if 
								End if 
							End if 
							
							If ($hasStep)
								$res:=This:C1470.createLotStepFromStepEntity($step_e; $length+1)
								If ($res.success)
									$length:=$length+1
								End if 
							End if 
						End for each 
						This:C1470.loadLotSteps()
						This:C1470._activate_save_cancel_button()
						Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					End if 
				End if 
			End if 
	End case 
	
Function printLotTraveller()

	Planning_printLotTraveller(Form:C1466.current_item)

Function printProdLotTraveller()

	Planning_printProdLotTrav(Form:C1466.current_item)

Function isLotStepPropertyEnabled($lotStep : cs:C1710.LotStepEntity; $propertyName : Text)->$enabled : Boolean
	// LotStep.properties is the copy of Step.stepProperties made when the step
	// was created; items carry {name; enable} (legacy rows may use "enabled")
	var $item : Object

	$enabled:=False:C215
	If (($lotStep=Null:C1517) || ($lotStep.properties=Null:C1517) || ($lotStep.properties.items=Null:C1517))
		return
	End if

	For each ($item; $lotStep.properties.items)
		If (String:C10($item.name)=$propertyName)
			If ($item.enable#Null:C1517)
				$enabled:=Bool:C1537($item.enable)
			Else
				$enabled:=Bool:C1537($item.enabled)
			End if
			return
		End if
	End for each

Function splitLot()
	// Split part of the lot into a new sublot: same lot number, incremented
	// subSequence, steps starting at the mother's current step.
	var $check : Object
	var $form : Object
	var $params : Object
	var $result : Object
	var $snItem : Object
	var $winRef : Integer

	$check:=cs:C1710.LotSplitService.me.canSplitAtCurrentStep(Form:C1466.current_item; New object:C1471("inModification"; Form:C1466.sfw.checkIsInModification()))
	If (Not:C34($check.allowed))
		cs:C1710.sfw_dialog.me.alert($check.message)
		return
	End if

	$form:=New object:C1471()
	$form.motherLotNumber:=String:C10(Form:C1466.current_item.lotNumber)
	$form.currentStepDisplay:="Step "+String:C10($check.currentStep.order)+" — "+String:C10($check.currentStep.description)
	$form.availableQty:=$check.availableQty
	$form.quantity:=0
	$form.serialized:=Bool:C1537(Form:C1466.current_item.serialization)
	$form.snItems:=New collection:C1472()

	If (($form.serialized) && (Form:C1466.current_item.snTable#Null:C1517) && (Form:C1466.current_item.snTable.items#Null:C1517))
		For each ($snItem; Form:C1466.current_item.snTable.items)
			If (Bool:C1537($snItem.pass)) && (Not:C34(Bool:C1537($snItem.split_out)))
				$form.snItems.push(New object:C1471(\
					"selected"; False:C215; \
					"id"; $snItem.id; \
					"serial_number"; String:C10($snItem.serial_number); \
					"comments"; String:C10($snItem.comments)\
					))
			End if
		End for each
	End if

	$winRef:=Open form window:C675("planning_splitLot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("planning_splitLot"; $form)
	CLOSE WINDOW:C154($winRef)

	If (OK=1)
		$params:=New object:C1471(\
			"quantity"; Num:C11($form.quantity); \
			"selectedSnIds"; $form.snItems.query("selected = :1"; True:C214).extract("id")\
			)

		$result:=cs:C1710.LotSplitService.me.executeSplit(Form:C1466.current_item; $params)

		If ($result.success)
			This:C1470.loadLotSteps()
			This:C1470.updatePanelTabLabels()
			This:C1470._activate_save_cancel_button()
			cs:C1710.sfw_dialog.me.alert("Sublot "+String:C10($result.child.lotNumber)+" (sub "+String:C10($result.child.subSequence)+") created with "+String:C10($params.quantity)+" item(s). Save the lot to confirm the remaining count.")
		Else
			cs:C1710.sfw_dialog.me.alert($result.message)
		End if
	End if

Function checkLotStepsUnlockedForReplace()->$success : Boolean
	
	var $step : 4D:C1709.Entity
	var $info : Object
	var $lockedSteps : Collection
	
	$success:=True:C214
	$lockedSteps:=New collection:C1472()
	
	For each ($step; Form:C1466.lb_steps)
		$info:=$step.lock()
		If ($info.success=False:C215)
			For each ($lockedStep; $lockedSteps)
				$lockedStep.unlock()
			End for each 
			cs:C1710.sfw_dialog.me.alert("One or more step records are locked. Please free the records before replacing steps.")
			$success:=False:C215
			return 
		End if 
		$lockedSteps.push($step)
	End for each 
	
Function addSingleStep()
	
	var $form : Object
	var $winRef : Integer
	var $step_e : 4D:C1709.Entity
	var $res : Object
	
	$form:=New object:C1471()
	
	$winRef:=Open form window:C675("addSingleStep"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("addSingleStep"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1) && ($form.selectedStep#Null:C1517)
		$step_e:=$form.selectedStep
		$res:=This:C1470.createLotStepFromStepEntity($step_e; Form:C1466.lb_steps.length+1)
		If ($res.success)
			This:C1470.loadLotSteps()
			This:C1470._activate_save_cancel_button()
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
		End if 
	End if 
	
Function createLotStepFromStepEntity($step_e : Object; $order : Integer)->$result : Object
	
	var $step_new : 4D:C1709.Entity
	var $dtbl : Object
	
	$step_new:=ds:C1482.LotStep.new()
	$step_new.description:=$step_e.description
	$step_new.alert:=$step_e.alert
	$step_new.UUID_Lot:=Form:C1466.current_item.UUID
	$step_new.properties:=$step_e.stepProperties
	If ($step_e.stepTemplate#Null:C1517) && ($step_e.stepTemplate.bins#Null:C1517) && ($step_e.stepTemplate.bins.items#Null:C1517)
		$step_new.bins:=$step_e.stepTemplate.bins
		For each ($bin; $step_new.bins.items)
			$bin["quantity"]:=0
		End for each 
	End if 
	If ($step_e.stepTemplate#Null:C1517) && ($step_e.stepTemplate.dataTables#Null:C1517) && ($step_e.stepTemplate.dataTables.items#Null:C1517) && ($step_e.stepTemplate.dataTables.items.length>0)
		$dtbl:=New object:C1471()
		For each ($dtCol; $step_e.stepTemplate.dataTables.items.orderBy("order asc"))
			$dtbl[$dtCol.key]:=New collection:C1472()
		End for each 
		$step_new.dataTable:=$dtbl
	End if 
	$step_new.area:=$step_e.areas
	$step_new.UUID_Step:=$step_e.UUID
	If ($step_e.moreData#Null:C1517) && ($step_e.moreData.specificationControl#Null:C1517)
		$step_new.specificationControl:=$step_e.moreData.specificationControl
	End if
	$step_new.order:=$order
	$step_new.properties:=$step_e.stepProperties
	// carry the lot's SN table onto the new step (only units still marked pass)
	If ((Form:C1466.current_item.snTable#Null:C1517) && (Form:C1466.current_item.snTable.items#Null:C1517) && (Form:C1466.current_item.snTable.items.length>0))
		$step_new.snTable:=New object:C1471("items"; OB Copy:C1225(Form:C1466.current_item.snTable).items.query("pass = :1"; True:C214))
	End if
	$result:=$step_new.save()
	
Function loadLotHolds()
	
	Form:C1466.holdRow:=Null:C1517
	Form:C1466.holdPos:=0
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lotHold#Null:C1517) && (Form:C1466.current_item.lotHold.items#Null:C1517)
		Form:C1466.lb_lotHolds:=LotHoldForm_mapItemsForList(Form:C1466.current_item.lotHold.items).orderBy("sortDate desc; sortTime desc")
	Else 
		Form:C1466.lb_lotHolds:=New collection:C1472()
	End if 
	
	This:C1470.updatePanelTabLabels()
	
Function bActionLotHolds()
	
	var $holdOn : Object
	var $lot : 4D:C1709.Entity
	
	If (Form:C1466.holdRow=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("Please select a hold record first.")
		return 
	End if 
	
	$lot:=Form:C1466.current_item
	$holdOn:=LotHoldForm_getHoldOnForEvent($lot; Form:C1466.holdRow)
	
	If ($holdOn=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("Unable to identify the hold ON event for the selected record.")
		return 
	End if 
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "View NCMN")
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--NCMN")
	
	APPEND MENU ITEM:C411($refMenu; "View ISSNF")
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--ISSNF")
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	Case of 
		: ($choose="--NCMN")
			LotHoldForm_viewHoldForm($lot; "NCMN"; $holdOn)
		: ($choose="--ISSNF")
			LotHoldForm_viewHoldForm($lot; "ISSNF"; $holdOn)
	End case 
	
Function holdLotAction($action : Text)

	If (($action="off") || ($action="Hold OFF"))
		If (Not:C34(LotHold_checkNcmnApprovals(Form:C1466.current_item)))
			cs:C1710.sfw_dialog.me.alert("This lot cannot be taken off hold: all four NCMN approvals (Customer Service, Engineering, QA/QC, Production) must be checked first.")
			return
		End if
	End if

	$form:=New object:C1471(\
		"holdLot"; New object:C1471(); \
		"holdDate"; Current date:C33; \
		"holdTime"; Time:C179(Current time:C178); \
		"holdAction"; $action; \
		"holdReason"; ""; \
		"performedBy"; ""; \
		"staffCode"; ""\
		)
	
	$winRef:=Open form window:C675("holdLot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("holdLot"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		If (Form:C1466.current_item.lotHold=Null:C1517) | (Form:C1466.current_item.lotHold.items=Null:C1517)
			Form:C1466.current_item.lotHold:=New object:C1471("items"; New collection:C1472())
		End if 
		
		Form:C1466.current_item.lotHold.items.push(New object:C1471(\
			"holdDate"; $form.holdDate; \
			"holdTime"; $form.holdTime; \
			"holdDateText"; String:C10($form.holdDate; Internal date short:K1:7)+" "+String:C10($form.holdTime; HH MM:K7:2); \
			"holdAction"; $form.holdAction; \
			"holdLot"; $form.holdLot; \
			"holdCode"; $form.holdLot.code; \
			"holdReason"; $form.holdReason; \
			"performedBy"; $form.performedBy\
			))
		
		Form:C1466.current_item.onHold:=($action="Hold ON")
		This:C1470.loadLotHolds()
		This:C1470._activate_save_cancel_button()
	End if 
	
Function loadLotSerialization()
	
	Form:C1466.snItem:=Null:C1517
	
Function showSerializationDF()
	
	$detailWidth:=422
	$labWidth:=88
	$spacer:=10
	
	OBJECT SET VISIBLE:C603(*; "rec_sz_editor"; True:C214)
	OBJECT SET VISIBLE:C603(*; "sz_lbl_snEditor"; True:C214)
	OBJECT SET VISIBLE:C603(*; "sz_lab_@"; True:C214)
	OBJECT SET VISIBLE:C603(*; "sz_inp_@"; True:C214)
	OBJECT SET VISIBLE:C603(*; "sz_chk_@"; True:C214)
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "vl_rec_bgkd"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "vl_rec_bgkd"; $left; $up; $right; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_serialization"; $left_lb; $up_lb; $right_lb; $down_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_serialization"; $left_lb; $up_lb; $widthSubform-$detailWidth-$spacer; $heightSubform)
	
	$editorLeft:=$widthSubform-$detailWidth
	$editorRight:=$widthSubform
	$inpLeft:=$editorLeft+$labWidth+$spacer+$spacer
	$inpRight:=$editorRight-$spacer
	
	OBJECT SET COORDINATES:C1248(*; "rec_sz_editor"; $editorLeft; $up_lb; $editorRight; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "sz_lbl_snEditor"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_lbl_snEditor"; $editorLeft+$spacer; $up; $editorRight-$spacer; $down)
	
	OBJECT GET COORDINATES:C663(*; "sz_lab_sn"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_lab_sn"; $editorLeft+$spacer; $up; $editorLeft+$spacer+$labWidth; $down)
	OBJECT GET COORDINATES:C663(*; "sz_inp_sn"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_inp_sn"; $inpLeft; $up; $inpRight; $down)
	
	OBJECT GET COORDINATES:C663(*; "sz_lab_secondIdentifier"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_lab_secondIdentifier"; $editorLeft+$spacer; $up; $editorLeft+$spacer+$labWidth; $down)
	OBJECT GET COORDINATES:C663(*; "sz_inp_secondIdentifier"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_inp_secondIdentifier"; $inpLeft; $up; $inpRight; $down)
	
	OBJECT GET COORDINATES:C663(*; "sz_lab_pass"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_lab_pass"; $editorLeft+$spacer; $up; $editorLeft+$spacer+$labWidth; $down)
	OBJECT GET COORDINATES:C663(*; "sz_chk_pass"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_chk_pass"; $inpLeft; $up; $inpLeft+60; $down)
	
	OBJECT GET COORDINATES:C663(*; "sz_lab_splitOut"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_lab_splitOut"; $editorLeft+$spacer; $up; $editorLeft+$spacer+$labWidth; $down)
	OBJECT GET COORDINATES:C663(*; "sz_chk_splitOut"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_chk_splitOut"; $inpLeft; $up; $inpLeft+17; $down)
	
	OBJECT GET COORDINATES:C663(*; "sz_lab_comments"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_lab_comments"; $editorLeft+$spacer; $up; $editorLeft+$spacer+$labWidth; $down)
	OBJECT GET COORDINATES:C663(*; "sz_inp_comments"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "sz_inp_comments"; $inpLeft; $up; $inpRight; $heightSubform-$spacer)
	
	OBJECT GET COORDINATES:C663(*; "bActionSerialization"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "bActionSerialization"; $left; $heightSubform-$spacer-($down-$up); $right; $heightSubform-$spacer)
	
Function hideSerializationDF()
	
	$spacer:=10
	
	OBJECT SET VISIBLE:C603(*; "rec_sz_editor"; False:C215)
	OBJECT SET VISIBLE:C603(*; "sz_lbl_snEditor"; False:C215)
	OBJECT SET VISIBLE:C603(*; "sz_lab_@"; False:C215)
	OBJECT SET VISIBLE:C603(*; "sz_inp_@"; False:C215)
	OBJECT SET VISIBLE:C603(*; "sz_chk_@"; False:C215)
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "vl_rec_bgkd"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "vl_rec_bgkd"; $left; $up; $right; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_serialization"; $left_lb; $up_lb; $right_lb; $down_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_serialization"; $left_lb; $up_lb; $widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "bActionSerialization"; $left; $up; $right; $down)
	OBJECT SET COORDINATES:C1248(*; "bActionSerialization"; $left; $heightSubform-$spacer-($down-$up); $right; $heightSubform-$spacer)
	
Function manageSerializationDetailPanel()
	
	If (Form:C1466.snItem#Null:C1517)
		This:C1470.showSerializationDF()
	Else 
		This:C1470.hideSerializationDF()
	End if 
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function buildSnTable($rangeMin : Integer; $rangeMax : Integer)->$snTable : Object
	
	$snTable:=New object:C1471("items"; New collection:C1472())
	
	For ($i; $rangeMin; $rangeMax)
		$snTable.items.push(New object:C1471(\
			"id"; $i; \
			"pass"; True:C214; \
			"description"; ""\
			))
	End for 
	
Function bActionSerialization()
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Generate SN Table")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--generate")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	If (Form:C1466.current_item.snTable#Null:C1517) && (Form:C1466.current_item.snTable.items#Null:C1517) && (Form:C1466.current_item.snTable.items.length>0)
		APPEND MENU ITEM:C411($refMenu; "Clear SN Table")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--clear")
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/remove.png")
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
		: ($choose="--generate")
			$form:=New object:C1471("itemsNumber"; 0)
			
			$winRef:=Open form window:C675("generate_sn_table"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("generate_sn_table"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)

				var $existingItems; $newItems; $found : Collection
				var $failedStepSaves : Integer

				// keep already entered serial numbers / statuses when regenerating
				$existingItems:=New collection:C1472()
				If ((Form:C1466.current_item.snTable#Null:C1517) && (Form:C1466.current_item.snTable.items#Null:C1517))
					$existingItems:=Form:C1466.current_item.snTable.items
				End if

				$newItems:=New collection:C1472()
				For ($i; 1; $form.itemsNumber)
					$found:=$existingItems.query("id = :1"; $i)
					If ($found.length>0)
						$newItems.push($found[0])
					Else
						$newItems.push(New object:C1471(\
							"id"; $i; \
							"serial_number"; ""; \
							"pass"; True:C214; \
							"split_out"; False:C215; \
							"comments"; ""\
							))
					End if
				End for

				Form:C1466.current_item.snTable:=New object:C1471("items"; $newItems)

				$failedStepSaves:=0
				For each ($step; Form:C1466.current_item.lotSteps)
					// each step gets its own copy, restricted to units still marked pass
					$step.snTable:=New object:C1471("items"; OB Copy:C1225(Form:C1466.current_item.snTable).items.query("pass = :1"; True:C214))
					If (Not:C34($step.save().success))
						$failedStepSaves:=$failedStepSaves+1
					End if
				End for each

				If ($failedStepSaves>0)
					cs:C1710.sfw_dialog.me.alert(String:C10($failedStepSaves)+" step(s) could not be updated with the SN table (record locked). Please free the record(s) and generate again.")
				End if

				This:C1470._activate_save_cancel_button()
			End if
			
		: ($choose="--clear")
			Form:C1466.current_item.snTable.items:=New collection:C1472()
			For each ($step; Form:C1466.current_item.lotSteps)
				If ($step.snTable=Null:C1517) | ($step.snTable.items=Null:C1517)
					$step.snTable:=New object:C1471("items"; New collection:C1472())
				Else 
					$step.snTable.items:=New collection:C1472()
				End if 
				$res:=$step.save()
			End for each 
			This:C1470._activate_save_cancel_button()
			
	End case 
	
Function selectPurchaseOrder()
	
	var $form : Object
	
	If (Form:C1466.sfw.checkIsInModification())
		OBJECT GET COORDINATES:C663(*; "field_purchaseOrder"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "poNum"; \
			"lb_items"; ds:C1482.PurchaseOrder.query("UUID_Customer = :1"; Form:C1466.current_item.job.customer.UUID); \
			"allData"; ds:C1482.PurchaseOrder.query("UUID_Customer = :1"; Form:C1466.current_item.job.customer.UUID); \
			"dataclass"; "PurchaseOrder"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (OK=1) & ($form.item#Null:C1517)
			Form:C1466.current_item.job.UUID_PurchaseOrder:=$form.item.UUID
			Form:C1466.current_item.job.save()
			This:C1470._activate_save_cancel_button()
		End if 
	End if 