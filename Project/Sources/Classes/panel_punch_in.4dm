singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID

Function checkBinQuantities($showAlert : Boolean)
	// block save while the total of the bin quantities differs from the step's quantity in
	var $bin : Object
	var $total : Real
	var $message; $prefix; $existing : Text
	var $kept : Collection

	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.current_item.bins=Null:C1517) || (Form:C1466.current_item.bins.items=Null:C1517) || (Form:C1466.current_item.bins.items.length=0)
		return
	End if

	// the rule only applies when binning is enabled on the step's template
	If (Form:C1466.current_item.step=Null:C1517) || (Form:C1466.current_item.step.stepTemplate=Null:C1517) || (Not:C34(Bool:C1537(Form:C1466.current_item.step.stepTemplate.binning)))
		return
	End if

	$total:=0
	For each ($bin; Form:C1466.current_item.bins.items)
		$total:=$total+Num:C11($bin.quantity)
	End for each

	// drop any previous bin-total message (the quantities inside the text may have changed)
	$prefix:="The total of the bin quantities"
	$kept:=New collection:C1472
	If (Form:C1466.validationRulesMessages#Null:C1517)
		For each ($existing; Form:C1466.validationRulesMessages)
			If (Position:C15($prefix; $existing)#1)
				$kept.push($existing)
			End if
		End for each
	End if
	Form:C1466.validationRulesMessages:=$kept

	If ($total#Num:C11(Form:C1466.current_item.qtyIn))
		$message:=$prefix+" ("+String:C10($total)+") is different from the quantity in ("+String:C10(Num:C11(Form:C1466.current_item.qtyIn))+")."
		Form:C1466.canValidate:=False:C215
		Form:C1466.validationRulesPassedWithSuccess:=False:C215
		Form:C1466.validationRulesMessages.push($message)
		If ($showAlert)
			cs:C1710.sfw_dialog.me.alert($message+"\rSave is not allowed until the quantities match.")
		End if
	Else
		// quantities match again: lift the block (only if no other validation message remains)
		If (Form:C1466.validationRulesMessages.length=0)
			Form:C1466.canValidate:=True:C214
			Form:C1466.validationRulesPassedWithSuccess:=True:C214
		End if
	End if

Function formMethod()

	Form:C1466.sfw.panelFormMethod()

	This:C1470.checkBinQuantities(False:C215)

	Form:C1466.specificationControl:=Form:C1466.current_item.getSpecificationControl()
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.properties#Null:C1517) && (Form:C1466.current_item.properties.items#Null:C1517)
		Form:C1466.stepPropertiesDisplay:=Form:C1466.current_item.properties.items.query("enabled = :1"; True:C214).extract("name").join(", ")
	Else 
		Form:C1466.stepPropertiesDisplay:=""
	End if 
	
	var $nextStep : 4D:C1709.Entity
	If (Form:C1466.current_item#Null:C1517)
		$nextStep:=Form:C1466.current_item.lot.lotSteps.query("order = :1"; Form:C1466.current_item.order+1).first()
		If ($nextStep#Null:C1517)
			Form:C1466.nextArea:=String:C10($nextStep.step.stepArea.name)
		Else 
			Form:C1466.nextArea:=""
		End if 
	End if 
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.snTable#Null:C1517) && (Form:C1466.current_item.snTable.items#Null:C1517)
		Form:C1466.hasSnItems:=(Form:C1466.current_item.snTable.items.length>0)
	Else 
		Form:C1466.hasSnItems:=False:C215
	End if 
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			//Tools Listbox
			This:C1470.loadToolsLb()
			This:C1470.loadDataTable()
			This:C1470.loadLotHolds()
			This:C1470.loadInventoryPulls()
			This:C1470.displayBannerLotOnHold()
			This:C1470.refreshActualHours()
	End case 
	
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadLotHolds()
		This:C1470.loadInventoryPulls()
		This:C1470.loadDataTable()
		This:C1470.displayBannerLotOnHold()
		This:C1470.refreshActualHours()
	End if 
	
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
Function canEditPanelFields()->$canEdit : Boolean
	
	$canEdit:=False:C215
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lot#Null:C1517) && (Form:C1466.current_item.lot.onHold)
		return 
	End if 
	$canEdit:=True:C214
	
Function applyCommentFieldFormats()
	
	var $format1 : Text
	var $format2 : Text
	
	$format1:=""
	$format2:=""
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.step#Null:C1517) && (Form:C1466.current_item.step.stepTemplate#Null:C1517)
		$format1:=Form:C1466.current_item.step.stepTemplate.comment1
		$format2:=Form:C1466.current_item.step.stepTemplate.comment2
	End if 
	
	If ($format1="") && (Form:C1466.current_item#Null:C1517)
		$format1:=Form:C1466.current_item.commentFormat1
	End if 
	If ($format2="") && (Form:C1466.current_item#Null:C1517)
		$format2:=Form:C1466.current_item.commentFormat2
	End if 
	
	If ($format1#"")
		OBJECT SET FORMAT:C236(*; "entryField_formattedComment1"; $format1)
		OBJECT SET FILTER:C235(*; "entryField_formattedComment1"; $format1)
		OBJECT SET PLACEHOLDER:C1295(*; "entryField_formattedComment1"; Replace string:C233($format1; "#"; "_"))
	End if 
	
	If ($format2#"")
		OBJECT SET FORMAT:C236(*; "entryField_formattedComment2"; $format2)
		OBJECT SET FILTER:C235(*; "entryField_formattedComment2"; $format2)
		OBJECT SET PLACEHOLDER:C1295(*; "entryField_formattedComment2"; Replace string:C233($format2; "#"; "_"))
	End if 
	
Function displayBannerLotOnHold()
	
	$bannerHeight:=30
	$canEdit:=This:C1470.canEditPanelFields()
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lot#Null:C1517) && (Form:C1466.current_item.lot.onHold)
		OBJECT SET VISIBLE:C603(*; "btn_hold_forms"; True:C214)
		OBJECT SET ENABLED:C1123(*; "btn_hold_forms"; True:C214)
		OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
		OBJECT SET COORDINATES:C1248(*; "banner_lotOnHold"; 0; $heightSubform-$bannerHeight; $widthSubform; $heightSubform)
		OBJECT SET COORDINATES:C1248(*; "banner_lotOnHold_lbl"; 0; $heightSubform-$bannerHeight; $widthSubform; $heightSubform)
		
		OBJECT SET VISIBLE:C603(*; "banner_lotOnHold"; True:C214)
		OBJECT SET VISIBLE:C603(*; "banner_lotOnHold_lbl"; True:C214)
	Else 
		OBJECT SET VISIBLE:C603(*; "btn_hold_forms"; False:C215)
		OBJECT SET ENABLED:C1123(*; "btn_hold_forms"; False:C215)
		OBJECT SET VISIBLE:C603(*; "banner_lotOnHold"; False:C215)
		OBJECT SET VISIBLE:C603(*; "banner_lotOnHold_lbl"; False:C215)
	End if 
	
	OBJECT SET ENABLED:C1123(*; "checkbox_lotOnHold"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENTERABLE:C238(*; "@entryField@"; $canEdit)
	OBJECT SET ENABLED:C1123(*; "df_field@"; $canEdit)
	OBJECT SET VISIBLE:C603(*; "df_btnDatePicker@"; $canEdit)
	OBJECT SET ENABLED:C1123(*; "cp_df_field_quantity"; $canEdit)
	OBJECT SET ENABLED:C1123(*; "sn_checkbox_pass"; $canEdit)
	OBJECT SET ENABLED:C1123(*; "sn_field_description_entryField"; $canEdit)
	
	This:C1470.applyCommentFieldFormats()
	This:C1470.displayStartButton()
	This:C1470.displayQASignoffSection()
	
Function displayQASignoffSection()
	
	var $show : Boolean
	var $canEdit : Boolean
	
	$show:=False:C215
	If (Form:C1466.current_item#Null:C1517)
		$show:=LotStep_hasQASignoff(Form:C1466.current_item)
	End if 
	
	$canEdit:=This:C1470.canEditPanelFields()
	
	OBJECT SET VISIBLE:C603(*; "dates_bkgd4"; $show)
	OBJECT SET VISIBLE:C603(*; "dates_header4"; $show)
	OBJECT SET VISIBLE:C603(*; "label_punch_in_section4"; $show)
	OBJECT SET VISIBLE:C603(*; "qa_@"; $show)
	OBJECT SET ENABLED:C1123(*; "qa_radio_@"; $show && $canEdit)
	
	If ($show)
		This:C1470.refreshQASignoffDisplay()
	End if 
	
Function refreshQASignoffDisplay()
	
	Form:C1466.qaSignoffDisplay:=""
	Form:C1466.qaLotAccepted:=False:C215
	Form:C1466.qaLotRejected:=False:C215
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.approvedBy#"")
		Form:C1466.qaSignoffDisplay:=LotStep_qaSignoffLabel(Form:C1466.current_item.approvedBy)
		Form:C1466.qaLotAccepted:=Not:C34(Form:C1466.current_item.qaRejected)
		Form:C1466.qaLotRejected:=Bool:C1537(Form:C1466.current_item.qaRejected)
	End if 
	
Function applyQASignoffDecision($qaRejected : Boolean)
	
	var $result : Object
	var $previousRejected : Boolean
	var $hadSignoff : Boolean
	
	If (Not:C34(This:C1470.canEditPanelFields()))
		This:C1470.refreshQASignoffDisplay()
		return 
	End if 
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	If (Not:C34(LotStep_hasQASignoff(Form:C1466.current_item)))
		return 
	End if 
	
	$hadSignoff:=(Form:C1466.current_item.approvedBy#"")
	$previousRejected:=Bool:C1537(Form:C1466.current_item.qaRejected)
	This:C1470.refreshQASignoffDisplay()
	
	$result:=LotStep_scanQASignoff(Form:C1466.current_item; $qaRejected)
	
	If ($result.success)
		Form:C1466.qaSignoffDisplay:=$result.display
		Form:C1466.qaLotAccepted:=Not:C34($qaRejected)
		Form:C1466.qaLotRejected:=$qaRejected
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Else 
		If ($hadSignoff)
			Form:C1466.current_item.qaRejected:=$previousRejected
			Form:C1466.current_item.isApproved:=Not:C34($previousRejected)
		End if 
		This:C1470.refreshQASignoffDisplay()
	End if 
	
Function displayStartButton()
	
	OBJECT SET VISIBLE:C603(*; "btnStart"; True:C214)
	OBJECT SET ENABLED:C1123(*; "btnStart"; Form:C1466.sfw.checkIsInModification() && This:C1470.canEditPanelFields())
	
Function refreshActualHours()
	
	If (Form:C1466.current_item#Null:C1517)
		LotStep_updateActHours(Form:C1466.current_item)
	End if 
	
Function redrawAndSetVisible()
	
	This:C1470.displayBannerLotOnHold()
	
	//Should use count formula in panel definition but can't from an object.. checl with Olivier later
	Use (Form:C1466.sfw.entry.panel.pages)
		If (Form:C1466.current_item.stepInterruptions#Null:C1517) && (Form:C1466.current_item.stepInterruptions.items#Null:C1517)
			Form:C1466.sfw.entry.panel.pages[1].label:="Step Interruption ["+String:C10(Form:C1466.current_item.stepInterruptions.items.length)+"]"
		Else 
			Form:C1466.sfw.entry.panel.pages[1].label:="Step Interruption [0]"
		End if 
		var $dtCount : Integer
		If (Form:C1466.lb_data_table#Null:C1517)
			$dtCount:=Form:C1466.lb_data_table.length
		Else 
			$dtCount:=0
		End if 
		Form:C1466.sfw.entry.panel.pages[5].label:="Data Table ["+String:C10($dtCount)+"]"
		var $holdCount : Integer
		$holdCount:=0
		If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lot#Null:C1517) && (Form:C1466.current_item.lot.lotHold#Null:C1517) && (Form:C1466.current_item.lot.lotHold.items#Null:C1517)
			For each ($holdItem; Form:C1466.current_item.lot.lotHold.items)
				If (($holdItem.action="on") || (String:C10($holdItem.holdAction)="Hold ON"))
					$holdCount:=$holdCount+1
				End if 
			End for each 
		End if 
		Form:C1466.sfw.entry.panel.pages[2].label:="Lot Holds ["+String:C10($holdCount)+"]"
		var $snCount : Integer
		If (Form:C1466.current_item.snTable#Null:C1517) && (Form:C1466.current_item.snTable.items#Null:C1517)
			$snCount:=Form:C1466.current_item.snTable.items.length
		Else 
			$snCount:=0
		End if 
		Form:C1466.hasSnItems:=($snCount>0)
		Form:C1466.sfw.entry.panel.pages[3].label:="Serialization ["+String:C10($snCount)+"]"
		var $pullCount : Integer
		If (Form:C1466.lb_inventoryPulls#Null:C1517)
			$pullCount:=Form:C1466.lb_inventoryPulls.length
		Else 
			$pullCount:=0
		End if 
		Form:C1466.sfw.entry.panel.pages[4].label:="Inventory Pulls ["+String:C10($pullCount)+"]"
	End use 
	Form:C1466.sfw.drawHTab()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	Case of 
		: (FORM Get current page:C276(*)=2)
			
			$heightButton:=21
			$spaceButton:=5
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
			OBJECT GET COORDINATES:C663(*; "bActionStepInterruptions"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
			OBJECT SET COORDINATES:C1248(*; "bActionStepInterruptions"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
			
			If (Form:C1466.stepInterruptionRow#Null:C1517)
				This:C1470.displayDetailForm()
			Else 
				This:C1470.hideDetailForm()
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
				This:C1470.displaySerializationDetailForm()
			Else 
				This:C1470.hideSerializationDetailForm()
			End if 
			
		: (FORM Get current page:C276(*)=5)
			
			$heightButton:=21
			$spaceButton:=5
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd5"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd5"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
			OBJECT GET COORDINATES:C663(*; "lb_inventoryPulls"; $g_lb; $h_lb; $d_lb; $b_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_inventoryPulls"; $g_lb; $h_lb; $widthSubform; $heightSubform-($heightButton+$spaceButton))
			OBJECT GET COORDINATES:C663(*; "bActionInventoryPulls"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
			OBJECT SET COORDINATES:C1248(*; "bActionInventoryPulls"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
			
		: (FORM Get current page:C276(*)=6)
			
			$heightButton:=21
			$spaceButton:=5
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd1"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd1"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
			OBJECT GET COORDINATES:C663(*; "lb_data_table"; $g_lb; $h_lb; $d_lb; $b_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_data_table"; $g_lb; $h_lb; $widthSubform; $heightSubform-($heightButton+$spaceButton)*2)
			OBJECT GET COORDINATES:C663(*; "bActionStepInterruptions1"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
			OBJECT SET COORDINATES:C1248(*; "bActionStepInterruptions1"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
			
		: (FORM Get current page:C276(*)=7)
			
			If (Form:C1466.consumedPartsRow#Null:C1517)
				This:C1470.displayConsumedPartsDF()
			Else 
				This:C1470.hideConsumedPartsDF()
			End if 
			
	End case 
	
Function bActionLotHolds()
	
	var $holdOn : Object
	var $lot : 4D:C1709.Entity
	
	If (Form:C1466.holdRow=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("Please select a hold record first.")
		return 
	End if 
	
	$lot:=Form:C1466.current_item.lot
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
	
Function bActionSteps()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Log Step Interruption")
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--log_step_interruption")
	SET MENU ITEM ICON:C984($refMenu; 1; "Path:/RESOURCES/image/button/add.png")
	
	If (Not:C34(This:C1470.canEditPanelFields()))
		DISABLE MENU ITEM:C150($refMenu; 1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	Case of 
		: ($choose="--log_step_interruption")
			$form:=New object:C1471()
			
			$winRef:=Open form window:C675("logStepInterruption"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("logStepInterruption"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				
				If (Form:C1466.current_item.stepInterruptions=Null:C1517)
					Form:C1466.current_item.stepInterruptions:=New object:C1471("items"; New collection:C1472())
				End if 
				
				If ($form.start_time#Null:C1517)
					$form.start_time:=Time:C179($form.start_time)
				End if 
				
				If ($form.end_time#Null:C1517)
					$form.end_time:=Time:C179($form.end_time)
				End if 
				
				Form:C1466.current_item.stepInterruptions.items.push($form)
				
			End if 
	End case 
	
Function initStepInterruptionRowTimes()
	
	If (Form:C1466.stepInterruptionRow=Null:C1517)
		return 
	End if 
	
	Form:C1466.stepInterruptionStartTimeDisplay:=This:C1470.formatInterruptionTimeForDisplay(Form:C1466.stepInterruptionRow.start_time)
	Form:C1466.stepInterruptionEndTimeDisplay:=This:C1470.formatInterruptionTimeForDisplay(Form:C1466.stepInterruptionRow.end_time)
	
Function formatInterruptionTimeForDisplay($value : Variant)->$display : Text
	
	Case of 
		: ($value=Null:C1517)
			$display:="00:00"
		: (Value type:C1509($value)=Is time:K8:8)
			$display:=String:C10(Time:C179($value); HH MM:K7:2)
		: ((Value type:C1509($value)=Is real:K8:4) | (Value type:C1509($value)=Is longint:K8:6))
			$display:=String:C10(Time:C179($value); HH MM:K7:2)
		: (String:C10($value)="")
			$display:="00:00"
		Else 
			$display:=String:C10($value)
	End case 
	
Function formatInterruptionTimeOnLosingFocus($raw : Text)->$formatted : Text
	var $digits : Text
	var $ch : Text
	var $hh : Text
	var $mm : Text
	var $i : Integer
	
	$digits:=""
	For ($i; 1; Length:C16($raw))
		$ch:=Substring:C12($raw; $i; 1)
		If ($ch>="0") & ($ch<="9")
			$digits:=$digits+$ch
		End if 
	End for 
	
	Case of 
		: (Length:C16($digits)=0)
			$hh:="00"
			$mm:="00"
		: (Length:C16($digits)=1)
			$hh:="0"+$digits
			$mm:="00"
		: (Length:C16($digits)=2)
			$hh:=$digits
			$mm:="00"
		: (Length:C16($digits)=3)
			$hh:=Substring:C12($digits; 1; 2)
			$mm:=Substring:C12($digits; 3; 1)+"0"
		Else 
			$hh:=Substring:C12($digits; 1; 2)
			$mm:=Substring:C12($digits; 3; 2)
	End case 
	
	$formatted:=$hh+":"+$mm
	
Function displayDetailForm()
	
	This:C1470.initStepInterruptionRowTimes()
	
	OBJECT SET VISIBLE:C603(*; "df@"; True:C214)
	
	OBJECT SET ENABLED:C1123(*; "df_field@"; This:C1470.canEditPanelFields())
	OBJECT SET VISIBLE:C603(*; "df_btnDatePicker@"; This:C1470.canEditPanelFields())
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	$heightButton:=21
	$spaceButton:=5
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "bActionStepInterruptions"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
	OBJECT SET COORDINATES:C1248(*; "bActionStepInterruptions"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
	
	OBJECT GET COORDINATES:C663(*; "lb_step_interruptions"; $g_lb; $h_lb; $d_lb; $b_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_step_interruptions"; $d_bkgd; $h_lb; $widthSubform-300; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "lb_step_interruptions"; $g_lb; $h_lb; $d_lb; $b_lb)
	
	OBJECT SET COORDINATES:C1248(*; "df_bkgd"; $d_lb; $h_lb-1; $widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "df_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	
	FORM GET OBJECTS:C898($_formObjects; $_variablesArray; $_pagesArray; Form current page:K67:6)
	
	For ($i; 1; Size of array:C274($_formObjects))
		If ($_formObjects{$i}="df_label@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+10; $ob_up)
		End if 
		If ($_formObjects{$i}="df_field@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+100; $ob_up)
		End if 
		If ($_formObjects{$i}="df_btnDatePicker@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+240; $ob_up)
		End if 
	End for 
	
Function hideDetailForm()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	$heightButton:=21
	$spaceButton:=5
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "bActionStepInterruptions"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
	OBJECT SET COORDINATES:C1248(*; "bActionStepInterruptions"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
	
	OBJECT GET COORDINATES:C663(*; "lb_step_interruptions"; $g_lb; $h_lb; $d_lb; $b_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_step_interruptions"; $g_lb; $h_lb; $widthSubform; $heightSubform)
	
	OBJECT SET VISIBLE:C603(*; "df@"; False:C215)
	
Function displayConsumedPartsDF()
	
	OBJECT SET VISIBLE:C603(*; "cp_df@"; True:C214)
	OBJECT SET ENABLED:C1123(*; "cp_df_field_quantity"; This:C1470.canEditPanelFields())
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	$heightButton:=21
	$spaceButton:=5
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd2"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd2"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "bActionConsumedParts"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
	OBJECT SET COORDINATES:C1248(*; "bActionConsumedParts"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
	
	OBJECT GET COORDINATES:C663(*; "lb_binning"; $g_lb; $h_lb; $d_lb; $b_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_binning"; $d_bkgd; $h_lb; $widthSubform-300; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "lb_binning"; $g_lb; $h_lb; $d_lb; $b_lb)
	
	OBJECT SET COORDINATES:C1248(*; "cp_df_bkgd"; $d_lb; $h_lb-1; $widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "cp_df_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	
	FORM GET OBJECTS:C898($_formObjects; $_variablesArray; $_pagesArray; Form current page:K67:6)
	
	For ($i; 1; Size of array:C274($_formObjects))
		If ($_formObjects{$i}="cp_df_label@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+10; $ob_up)
		End if 
		If ($_formObjects{$i}="cp_df_field@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+100; $ob_up)
		End if 
	End for 
	
Function hideConsumedPartsDF()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	$heightButton:=21
	$spaceButton:=5
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd2"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd2"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "bActionConsumedParts"; $g_btn_act; $h_btn_act; $d_btn_act; $b_btn_act)
	OBJECT SET COORDINATES:C1248(*; "bActionConsumedParts"; $g_btn_act; $heightSubform-$heightButton-$spaceButton)
	
	OBJECT GET COORDINATES:C663(*; "lb_binning"; $g_lb; $h_lb; $d_lb; $b_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_binning"; $g_lb; $h_lb; $widthSubform; $heightSubform)
	
	OBJECT SET VISIBLE:C603(*; "cp_df@"; False:C215)
	
Function displaySerializationDetailForm()
	
	OBJECT SET VISIBLE:C603(*; "sn_@"; True:C214)
	OBJECT SET ENABLED:C1123(*; "sn_checkbox_pass"; This:C1470.canEditPanelFields())
	OBJECT SET ENABLED:C1123(*; "sn_field_description_entryField"; This:C1470.canEditPanelFields())
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	$detailWidth:=300
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd4"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd4"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "lb_serialization"; $g_lb; $h_lb; $d_lb; $b_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_serialization"; $d_bkgd; $h_lb; $widthSubform-$detailWidth; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "lb_serialization"; $g_lb; $h_lb; $d_lb; $b_lb)
	
	OBJECT SET COORDINATES:C1248(*; "sn_bkgd"; $d_lb; $h_lb-1; $widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "sn_bkgd"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	
	FORM GET OBJECTS:C898($_formObjects; $_variablesArray; $_pagesArray; Form current page:K67:6)
	
	For ($i; 1; Size of array:C274($_formObjects))
		If ($_formObjects{$i}="sn_lbl@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+10; $ob_up)
		End if 
		If ($_formObjects{$i}="sn_label@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+10; $ob_up)
		End if 
		If ($_formObjects{$i}="sn_field@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+100; $ob_up)
		End if 
		If ($_formObjects{$i}="sn_checkbox@")
			OBJECT GET COORDINATES:C663(*; $_formObjects{$i}; $ob_left; $ob_up; $ob_right; $ob_down)
			OBJECT SET COORDINATES:C1248(*; $_formObjects{$i}; $g_bkgd+100; $ob_up)
		End if 
	End for 
	
Function hideSerializationDetailForm()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	OBJECT GET COORDINATES:C663(*; "rec_bkgd4"; $g_bkgd; $h_bkgd; $d_bkgd; $b_bkgd)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd4"; $g_bkgd; $h_bkgd; $d_bkgd; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "lb_serialization"; $g_lb; $h_lb; $d_lb; $b_lb)
	OBJECT SET COORDINATES:C1248(*; "lb_serialization"; $g_lb; $h_lb; $widthSubform; $heightSubform)
	
	OBJECT SET VISIBLE:C603(*; "sn_@"; False:C215)
	
Function loadToolsLb()
	
	Form:C1466.tools_lb:=New collection:C1472()
	
	If (Form:C1466.current_item.tools=Null:C1517)
		Form:C1466.current_item.tools:=New object:C1471()
	End if 
	
	//Empty tools object
	If (Form:C1466.current_item.tools.items=Null:C1517)
		Form:C1466.current_item.tools.items:=New collection:C1472()
	End if 
	
	//In case a new tool is added in the template
	If (Form:C1466.current_item.tools.items.length<Form:C1466.current_item.step.stepTemplate.stepTemplateToolTypes.length)
		$stepTemplateToolTypes:=Form:C1466.current_item.step.stepTemplate.stepTemplateToolTypes
		For each ($item; $stepTemplateToolTypes)
			If (Form:C1466.current_item.tools.items.query("uuid_toolType = :1 & order"; $item.UUID_ToolType; $item.order).length=0)
				Form:C1466.current_item.tools.items.push(New object:C1471("order"; $item.order; "uuid_toolType"; $item.toolType.UUID; "toolType"; $item.toolType.name; "toolName"; ""; "toolDate"; !00-00-00!))
			End if 
		End for each 
	End if 
	
Function loadDataTable()
	
	var $dataTable : Object
	var $list : Object
	var $nbCols; $i : Integer
	var $colName; $headerName; $fieldName; $headerTitle : Text
	var $row : Object
	
	// Remove all existing columns
	While (LISTBOX Get number of columns:C831(*; "lb_data_table")>0)
		LISTBOX DELETE COLUMN:C830(*; "lb_data_table"; 1)
	End while 
	
	Form:C1466.lb_data_table:=New collection:C1472()
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	$list:=Form:C1466.current_item.buildDataTableList(False:C215)
	If (Not:C34($list.hasTable))
		return 
	End if 
	
	$dataTable:=Form:C1466.current_item.ensureDataTable()
	Form:C1466.current_item.dataTable:=$dataTable
	Form:C1466.lb_dt_source:=$dataTable
	
	$nbCols:=$list.colCount
	
	// Insert one column per header (use col_N field names — headers may contain spaces)
	For ($i; 1; $nbCols)
		$colName:="col_dt_"+String:C10($i)
		$headerName:="hdr_dt_"+String:C10($i)
		$fieldName:="col_"+String:C10($i)
		$headerTitle:=String:C10($list["hdr"+String:C10($i)])
		LISTBOX INSERT COLUMN FORMULA:C970(*; "lb_data_table"; $i; $colName; "This."+$fieldName; Is text:K8:3; $headerName; $colName)
		OBJECT SET TITLE:C194(*; $headerName; $headerTitle)
	End for 
	
	For each ($row; $list.rows)
		Form:C1466.lb_data_table.push($row)
	End for each 
	
Function bActionDataTable()
	
	var $isModification; $hasSelection : Boolean
	$isModification:=This:C1470.canEditPanelFields()
	$hasSelection:=(Form:C1466.dataTablePos>0)
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Add Row")
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--add_row")
	SET MENU ITEM ICON:C984($refMenu; 1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34($isModification))
		DISABLE MENU ITEM:C150($refMenu; 1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Delete Row")
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--delete_row")
	SET MENU ITEM ICON:C984($refMenu; 2; "Path:/RESOURCES/image/button/delete.png")
	If (Not:C34($isModification)) | (Not:C34($hasSelection))
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	Case of 
		: ($choose="--add_row")
			This:C1470.addDataTableRow()
		: ($choose="--delete_row")
			This:C1470.deleteDataTableRow()
	End case 
	
Function addDataTableRow()
	
	var $dataTable : Object
	var $headers : Collection
	var $formObj; $page1Objects; $formData : Object
	var $header; $fieldName : Text
	var $i; $j; $top; $btnTop; $formWidth; $formHeight : Integer
	
	$dataTable:=Form:C1466.current_item.ensureDataTable()
	
	If ($dataTable=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No data table is defined for this step.")
		return 
	End if 
	Form:C1466.current_item.dataTable:=$dataTable
	
	$headers:=Form:C1466.current_item.getDataTableColumnKeys()
	
	If ($headers.length=0)
		cs:C1710.sfw_dialog.me.alert("No data table columns are defined for this step.")
		return 
	End if 
	
	$formWidth:=380
	$formHeight:=20+($headers.length*35)+54
	
	// Build form objects: one label + input per header
	$page1Objects:=New object:C1471()
	
	For ($i; 1; $headers.length)
		$header:=$headers[$i-1]
		$fieldName:="col_"+String:C10($i)
		$top:=20+(($i-1)*35)
		
		$page1Objects["lbl_"+String:C10($i)]:=New object:C1471(\
			"type"; "text"; \
			"top"; $top+2; \
			"left"; 10; \
			"width"; 120; \
			"height"; 20; \
			"text"; $header; \
			"stroke"; "#808080")
		
		$page1Objects["inp_"+String:C10($i)]:=New object:C1471(\
			"type"; "input"; \
			"top"; $top; \
			"left"; 140; \
			"width"; 220; \
			"height"; 22; \
			"dataSource"; "Form.newRow."+$fieldName; \
			"enterable"; True:C214; \
			"focusable"; True:C214; \
			"borderStyle"; "system")
	End for 
	
	$btnTop:=20+($headers.length*35)+10
	
	$page1Objects["btnOK"]:=New object:C1471(\
		"type"; "button"; \
		"text"; "OK"; \
		"top"; $btnTop; \
		"left"; $formWidth-180; \
		"width"; 80; \
		"height"; 24; \
		"action"; "accept")
	
	$page1Objects["btnCancel"]:=New object:C1471(\
		"type"; "button"; \
		"text"; "Cancel"; \
		"top"; $btnTop; \
		"left"; $formWidth-90; \
		"width"; 80; \
		"height"; 24; \
		"action"; "cancel")
	
	// Assemble the dynamic form definition
	$formObj:=New object:C1471(\
		"$4d"; New object:C1471("version"; "1"; "kind"; "form"); \
		"windowTitle"; "Add Row"; \
		"windowSizingX"; "fixed"; \
		"windowSizingY"; "fixed"; \
		"windowMinWidth"; $formWidth; \
		"windowMinHeight"; $formHeight; \
		"windowMaxWidth"; $formWidth; \
		"windowMaxHeight"; $formHeight; \
		"pages"; New collection:C1472(Null:C1517; New object:C1471("objects"; $page1Objects)))
	
	var $newRow : Object
	$newRow:=New object:C1471()
	For ($i; 1; $headers.length)
		$newRow["col_"+String:C10($i)]:=""
	End for 
	$formData:=New object:C1471("newRow"; $newRow)
	
	$winRef:=Open form window:C675($formObj; Modal form dialog box:K39:7; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40($formObj; $formData)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		var $j : Integer
		$newRow:=New object:C1471()
		For ($j; 1; $headers.length)
			var $value : Text
			$header:=$headers[$j-1]
			$fieldName:="col_"+String:C10($j)
			$value:=String:C10($formData.newRow[$fieldName])
			$newRow[$fieldName]:=$value
			$dataTable[$header].push($value)
		End for 
		Form:C1466.lb_data_table.push($newRow)
		Form:C1466.current_item.dataTable:=Form:C1466.lb_dt_source
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	End if 
	
Function editDataTableRow()
	
	var $dataTable : Object
	var $headers : Collection
	var $formObj; $page1Objects; $formData : Object
	var $header; $fieldName : Text
	var $i; $j; $top; $btnTop; $formWidth; $formHeight; $pos : Integer
	
	$pos:=Form:C1466.dataTablePos-1  // 0-based index
	
	If ($pos<0)
		return 
	End if 
	
	$dataTable:=Form:C1466.current_item.ensureDataTable()
	
	If ($dataTable=Null:C1517)
		return 
	End if 
	Form:C1466.current_item.dataTable:=$dataTable
	Form:C1466.lb_dt_source:=$dataTable
	
	$headers:=Form:C1466.current_item.getDataTableColumnKeys()
	
	If ($headers.length=0)
		return 
	End if 
	
	$formWidth:=380
	$formHeight:=20+($headers.length*35)+54
	
	// Build form prefilled with current row values
	$page1Objects:=New object:C1471()
	
	For ($i; 1; $headers.length)
		$header:=$headers[$i-1]
		$fieldName:="col_"+String:C10($i)
		$top:=20+(($i-1)*35)
		
		$page1Objects["lbl_"+String:C10($i)]:=New object:C1471(\
			"type"; "text"; \
			"top"; $top+2; \
			"left"; 10; \
			"width"; 120; \
			"height"; 20; \
			"text"; $header; \
			"stroke"; "#808080")
		
		$page1Objects["inp_"+String:C10($i)]:=New object:C1471(\
			"type"; "input"; \
			"top"; $top; \
			"left"; 140; \
			"width"; 220; \
			"height"; 22; \
			"dataSource"; "Form.editRow."+$fieldName; \
			"enterable"; True:C214; \
			"focusable"; True:C214; \
			"borderStyle"; "system")
	End for 
	
	$btnTop:=20+($headers.length*35)+10
	
	$page1Objects["btnOK"]:=New object:C1471(\
		"type"; "button"; \
		"text"; "OK"; \
		"top"; $btnTop; \
		"left"; $formWidth-180; \
		"width"; 80; \
		"height"; 24; \
		"action"; "accept")
	
	$page1Objects["btnCancel"]:=New object:C1471(\
		"type"; "button"; \
		"text"; "Cancel"; \
		"top"; $btnTop; \
		"left"; $formWidth-90; \
		"width"; 80; \
		"height"; 24; \
		"action"; "cancel")
	
	$formObj:=New object:C1471(\
		"$4d"; New object:C1471("version"; "1"; "kind"; "form"); \
		"windowTitle"; "Edit Row"; \
		"windowSizingX"; "fixed"; \
		"windowSizingY"; "fixed"; \
		"windowMinWidth"; $formWidth; \
		"windowMinHeight"; $formHeight; \
		"windowMaxWidth"; $formWidth; \
		"windowMaxHeight"; $formHeight; \
		"pages"; New collection:C1472(Null:C1517; New object:C1471("objects"; $page1Objects)))
	
	// Prefill with current values
	var $editRow : Object
	var $j : Integer
	$editRow:=New object:C1471()
	For ($j; 1; $headers.length)
		$header:=$headers[$j-1]
		$fieldName:="col_"+String:C10($j)
		$editRow[$fieldName]:=String:C10($dataTable[$header][$pos])
	End for 
	$formData:=New object:C1471("editRow"; $editRow)
	
	$winRef:=Open form window:C675($formObj; Modal form dialog box:K39:7; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40($formObj; $formData)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		var $updatedRow : Object
		$updatedRow:=New object:C1471()
		For ($j; 1; $headers.length)
			var $value : Text
			$header:=$headers[$j-1]
			$fieldName:="col_"+String:C10($j)
			$value:=String:C10($formData.editRow[$fieldName])
			$updatedRow[$fieldName]:=$value
			$dataTable[$header][$pos]:=$value
		End for 
		Form:C1466.lb_data_table[$pos]:=$updatedRow
		Form:C1466.current_item.dataTable:=Form:C1466.lb_dt_source
	End if 
	
Function deleteDataTableRow()
	
	var $pos : Integer
	var $header; $fieldName : Text
	
	$pos:=Form:C1466.dataTablePos
	
	If ($pos<=0)
		return 
	End if 
	
	// Remove the value at $pos from each header's array in the source
	var $dataTable : Object
	$dataTable:=Form:C1466.lb_dt_source
	
	If ($dataTable#Null:C1517)
		var $headers : Collection
		$headers:=OB Keys:C1719($dataTable)
		For each ($header; $headers)
			$dataTable[$header]:=$dataTable[$header].slice(0; $pos-1).concat($dataTable[$header].slice($pos))
		End for each 
	End if 
	
	// Remove the row from the listbox collection ($pos is 1-based, convert to 0-based)
	Form:C1466.lb_data_table:=Form:C1466.lb_data_table.slice(0; $pos-1).concat(Form:C1466.lb_data_table.slice($pos))
	Form:C1466.dataTableRow:=Null:C1517
	Form:C1466.dataTablePos:=0
	Form:C1466.current_item.dataTable:=Form:C1466.lb_dt_source
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function holdLotAction($action : Text)
	
	var $lot : 4D:C1709.Entity
	var $holds : Collection
	var $lastOn : Object
	var $holdCode : Text
	var $saveCheck : Object
	var $previousLotHold : Object
	var $previousOnHold : Boolean
	
	$form:=New object:C1471(\
		"holdLot"; New object:C1471(); \
		"holdDate"; Current date:C33; \
		"holdTime"; Time:C179(Current time:C178); \
		"holdAction"; Choose:C955($action="on"; "Hold ON"; "Hold OFF"); \
		"holdReason"; ""; \
		"performedBy"; ""; \
		"staffCode"; ""\
		)
	
	$lot:=Form:C1466.current_item.lot

	If ($lot=Null:C1517)
		return
	End if

	If ($action="off")
		If (Not:C34(LotHold_checkNcmnApprovals($lot)))
			cs:C1710.sfw_dialog.me.alert("This lot cannot be taken off hold: all four NCMN approvals (Customer Service, Engineering, QA/QC, Production) must be checked first.")
			return
		End if
	End if

	$saveCheck:=LotHoldForm_trySaveLot($lot)
	If (Not:C34($saveCheck.success))
		cs:C1710.sfw_dialog.me.alert("The lot record is locked or could not be saved. Please free the record before changing the hold status.")
		return
	End if

	If ($action="off") && ($lot.lotHold#Null:C1517) && ($lot.lotHold.items#Null:C1517)
		$lastOn:=$lot.lotHold.items.query("action = :1"; "on").orderBy("date desc; time desc").first()
		If ($lastOn=Null:C1517)
			$lastOn:=$lot.lotHold.items.query("holdAction = :1"; "Hold ON").orderBy("holdDate desc; holdTime desc").first()
		End if 
		If ($lastOn#Null:C1517)
			$holdCode:=""
			If ($lastOn.hold_code#Null:C1517)
				$holdCode:=$lastOn.hold_code
			Else 
				$holdCode:=$lastOn.holdCode
			End if 
			$form.hold_code:=New object:C1471("code"; $holdCode)
		End if 
	End if 
	
	$winRef:=Open form window:C675("holdLot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("holdLot"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		If ($lot.lotHold#Null:C1517) && ($lot.lotHold.items#Null:C1517)
			$previousLotHold:=New object:C1471("items"; $lot.lotHold.items.copy())
		Else 
			$previousLotHold:=Null:C1517
		End if 
		$previousOnHold:=Bool:C1537($lot.onHold)
		
		$holds:=New collection:C1472()
		If ($lot.lotHold#Null:C1517) && ($lot.lotHold.items#Null:C1517)
			For each ($item; $lot.lotHold.items)
				$holds.push($item)
			End for each 
		End if 
		
		$holds.push(New object:C1471(\
			"UUID"; Generate UUID:C1066; \
			"action"; $action; \
			"date"; $form.holdDate; \
			"time"; $form.holdTime; \
			"hold_code"; $form.holdLot.code; \
			"hold_reason"; $form.holdReason; \
			"performedBy"; $form.performedBy\
			))
		
		$lot.lotHold:=New object:C1471("items"; $holds)
		$lot.onHold:=($action="on")
		
		$saveCheck:=LotHoldForm_trySaveLot($lot)
		If (Not:C34($saveCheck.success))
			If ($previousLotHold#Null:C1517)
				$lot.lotHold:=$previousLotHold
			Else 
				$lot.lotHold:=Null:C1517
			End if 
			$lot.onHold:=$previousOnHold
			cs:C1710.sfw_dialog.me.alert("The lot record is locked or could not be saved. Please free the record before changing the hold status.")
			return 
		End if 
		
		This:C1470.loadLotHolds()
		This:C1470.displayBannerLotOnHold()
		This:C1470.redrawAndSetVisible()
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	End if 
	
Function loadLotHolds()
	
	Form:C1466.holdRow:=Null:C1517
	Form:C1466.holdPos:=0
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lot#Null:C1517) && (Form:C1466.current_item.lot.lotHold#Null:C1517) && (Form:C1466.current_item.lot.lotHold.items#Null:C1517)
		Form:C1466.lb_lotHolds:=LotHoldForm_mapItemsForList(Form:C1466.current_item.lot.lotHold.items).orderBy("sortDate desc; sortTime desc")
	Else 
		Form:C1466.lb_lotHolds:=New collection:C1472()
	End if 
	
Function loadInventoryPulls()
	
	Form:C1466.inventoryPullRow:=Null:C1517
	Form:C1466.inventoryPullPos:=0
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.lot#Null:C1517)
		Form:C1466.lb_inventoryPulls:=InventoryPullForm_loadForLot(Form:C1466.current_item.lot)
	Else 
		Form:C1466.lb_inventoryPulls:=New collection:C1472()
	End if 
	
Function bActionInventoryPulls()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Pull from inventory")
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--pull_from_inventory")
	SET MENU ITEM ICON:C984($refMenu; 1; "Path:/RESOURCES/image/button/add.png")
	
	APPEND MENU ITEM:C411($refMenu; "Put back to inventory")
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--put_back_to_inventory")
	SET MENU ITEM ICON:C984($refMenu; 2; "Path:/RESOURCES/image/button/add.png")
	
	If (Not:C34(This:C1470.canEditPanelFields()))
		DISABLE MENU ITEM:C150($refMenu; 1)
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	Case of 
		: ($choose="--pull_from_inventory")
			This:C1470.pullFromInventory()
		: ($choose="--put_back_to_inventory")
			This:C1470.putBackToInventory()
	End case 
	
Function pullFromInventory()
	
	var $lot : 4D:C1709.Entity
	var $inventoryItems : cs:C1710.InventorySelection
	var $form : Object
	var $winRef : Integer
	var $result : Object
	
	$lot:=Form:C1466.current_item.lot
	If ($lot=Null:C1517)
		return 
	End if 
	
	$inventoryItems:=InventoryPullForm_pullList($lot.UUID; (($lot.job#Null:C1517) ? $lot.job.UUID : ""))
	If ($inventoryItems.length=0)
		cs:C1710.sfw_dialog.me.alert("No inventory with available quantity found for this lot.")
		return 
	End if 
	
	$form:=New object:C1471(\
		"inventoryItems"; $inventoryItems; \
		"selectedInventory"; Null:C1517; \
		"inventoryDisplay"; ""; \
		"availableQty"; 0; \
		"qtyToPull"; 0; \
		"performedBy"; ""\
		)
	
	$winRef:=Open form window:C675("pullFromInventory"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("pullFromInventory"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		$result:=InventoryPullForm_savePull($lot; $form.selectedInventory; $form.qtyToPull; $form.performedBy)
		If ($result.success)
			This:C1470.loadInventoryPulls()
			This:C1470.redrawAndSetVisible()
			This:C1470._activate_save_cancel_button()
		Else 
			cs:C1710.sfw_dialog.me.alert($result.message)
		End if 
	End if 
	
Function putBackToInventory()
	
	var $lot : 4D:C1709.Entity
	var $inventoryItems : Collection
	var $form : Object
	var $winRef : Integer
	var $result : Object
	
	$lot:=Form:C1466.current_item.lot
	If ($lot=Null:C1517)
		return 
	End if 
	
	$inventoryItems:=InventoryPullForm_putBackList($lot.UUID; (($lot.job#Null:C1517) ? $lot.job.UUID : ""))
	If ($inventoryItems.length=0)
		cs:C1710.sfw_dialog.me.alert("No pulled inventory available to put back for this lot.")
		return 
	End if 
	
	$form:=New object:C1471(\
		"inventoryItems"; $inventoryItems; \
		"selectedInventory"; Null:C1517; \
		"inventoryDisplay"; ""; \
		"maxQty"; 0; \
		"qtyToPutBack"; 0; \
		"performedBy"; ""\
		)
	
	$winRef:=Open form window:C675("putBackToInventory"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("putBackToInventory"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		$result:=InventoryPullForm_savePutBack($lot; $form.selectedInventory; $form.qtyToPutBack; $form.performedBy)
		If ($result.success)
			This:C1470.loadInventoryPulls()
			This:C1470.redrawAndSetVisible()
			This:C1470._activate_save_cancel_button()
		Else 
			cs:C1710.sfw_dialog.me.alert($result.message)
		End if 
	End if 
	