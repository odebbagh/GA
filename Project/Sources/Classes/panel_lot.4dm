singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		This:C1470.drawPup_Job()
		This:C1470.loadAllTabs()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=2)
				This:C1470.manageReOrderBtns()
				
				This:C1470.loadLotSteps()
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadMaterials()
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
	This:C1470.hideDatePickers()
	This:C1470.drawPup_LotStatus()
	This:C1470.drawPup_Job()
	
	
	OBJECT SET VISIBLE:C603(*; "bScan@"; ((Form:C1466.situation.mode="add") || (Form:C1466.situation.mode="modify")))
	OBJECT SET VISIBLE:C603(*; "btnForwar@"; Form:C1466.situation.mode="view")
	OBJECT SET ENTERABLE:C238(*; "entryField_CustomerName"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_lotNumber"; False:C215)
	
	OBJECT SET ENTERABLE:C238(*; "entryField_poNumber"; False:C215)
	OBJECT SET ENABLED:C1123(*; "pup_job"; Form:C1466.situation.mode="add")
	
	OBJECT SET ENTERABLE:C238(*; "pup_job"; Form:C1466.situation.mode="add")
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Lot Steps ("+String:C10(Form:C1466.lb_steps.length)+")"
		
	End use 
	Form:C1466.sfw.drawHTab()
	
	Case of 
		: (FORM Get current page:C276(*)=2)  // Lot Steps
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_steps"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionLotSteps"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			
			OBJECT GET COORDINATES:C663(*; "btnMoveTop"; $left_mt; $top_mt; $right_mt; $bottom_mt)
			OBJECT GET COORDINATES:C663(*; "btnMoveUp"; $left_mu; $top_mu; $right_mu; $bottom_mu)
			OBJECT GET COORDINATES:C663(*; "btnMoveDown"; $left_md; $top_md; $right_md; $bottom_md)
			OBJECT GET COORDINATES:C663(*; "btnMoveBottom"; $left_mb; $top_mb; $right_mb; $bottom_mb)
			OBJECT GET COORDINATES:C663(*; "btnDeleteRow"; $left_dr; $top_dr; $right_dr; $bottom_dr)
			
			$offset:=4
			$offset_r:=60
			$offset_btns_r:=15
			$offset_bAc:=10
			
			$width:=$right-$left
			$height:=$bottom-$top
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			$width_mt:=$right_mt-$left_mt
			$width_mu:=$right_mu-$left_mu
			$width_md:=$right_md-$left_md
			$width_mb:=$right_mb-$left_mb
			$width_dr:=$right_dr-$left_dr
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_steps"; $left_lb; $top_lb; $widthSubform-$offset_r; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionLotSteps"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			
			OBJECT SET COORDINATES:C1248(*; "btnMoveTop"; $widthSubform-$offset_btns_r-$width_mt; $top_mt; $widthSubform-$offset_btns_r; $bottom_mt)
			OBJECT SET COORDINATES:C1248(*; "btnMoveUp"; $widthSubform-$offset_btns_r-$width_mu; $top_mu; $widthSubform-$offset_btns_r; $bottom_mu)
			OBJECT SET COORDINATES:C1248(*; "btnMoveDown"; $widthSubform-$offset_btns_r-$width_md; $top_md; $widthSubform-$offset_btns_r; $bottom_md)
			OBJECT SET COORDINATES:C1248(*; "btnMoveBottom"; $widthSubform-$offset_btns_r-$width_mb; $top_mb; $widthSubform-$offset_btns_r; $bottom_mb)
			OBJECT SET COORDINATES:C1248(*; "btnDeleteRow"; $widthSubform-$offset_btns_r-$width_dr; $top_dr; $widthSubform-$offset_btns_r; $bottom_dr)
			
		: (FORM Get current page:C276(*)=3)  // Customer Provided Material
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_materials"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionCustProvMat"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_r:=5
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_materials"; $left_lb; $top_lb; $widthSubform-$offset_r; -$heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionCustProvMat"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			
		: (FORM Get current page:C276(*)=4)
			
			OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
			$offset:=4
			
			OBJECT GET COORDINATES:C663(*; "entryField_cOfCRemarks"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_cOfCRemarks"; $g; $h; $widthSubform-30; $b)
			
	End case 
	
Function loadAllTabs()
	This:C1470.loadLotSteps()
	
Function loadLotSteps()
	//Form.lb_steps:=Form.current_item.steps.orderBy("order asc")
	Form:C1466.currentstep:=0
	
	Form:C1466.lb_steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; Form:C1466.current_item.UUID).orderBy("order asc")
	$currentstep:=Form:C1466.lb_steps.query("qtyIn = :1 AND qtyOut = :1 AND dateIn = :2 AND dateOut = :2"; 0; !00-00-00!).orderBy("order asc")
	
	If ($currentstep.length>0)
		Form:C1466.currentstep:=$currentstep[0].order
	End if 
	
Function bActionSteps()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		
		APPEND MENU ITEM:C411($refMenu; "Create from step file")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_stepfile")
		
		APPEND MENU ITEM:C411($refMenu; "Create a step from template")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_template")
		
		APPEND MENU ITEM:C411($refMenu; "Edit a step")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		APPEND MENU ITEM:C411($refMenu; "Remove a step")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--remove")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		APPEND MENU ITEM:C411($refMenu; "Add steps from step file")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_step_file")
		
		APPEND MENU ITEM:C411($refMenu; "Generate traveller tag")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--Generate_traveller_tag")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--create_from_stepfile")
				$form:=New object:C1471("lotInfo"; New object:C1471("customer"; Form:C1466.current_item.job.purchaseOrder.customer))
				
				$winRef:=Open form window:C675("createFromStepFile"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createFromStepFile"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					$length:=Form:C1466.lb_steps.length
					If (($form.stepFile.stepsDefinition#Null:C1517) & ($form.stepFile.stepsDefinition.items#Null:C1517) & ($form.stepFile.stepsDefinition.items.length>0))
						For each ($item; $form.stepFile.stepsDefinition.items)
							If (cs:C1710.sfw_string.me.isAnEmptyUUID($item.UUID_Step)=False:C215)
								$step_o:=ds:C1482.Step.query("UUID = :1"; $item.UUID_Step).first()
								If ($step_o#Null:C1517)
									$step_o:=$step_o.toObject("description, alert, dataTables")
									
									$step_new:=ds:C1482.LotStep.new()
									
									$step_new.fromObject($step_o)
									$step_new.UUID_Lot:=Form:C1466.current_item.UUID
									
									If ($step_new.dataTables#Null:C1517) && ($step_new.dataTables.items#Null:C1517) && ($step_new.dataTables.items.length>0)
										$dtbl:=New object:C1471()
										For each ($dtCol; $step_new.dataTables.items.orderBy("order asc"))
											$dtbl[$dtCol.key]:=New collection:C1472()
										End for each
										$step_new.dataTable:=$dtbl
									End if
									
									If ($form.mode="append")
										$step_new.order:=$length+1
										$length:=$length+1
									Else 
										$step_new.order:=$item.order
									End if 
									
									$res:=$step_new.save()
								End if 
							End if 
						End for each 
					Else 
						For each ($step; $form.stepFile.moreData.selectedSteps)
							$step_o:=ds:C1482.Step.query("UUID = :1"; $step.UUID).first()
							$step_o:=$step_o.toObject("description, alert, dataTables")
							
							$step_new:=ds:C1482.LotStep.new()
							
							$step_new.fromObject($step_o)
							$step_new.UUID_Lot:=Form:C1466.current_item.UUID
							
							If ($step_new.dataTables#Null:C1517) && ($step_new.dataTables.items#Null:C1517) && ($step_new.dataTables.items.length>0)
								$dtbl:=New object:C1471()
								For each ($dtCol; $step_new.dataTables.items.orderBy("order asc"))
									$dtbl[$dtCol.key]:=New collection:C1472()
								End for each
								$step_new.dataTable:=$dtbl
							End if
							
							If ($form.mode="append")
								$step_new.order:=$length+1
								$length:=$length+1
							Else 
								$step_new.order:=$step.order
							End if 
							
							$res:=$step_new.save()
						End for each 
					End if 
					
					If ($form.mode="replace")
						Form:C1466.lb_steps.drop()
					End if 
					
					This:C1470.loadLotSteps()
					
					This:C1470._activate_save_cancel_button()
				End if 
				
			: ($choose="--create_from_template")
				$form:=New object:C1471(\
					"lotStep"; ds:C1482.LotStep.new()\
					)
				
				$form.lotStep.UUID_Lot:=Form:C1466.current_item.UUID
				$form.lotStep.order:=Form:C1466.lb_steps.length+1
				
				$winRef:=Open form window:C675("createStep_StepTemplate"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createStep_StepTemplate"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					$lotStep_e:=$form.lotStep
					
					$res:=$lotStep_e.save()
					
					If ($res.success)
						This:C1470.loadLotSteps()
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
				
			: ($choose="--create_from_step_file")
				$form:=New object:C1471("lotInfo"; New object:C1471("customer"; Form:C1466.current_item.customer))
				
				$winRef:=Open form window:C675("createStepFromStepFile"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createStepFromStepFile"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					For each ($step; $form.selectedSteps)
						$step_o:=$step.toObject("description, alert, qtyIn, qtyOut, dateIn, dateOut, dataTables")
						
						$step_new:=ds:C1482.LotStep.new()
						
						$step_new.fromObject($step_o)
						
						$step_new.UUID_Lot:=Form:C1466.current_item.UUID
						$step_new.order:=Form:C1466.lb_steps.length+1
						
						If ($step_new.dataTables#Null:C1517) && ($step_new.dataTables.items#Null:C1517) && ($step_new.dataTables.items.length>0)
							$dtbl:=New object:C1471()
							For each ($dtCol; $step_new.dataTables.items.orderBy("order asc"))
								$dtbl[$dtCol.key]:=New collection:C1472()
							End for each
							$step_new.dataTable:=$dtbl
						End if
						
						$res:=$step_new.save()
					End for each 
					
					This:C1470.loadLotSteps()
					
					This:C1470._activate_save_cancel_button()
				End if 
				
			: ($choose="--edit")
			: ($choose="--remove")
				
			: ($choose="--Generate_traveller_tag")
				
				var $check; $uncheked : Picture
				var $context_o : Object
				var $parameters : Object:=New object:C1471
				$wpDoc:=WP New:C1317()
				
				$parameters.data:=Form:C1466.current_item.moreData.barcodeData
				//$parameters.text:=Form.current_item.lotNumber
				$barcode:=_ga_generateBarCode($parameters)  //Form.current_item.lotNumber)
				
				$context:=New object:C1471(\
					"travelerNumber"; Form:C1466.current_item.moreData.barcodeData; \
					"jobNumber"; Form:C1466.current_item.job.jobNumber; \
					"partNumber"; Form:C1466.current_item.job.deviceNumber; \
					"lotNumber"; Form:C1466.current_item.lotNumber; \
					"customerNumber"; Form:C1466.current_item.job.purchaseOrder.customer.name; \
					"customerPo"; Form:C1466.current_item.job.purchaseOrder.poNumber; \
					"buildQty"; Form:C1466.current_item.job.qty; \
					"process"; Form:C1466.current_item.job.process; \
					"qualifier"; Form:C1466.current_item.job.pr_qualifier; \
					"dpaRating"; "DX-A1"; \
					"bin"; "325447"; \
					"esdClass"; "0"; \
					"barcode"; $barcode\
					)
				
				$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/travellerTag.4wp")
				$wpDoc:=WP Import document:C1318($file.platformPath)
				
				WP SET DATA CONTEXT:C1786($wpDoc; $context)
				
				SET PRINT PREVIEW:C364(True:C214)
				
				$path:=System folder:C487(Desktop:K41:16)+String:C10(Form:C1466.current_item.lotNumber)+".pdf"
				WP EXPORT DOCUMENT:C1337($wpDoc; $path; wk pdf:K81:315)
				ALERT:C41("Traveller tag exported successfully.")
				OPEN URL:C673($path)
				
				
				
				
				
				
		End case 
		
	Else 
		$refMenu:=Create menu:C408
		
		APPEND MENU ITEM:C411($refMenu; "Create from step file")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_stepfile")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		APPEND MENU ITEM:C411($refMenu; "Create a step from template")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_template")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		APPEND MENU ITEM:C411($refMenu; "(Edit a step")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		APPEND MENU ITEM:C411($refMenu; "(Remove a step")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--remove")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		APPEND MENU ITEM:C411($refMenu; "(Add steps from step file")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create_from_step_file")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		APPEND MENU ITEM:C411($refMenu; "Generate traveller tag")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--Generate_traveller_tag")
		DISABLE MENU ITEM:C150($refMenu; -1)
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
	End if 
	
Function btnReOrderLots($from : Integer; $to : Integer)
	If (Form:C1466.selectedLot#Null:C1517)
		$coef:=1
		
		If (($to-$from)>0)
			$coef:=-1
		End if 
		
		If ($coef>0)
			$lotsToReOrder:=Form:C1466.lb_steps.query("order >= :1 AND order < :2"; Choose:C955(($from>$to); $to; $from); Choose:C955(($from>$to); $from; $to))
		Else 
			$lotsToReOrder:=Form:C1466.lb_steps.query("order > :1 AND order <= :2"; Choose:C955(($from>$to); $to; $from); Choose:C955(($from>$to); $from; $to))
		End if 
		
		For each ($lot; $lotsToReOrder)
			$lot.order:=$lot.order+$coef
			
			$res:=$lot.save()
		End for each 
		
		Form:C1466.selectedLot.order:=$to
		
		$res:=Form:C1466.selectedLot.save()
		
		This:C1470.loadLotSteps()
		
		Form:C1466.selectedLot:=Form:C1466.lb_steps.query("order = :1"; $to).first()
		LISTBOX SELECT ROW:C912(*; "lb_steps"; $to)
		This:C1470.manageReOrderBtns()
		This:C1470._activate_save_cancel_button()
	End if 
	
Function manageReOrderBtns()
	OBJECT SET VISIBLE:C603(*; "btnMoveTop"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnMoveUp"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnMoveDown"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnMoveBottom"; Form:C1466.sfw.checkIsInModification())
	
	OBJECT SET ENABLED:C1123(*; "btnMoveTop"; (Form:C1466.selectedLot#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnMoveUp"; (Form:C1466.selectedLot#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnMoveDown"; (Form:C1466.selectedLot#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnMoveBottom"; (Form:C1466.selectedLot#Null:C1517))
	
	If (Form:C1466.sfw.checkIsInModification() & (Form:C1466.selectedLot#Null:C1517))
		Case of 
			: (Form:C1466.selectedLotPos=1)
				OBJECT SET ENABLED:C1123(*; "btnMoveTop"; False:C215)
				OBJECT SET ENABLED:C1123(*; "btnMoveUp"; False:C215)
				
			: (Form:C1466.selectedLotPos=Form:C1466.lb_steps.length)
				OBJECT SET ENABLED:C1123(*; "btnMoveBottom"; False:C215)
				OBJECT SET ENABLED:C1123(*; "btnMoveDown"; False:C215)
		End case 
	End if 
	
Function btnOpenCustomer()
	If (Form:C1466.current_item.purchaseOrder.customer#Null:C1517)
		$es:=ds:C1482.Customer.query("name = :1"; Form:C1466.current_item.job.purchaseOrder.customer.name)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "customer")
		End if 
	End if 
	
Function btnOpenPurchaseOrder()
	If (Form:C1466.current_item.job.purchaseOrder#Null:C1517)
		$es:=ds:C1482.PurchaseOrder.query("poNumber = :1"; Form:C1466.current_item.job.purchaseOrder.poNumber)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "purchaseOrders")
		End if 
	End if 
	
Function btnOpenJob()
	$entity:=Form:C1466.current_item.job
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "jobs")
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	
Function drawPup_LotStatus()
	If (Form:C1466.current_item#Null:C1517)
		Case of 
			: (Form:C1466.current_item.status=1)
				$color:="SeaGreen"
				$statusName:="Accepted"
				
			: (Form:C1466.current_item.status=2)
				$color:="Crimson"
				$statusName:="Rejected"
				
			Else 
				$color:=""
				$statusName:=" "
		End case 
		
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_lotStatus"; $statusName; $pathIcon; False:C215)
	End if 
	
Function pup_status()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		
		APPEND MENU ITEM:C411($menu; " "; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--nothing")
		
		If (Form:C1466.current_item.status=0)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		APPEND MENU ITEM:C411($menu; "Accepted"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--accepted")
		
		If (Form:C1466.current_item.status=1)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		APPEND MENU ITEM:C411($menu; "Rejected"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--rejected")
		
		If (Form:C1466.current_item.status=2)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose="--accepted")
				Form:C1466.current_item.status:=1
				
			: ($choose="--rejected")
				Form:C1466.current_item.status:=2
				
			Else 
				Form:C1466.current_item.status:=0
		End case 
		
	End if 
	This:C1470.drawPup_LotStatus()
	
	//Function selectJob()
	//If (Form.sfw.checkIsInModification())
	//Case of 
	//: (FORM Event.code=On Getting Focus) | (FORM Event.code=On Clicked)
	//OBJECT GET COORDINATES(*; "Field_customerName"; $l; $t; $r; $b)
	//CONVERT COORDINATES($l; $b; XY Current form; XY Main window)
	
	//$form:=New object(\
		"colName"; "jobNumber"; \
		"lb_items"; ds.Job.all().orderBy("jobNumber"); \
		"allData"; ds.Job.all().orderBy("jobNumber"); \
		"dataclass"; "Job"\
		)
	
	//$winRef:=Open form window("selectNto1"; Pop up form window; $l; $b-20)
	//DIALOG("selectNto1"; $form)
	//CLOSE WINDOW($winRef)
	
	//If (ok=1)
	//Form.current_item.UUID_Job:=$form.item.UUID
	
	//cs.panel_purchaseOrder.me._activate_save_cancel_button()
	//End if 
	//End case 
	//End if 
	
	
Function bActionCustProvMat()
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Receive Material")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--receive_material")
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--receive_material")
			$form:=New object:C1471(\
				"inventory_e"; ds:C1482.Inventory.new()\
				)
			
			$form.inventory_e.vendor:=Form:C1466.current_item.job.customerName
			$form.inventory_e.UUID_Lotzz:=Form:C1466.current_item.UUID
			$form.inventory_e.stockNum:="man_"+String:C10(ds:C1482.Inventory.all().length)+String:C10(Milliseconds:C459)
			$form.inventory_e.inventoryID:=(ds:C1482.Inventory.all().length>0) ? ds:C1482.Inventory.all().max("inventoryID")+1 : 1
			$form.inventory_e.code:="INV"+String:C10($form.inventory_e.inventoryID; "00000#")
			
			$winRef:=Open form window:C675("createManualInv_lot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createManualInv_lot"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (ok=1)
				$form.inventory_e.initialQty:=$form.inventory_e.qtyInStock
				$form.inventory_e.availableQty:=$form.inventory_e.qtyInStock
				
				$res:=$form.inventory_e.save()
				
				If ($res.success)
					This:C1470.loadMaterials()
					$form.inventory_e.afterCreation()
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
	End case 
	
	
Function loadMaterials()
	Form:C1466.lb_materials:=ds:C1482.Inventory.query("UUID_Lot = :1"; Form:C1466.current_item.UUID)
	
	
Function btnOpenLotParent()
	$entity:=Form:C1466.current_item.lotParent
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "lots")
	
	
Function splitLot()
	If (Form:C1466.sfw.checkIsInModification())
		var $splitGate : Object
		
		$splitGate:=cs:C1710.LotSplitService.me.canSplit(Form:C1466.current_item; New object:C1471("inModification"; Form:C1466.sfw.checkIsInModification()))
		If (Not:C34(Bool:C1537($splitGate.allowed)))
			cs:C1710.sfw_dialog.me.alert(String:C10($splitGate.message))
			return 
		End if 
		
		If (Undefined:C82(Form:C1466.current_item.lotParent))
			
			$newLot:=ds:C1482.Lot.new()
			
			$dataclassObject:=ds:C1482.Lot
			
			$id:=Form:C1466.current_item.subLots.length+1
			
			$newLotNumber:=Form:C1466.current_item.lotNumber+"-"+String:C10($id)
			
			$lot_es:=ds:C1482.Lot.query("lotNumber = :1"; $newLotNumber)
			
			While ($lot_es.length>0)
				$id:=$id+1
				
				$newLotNumber:=(Form:C1466.current_item.lotNumber)+"-"+String:C10($id)
				
				$lot_es:=ds:C1482.Lot.query("lotNumber = :1"; $newLotNumber)
			End while 
			
			For each ($attributeName; $dataclassObject)
				$attribute:=$dataclassObject[$attributeName]
				
				If ($attribute.kind="storage")
					Case of 
						: ($attributeName="UUID") & ($attribute.type="string")
							$newLot[$attributeName]:=Generate UUID:C1066
						: ($attributeName="UUID_LotParent") & ($attribute.type="string")
							$newLot.UUID_LotParent:=Form:C1466.current_item.UUID
						: ($attributeName="lotNumber")
							$newLot.lotNumber:=$newLotNumber
						Else 
							$newLot[$attributeName]:=Form:C1466.current_item[$attributeName]
					End case 
				End if 
			End for each 
			
			$res:=$newLot.save()
			
			If ($res.success)
				This:C1470._activate_save_cancel_button()
			End if 
			
		Else 
			//Sub Lot
			ALERT:C41("sub lot")
		End if 
	End if 
	
	
	
Function generateCofC()
	//Check if all QC Steps are done :
	$qcLotStepsDateOut:=Form:C1466.lb_steps.query("areas =:1"; "QC").toCollection().extract("dateOut")
	$allDone:=False:C215
	If ($qcLotStepsDateOut.indexOf(!00-00-00!)=-1)
		$allDone:=True:C214
	End if 
	
	If ($allDone)
		var $context : Object
		var $pictureVar : Picture
		var $filePath : Text
		
		$context:=New object:C1471()
		
		$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/COfCTemplate.4wp")
		$template:=WP Import document:C1318($file.platformPath)
		
		$context.user:=Current machine:C483
		$context.lot:=Form:C1466.current_item
		
		$images:=WP Get elements:C1550($template; wk type image:K81:192)
		$lotStep:=Form:C1466.current_item.steps.query("type =:1"; 999)
		If ($lotStep.length#1) | ((Form:C1466.current_item.dateOut#!00-00-00!) & (Form:C1466.current_item.readyToShipDate#!00-00-00!))
			WP DELETE PICTURE:C1701($images[0])
		End if 
		
		$context.lotStep:=$lotStep
		If (Not:C34(Undefined:C82(Form:C1466.current_item.job.address.shipping)))
			$shippingAddress:=Form:C1466.current_item.job.address.shipping
			$address:=$shippingAddress.street+"\n"+$shippingAddress.city+"\n"+$shippingAddress.state+" "+$shippingAddress.zipCode+"\n"+$shippingAddress.country
			
			$context.address:=Form:C1466.current_item.job.dropShipCustomer+"\n"+$address
		End if 
		
		
		
		//TO DO : To be changed and store stamp in database
		Case of 
				
			: (Form:C1466.current_item.status=1)
				$filePath:=Get 4D folder:C485(Current resources folder:K5:16)+"picts_GA"+Folder separator:K24:12+"QAStampAccept"+Form:C1466.current_item.cOfCInspector+".jpeg"
			: (Form:C1466.current_item.status=2)
				$filePath:=Get 4D folder:C485(Current resources folder:K5:16)+"picts_GA"+Folder separator:K24:12+"QAStampReject"+Form:C1466.current_item.cOfCInspector+".jpeg"
			Else 
				
		End case 
		
		READ PICTURE FILE:C678($filePath; $pictureVar)
		TRANSFORM PICTURE:C988($pictureVar; Scale:K61:2; 0.8; 0.8)
		$context.stamp:=$pictureVar
		
		//TO DO : To be changed and store signature in database
		If (Form:C1466.current_item.status>0) | (Form:C1466.current_item.location="Completed") | (Form:C1466.current_item.dateOut=!00-00-00!)
			$filePath:=Get 4D folder:C485(Current resources folder:K5:16)+"picts_GA"+Folder separator:K24:12+"QASignature"+Form:C1466.current_item.cOfCInspector+".jpeg"
			
			READ PICTURE FILE:C678($filePath; $pictureVar)
			TRANSFORM PICTURE:C988($pictureVar; Scale:K61:2; 0.5; 0.5)
			$context.signature:=$pictureVar
		End if 
		
		SET PRINT OPTION:C733(Orientation option:K47:2; 1)
		
		WP SET DATA CONTEXT:C1786($template; $context)
		
		PRINT SETTINGS:C106(2)
		
		WP PRINT:C1343($template)
		
	Else 
		cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "Can't print the Certificate of Conformance.Some QC steps still not done yet!"))
	End if 
	
	
	
/*
	
Function drawPup_PO()
If (Form.current_item#Null)
$poNumber:=String(Form.current_item.purchaseOrder.poNumber) || " "
Form.sfw.drawButtonPup("pup_purchaseOrder"; $poNumber; ""; (Form.current_item.purchaseOrder=Null))
End if 
//sfw/image/skin/rainbow/icon/spacer-1x24.png
	
Function selectPO()
	
If (Form.sfw.checkIsInModification())
	
$selector:=cs.sfw_definitionSelector.new("selectorPurchaseOrder"; "purchaseOrders")
$selector.setTitle("Choose a Purchase Order")
$selector.setCurrentItem(Form.current_item.purchaseOrder)
$selector.setOptions("noCutLink")
$selector.openSelector()
	
Case of 
: ($selector.isSelected())
$itemSeleted:=$selector.getCurrentItem()
	
Case of 
: ($itemSeleted=Null)
: (cs.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False)
Form.current_item.UUID_PurchaseOrder:=$itemSeleted.UUID
If (cs.sfw_string.me.isAnEmptyUUID(Form.current_item.UUID_PurchaseOrder)=True)
Form.current_item.UUID_PurchaseOrder:=16*"00"
End if 
End case 
This.drawPup_PO()
	
: ($selector.asCutTheLink())
Form.current_item.UUID_PurchaseOrder:=16*"00"
	
End case 
End if 
*/
	
Function drawPup_Job()
	
	If (Form:C1466.current_item#Null:C1517)
		$jobNumber:=String:C10(Form:C1466.current_item.job.jobNumber) || " "
		Form:C1466.sfw.drawButtonPup("pup_job"; $jobNumber; ""; (Form:C1466.current_item.job=Null:C1517))
	End if 
	//sfw/image/skin/rainbow/icon/spacer-1x24.png
	
Function selectJob()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorJob"; "jobs")
		$selector.setTitle("Choose a Job")
		$selector.setCurrentItem(Form:C1466.current_item.job)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						Form:C1466.current_item.UUID_Job:=$itemSeleted.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Job)=True:C214)
							Form:C1466.current_item.UUID_Job:=16*"00"
						End if 
				End case 
				This:C1470.drawPup_Job()
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Job:=16*"00"
				
		End case 
	End if 
	
	
	
	
	
	
	