singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		This:C1470.loadCurrentStep()
		//This.displayBannerLotOnHold()
		
		Case of 
			: (FORM Get current page:C276(*)=1)
				// add load functions
				This:C1470.loadTools()
				This:C1470.loadPMs()
				This:C1470.loadStepInterruptions()
				This:C1470.loadDataTables()
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadInventoryPulls()
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadSerialization()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
	
Function pup_XXX()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
	End if 
	This:C1470.drawPup_XXX()
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	OBJECT SET VISIBLE:C603(*; "banner_page_1"; (Form:C1466.currentStepOrder=0))
	
	If (OBJECT Get visible:C1075(*; "banner_lotOnHold_page"+String:C10(FORM Get current page:C276(*))))
		OBJECT GET COORDINATES:C663(*; "banner_lotOnHold_page"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $bottom)
		
		$width:=$right-$left
		$height:=$bottom-$top
		
		OBJECT SET COORDINATES:C1248(*; "banner_lotOnHold_page"+String:C10(FORM Get current page:C276(*)); $widthSubform-$width; $heightSubform-$height; $widthSubform; $heightSubform)
		
	End if 
	
	Case of 
		: (FORM Get current page:C276(*)=2)
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_pulls_2"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionPulls_2"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_pulls_2"; $left_lb; $top_lb; $right_lb; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionPulls_2"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			
		: (FORM Get current page:C276(*)=3)
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_3"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_sel_3"; $left_sel; $top_sel; $right_sel; $bottom_sel)
			OBJECT GET COORDINATES:C663(*; "lb_serializations_3"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			
			$offset:=4
			$offset_bAc:=10
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_3"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_sel_3"; $left_sel; $top_sel; $right_sel; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_serializations_3"; $left_lb; $top_lb; $right_lb; $heightSubform-$offset-1)
			
			
			This:C1470.displaySerialization()
	End case 
	
Function displaySerialization()
	OBJECT SET VISIBLE:C603(*; "selectedItemlabel_@"; Not:C34(Form:C1466.selectedItem=Null:C1517))
	OBJECT SET VISIBLE:C603(*; "Field_selectedItem_@"; Not:C34(Form:C1466.selectedItem=Null:C1517))
	OBJECT SET VISIBLE:C603(*; "entryField_selectedItem_@"; Not:C34(Form:C1466.selectedItem=Null:C1517))
	
	
Function checkForCertifications()->$valid : Boolean
	
	If (ds:C1482.sfw_User.query("login = :1"; Current user:C182).length>0)
		$staff_es:=ds:C1482.sfw_User.query("login = :1"; Current user:C182).first().staffs
	End if 
	
	If ($staff_es.length>0)
		$staff_e:=$staff_es[0]
		
		$missingCertifications:=New collection:C1472()
		
		If (Form:C1466.currentStep#Null:C1517) && (Form:C1466.currentStep.requitedCertifications#Null:C1517)
			$certifications:=Form:C1466.currentStep.requitedCertifications.items
			
			For each ($certification; $certifications)
				$assignments:=$staff_e.assignments.query("UUID_Certification = :1"; $certification.UUID_Certification)
				
				If ($assignments.length=0)
					$missingCertifications.push($certification)
				End if 
			End for each 
		End if 
		
		$valid:=($missingCertifications.length=0)
	End if 
	
Function loadCurrentStep()
	Form:C1466.currentStep:=Null:C1517
	Form:C1466.currentStepOrder:=0
	
	$currentstep:=Form:C1466.current_item.steps.query("qtyIn = :1 AND qtyOut = :1 AND dateIn = :2 AND dateOut = :2"; 0; !00-00-00!).orderBy("order asc")
	
	If ($currentstep.length>0)
		Form:C1466.currentStep:=$currentstep[0]
		OBJECT SET FORMAT:C236(*; "EntryField_comment1"; Form:C1466.currentStep.commentFormat1)
		OBJECT SET FILTER:C235(*; "EntryField_comment1"; Form:C1466.currentStep.commentFormat1)
		
		OBJECT SET FORMAT:C236(*; "EntryField_comment2"; Form:C1466.currentStep.commentFormat2)
		OBJECT SET FILTER:C235(*; "EntryField_comment2"; Form:C1466.currentStep.commentFormat2)
		
		OBJECT SET PLACEHOLDER:C1295(*; "EntryField_comment1"; Replace string:C233(Form:C1466.currentStep.commentFormat1; "#"; "_"))
		OBJECT SET PLACEHOLDER:C1295(*; "EntryField_comment2"; Replace string:C233(Form:C1466.currentStep.commentFormat2; "#"; "_"))
		
		If (This:C1470.checkForCertifications())
			Form:C1466.currentStepOrder:=Form:C1466.currentStep.order
			
			//OBJECT SET FORMAT(*; "EntryField_comment1"; Form.currentStep.commentFormat1)
			//OBJECT SET FILTER(*; "EntryField_comment1"; Form.currentStep.commentFormat1)
			
			//OBJECT SET FORMAT(*; "EntryField_comment2"; Form.currentStep.commentFormat2)
			//OBJECT SET FILTER(*; "EntryField_comment2"; Form.currentStep.commentFormat2)
			
			//OBJECT SET PLACEHOLDER(*; "EntryField_comment1"; Replace string(Form.currentStep.commentFormat1; "#"; "_"))
			//OBJECT SET PLACEHOLDER(*; "EntryField_comment2"; Replace string(Form.currentStep.commentFormat2; "#"; "_"))
			
			If (FORM Get current page:C276(*)#4)
				//FORM GOTO PAGE(1; *)
			End if 
		Else 
			Form:C1466.currentStepOrder:=0
			//FORM GOTO PAGE(3; *)
			//cs.sfw_dialog.me.alert("Some certifications are required for this lotStep !")
		End if 
	Else 
		Form:C1466.currentStepOrder:=0
		//FORM GOTO PAGE(2; *)
		This:C1470.displayBanner("No Current Step !!")
	End if 
	
	
Function loadTools()
	If (Form:C1466.currentStep#Null:C1517) && (Form:C1466.currentStep.tools#Null:C1517)
		Form:C1466.lb_tools:=Form:C1466.currentStep.tools.items
	Else 
		Form:C1466.lb_tools:=New collection:C1472()
	End if 
	
	
Function loadPMs()
	If (Form:C1466.currentStep#Null:C1517) && (Form:C1466.currentStep.parametricMeasurements#Null:C1517)
		Form:C1466.lb_pms:=Form:C1466.currentStep.parametricMeasurements.items
	Else 
		Form:C1466.lb_pms:=New collection:C1472()
	End if 
	
	
Function loadStepInterruptions()
	If (Form:C1466.currentStep#Null:C1517) && (Form:C1466.currentStep.stepInterruptions#Null:C1517)
		Form:C1466.lb_stepInterruptions:=Form:C1466.currentStep.stepInterruptions.items
	Else 
		Form:C1466.lb_stepInterruptions:=New collection:C1472()
	End if 
	
	
Function loadDataTables()
	If (Form:C1466.currentStep#Null:C1517) && (Form:C1466.currentStep.dataTables#Null:C1517) && (Form:C1466.currentStep.dataTables.items#Null:C1517)
		For each ($col; Form:C1466.currentStep.dataTables.items)
			If ($col.UUID=Null:C1517) | (String:C10($col.UUID)="")
				$col.UUID:=Generate UUID:C1066
			End if 
			$colName:=String:C10($col.name)
			If ($colName="")
				$colName:=String:C10($col.key)
			End if 
			$col.name:=$colName
			$col.key:=$colName
		End for each 
		$maxOrder:=0
		For each ($col; Form:C1466.currentStep.dataTables.items)
			If (Not:C34(Undefined:C82($col.order))) & ($col.order#Null:C1517)
				If (Num:C11($col.order)>$maxOrder)
					$maxOrder:=Num:C11($col.order)
				End if 
			End if 
		End for each 
		$nextOrder:=$maxOrder+1
		For each ($col; Form:C1466.currentStep.dataTables.items)
			If (Undefined:C82($col.order)) | ($col.order=Null:C1517)
				$col.order:=$nextOrder
				$nextOrder:=$nextOrder+1
			End if 
		End for each 
		Form:C1466.lb_dataTables:=Form:C1466.currentStep.dataTables.items.orderBy("order asc").copy()
	Else 
		Form:C1466.lb_dataTables:=New collection:C1472()
	End if 
	
	//Function displayBannerLotOnHold()
	//var $pict : Picture
	
	//If (Form.current_item.onHold)
	//OBJECT SET VISIBLE(*; "banner_lotOnHold"; True)
	//$bannerMessage:="Lot On Hold"
	
	//$svg:=SVG_New(285; 184)
	//$group:=SVG_New_group($svg; "onHold")
	//$rect:=SVG_New_rect($group; 0; 0; 500; 30; 0; 0; "green:50"; "orangered:50"; 1)
	//$text:=SVG_New_text($group; $bannerMessage; 175; 7; "helvetica"; 10; Bold; 3)
	//SVG_SET_TRANSFORM_ROTATE($group; -30; 250; 20)
	//SVG_SET_TRANSFORM_TRANSLATE($group; -50; 50)
	//SVG EXPORT TO PICTURE($svg; $pict)
	//SVG_CLEAR($svg)
	//Else 
	//OBJECT SET VISIBLE(*; "banner_lotOnHold"; False)
	//End if 
	//Form.bannerOnHold:=$pict
	
Function displayBanner($bannerMessage : Text)
	var $pict : Picture
	
	OBJECT SET VISIBLE:C603(*; "banner_page_1"; True:C214)
	
	$svg:=SVG_New(285; 184)
	$group:=SVG_New_group($svg; "onHold")
	$rect:=SVG_New_rect($group; 0; 0; 500; 30; 0; 0; "green:50"; "orangered:50"; 1)
	$text:=SVG_New_text($group; $bannerMessage; 175; 7; "helvetica"; 10; Bold:K14:2; 3)
	SVG_SET_TRANSFORM_ROTATE($group; -30; 250; 20)
	SVG_SET_TRANSFORM_TRANSLATE($group; -50; 50)
	SVG EXPORT TO PICTURE:C1017($svg; $pict)
	SVG_CLEAR($svg)
	
	Form:C1466.banner:=$pict
	
Function bActionChooseSkill()
	If (Form:C1466.currentToolType=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No Tool Type Selected !")
	Else 
		$refMenu:=Create menu:C408
		
		APPEND MENU ITEM:C411($refMenu; "Choose a tool")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--choose")
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--choose")
				$form:=New object:C1471(\
					"toolType"; Form:C1466.currentToolType; \
					"lb_tools"; ds:C1482.Tool.query("UUID_ToolType = :1"; Form:C1466.currentToolType.UUID)\
					)
				
				$winRef:=Open form window:C675("chooseTool_punchIn"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("chooseTool_punchIn"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.currentToolType.tool.UUID:=$form.selectedTool.UUID
					Form:C1466.currentToolType.tool.name:=$form.selectedTool.name
					Form:C1466.currentToolType.tool.date:=$form.selectedTool.date
					
					$res:=Form:C1466.currentStep.save()
					
					If (Not:C34($res.success))
						Form:C1466.currentToolType.tool.UUID:=""
						Form:C1466.currentToolType.tool.name:=""
					End if 
					
					This:C1470.loadTools()
					
					This:C1470._activate_save_cancel_button()
				End if 
		End case 
	End if 
	
Function bActionStepInterruption()
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Add an Interruption")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--add")
			$form:=New object:C1471(\
				"stepInterruption"; New object:C1471(\
				"startDate"; !00-00-00!; \
				"startTime"; ?00:00:00?; \
				"endDate"; !00-00-00!; \
				"endTime"; ?00:00:00?; \
				"engineer"; ""; \
				"description"; ""\
				))
			
			$winRef:=Open form window:C675("createStepInterruption_punchIn"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createStepInterruption_punchIn"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (ok=1)
				Form:C1466.currentStep.stepInterruptions.items.push($form.stepInterruption)
				
				$res:=Form:C1466.currentStep.save()
				
				If ($res.success)
					This:C1470.loadStepInterruptions()
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
			
	End case 
	
	
Function bActionDataTables()
	If (Form:C1466.currentDataTable=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No Data Table Selected !")
	Else 
		$refMenu:=Create menu:C408
		
		APPEND MENU ITEM:C411($refMenu; "Add a Data Table value")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--add")
				$dtLabel:=String:C10(Form:C1466.currentDataTable.name)
				If ($dtLabel="")
					$dtLabel:=String:C10(Form:C1466.currentDataTable.key)
				End if 
				$value:=Request:C163("Add a Data Table value to "+$dtLabel+" :")
				
				If (ok=1)
					Form:C1466.currentDataTable.value:=$value
					
					$res:=Form:C1466.currentStep.save()
					
					If ($res.success)
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
		End case 
	End if 
	
Function bActionPMs()
	If (Form:C1466.currentPM=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No Parametric Measurement Selected !")
	Else 
		$refMenu:=Create menu:C408
		
		APPEND MENU ITEM:C411($refMenu; "Add a Parametric Measurement value")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--add")
				$value:=Request:C163("Add a Parametric Measurement value to "+Form:C1466.currentPM.key+" :")
				
				If (ok=1)
					Form:C1466.currentPM.value:=$value
					
					$res:=Form:C1466.currentStep.save()
					
					If ($res.success)
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
		End case 
	End if 
	
Function loadInventoryPulls()
	If (Form:C1466.currentStep#Null:C1517)
		Form:C1466.lb_pulls:=ds:C1482.Inventory.query("UUID_Job = :1"; Form:C1466.currentStep.lot.job.UUID).pulls.query("type = :1"; "Pull").orderBy("inventory.code asc")
	End if 
	
Function bActionInvPull()
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Pull")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--pull")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.selectedPull=Null:C1517)
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	If ($choose#"")
		$form:=New object:C1471(\
			"onlyPull"; True:C214; \
			"invPull"; New object:C1471(\
			"order"; Form:C1466.lb_pulls.length+1; \
			"isPull"; True:C214; \
			"date"; Current date:C33(); \
			"currentQty"; Form:C1466.selectedPull.inventory.availableQty; \
			"qtyToPull"; 0; \
			"pulledBy"; ""; \
			"note"; ""\
			))
		
		$user_es:=ds:C1482.sfw_User.query("login = :1"; Current user:C182)
		
		$form.invPull.pulledBy:=($user_es.length>0) ? $user_es[0].fullName : ""
		
		$winRef:=Open form window:C675("create_invPull"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
		DIALOG:C40("create_invPull"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (OK=1)
			$pull_e:=ds:C1482.InventoryPull.new()
			$pull_e.type:="Pull"
			$pull_e.date:=cs:C1710.sfw_stmp.me.build($form.invPull.date)
			$pull_e.qty:=$form.invPull.qtyToPull
			$pull_e.remaining:=$form.invPull.currentQty-$form.invPull.qtyToPull
			$pull_e.performedBy:=$form.invPull.pulledBy
			//$pull_e.lotNumber:="N/A"
			$pull_e.statusIQA:="N/A"
			
			$pull_e.UUID_Inventory:=Form:C1466.selectedPull.inventory.UUID
			
			$res:=$pull_e.save()
			
			If ($res.success)
				Form:C1466.selectedPull.inventory.availableQty:=$pull_e.remaining
				
				
				$res:=Form:C1466.selectedPull.inventory.save()
				
				If (Not:C34($res.success))
					//TRACE
				End if 
				This:C1470.loadInventoryPulls()
				This:C1470._activate_save_cancel_button()
			End if 
		End if 
	End if 
	
	
Function loadSerialization()
	If (Form:C1466.currentStep#Null:C1517)
		Form:C1466.lb_serialization:=(Form:C1466.currentStep.serialization#Null:C1517) ? Form:C1466.currentStep.serialization.items : New collection:C1472()
	End if 
	