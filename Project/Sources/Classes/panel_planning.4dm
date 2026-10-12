singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	// Router: each block runs only for the events that need it.
	// 1. record: the lot shown changed, or the same lot was saved / cancelled / reloaded / put
	//    in Modify (the main window then sends On Bound Variable Change). Done BEFORE
	//    panelFormMethod: the framework redraws the tab bar there, so it shows the fresh counts
	//    and this panel never has to redraw it again.
	// 2. page: the data of the page being shown (load, tab change, record refresh)
	// 3. look: show / hide / positions, on every remaining event - no database access there
	var $recordRefreshed : Boolean
	
	// 1. record (Form.previousItemUUID: the last lot the framework's updateOfPanelNeeded saw)
	$recordRefreshed:=(Form:C1466.current_item#Null:C1517) && ((String:C10(Form:C1466.previousItemUUID)#String:C10(Form:C1466.current_item.UUID)) | (FORM Event:C1606.code=On Bound Variable Change:K2:52))
	If ($recordRefreshed)
		This:C1470.loadRecordContext()
	End if 
	
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	If (Bool:C1537(Form:C1466.useHTab))
		Form:C1466.planningTabsDirty:=False:C215  // panelFormMethod has just redrawn the tab bar with the current labels
	End if 
	Form:C1466.sfw.updateOfPanelNeeded()  // the framework remembers the lot shown (and redraws the tabs on a new lot)
	
	// 2. page
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
				This:C1470.loadShipTo()
		End case 
	End if 
	
	// 3. look
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	// safety net: a tab label changed after the framework's redraw of this event (e.g. the Step
	// tab recounted the steps and found another number): redraw once, now
	If (Bool:C1537(Form:C1466.planningTabsDirty))
		Form:C1466.sfw.drawHTab()
		Form:C1466.planningTabsDirty:=False:C215
	End if 
	
Function loadRecordContext()
	// What the lot shows whatever the page: its location and the tab counts.
	// Runs when a lot is shown or refreshed, not on every event.
	This:C1470.loadLocation()
	This:C1470.updatePanelTabLabels()
	
Function redrawAndSetVisible()
	// Appearance only: runs on nearly every event, so no query and no tab redraw here
	// (the framework redraws the tab bar on every event, in panelFormMethod).
	
	// the serial-number editor fields are not "entryField" objects (their sz_ names drive the
	// layout): locked outside Modify here, as the framework locks the entryField ones (Split out is
	// never typed: the split sets it)
	OBJECT SET ENTERABLE:C238(*; "sz_inp_secondIdentifier"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENTERABLE:C238(*; "sz_inp_comments"; Form:C1466.sfw.checkIsInModification())
	This:C1470.drawPup_latePareto()  // a pop-up only in Modify: redrawn on every event, as Receiving does
	
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
	// Counts the steps and the holds of the lot and sets the two tab labels. It never redraws the
	// tab bar: the framework does it on every event (panelFormMethod), and formMethod redraws once
	// at its end if a label changed after that.
	// Called when a lot is shown or refreshed (loadRecordContext) and after the actions that
	// change the counts (loadLotSteps, loadLotHolds, split, merge). An action's object method
	// runs before the form method of the same click, so its new label is drawn by the framework.
	var $stepCount : Integer
	var $holdCount : Integer
	var $holdItem : Object
	var $stepsLabel : Text
	var $holdsLabel : Text
	
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
	$stepsLabel:="Step ["+String:C10($stepCount)+"]"
	$holdsLabel:="Lot Holds ["+String:C10($holdCount)+"]"
	If (Form:C1466.sfw.entry.panel.pages[1].label#$stepsLabel) | (Form:C1466.sfw.entry.panel.pages[2].label#$holdsLabel)
		Use (Form:C1466.sfw.entry.panel.pages)
			Form:C1466.sfw.entry.panel.pages[1].label:=$stepsLabel
			Form:C1466.sfw.entry.panel.pages[2].label:=$holdsLabel
		End use 
		Form:C1466.planningTabsDirty:=True:C214
	End if 
	
Function loadAllTabs()
	
	This:C1470.loadLotSteps()
	
Function loadLotSteps()
	
	// the step selected before the reload stays selected (Save, Cancel, reorder reload the list)
	var $selectedUUID : Text
	var $selected : 4D:C1709.Entity
	$selectedUUID:=(Form:C1466.stepRow#Null:C1517) ? Form:C1466.stepRow.UUID : ""
	
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
	
	$selected:=($selectedUUID="") ? Null:C1517 : Form:C1466.lb_steps.query("UUID = :1"; $selectedUUID).first()
	If ($selected#Null:C1517)
		Form:C1466.stepRow:=$selected
		Form:C1466.stepPos:=$selected.indexOf(Form:C1466.lb_steps)+1
		LISTBOX SELECT ROW:C912(*; "lb_steps"; Form:C1466.stepPos)
	Else 
		Form:C1466.stepRow:=Null:C1517
	End if 
	
	This:C1470.loadLocation()
	This:C1470.updatePanelTabLabels()
	
Function loadLocation()
	// Where the lot is, as the legacy app showed it (update_plandata): the current step as
	// "3 of 6 : DESCRIPTION", "completed" once every step is out, "merged" for a lot merged into
	// another; the date it got there (its date in, then the date out of the last step done); the
	// rejects of that last step (qty in - qty out); the cycle time in days once it has a date out.
	var $steps; $done : cs:C1710.LotStepSelection
	var $current; $nextStep; $last : cs:C1710.LotStepEntity
	
	$steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; Form:C1466.current_item.UUID).orderBy("order asc")
	$current:=$steps.query("qtyOut = 0 AND dateOut = :1"; !00-00-00!).orderBy("order asc").first()
	Form:C1466.locCurrentArea:=""
	Form:C1466.locNextArea:=""
	Form:C1466.location:=""
	If ($current#Null:C1517)
		Form:C1466.location:=String:C10($current.order)+" of "+String:C10($steps.length)+" : "+$current.description
		If ($current.step#Null:C1517) && ($current.step.stepArea#Null:C1517)
			Form:C1466.locCurrentArea:=String:C10($current.step.stepArea.name)
		End if 
		$nextStep:=$steps.query("order = :1"; $current.order+1).first()
		If ($nextStep#Null:C1517) && ($nextStep.step#Null:C1517) && ($nextStep.step.stepArea#Null:C1517)
			Form:C1466.locNextArea:=String:C10($nextStep.step.stepArea.name)
		End if 
		$done:=$steps.query("order < :1"; $current.order)
	Else 
		If ($steps.length>0)
			Form:C1466.location:="completed"
		End if 
		$done:=$steps
	End if 
	If (String:C10(Form:C1466.current_item.location)="merged")
		Form:C1466.location:="merged"
	End if 
	Form:C1466.locLocation:=Form:C1466.location
	
	Form:C1466.locDateToLocation:=Form:C1466.current_item.dateIn
	Form:C1466.locLastStepRejects:=0
	$last:=$done.query("dateOut # :1"; !00-00-00!).orderBy("order desc").first()
	If ($last#Null:C1517)
		Form:C1466.locDateToLocation:=$last.dateOut
		Form:C1466.locLastStepRejects:=Num:C11($last.qtyIn)-Num:C11($last.qtyOut)
	End if 
	
	Form:C1466.locCycleTime:=""
	If (Form:C1466.current_item.dateOut#!00-00-00!)
		Form:C1466.locCycleTime:=String:C10(Form:C1466.current_item.dateOut-Form:C1466.current_item.dateIn)+" day(s)"
	End if 
	
Function latePareto()->$codes : Collection
	// the reasons a lot is late (legacy list LatePareto), for the late-shipment and long-cycle reports
	$codes:=New collection:C1472("CBI. Capacity BI"; "CH. Capacity handler"; "CO. Capacity other"; "CP. Capacity prober"; "CT. Capacity tester"; "CW. Capacity hardware"; "DP. Data Prep"; "EI. Engineering Issue"; "HW. Hardware"; "HWS. No test sockets"; "MW. Missed window"; "Ot. Other"; "QF. QA Fail"; "SM. Waiting for shipping mater"; "TP. Test Program"; "WQ. Waiting for Qual"; "WS. Waiting for source"; "XI. Incomplete Info")
	
Function selectLatePareto()
	// Late Pareto pop-up: one of the codes, or None to clear it (Modify only)
	var $menu; $code; $choice : Text
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "None")
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--none")
	For each ($code; This:C1470.latePareto())
		APPEND MENU ITEM:C411($menu; $code)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $code)
		If ($code=String:C10(Form:C1466.current_item.latePareto))
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if 
	End for each 
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice="")
		return 
	End if 
	Form:C1466.current_item.latePareto:=Choose:C955($choice="--none"; ""; $choice)
	This:C1470.drawPup_latePareto()
	This:C1470._activate_save_cancel_button()
	
Function drawPup_latePareto()
	var $code : Text
	
	$code:=""
	If (Form:C1466.current_item#Null:C1517)
		$code:=String:C10(Form:C1466.current_item.latePareto)
	End if 
	// an empty title would leave the previous one on the button (None would still show MW): a space
	// clears it, as Receiving's Customer button does
	Form:C1466.sfw.drawButtonPup("pup_latePareto"; $code || " "; ""; False:C215)
	
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
	This:C1470._activate_save_cancel_button()  // written in the Modify transaction: Save confirms it
	
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
	
	Form:C1466.stepRow:=Null:C1517  // dropped: nothing to select again
	This:C1470.loadLotSteps()
	This:C1470._activate_save_cancel_button()  // written in the Modify transaction: Save confirms it
	
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
	APPEND MENU ITEM:C411($refMenu; "Merge Lot...")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--merge_lot")
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
		: ($choose="--merge_lot")
			This:C1470.mergeLot()
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
								$res:=This:C1470.createLotStepFromStepEntity($step_e; $length+1; $item)
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
	// one reading for every caller: what is ticked in Planning ("enabled"), else the import ("enable")
	$enabled:=cs:C1710.ga_serialization.me.hasProperty($lotStep; $propertyName)
	
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
	$form.motherLotNumber:=Form:C1466.current_item.displayNumber
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
			// lot history: one event on each side of the split (ga_events)
			var $splitText : Text
			$splitText:=String:C10(Num:C11($params.quantity))+" unit(s) at "+String:C10($form.currentStepDisplay)
			If ($params.selectedSnIds.length>0)
				$splitText+=", SN "+$params.selectedSnIds.join(", ")
			End if
			cs:C1710.ga_events.me.addEvent("planning"; Form:C1466.current_item.UUID; "ga_lotSplit"; "Lot split"; New collection:C1472("Moved to sublot "+$result.child.displayNumber+": "+$splitText))
			cs:C1710.ga_events.me.addEvent("planning"; $result.child.UUID; "ga_lotSplit"; "Lot split"; New collection:C1472("Created from lot "+String:C10($form.motherLotNumber)+": "+$splitText))
			cs:C1710.sfw_eventManager.me.refresh(Form:C1466.current_item.UUID; Form:C1466.sfw.entry)
			cs:C1710.sfw_dialog.me.alert("Sublot "+$result.child.displayNumber+" created with "+String:C10($params.quantity)+" item(s). Save the lot to confirm the remaining count.")
		Else
			cs:C1710.sfw_dialog.me.alert($result.message)
		End if
	End if

Function mergeLot()
	// Merge a whole lot of the same job into this lot, at its current step (LotMergeService,
	// rules from the legacy app). The merged lot is closed; this lot's count is saved with the panel.
	var $check : Object
	var $form : Object
	var $result : Object
	var $text : Text
	var $winRef : Integer
	
	$check:=cs:C1710.LotMergeService.me.canMerge(Form:C1466.current_item; New object:C1471("inModification"; Form:C1466.sfw.checkIsInModification()))
	If (Not:C34($check.allowed))
		cs:C1710.sfw_dialog.me.alert($check.message)
		return 
	End if 
	
	$form:=New object:C1471()
	$form.motherLotNumber:=Form:C1466.current_item.displayNumber+"  -  count "+String:C10(Form:C1466.current_item.ourCount)
	$form.currentStepDisplay:="Step "+String:C10($check.currentStep.order)+" - "+String:C10($check.currentStep.description)
	$form.jobDisplay:=(Form:C1466.current_item.job#Null:C1517) ? String:C10(Form:C1466.current_item.job.jobNumber) : ""
	$form.candidates:=cs:C1710.LotMergeService.me.candidates(Form:C1466.current_item)
	$form.selected:=Null:C1517
	$form.selectedMessage:=""
	If ($form.candidates.length=0)
		cs:C1710.sfw_dialog.me.alert("No other open lot of job "+$form.jobDisplay+" can be merged into this lot.")
		return 
	End if 
	
	$winRef:=Open form window:C675("planning_mergeLot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("planning_mergeLot"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1) && ($form.selected#Null:C1517)
		$result:=cs:C1710.LotMergeService.me.executeMerge(Form:C1466.current_item; String:C10($form.selected.UUID))
		If ($result.success)
			This:C1470.loadLotSteps()
			This:C1470.updatePanelTabLabels()
			This:C1470._activate_save_cancel_button()
			// lot history: one event on each side of the merge (ga_events)
			$text:=String:C10($result.quantity)+" unit(s) at "+$form.currentStepDisplay
			If ($result.movedSn.length>0)
				$text+=", SN "+$result.movedSn.join(", ")
			End if 
			cs:C1710.ga_events.me.addEvent("planning"; Form:C1466.current_item.UUID; "ga_lotMerge"; "Lot merged"; New collection:C1472("Acquired lot "+$result.child.displayNumber+": "+$text).combine($result.warnings))
			cs:C1710.ga_events.me.addEvent("planning"; $result.child.UUID; "ga_lotMerge"; "Lot merged"; New collection:C1472("Merged into lot "+Form:C1466.current_item.displayNumber+": "+$text+". Nothing retained, lot closed."))
			cs:C1710.sfw_eventManager.me.refresh(Form:C1466.current_item.UUID; Form:C1466.sfw.entry)
			cs:C1710.sfw_dialog.me.alert("Lot "+$result.child.displayNumber+" merged: "+String:C10($result.quantity)+" item(s) added. Save this lot to confirm its new count.")
		Else 
			cs:C1710.sfw_dialog.me.alert($result.message)
		End if 
	End if 
	
Function loadShipTo()
	// Ship To tab: the lot's own ship-to address in the framework address editor (as Buying Orders).
	// A lot that has none yet gets its customer's shipping address when the tab opens in Modify.
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If ((Form:C1466.current_item.shipToAddress=Null:C1517) || (Form:C1466.current_item.shipToAddress.detail=Null:C1517)) && (Form:C1466.sfw.checkIsInModification())
		Form:C1466.current_item.followCustomerShipTo()
	End if 
	Form:C1466.subFormAddress:=New object:C1471("situation"; Form:C1466.situation; "readOnly"; Not:C34(Form:C1466.sfw.checkIsInModification()))
	Form:C1466.subFormAddress.address:=Form:C1466.current_item.shipToAddress
	// the editor changes the address object in place: keep the attribute touched while editing so
	// those changes are part of the save (same as Buying Orders)
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item.shipToAddress#Null:C1517)
		Form:C1466.current_item.shipToAddress:=Form:C1466.current_item.shipToAddress
	End if 
	Form:C1466.subFormAddress:=Form:C1466.subFormAddress
	OBJECT SET ENABLED:C1123(*; "bShipToFromCustomer"; Form:C1466.sfw.checkIsInModification())
	
Function copyShipToFromCustomer()
	// "Copy the customer's shipping address": back to the customer's address, replacing this lot's
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	If (Form:C1466.current_item.job=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("This lot has no customer yet: choose it in Receiving first.")
		return 
	End if 
	If (Form:C1466.current_item.job.customer=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("This lot has no customer yet: choose it in Receiving first.")
		return 
	End if 
	If (Form:C1466.current_item.copyShipToFromCustomer(Form:C1466.current_item.job.customer))
		This:C1470.loadShipTo()
		This:C1470._activate_save_cancel_button()
	Else 
		cs:C1710.sfw_dialog.me.alert("The customer has no address to copy.")
	End if 
	
Function saveStepRow()
	// The step detail panel (description, alert) edits this lot's copy of the step and writes it at
	// once, like the step properties and the reorder buttons. Planning runs Modify inside a
	// transaction (enableTransaction): Save validates it, leaving without saving cancels it. So the
	// Save button must become active, or the change is lost when the user leaves the lot.
	var $res : Object
	
	If (Form:C1466.stepRow=Null:C1517)
		return 
	End if 
	$res:=Form:C1466.stepRow.save()
	If (Not:C34($res.success))
		cs:C1710.sfw_dialog.me.alert("This step could not be saved"+Choose:C955(String:C10($res.statusText)=""; "."; ": "+String:C10($res.statusText)))
	Else 
		This:C1470._activate_save_cancel_button()
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
	
Function createLotStepFromStepEntity($step_e : Object; $order : Integer; $fileRow : Object)->$result : Object
	
	var $step_new : 4D:C1709.Entity
	var $dtbl : Object
	
	$step_new:=ds:C1482.LotStep.new()
	$step_new.description:=$step_e.description
	$step_new.alert:=$step_e.alert
	$step_new.UUID_Lot:=Form:C1466.current_item.UUID
	$step_new.properties:=cs:C1710.ga_serialization.me.normalizedProperties($step_e.stepProperties)  // "enabled" = the definition's "enable"
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
	// a step file row brings the step's minimum yield (Min % at punch out) and planned hours
	If ($fileRow#Null:C1517)
		If (Num:C11($fileRow.yield)>0)
			$step_new.minYield:=Num:C11($fileRow.yield)
		End if 
		If (Num:C11($fileRow.planned_hours)>0)
			$step_new.plannedHours:=Num:C11($fileRow.planned_hours)
		End if 
	End if 
	$step_new.properties:=cs:C1710.ga_serialization.me.normalizedProperties($step_e.stepProperties)  // "enabled" = the definition's "enable"
	cs:C1710.ga_serialization.me.syncStep(Form:C1466.current_item; $step_new)  // an SN step (SNA / SNF) gets the lot's active units
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
	
	// the hold forms on their Golden Altos paper forms (LotHoldForm_print)
	APPEND MENU ITEM:C411($refMenu; "(-")
	APPEND MENU ITEM:C411($refMenu; "Print NCMN (GAF-1014)")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--printNCMN")
	APPEND MENU ITEM:C411($refMenu; "Print ISSNF (GAF-1514)")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--printISSNF")
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	Case of 
		: ($choose="--NCMN")
			LotHoldForm_viewHoldForm($lot; "NCMN"; $holdOn)
		: ($choose="--ISSNF")
			LotHoldForm_viewHoldForm($lot; "ISSNF"; $holdOn)
		: ($choose="--printNCMN")
			LotHoldForm_print("NCMN"; LotHoldForm_resolveFormForHold($lot; "NCMN"; $holdOn))
		: ($choose="--printISSNF")
			LotHoldForm_print("ISSNF"; LotHoldForm_resolveFormForHold($lot; "ISSNF"; $holdOn))
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
			// default: the lot's customer count (else our count); another number is asked to confirm
			$form:=New object:C1471("itemsNumber"; Num:C11(Form:C1466.current_item.customerCount); "customerCount"; Num:C11(Form:C1466.current_item.customerCount))
			If ($form.itemsNumber=0)
				$form.itemsNumber:=Num:C11(Form:C1466.current_item.ourCount)
			End if 
			
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

				// only the steps marked SNA / SNF get the list (ga_serialization)
				$failedStepSaves:=cs:C1710.ga_serialization.me.syncAllSteps(Form:C1466.current_item)

				If ($failedStepSaves>0)
					cs:C1710.sfw_dialog.me.alert(String:C10($failedStepSaves)+" step(s) could not be updated with the SN table (record locked). Please free the record(s) and generate again.")
				End if
				If (Not:C34(cs:C1710.ga_serialization.me.hasSnStep(Form:C1466.current_item)))
					cs:C1710.sfw_dialog.me.alert("No step is marked SNA or SNF yet, so no step has the serial numbers.\rTick SNA on the step where the units are recorded (Step tab, properties): it gets the list at once.")
				End if 

				This:C1470._activate_save_cancel_button()
			End if
			
		: ($choose="--clear")
			Form:C1466.current_item.snTable.items:=New collection:C1472()
			For each ($step; Form:C1466.current_item.lotSteps)
				// only the steps that have a list (the SN steps) are touched; a step without one
				// has no snTable at all
				If ($step.snTable#Null:C1517)
					If ($step.snTable.items#Null:C1517)
						If ($step.snTable.items.length>0)
							$step.snTable.items:=New collection:C1472()
							$step.snTable:=$step.snTable  // touch the object attribute so save() persists the nested change
							$res:=$step.save()
						End if 
					End if 
				End if 
			End for each 
			This:C1470._activate_save_cancel_button()
			
	End case

//Mark:- Dynamic-rendering mirrors of the form object methods
// activateDocument() on this entry adds the framework Documents page, which switches the
// panel to dynamic-source rendering: every object method of the form is replaced by
// sfw_dynamicForm_script, which calls cs.panel_planning.me[objectName]() - and does nothing, without
// an error, when there is no function of that name. Each function below is the object
// method of the object it is named after (Self replaced by the object's name). The
// ObjectMethods files are kept: CHANGE BOTH, or the panel behaves differently once the
// Documents page is removed.

Function bShipToFromCustomer()
	cs:C1710.panel_planning.me.copyShipToFromCustomer()
	
Function btnDatePicker_commitDate()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.current_item.commit; OBJECT Get name:C1087(Object current:K67:2))  // the app's calendar
			
			If ($date#!00-00-00!)
				Form:C1466.current_item.commit:=$date
			End if 
	End case
	
Function btn_delete_row()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			cs:C1710.panel_planning.me.btnDeleteStep()
			
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; OBJECT Get name:C1087(Object current:K67:2)); 9000; 9019))
			
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469()
	End case
	
Function btn_hold_forms()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			If (Form:C1466.current_item.onHold)
				
				var $defaults : Object
				var $form : Object
				
				$refMenu:=Create menu:C408
				
				APPEND MENU ITEM:C411($refMenu; "Non-Conforming Material Notice")
				SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--NCMN")
				
				APPEND MENU ITEM:C411($refMenu; "Internal Start-Stop Notification Form")
				SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--ISSNF")
				
				$defaults:=New object:C1471(\
					"customer"; Form:C1466.current_item.job.customer.name; \
					"lotNumber"; String:C10(Form:C1466.current_item.number)\
					)
				
				$choose:=Dynamic pop up menu:C1006($refMenu)
				Case of 
					: ($choose="--NCMN")
						$form:=LotHoldForm_resolveForm(Form:C1466.current_item; "NCMN"; $defaults)
						
						$winRef:=Open form window:C675("NCMN"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
						DIALOG:C40("NCMN"; $form)
						CLOSE WINDOW:C154($winRef)
						
						If (OK=1)
							LotHoldForm_saveForm(Form:C1466.current_item; "NCMN"; $form)
							Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
						End if 
						
					: ($choose="--ISSNF")
						$form:=LotHoldForm_resolveForm(Form:C1466.current_item; "ISSNF"; $defaults)
						
						$winRef:=Open form window:C675("ISSNF"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
						DIALOG:C40("ISSNF"; $form)
						CLOSE WINDOW:C154($winRef)
						
						If (OK=1)
							LotHoldForm_saveForm(Form:C1466.current_item; "ISSNF"; $form)
							Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
						End if 
				End case 
				
			Else 
				
			End if 
	End case
	
Function btn_move_down()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			cs:C1710.panel_planning.me.btnReOrderSteps("down")
			
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; OBJECT Get name:C1087(Object current:K67:2)); 9000; 9019))
			
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469()
	End case
	
Function btn_move_first()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			cs:C1710.panel_planning.me.btnReOrderSteps("first")
			
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; OBJECT Get name:C1087(Object current:K67:2)); 9000; 9019))
			
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469()
	End case
	
Function btn_move_last()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			cs:C1710.panel_planning.me.btnReOrderSteps("last")
			
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; OBJECT Get name:C1087(Object current:K67:2)); 9000; 9019))
			
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469()
	End case
	
Function btn_move_up()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			cs:C1710.panel_planning.me.btnReOrderSteps("up")
			
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; OBJECT Get name:C1087(Object current:K67:2)); 9000; 9019))
			
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469()
	End case
	
Function checkbox_lotOnHold()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			If (Not:C34(Form:C1466.sfw.checkIsInModification()))
				Form:C1466.current_item.onHold:=Not:C34(Form:C1466.current_item.onHold)  // revert
				return 
			End if 
			// Revert the checkbox — the dialog will set the real value
			Form:C1466.current_item.onHold:=Not:C34(Form:C1466.current_item.onHold)
			cs:C1710.panel_planning.me.holdLotAction(Choose:C955(Form:C1466.current_item.onHold; "off"; "on"))
	End case
	
Function df_steps_enabled_column()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			If (Form:C1466.selectedProperty#Null:C1517)
				// SNA / SNF ticked or unticked: the step gets or loses the lot's serial numbers
				If (New collection:C1472("SNA"; "SNF").indexOf(String:C10(Form:C1466.selectedProperty.name))#-1)
					cs:C1710.ga_serialization.me.syncStep(Form:C1466.current_item; Form:C1466.stepRow)
				End if 
				Form:C1466.stepRow.save()
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			End if 
	End case
	
Function df_steps_entry_alert()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			cs:C1710.panel_planning.me.saveStepRow()
	End case
	
Function df_steps_entry_description()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			cs:C1710.panel_planning.me.saveStepRow()
	End case
	
Function lb_serialization()

	If ((FORM Event:C1606.code=On Clicked:K2:13) | (FORM Event:C1606.code=On Selection Change:K2:69))
		cs:C1710.panel_planning.me.manageSerializationDetailPanel()
	End if
	
Function lb_steps()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			
			//cs.panel_planning.me.showDetailsForm()
			
			If (Form:C1466.stepRow#Null:C1517) && (Contextual click:C713)
				
				var $lotStepEntity : cs:C1710.LotStepEntity
				var $sfwInstance : cs:C1710.sfw
				
				$sfwInstance:=cs:C1710.sfw.new()
				$lotStepEntity:=Form:C1466.stepRow
				
				//$actions:=New collection()
				//$actions:=$lotStepEntity.getPossibleActions()
				
				//$refMenu:=Create menu
				
				//For ($i; 1; $actions.length)
				//APPEND MENU ITEM($refMenu; $actions[$i-1])
				//SET MENU ITEM PARAMETER($refMenu; $i; "--"+Replace string($actions[$i-1]; " "; ""))
				//End for 
				
				$refMenu:=Create menu:C408
				
				APPEND MENU ITEM:C411($refMenu; "Punch In")
				SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--PunchIn")
				
				APPEND MENU ITEM:C411($refMenu; "Punch Out")
				SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--PunchOut")
				
				$choose:=Dynamic pop up menu:C1006($refMenu)
				Case of 
					: ($choose="--PunchIn")
						$sfwInstance.openInANewWindow(Form:C1466.stepRow; "production"; "punchIn")
					: ($choose="--PunchOut")
						$sfwInstance.openInANewWindow(Form:C1466.stepRow; "production"; "punchOut")
				End case 
				
			End if 
			
			//$inModification:=sfw_checkIsInModification & (Form.stepRow#Null)
			
			//OBJECT SET ENABLED(*; "btn_move_first"; $inModification)
			//OBJECT SET ENABLED(*; "btn_move_up"; $inModification)
			//OBJECT SET ENABLED(*; "btn_move_down"; $inModification)
			//OBJECT SET ENABLED(*; "btn_move_last"; $inModification)
			//OBJECT SET ENABLED(*; "btn_delete_row"; $inModification)
			
	End case
	
Function pup_latePareto()
	cs:C1710.panel_planning.me.selectLatePareto()
	
Function sz_inp_comments()
	// Comments of a unit on the lot's table. The steps keep their own comments (why a unit failed
	// there), so this one is not copied to them. Touching the table lets Save see the change.
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			Form:C1466.current_item.snTable:=Form:C1466.current_item.snTable
			cs:C1710.panel_planning.me._activate_save_cancel_button()
	End case
	
Function sz_inp_secondIdentifier()
	Case of 
		: (FORM Event:C1606.code=On Before Keystroke:K2:6)
			
			Form:C1466.previousSN:=Form:C1466.snItem.serial_number
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			START TRANSACTION:C239
			$FailedSave:=False:C215
			For each ($step; Form:C1466.current_item.lotSteps)
				If (($step.snTable#Null:C1517) && ($step.snTable.items#Null:C1517))
					$item:=$step.snTable.items.query("id = :1"; Form:C1466.snItem.id)
					If ($item.length>0)
						$item[0].serial_number:=Form:C1466.snItem.serial_number
						$step.snTable:=$step.snTable  // touch the object attribute so save() persists the nested change
						$result:=$step.save()
						If (Not:C34($result.success))
							$FailedSave:=True:C214
						End if
					End if
				End if
			End for each
			
			If ($FailedSave)
				Form:C1466.snItem.serial_number:=Form:C1466.previousSN
				CANCEL TRANSACTION:C241
				ALERT:C41("One or more steps are locked, please free the record to update the serial number.")
			Else 
				VALIDATE TRANSACTION:C240
			End if 
			
	End case
	
