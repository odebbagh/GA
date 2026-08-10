singleton Class constructor
	// It's a singleton class
	
Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.drawPup_customer()
		This:C1470.loadLotSteps()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of 
			: ((FORM Get current page:C276(*)=2) | (FORM Get current page:C276(*)=3))
				This:C1470.loadLotSteps()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	OBJECT SET ENTERABLE:C238(*; "entryField_jobNumber"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_lotNumber"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_deviceNumber"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_customerLotNumber"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "pup_customer"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENABLED:C1123(*; "pup_customer"; Form:C1466.sfw.checkIsInModification())
	
	This:C1470.refreshStepTabLabel()
	Form:C1466.sfw.drawHTab()
	This:C1470.drawPup_customer()
	
	Case of 
		: (FORM Get current page:C276(*)=2)
			If (Form:C1466.stepRow#Null:C1517)
				This:C1470.displayDetailForm()
			Else 
				This:C1470.hideDetailForm()
			End if 
			This:C1470.manageReOrderBtns()
	End case 

Function loadLotSteps()
	Form:C1466.stepRow:=Null:C1517
	Form:C1466.stepPos:=0
	Form:C1466.lb_steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; Form:C1466.current_item.UUID).orderBy("order asc")
	This:C1470.refreshStepTabLabel()
	Form:C1466.sfw.drawHTab()
	This:C1470.hideDetailForm()
	This:C1470.manageReOrderBtns()

	
Function refreshStepTabLabel()
	Use (Form:C1466.sfw.entry.panel.pages)
		If (Form:C1466.sfw.entry.panel.pages.length>1)
			Form:C1466.sfw.entry.panel.pages[1].label:="Steps ("+String:C10(Form:C1466.lb_steps.length)+")"
		End if 
	End use 
	
Function bActionSteps()
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Add Step from Step File")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_stepfile")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	Case of 
		: ($choose="--create_from_stepfile")
			$form:=New object:C1471("lotInfo"; New object:C1471("customer"; Form:C1466.current_item.job.purchaseOrder.customer))
			
			$winRef:=Open form window:C675("createFromStepFile"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createFromStepFile"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				$length:=Form:C1466.lb_steps.length
				If (($form.stepFile.stepsDefinition#Null:C1517) & ($form.stepFile.stepsDefinition.items#Null:C1517) & ($form.stepFile.stepsDefinition.items.length>0))
					For each ($item; $form.stepFile.stepsDefinition.items)
						$hasStep:=False:C215
						
						// Preferred lookup from imported UUID link in step definition.
						If (cs:C1710.sfw_string.me.isAnEmptyUUID($item.UUID_Step)=False:C215)
							$step_e:=ds:C1482.Step.query("UUID = :1"; $item.UUID_Step).first()
							$hasStep:=($step_e#Null:C1517)
						End if 
						
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
							$step_new:=ds:C1482.LotStep.new()
							$step_new.description:=$step_e.description
							$step_new.alert:=$step_e.alert
							$step_new.UUID_Lot:=Form:C1466.current_item.UUID
							$step_new.order:=$length+1
							$length:=$length+1
							$res:=$step_new.save()
						End if 
					End for each 
				End if 
				This:C1470.loadLotSteps()
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			End if 
	End case 
	
Function selectCustomer()
	var $job : cs:C1710.JobEntity
	var $form : Object
	
	If (Form:C1466.sfw.checkIsInModification())
		$job:=Form:C1466.current_item.job
		If ($job=Null:C1517)
			$job:=ds:C1482.Job.get(Form:C1466.current_item.UUID_Job)
		End if 
		If ($job#Null:C1517)
			$form:=New object:C1471()
			$form.lb_items:=ds:C1482.Customer.all().orderBy("name")
			$form.words:=""
			
			OBJECT GET COORDINATES:C663(*; "pup_customer"; $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
			
			$winRef:=Open form window:C675("selectCustomer"; Pop up form window:K39:11; $l; $b+1)
			DIALOG:C40("selectCustomer"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1) && ($form.item#Null:C1517)
				$job.UUID_Customer:=$form.item.UUID
				$job.customerName:=$form.item.name
				$res:=$job.save()
				If ($res.success)
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					This:C1470.drawPup_customer()
				End if 
			End if 
		End if 
	End if 
	
Function selectJob()
	var $form : Object
	
	If (Form:C1466.sfw.checkIsInModification())
		OBJECT GET COORDINATES:C663(*; "pup_job"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "jobNumber"; \
			"lb_items"; ds:C1482.Job.all().orderBy("jobNumber"); \
			"allData"; ds:C1482.Job.all().orderBy("jobNumber"); \
			"dataclass"; "Job"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (OK=1) & ($form.item#Null:C1517)
			Form:C1466.current_item.UUID_Job:=$form.item.UUID
			Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
			This:C1470.drawPup_customer()
		End if 
	End if 
	
Function drawPup_customer()
	var $job : cs:C1710.JobEntity
	var $customerName : Text
	var $disabled : Boolean
	
	$customerName:=" "
	$disabled:=True:C214
	$job:=Form:C1466.current_item.job
	If ($job=Null:C1517)
		$job:=ds:C1482.Job.get(Form:C1466.current_item.UUID_Job)
	End if 
	If ($job#Null:C1517)
		$customerName:=$job.customer.name || " "
		$disabled:=Not:C34(Form:C1466.sfw.checkIsInModification())
	End if 
	Form:C1466.sfw.drawButtonPup("pup_customer"; $customerName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; $disabled)
Function manageReOrderBtns()
	OBJECT SET VISIBLE:C603(*; "btn_move@"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btn_delete_row"; Form:C1466.sfw.checkIsInModification())

	OBJECT SET ENABLED:C1123(*; "btn_move@"; (Form:C1466.stepRow#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btn_delete_row"; (Form:C1466.stepRow#Null:C1517))

	If (Form:C1466.sfw.checkIsInModification() & (Form:C1466.stepRow#Null:C1517))
		Case of 
			: (Form:C1466.stepPos=1)
				OBJECT SET ENABLED:C1123(*; "btn_move_first"; False:C215)
				OBJECT SET ENABLED:C1123(*; "btn_move_up"; False:C215)
				
			: (Form:C1466.stepPos=Form:C1466.lb_steps.length)
				OBJECT SET ENABLED:C1123(*; "btn_move_last"; False:C215)
				OBJECT SET ENABLED:C1123(*; "btn_move_down"; False:C215)
		End case 
	End if 

Function btnReOrderSteps($from : Integer; $to : Integer)
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.stepRow=Null:C1517)
		return 
	End if 
	If (($from=$to) | ($from<1) | ($to<1) | ($to>Form:C1466.lb_steps.length))
		return 
	End if 
	
	$coef:=1
	If (($to-$from)>0)
		$coef:=-1
	End if 
	
	If ($coef>0)
		$stepsToReOrder:=Form:C1466.lb_steps.query("order >= :1 AND order < :2"; Choose:C955(($from>$to); $to; $from); Choose:C955(($from>$to); $from; $to))
	Else 
		$stepsToReOrder:=Form:C1466.lb_steps.query("order > :1 AND order <= :2"; Choose:C955(($from>$to); $to; $from); Choose:C955(($from>$to); $from; $to))
	End if 
	
	For each ($lotStep; $stepsToReOrder)
		$lotStep.order:=$lotStep.order+$coef
		$res:=$lotStep.save()
	End for each 
	
	Form:C1466.stepRow.order:=$to
	$res:=Form:C1466.stepRow.save()
	
	This:C1470.loadLotSteps()
	Form:C1466.stepRow:=Form:C1466.lb_steps.query("order = :1"; $to).first()
	Form:C1466.stepPos:=$to
	LISTBOX SELECT ROW:C912(*; "lb_steps"; $to)
	This:C1470.displayDetailForm()
	This:C1470.manageReOrderBtns()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function deleteSelectedStep()
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.stepRow=Null:C1517)
		return 
	End if 
	
	$deletedOrder:=Form:C1466.stepRow.order
	$res:=Form:C1466.stepRow.drop()
	If (Not:C34($res.success))
		return 
	End if 
	
	$stepsToReOrder:=ds:C1482.LotStep.query("UUID_Lot = :1 AND order > :2"; Form:C1466.current_item.UUID; $deletedOrder).orderBy("order asc")
	For each ($lotStep; $stepsToReOrder)
		$lotStep.order:=$lotStep.order-1
		$res:=$lotStep.save()
	End for each 
	
	This:C1470.loadLotSteps()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	


Function refreshStepsTabLayout($showDetail : Boolean)
	var $widthSubform : Integer
	var $heightSubform : Integer
	var $leftSidebar : Integer
	var $topPanel : Integer
	var $rightSidebar : Integer
	var $bottomSidebar : Integer
	var $leftLb : Integer
	var $topLb : Integer
	var $rightLb : Integer
	var $bottomLb : Integer
	var $leftAction : Integer
	var $topAction : Integer
	var $rightAction : Integer
	var $bottomAction : Integer
	var $widthUpDownBtns : Integer
	var $hzDistancing : Integer
	var $detailWidth : Integer
	var $listRight : Integer
	var $detailLeft : Integer
	var $labLeft : Integer
	var $inpLeft : Integer
	var $inpRight : Integer
	var $btnRight : Integer
	var $btnTop : Integer
	var $btnBottom : Integer
	var $actionH : Integer
	var $_formObjects : Array
	var $_variablesArray : Array
	var $_pagesArray : Array
	var $i : Integer
	var $obLeft : Integer
	var $obTop : Integer
	var $obRight : Integer
	var $obBottom : Integer
	var $objectName : Text
	
	If (FORM Get current page:C276(*)#2)
		return 
	End if 
	
	$widthUpDownBtns:=26
	$hzDistancing:=10
	$detailWidth:=300
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $leftSidebar; $topPanel; $rightSidebar; $bottomSidebar)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $leftSidebar; $topPanel; $rightSidebar; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $leftLb; $topLb; $rightLb; $bottomLb)
	
	If ($showDetail)
		$listRight:=$widthSubform-$widthUpDownBtns-$detailWidth-$hzDistancing
	Else 
		$listRight:=$widthSubform-$widthUpDownBtns-$hzDistancing
	End if 
	
	OBJECT SET COORDINATES:C1248(*; "lb_steps"; $rightSidebar; $topLb; $listRight; $heightSubform)
	
	This:C1470.setStepPositionState()
	
	OBJECT GET COORDINATES:C663(*; "bActionSteps"; $leftAction; $topAction; $rightAction; $bottomAction)
	$actionH:=$bottomAction-$topAction
	OBJECT SET COORDINATES:C1248(*; "bActionSteps"; $leftAction; $heightSubform-$actionH-10; $rightAction; $heightSubform-10)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_first"; $obLeft; $btnTop; $btnRight; $btnBottom)
	$detailLeft:=$btnRight+$hzDistancing
	
	If ($showDetail)
		OBJECT SET VISIBLE:C603(*; "df@"; True:C214)
		OBJECT SET VISIBLE:C603(*; "bgkd"; True:C214)
		
		OBJECT SET COORDINATES:C1248(*; "bgkd"; $detailLeft; $topLb-1; $widthSubform-4; $heightSubform)
		
		$labLeft:=$detailLeft+10
		$inpLeft:=$labLeft+90
		$inpRight:=$widthSubform-12
		
		FORM GET OBJECTS:C898($_formObjects; $_variablesArray; $_pagesArray; Form current page:K67:6)
		
		For ($i; 1; Size of array:C274($_formObjects))
			$objectName:=$_formObjects{$i}
			Case of 
				: ($objectName="df_steps_label@")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $labLeft; $obTop; $labLeft+80; $obBottom)
				: ($objectName="df_steps_entry_description")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $inpLeft; $obTop; $inpRight; $obBottom)
				: ($objectName="df_steps_entry_control_params")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $inpLeft; $obTop; $inpRight; $heightSubform-8)
				: ($objectName="df_steps_entry@")
					OBJECT GET COORDINATES:C663(*; $objectName; $obLeft; $obTop; $obRight; $obBottom)
					OBJECT SET COORDINATES:C1248(*; $objectName; $inpLeft; $obTop; $inpRight; $obBottom)
			End case 
		End for 
	Else 
		OBJECT SET VISIBLE:C603(*; "df@"; False:C215)
		OBJECT SET VISIBLE:C603(*; "bgkd"; False:C215)
	End if 
	
Function displayDetailForm()
	This:C1470.refreshStepsTabLayout(True:C214)
	
Function hideDetailForm()
	This:C1470.refreshStepsTabLayout(False:C215)
	
Function setStepPositionState()
	
	$widthUpDownBtns:=26
	$hzDistancing:=10
	OBJECT GET COORDINATES:C663(*; "lb_steps"; $left_lb; $top_lb; $right_lb; $bottom_lb)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_first"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_first"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_up"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_up"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_down"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_down"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_move_last"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_move_last"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
	OBJECT GET COORDINATES:C663(*; "btn_delete_row"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "btn_delete_row"; $right_lb+$hzDistancing; $top; $right_lb+$hzDistancing+$widthUpDownBtns; $bottom)
	
