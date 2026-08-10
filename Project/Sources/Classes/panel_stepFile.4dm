property current_process : Text
property current_processUUID : Text
singleton Class constructor
	
	
Function formMethod()
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		Form:C1466.steps_lb:=New collection:C1472()
		Form:C1466.current_process:=Null:C1517
		Form:C1466.current_processUUID:=Null:C1517
		If (Not:C34(Undefined:C82(Form:C1466.sf_stepRulesPanelOpen)))
			Form:C1466.sf_stepRulesPanelOpen:=False:C215
		End if 
		If (Not:C34(Undefined:C82(Form:C1466.sf_stepRulesLastUUID)))
			Form:C1466.sf_stepRulesLastUUID:=""
		End if 
		If (Not:C34(Undefined:C82(Form:C1466.sf_specificationsPanelOpen)))
			Form:C1466.sf_specificationsPanelOpen:=False:C215
		End if 
		If (Not:C34(Undefined:C82(Form:C1466.sf_specificationsLastUUID)))
			Form:C1466.sf_specificationsLastUUID:=""
		End if 
		If (Not:C34(Undefined:C82(Form:C1466.sf_specificationsSearch)))
			Form:C1466.sf_specificationsSearch:=""
		End if 
		// Reload both step lists from current_item (Create / change record does not always fire recalculationOfPanelPageNeeded).
		This:C1470.loadSteps()
		This:C1470.loadSelectedSteps()
		This:C1470.drawPup_customer()
		This:C1470.drawPup_process()
		
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadSteps()
				This:C1470.loadSelectedSteps()
				This:C1470.manageReOrderBtns()
				This:C1470.manageStepDefinitionEditor()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function loadSteps()
	Form:C1466.selectedStep:=Null:C1517
	Form:C1466.selectedStepPos:=0
	
	If (Not:C34(Undefined:C82(Form:C1466.current_processUUID))) && (Form:C1466.current_processUUID#Null:C1517)
		Form:C1466.steps_lb:=ds:C1482.Step.query("UUID_StepProcess = :1"; Form:C1466.current_processUUID)  //.copy()
		//Else 
		//Form.steps_lb:=New collection()
	End if 
	
	
Function drawPup_customer()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.customer.name || " "
		Form:C1466.sfw.drawButtonPup("pup_customer"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.customer=Null:C1517))
	End if 
	
Function selectCustomer()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorCustomers"; "customer")
		$selector.setTitle("Choose a Customer")
		$selector.setCurrentItem(Form:C1466.current_item.customer)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						Form:C1466.current_item.UUID_Customer:=$itemSeleted.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer)=True:C214)
							Form:C1466.current_item.UUID_Customer:=16*"00"
						End if 
				End case 
				This:C1470.drawPup_customer()
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Customer:=16*"00"
			: ($selector.needCreation())
				$selector.createANewEntity("cs.panel_stepFile.me.callbackAfterCreationCustomer($1)")
		End case 
	End if 
	
Function callbackAfterCreationCustomer($key : Text)
	Form:C1466.current_item.UUID_Customer:=$key
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer)=True:C214)
		Form:C1466.current_item.UUID_Customer:=16*"00"
	End if 
	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_lead.me.drawPup_customer()); *)
	
	
	
Function drawPup_process()
	If (Form:C1466.current_process#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_process"; Form:C1466.current_process)
	Else 
		OBJECT SET TITLE:C194(*; "pup_process"; "⚙️ processes")
	End if 
	
	//OBJECT SET VISIBLE(*; "@billable"; False)
	
Function pup_process()
	var $form : Object
	var $processes : 4D:C1709.EntitySelection
	var $winRef : Integer
	
	If (Form:C1466.sfw.checkIsInModification())
		OBJECT GET COORDINATES:C663(*; "pup_process"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$processes:=ds:C1482.StepProcess.all().orderBy("name")
		
		$form:=New object:C1471(\
			"colName"; "name"; \
			"allData"; $processes; \
			"dataclass"; "StepProcess"\
			)
		//If ((Form.current_processUUID#Null) & (cs.sfw_string.me.isAnEmptyUUID(Form.current_processUUID)=False))
		//$form.initialUUID:=Form.current_processUUID
		//End if 
		
		$winRef:=Open form window:C675("select1toN"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("select1toN"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If ((ok=1) & ($form.item#Null:C1517))
			Form:C1466.current_processUUID:=$form.item.UUID
			Form:C1466.current_process:=$form.item.name
			This:C1470.loadSteps()
		End if 
	End if 
	
	This:C1470.drawPup_process()
	
	
Function ensureStepsDefinition()
	If (Form:C1466.current_item.stepsDefinition=Null:C1517)
		Form:C1466.current_item.stepsDefinition:=New object:C1471("items"; New collection:C1472())
	Else 
		If (Form:C1466.current_item.stepsDefinition.items=Null:C1517)
			Form:C1466.current_item.stepsDefinition.items:=New collection:C1472()
		End if 
	End if 
	
	
Function migrateLegacySelectedStepsIfNeeded()
	var $legacy : Collection
	var $stepEntity : 4D:C1709.Entity
	var $legacyRow : Object
	var $row : Object
	
	If (Form:C1466.current_item.stepsDefinition.items.length>0)
		return 
	End if 
	If (Form:C1466.current_item.moreData=Null:C1517)
		return 
	End if 
	If (Form:C1466.current_item.moreData.selectedSteps=Null:C1517)
		return 
	End if 
	$legacy:=Form:C1466.current_item.moreData.selectedSteps
	If ($legacy.length=0)
		return 
	End if 
	
	For each ($legacyRow; $legacy)
		$stepEntity:=ds:C1482.Step.query("UUID = :1"; $legacyRow.UUID).first()
		If ($stepEntity#Null:C1517)
			$row:=This:C1470.stepRowFromStepEntity($stepEntity; Num:C11($legacyRow.order))
			Form:C1466.current_item.stepsDefinition.items.push($row)
		Else 
			Form:C1466.current_item.stepsDefinition.items.push(New object:C1471(\
				"order"; Num:C11($legacyRow.order); \
				"UUID_Step"; $legacyRow.UUID; \
				"step_property_rules"; New object:C1471("items"; New collection:C1472())\
				))
		End if 
	End for each 
	
	
Function stepPropertyItemIsOn($it : Object)->$on : Boolean
	$on:=False:C215
	If ($it=Null:C1517)
		return 
	End if 
	If ($it.enable#Null:C1517)
		$on:=Bool:C1537($it.enable)
	Else 
		If ($it.enabled#Null:C1517)
			$on:=Bool:C1537($it.enabled)
		End if 
	End if 
	
	
Function stepPropertyNamesLabelForRow($row : Object)->$label : Text
	var $it : Object
	var $names : Collection
	var $n : Text
	var $pi : Integer
	var $useRules : Boolean
	
	$label:=""
	If ($row=Null:C1517)
		return 
	End if 
	
	$names:=New collection:C1472()
	$useRules:=False:C215
	If (($row.step_property_rules#Null:C1517) & ($row.step_property_rules.items#Null:C1517) & ($row.step_property_rules.items.length>0))
		$useRules:=True:C214
	End if 
	
	If ($useRules)
		For each ($it; $row.step_property_rules.items)
			If (($it.enable#Null:C1517) & Bool:C1537($it.enable))
				$n:=String:C10($it.name)
				If ($n#"")
					$names.push($n)
				End if 
			End if 
		End for each 
	Else 
		If (($row.stepProperties#Null:C1517) & ($row.stepProperties.items#Null:C1517))
			For each ($it; $row.stepProperties.items)
				If (This:C1470.stepPropertyItemIsOn($it))
					$n:=String:C10($it.name)
					If ($n#"")
						$names.push($n)
					End if 
				End if 
			End for each 
		End if 
	End if 
	
	If ($names.length>0)
		$label:=String:C10($names[0])
		For ($pi; 1; $names.length-1)
			$label:=$label+"-"+String:C10($names[$pi])
		End for 
	End if 
	
	
Function specificationDisplayLabelForRow($row : Object)->$label : Text
	var $it : Object
	var $parts : Collection
	var $t : Text
	var $pi : Integer
	
	$label:=""
	If ($row=Null:C1517)
		return 
	End if 
	
	$parts:=New collection:C1472()
	If (($row.stepSpecifications#Null:C1517) & ($row.stepSpecifications.items#Null:C1517))
		For each ($it; $row.stepSpecifications.items)
			If (($it.enable#Null:C1517) & Bool:C1537($it.enable))
				$t:=String:C10($it.spec)
				If ($t#"")
					$parts.push($t)
				End if 
			End if 
		End for each 
	End if 
	
	If ($parts.length>0)
		$label:=$parts[0]
		For ($pi; 1; $parts.length-1)
			$label:=$label+"-"+String:C10($parts[$pi])
		End for 
	Else 
		$label:=String:C10($row.specification)
	End if 
	
	
Function stepTemplateDisplayLabelForRow($row : Object)->$label : Text
	var $n : Integer
	
	$label:=""
	If ($row=Null:C1517)
		return 
	End if 
	$n:=Num:C11($row.step_template)
	If ($n=0)
		return 
	End if 
	$label:=String:C10($n)
	
	
Function touchLbSelectedSteps()
	var $p : Integer
	
	$p:=Num:C11(Form:C1466.stepPos)
	If ($p<=0)
		return 
	End if 
	LISTBOX SELECT ROW:C912(*; "lb_selectedSteps"; $p; lk replace selection:K53:1)
	
	
Function applyDerivedStepRowColumns($stepRow : Object)
	
	If ($stepRow=Null:C1517)
		return 
	End if 
	If ((Num:C11($stepRow.step_template)=0) & (Not:C34(Undefined:C82($stepRow.templateNumber))) & (Num:C11($stepRow.templateNumber)#0))
		$stepRow.step_template:=Num:C11($stepRow.templateNumber)
	End if 
	This:C1470.ensureStepSpecificationsForStep($stepRow)
	$stepRow.step_property_display:=This:C1470.stepPropertyNamesLabelForRow($stepRow)
	$stepRow.specification_display:=This:C1470.specificationDisplayLabelForRow($stepRow)
	$stepRow.step_template_display:=This:C1470.stepTemplateDisplayLabelForRow($stepRow)
	
	
Function refreshDerivedStepColumnsForCurrentStep()
	
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	This:C1470.applyDerivedStepRowColumns(Form:C1466.step)
	This:C1470.touchLbSelectedSteps()
	
	
Function refreshStepPropertyNamesColumn()
	var $stepRow : Object
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	This:C1470.ensureStepsDefinition()
	If ((Form:C1466.current_item.stepsDefinition=Null:C1517) || (Form:C1466.current_item.stepsDefinition.items=Null:C1517))
		return 
	End if 
	For each ($stepRow; Form:C1466.current_item.stepsDefinition.items)
		This:C1470.applyDerivedStepRowColumns($stepRow)
	End for each 
	This:C1470.touchLbSelectedSteps()
	
	
Function stepRowFromStepEntity($stepEntity : 4D:C1709.Entity; $order : Integer)->$row : Object
	var $md : Object
	var $specLookup : 4D:C1709.Entity
	var $tplByUUID : 4D:C1709.Entity
	
	$row:=New object:C1471
	$row.order:=$order
	$row.UUID_Step:=$stepEntity.UUID
	$row.description:=$stepEntity.description
	$row.alert:=$stepEntity.alert
	$row.specification:=""
	If ($stepEntity.specification#Null:C1517)
		$row.specification:=String:C10($stepEntity.specification.spec)
	Else 
		If (cs:C1710.sfw_string.me.isAnEmptyUUID($stepEntity.UUID_Specification)=False:C215)
			$specLookup:=ds:C1482.Specification.query("UUID = :1"; $stepEntity.UUID_Specification).first()
			If ($specLookup#Null:C1517)
				$row.specification:=String:C10($specLookup.spec)
			End if 
		End if 
	End if 
	$row.UUID_Specification:=16*"00"
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($stepEntity.UUID_Specification)=False:C215)
		$row.UUID_Specification:=$stepEntity.UUID_Specification
	End if 
	$row.area:=String:C10($stepEntity.areas)
	If ($row.area="")
		If ($stepEntity.stepArea#Null:C1517)
			$row.area:=String:C10($stepEntity.stepArea.name)
		End if 
	End if 
	$row.UUID_StepArea:=16*"00"
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($stepEntity.UUID_StepArea)=False:C215)
		$row.UUID_StepArea:=$stepEntity.UUID_StepArea
	End if 
	$row.step_template:=0
	If ($stepEntity.stepTemplate#Null:C1517)
		$row.step_template:=$stepEntity.stepTemplate.templateNumber
	Else 
		If (cs:C1710.sfw_string.me.isAnEmptyUUID($stepEntity.UUID_StepTemplate)=False:C215)
			$tplByUUID:=ds:C1482.StepTemplate.query("UUID = :1"; $stepEntity.UUID_StepTemplate).first()
			If ($tplByUUID#Null:C1517)
				$row.step_template:=$tplByUUID.templateNumber
			End if 
		End if 
	End if 
	$row.time:=0
	$row.yield:=0
	$row.temp_c:=0
	$row.template_repeat:=0
	$row.planned_hours:=0
	$row.bom_for_step:=""
	$row.step_property:=0
	$row.step_property_in_text:=""
	
	$md:=$stepEntity.moreData
	If ($md#Null:C1517)
		If ($md.time#Null:C1517)
			$row.time:=Num:C11($md.time)
		End if 
		If ($md.yield#Null:C1517)
			$row.yield:=Num:C11($md.yield)
		End if 
		If ($md.tempC#Null:C1517)
			$row.temp_c:=Num:C11($md.tempC)
		Else 
			If ($md.TempC#Null:C1517)
				$row.temp_c:=Num:C11($md.TempC)
			End if 
		End if 
		If ($md.template_repeat#Null:C1517)
			$row.template_repeat:=Num:C11($md.template_repeat)
		End if 
		If ($md.planhrs#Null:C1517)
			$row.planned_hours:=Num:C11($md.planhrs)
		Else 
			If ($md.planHrs#Null:C1517)
				$row.planned_hours:=Num:C11($md.planHrs)
			End if 
		End if 
		If ($md.BomForStep#Null:C1517)
			$row.bom_for_step:=String:C10($md.BomForStep)
		End if 
		If ($md.StepProperty#Null:C1517)
			$row.step_property:=Num:C11($md.StepProperty)
		End if 
		If ($md.StepPropertyinText#Null:C1517)
			$row.step_property_in_text:=String:C10($md.StepPropertyinText)
		End if 
		If (($row.specification="") & (Not:C34(Undefined:C82($md.controlSpecText))))
			$row.specification:=String:C10($md.controlSpecText)
		End if 
	End if 
	
	If ($stepEntity.stepProperties#Null:C1517)
		$row.stepProperties:=$stepEntity.stepProperties
	Else 
		$row.stepProperties:=New object:C1471("items"; New collection:C1472())
	End if 
	
	$row.step_property_rules:=This:C1470.newStepPropertyRulesObjectFromTemplate($stepEntity.stepTemplate)
	$row.step_property_rules_source_template:=Num:C11($row.step_template)
	This:C1470.mergeStepPropertyRuleEnableFromStepProperties($row)
	
	$row.stepSpecifications:=This:C1470.buildStepSpecificationsObjectForRow($row; $stepEntity; New collection:C1472())
	
	
Function buildStepSpecificationsObjectForRow($row : Object; $stepEntity : 4D:C1709.Entity; $extraLinkedSpecUUIDs : Collection)->$specObj : Object
	var $items : Collection
	var $linkedUUIDs : Collection
	var $specEnt : 4D:C1709.Entity
	var $link : 4D:C1709.Entity
	var $prior : Object
	var $oldItems : Collection
	var $fullTitle : Text
	var $en : Boolean
	var $x : Variant
	
	$specObj:=New object:C1471("items"; New collection:C1472())
	If ($row=Null:C1517)
		return 
	End if 
	
	$oldItems:=New collection:C1472()
	If (($row.stepSpecifications#Null:C1517) & ($row.stepSpecifications.items#Null:C1517))
		$oldItems:=$row.stepSpecifications.items
	End if 
	
	$linkedUUIDs:=New collection:C1472()
	If ($stepEntity#Null:C1517)
		For each ($link; ds:C1482.StepSpecification.query("UUID_Step = :1"; $stepEntity.UUID))
			If ($linkedUUIDs.indexOf($link.UUID_Specification)=-1)
				$linkedUUIDs.push($link.UUID_Specification)
			End if 
		End for each 
	End if 
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($row.UUID_Specification)=False:C215)
		If ($linkedUUIDs.indexOf($row.UUID_Specification)=-1)
			$linkedUUIDs.push($row.UUID_Specification)
		End if 
	End if 
	If ($extraLinkedSpecUUIDs#Null:C1517)
		For each ($x; $extraLinkedSpecUUIDs)
			If ($linkedUUIDs.indexOf($x)=-1)
				$linkedUUIDs.push($x)
			End if 
		End for each 
	End if 
	
	$items:=New collection:C1472()
	For each ($specEnt; ds:C1482.Specification.all().orderBy("spec"))
		$prior:=$oldItems.query("UUID_Specification = :1"; $specEnt.UUID).first()
		If ($prior#Null:C1517)
			$en:=False:C215
			If ($prior.enable#Null:C1517)
				$en:=Bool:C1537($prior.enable)
			End if 
		Else 
			$en:=($linkedUUIDs.indexOf($specEnt.UUID)#-1)
		End if 
		$fullTitle:=String:C10($specEnt.title)
		If ($fullTitle="")
			$fullTitle:=String:C10($specEnt.spec)
		End if 
		$items.push(New object:C1471(\
			"enable"; $en; \
			"UUID_Specification"; $specEnt.UUID; \
			"fullTitle"; $fullTitle; \
			"spec"; String:C10($specEnt.spec)\
			))
	End for each 
	
	$specObj.items:=$items
	
	
Function ensureStepSpecificationsForStep($step : Object)
	var $stepEnt : 4D:C1709.Entity
	var $need : Boolean
	var $catCount : Integer
	
	If ($step=Null:C1517)
		return 
	End if 
	
	$catCount:=ds:C1482.Specification.all().length
	$need:=True:C214
	If (($step.stepSpecifications#Null:C1517) & ($step.stepSpecifications.items#Null:C1517) & ($step.stepSpecifications.items.length=$catCount))
		$need:=False:C215
	End if 
	If (Not:C34($need))
		return 
	End if 
	
	$stepEnt:=Null:C1517
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($step.UUID_Step)=False:C215)
		$stepEnt:=ds:C1482.Step.query("UUID = :1"; $step.UUID_Step).first()
	End if 
	
	$step.stepSpecifications:=This:C1470.buildStepSpecificationsObjectForRow($step; $stepEnt; New collection:C1472())
	
	
Function applySfSpecificationsListboxFilter()
	var $needle : Text
	var $hay : Text
	var $it : Object
	var $filtered : Collection
	
	If (Form:C1466.step=Null:C1517)
		Form:C1466.sf_specificationsLB:=New collection:C1472()
		return 
	End if 
	This:C1470.ensureStepSpecificationsForStep(Form:C1466.step)
	If ((Form:C1466.step.stepSpecifications=Null:C1517) || (Form:C1466.step.stepSpecifications.items=Null:C1517))
		Form:C1466.sf_specificationsLB:=New collection:C1472()
		return 
	End if 
	
	If (Undefined:C82(Form:C1466.sf_specificationsSearch))
		Form:C1466.sf_specificationsSearch:=""
	End if 
	$needle:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace(String:C10(Form:C1466.sf_specificationsSearch)))
	
	If (Length:C16($needle)=0)
		Form:C1466.sf_specificationsLB:=Form:C1466.step.stepSpecifications.items
		return 
	End if 
	
	$filtered:=New collection:C1472()
	For each ($it; Form:C1466.step.stepSpecifications.items)
		$hay:=Lowercase:C14(String:C10($it.fullTitle)+" "+String:C10($it.spec))
		If (Position:C15($needle; $hay)>0)
			$filtered.push($it)
		End if 
	End for each 
	Form:C1466.sf_specificationsLB:=$filtered
	
	
Function syncSfSpecificationsListbox()
	
	If (Form:C1466.step=Null:C1517)
		Form:C1466.sf_specificationsLB:=New collection:C1472()
		return 
	End if 
	This:C1470.applySfSpecificationsListboxFilter()
	
	
Function syncStepSpecificationScalarsFromRow($step : Object)
	var $it : Object
	var $found : Boolean
	
	If ($step=Null:C1517)
		return 
	End if 
	If (($step.stepSpecifications=Null:C1517) || ($step.stepSpecifications.items=Null:C1517))
		return 
	End if 
	
	$found:=False:C215
	For each ($it; $step.stepSpecifications.items)
		If ((Not:C34($found)) & (Bool:C1537($it.enable)))
			$step.UUID_Specification:=$it.UUID_Specification
			$step.specification:=String:C10($it.spec)
			$found:=True:C214
		End if 
	End for each 
	
	If (Not:C34($found))
		$step.UUID_Specification:=16*"00"
		$step.specification:=""
	End if 
	
	
Function newStepPropertyRulesObjectFromTemplate($tpl : 4D:C1709.Entity)->$rulesObj : Object
	var $it : Object
	var $en : Boolean
	
	$rulesObj:=New object:C1471("items"; New collection:C1472())
	If ($tpl=Null:C1517)
		return 
	End if 
	If ($tpl.rules=Null:C1517) || ($tpl.rules.items=Null:C1517)
		return 
	End if 
	For each ($it; $tpl.rules.items)
		$en:=False:C215
		If ($it.enable#Null:C1517)
			$en:=Bool:C1537($it.enable)
		End if 
		$rulesObj.items.push(New object:C1471(\
			"id"; String:C10($it.id); \
			"name"; String:C10($it.name); \
			"description"; String:C10($it.description); \
			"bit"; String:C10($it.bit); \
			"enable"; $en\
			))
	End for each 
	
	
Function mergeStepPropertyRuleEnableFromStepProperties($row : Object)
	var $rule : Object
	var $match : Object
	
	If ($row=Null:C1517)
		return 
	End if 
	If (($row.step_property_rules=Null:C1517) || ($row.step_property_rules.items=Null:C1517))
		return 
	End if 
	If (($row.stepProperties=Null:C1517) || ($row.stepProperties.items=Null:C1517))
		return 
	End if 
	If ($row.stepProperties.items.length=0)
		return 
	End if 
	
	For each ($rule; $row.step_property_rules.items)
		$match:=Null:C1517
		If (String:C10($rule.bit)#"")
			$match:=$row.stepProperties.items.query("bit = :1"; String:C10($rule.bit)).first()
		End if 
		If (($match=Null:C1517) & (String:C10($rule.id)#""))
			$match:=$row.stepProperties.items.query("id = :1"; String:C10($rule.id)).first()
		End if 
		If (($match=Null:C1517) & (String:C10($rule.name)#""))
			$match:=$row.stepProperties.items.query("name = :1"; String:C10($rule.name)).first()
		End if 
		If ($match#Null:C1517)
			$rule.enable:=This:C1470.stepPropertyItemIsOn($match)
		End if 
	End for each 
	
	
Function ensureStepPropertiesItemsForRow($row : Object)
	var $spm : 4D:C1709.Entity
	var $bit : Text
	
	If ($row=Null:C1517)
		return 
	End if 
	If ($row.stepProperties=Null:C1517)
		$row.stepProperties:=New object:C1471("items"; New collection:C1472())
	End if 
	If ($row.stepProperties.items=Null:C1517)
		$row.stepProperties.items:=New collection:C1472()
	End if 
	If ($row.stepProperties.items.length>0)
		return 
	End if 
	
	For each ($spm; ds:C1482.StepProperty.all().orderBy("levelID"))
		$bit:=""
		If ($spm.moreData#Null:C1517)
			If ($spm.moreData.bit#Null:C1517)
				$bit:=String:C10($spm.moreData.bit)
			End if 
		End if 
		$row.stepProperties.items.push(New object:C1471(\
			"id"; $spm.UUID; \
			"name"; $spm.name; \
			"description"; $spm.description; \
			"bit"; $bit; \
			"enable"; False:C215\
			))
	End for each 
	
	
Function syncStepPropertiesEnableFromRules($row : Object)
	var $rule : Object
	var $match : Object
	
	If ($row=Null:C1517)
		return 
	End if 
	If (($row.step_property_rules=Null:C1517) || ($row.step_property_rules.items=Null:C1517))
		return 
	End if 
	This:C1470.ensureStepPropertiesItemsForRow($row)
	
	For each ($rule; $row.step_property_rules.items)
		$match:=Null:C1517
		If (String:C10($rule.bit)#"")
			$match:=$row.stepProperties.items.query("bit = :1"; String:C10($rule.bit)).first()
		End if 
		If (($match=Null:C1517) & (String:C10($rule.id)#""))
			$match:=$row.stepProperties.items.query("id = :1"; String:C10($rule.id)).first()
		End if 
		If (($match=Null:C1517) & (String:C10($rule.name)#""))
			$match:=$row.stepProperties.items.query("name = :1"; String:C10($rule.name)).first()
		End if 
		If ($match#Null:C1517)
			$match.enable:=Bool:C1537($rule.enable)
		End if 
	End for each 
	
	
Function ensureStepPropertyRulesForStep($step : Object)
	var $tpl : 4D:C1709.Entity
	var $tplNum : Integer
	
	If ($step=Null:C1517)
		return 
	End if 
	
	$tplNum:=Num:C11($step.step_template)
	
	If (($step.step_property_rules#Null:C1517) & ($step.step_property_rules.items#Null:C1517) & ($step.step_property_rules.items.length>0))
		If (Undefined:C82($step.step_property_rules_source_template))
			$step.step_property_rules_source_template:=$tplNum
			This:C1470.mergeStepPropertyRuleEnableFromStepProperties($step)
			return 
		End if 
		If (Num:C11($step.step_property_rules_source_template)=$tplNum)
			return 
		End if 
	End if 
	
	If ($tplNum=0)
		$step.step_property_rules:=New object:C1471("items"; New collection:C1472())
		$step.step_property_rules_source_template:=0
		return 
	End if 
	
	$tpl:=ds:C1482.StepTemplate.query("templateNumber = :1"; $tplNum).first()
	$step.step_property_rules:=This:C1470.newStepPropertyRulesObjectFromTemplate($tpl)
	$step.step_property_rules_source_template:=$tplNum
	This:C1470.mergeStepPropertyRuleEnableFromStepProperties($step)
	
	
Function syncSfStepRulesListbox()
	
	If (Form:C1466.step=Null:C1517)
		Form:C1466.sf_stepRulesLB:=New collection:C1472()
		return 
	End if 
	This:C1470.ensureStepPropertyRulesForStep(Form:C1466.step)
	If ((Form:C1466.step.step_property_rules#Null:C1517) & (Form:C1466.step.step_property_rules.items#Null:C1517))
		Form:C1466.sf_stepRulesLB:=Form:C1466.step.step_property_rules.items
	Else 
		Form:C1466.sf_stepRulesLB:=New collection:C1472()
	End if 
	
	
Function drawSfStepRulesButton()
	var $it : Object
	var $on : Integer
	var $tot : Integer
	
	If (Form:C1466.step=Null:C1517)
		OBJECT SET TITLE:C194(*; "sf_pup_stepRules"; "Step rules")
		return 
	End if 
	$on:=0
	$tot:=0
	If ((Form:C1466.step.step_property_rules#Null:C1517) & (Form:C1466.step.step_property_rules.items#Null:C1517))
		For each ($it; Form:C1466.step.step_property_rules.items)
			$tot:=$tot+1
			If (Bool:C1537($it.enable))
				$on:=$on+1
			End if 
		End for each 
	End if 
	OBJECT SET TITLE:C194(*; "sf_pup_stepRules"; String:C10($on)+"/"+String:C10($tot))
	
	
Function refreshStepDefinitionEditor()
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	This:C1470.syncSfStepRulesListbox()
	This:C1470.drawSfStepRulesButton()
	This:C1470.syncSfSpecificationsListbox()
	This:C1470.drawSfStepTemplate()
	This:C1470.drawSfArea()
	This:C1470.drawSfSpecification()
	This:C1470.refreshStepPropertyNamesColumn()
	
	
Function drawSfStepTemplate()
	var $tpl : 4D:C1709.Entity
	var $title : Text
	
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	$title:="Step template"
	If (Num:C11(Form:C1466.step.step_template)#0)
		$tpl:=ds:C1482.StepTemplate.query("templateNumber = :1"; Num:C11(Form:C1466.step.step_template)).first()
		If ($tpl#Null:C1517)
			$title:=$tpl.name
		Else 
			$title:="#"+String:C10(Form:C1466.step.step_template)
		End if 
	End if 
	OBJECT SET TITLE:C194(*; "sf_pup_stepTemplate"; $title)
	
	
Function drawSfArea()
	var $title : Text
	
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	$title:=Form:C1466.step.area
	If ($title="")
		$title:="Area"
	End if 
	OBJECT SET TITLE:C194(*; "sf_pup_area"; $title)
	
	
Function drawSfSpecification()
	var $title : Text
	var $specEnt : 4D:C1709.Entity
	var $it : Object
	var $on : Integer
	var $tot : Integer
	
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	This:C1470.ensureStepSpecificationsForStep(Form:C1466.step)
	If ((Form:C1466.step.stepSpecifications#Null:C1517) & (Form:C1466.step.stepSpecifications.items#Null:C1517) & (Form:C1466.step.stepSpecifications.items.length>0))
		$on:=0
		$tot:=Form:C1466.step.stepSpecifications.items.length
		For each ($it; Form:C1466.step.stepSpecifications.items)
			If (Bool:C1537($it.enable))
				$on:=$on+1
			End if 
		End for each 
		OBJECT SET TITLE:C194(*; "sf_pup_specification"; String:C10($on)+"/"+String:C10($tot))
		return 
	End if 
	
	$title:=""
	If (Not:C34(Undefined:C82(Form:C1466.step.UUID_Specification))) && (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.step.UUID_Specification)=False:C215)
		$specEnt:=ds:C1482.Specification.query("UUID = :1"; Form:C1466.step.UUID_Specification).first()
		If ($specEnt#Null:C1517)
			$title:=$specEnt.spec
		End if 
	End if 
	If ($title="")
		$title:=String:C10(Form:C1466.step.specification)
	End if 
	If (Length:C16($title)>36)
		$title:=Substring:C12($title; 1; 33)+"..."
	End if 
	If ($title="")
		$title:="Specification"
	End if 
	OBJECT SET TITLE:C194(*; "sf_pup_specification"; $title)
	
	
Function syncStepListboxSelectionAfterStepsLoad()
	var $row : Object
	var $still : Boolean
	
	If (Form:C1466.selectedSteps.length=0)
		Form:C1466.step:=Null:C1517
		Form:C1466.stepPos:=0
		LISTBOX SELECT ROW:C912(*; "lb_selectedSteps"; 0; lk remove from selection:K53:3)
		return 
	End if 
	
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	
	$still:=False:C215
	For each ($row; Form:C1466.selectedSteps)
		If ($row=Form:C1466.step)
			$still:=True:C214
		End if 
	End for each 
	
	If (Not:C34($still))
		Form:C1466.step:=Null:C1517
		Form:C1466.stepPos:=0
		LISTBOX SELECT ROW:C912(*; "lb_selectedSteps"; 0; lk remove from selection:K53:3)
	End if 
	
	
Function loadSelectedSteps()
	This:C1470.ensureStepsDefinition()
	This:C1470.migrateLegacySelectedStepsIfNeeded()
	This:C1470.refreshStepPropertyNamesColumn()
	Form:C1466.selectedSteps:=Form:C1466.current_item.stepsDefinition.items.orderBy("order")
	This:C1470.syncStepListboxSelectionAfterStepsLoad()
	This:C1470.manageReOrderBtns()
	
	
Function selectedStep()
	var $row : Object
	
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.selectedStep#Null:C1517)
		
		This:C1470.ensureStepsDefinition()
		This:C1470.migrateLegacySelectedStepsIfNeeded()
		
		If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.selectedStep.UUID)=False:C215)
			If (Form:C1466.current_item.stepsDefinition.items.query("UUID_Step = :1"; Form:C1466.selectedStep.UUID).first()#Null:C1517)
				return 
			End if 
		End if 
		
		$row:=This:C1470.stepRowFromStepEntity(Form:C1466.selectedStep; Form:C1466.current_item.stepsDefinition.items.length+1)
		Form:C1466.current_item.stepsDefinition.items.push($row)
		
		This:C1470.loadSelectedSteps()
		This:C1470.redrawAndSetVisible()
		
	End if 
	
	
Function manageStepDefinitionEditor()
	var $inpNamesLower : Collection
	var $detailLabsUpper : Collection
	var $detailLabsLower : Collection
	var $n : Text
	var $mod : Boolean
	var $hasRow : Boolean
	var $vis : Boolean
	var $rulesOpen : Boolean
	var $specsOpen : Boolean
	var $detailUpper : Boolean
	var $detailLower : Boolean
	var $sid : Text
	
	$mod:=Form:C1466.sfw.checkIsInModification()
	$hasRow:=(Form:C1466.step#Null:C1517)
	$vis:=$hasRow
	
	If ($hasRow)
		$sid:=String:C10(Form:C1466.step.UUID_Step)
		If ($sid="")
			$sid:="o:"+String:C10(Form:C1466.step.order)
		End if 
		If (Undefined:C82(Form:C1466.sf_stepRulesLastUUID))
			Form:C1466.sf_stepRulesLastUUID:=$sid
		Else 
			If (Form:C1466.sf_stepRulesLastUUID#$sid)
				Form:C1466.sf_stepRulesPanelOpen:=False:C215
				Form:C1466.sf_stepRulesLastUUID:=$sid
			End if 
		End if 
		If (Undefined:C82(Form:C1466.sf_specificationsLastUUID))
			Form:C1466.sf_specificationsLastUUID:=$sid
		Else 
			If (Form:C1466.sf_specificationsLastUUID#$sid)
				Form:C1466.sf_specificationsPanelOpen:=False:C215
				Form:C1466.sf_specificationsLastUUID:=$sid
				Form:C1466.sf_specificationsSearch:=""
			End if 
		End if 
	Else 
		Form:C1466.sf_stepRulesPanelOpen:=False:C215
		Form:C1466.sf_stepRulesLastUUID:=""
		Form:C1466.sf_specificationsPanelOpen:=False:C215
		Form:C1466.sf_specificationsLastUUID:=""
		Form:C1466.sf_specificationsSearch:=""
	End if 
	
	$rulesOpen:=False:C215
	If (Not:C34(Undefined:C82(Form:C1466.sf_stepRulesPanelOpen)))
		$rulesOpen:=Bool:C1537(Form:C1466.sf_stepRulesPanelOpen)
	End if 
	$specsOpen:=False:C215
	If (Not:C34(Undefined:C82(Form:C1466.sf_specificationsPanelOpen)))
		$specsOpen:=Bool:C1537(Form:C1466.sf_specificationsPanelOpen)
	End if 
	
	$detailUpper:=($vis & Not:C34($rulesOpen))
	$detailLower:=($detailUpper & Not:C34($specsOpen))
	
	OBJECT SET VISIBLE:C603(*; "rec_sf_editor"; $vis)
	OBJECT SET VISIBLE:C603(*; "sf_lbl_stepEditor"; $vis)
	OBJECT SET VISIBLE:C603(*; "sf_lab_stepRules"; $vis)
	OBJECT SET VISIBLE:C603(*; "sf_pup_stepRules"; $vis)
	OBJECT SET ENABLED:C1123(*; "sf_pup_stepRules"; $hasRow)
	
	$detailLabsUpper:=New collection:C1472("sf_lab_description"; "sf_lab_stepTemplate"; "sf_lab_area"; "sf_lab_specPick")
	For each ($n; $detailLabsUpper)
		OBJECT SET VISIBLE:C603(*; $n; $detailUpper)
	End for each 
	
	$detailLabsLower:=New collection:C1472("sf_lab_time"; "sf_lab_yield"; "sf_lab_tempC"; "sf_lab_planHrs"; "sf_lab_alert"; "sf_lab_bom")
	For each ($n; $detailLabsLower)
		OBJECT SET VISIBLE:C603(*; $n; $detailLower)
	End for each 
	
	$inpNamesLower:=New collection:C1472("sf_inp_time"; "sf_inp_yield"; "sf_inp_temp_c"; "sf_inp_planned_hours"; "sf_inp_alert"; "sf_inp_bom_for_step")
	For each ($n; $inpNamesLower)
		OBJECT SET VISIBLE:C603(*; $n; $detailLower)
		OBJECT SET ENTERABLE:C238(*; $n; Choose:C955(($mod & $hasRow & $detailLower); True:C214; False:C215))
	End for each 
	
	OBJECT SET VISIBLE:C603(*; "sf_inp_description"; $detailUpper)
	OBJECT SET ENTERABLE:C238(*; "sf_inp_description"; Choose:C955(($mod & $hasRow & $detailUpper); True:C214; False:C215))
	
	OBJECT SET VISIBLE:C603(*; "lb_sf_stepRules"; ($vis & $rulesOpen))
	OBJECT SET ENTERABLE:C238(*; "lb_sf_stepRules"; Choose:C955(($mod & $hasRow & $rulesOpen); True:C214; False:C215))
	
	OBJECT SET VISIBLE:C603(*; "lb_sf_specifications"; ($vis & $specsOpen & Not:C34($rulesOpen)))
	OBJECT SET ENTERABLE:C238(*; "lb_sf_specifications"; Choose:C955(($mod & $hasRow & $specsOpen & Not:C34($rulesOpen)); True:C214; False:C215))
	
	OBJECT SET VISIBLE:C603(*; "sf_lab_specificationsSearch"; ($vis & $specsOpen & Not:C34($rulesOpen)))
	OBJECT SET VISIBLE:C603(*; "sf_inp_specificationsSearch"; ($vis & $specsOpen & Not:C34($rulesOpen)))
	OBJECT SET ENTERABLE:C238(*; "sf_inp_specificationsSearch"; Choose:C955(($mod & $hasRow & $specsOpen & Not:C34($rulesOpen)); True:C214; False:C215))
	
	OBJECT SET VISIBLE:C603(*; "sf_pup_stepTemplate"; $detailUpper)
	OBJECT SET VISIBLE:C603(*; "sf_pup_area"; $detailUpper)
	OBJECT SET VISIBLE:C603(*; "sf_pup_specification"; $detailUpper)
	OBJECT SET ENABLED:C1123(*; "sf_pup_stepTemplate"; ($mod & $hasRow & $detailUpper))
	OBJECT SET ENABLED:C1123(*; "sf_pup_area"; ($mod & $hasRow & $detailUpper))
	OBJECT SET ENABLED:C1123(*; "sf_pup_specification"; ($mod & $hasRow & $detailUpper))
	
	If ($hasRow)
		This:C1470.ensureStepPropertyRulesForStep(Form:C1466.step)
		This:C1470.refreshStepDefinitionEditor()
	Else 
		Form:C1466.sf_stepRulesLB:=New collection:C1472()
		Form:C1466.sf_specificationsLB:=New collection:C1472()
		OBJECT SET TITLE:C194(*; "sf_pup_stepRules"; "Step rules")
	End if 
	
	
Function pupSfStepTemplate()
	var $templates : 4D:C1709.EntitySelection
	var $form : Object
	var $winRef : Integer
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.step=Null:C1517)
		return 
	End if 
	
	OBJECT GET COORDINATES:C663(*; "sf_pup_stepTemplate"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	
	$templates:=ds:C1482.StepTemplate.all().orderBy("name")
	
	$form:=New object:C1471(\
		"colName"; "name"; \
		"allData"; $templates; \
		"dataclass"; "StepTemplate"\
		)
	
	$winRef:=Open form window:C675("select1toN"; Pop up form window:K39:11; $l; $b+1)
	DIALOG:C40("select1toN"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If ((ok=1) & ($form.item#Null:C1517))
		Form:C1466.step.step_template:=Num:C11($form.item.templateNumber)
		Form:C1466.step.step_property_rules:=This:C1470.newStepPropertyRulesObjectFromTemplate($form.item)
		Form:C1466.step.step_property_rules_source_template:=Num:C11($form.item.templateNumber)
		This:C1470.mergeStepPropertyRuleEnableFromStepProperties(Form:C1466.step)
		This:C1470.syncSfStepRulesListbox()
		This:C1470.drawSfStepRulesButton()
		This:C1470.refreshDerivedStepColumnsForCurrentStep()
	End if
	
	This:C1470.drawSfStepTemplate()
	
	
Function pupSfArea()
	var $areas : 4D:C1709.EntitySelection
	var $form : Object
	var $winRef : Integer
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.step=Null:C1517)
		return 
	End if 
	
	OBJECT GET COORDINATES:C663(*; "sf_pup_area"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	
	$areas:=ds:C1482.StepArea.all().orderBy("name")
	
	$form:=New object:C1471(\
		"colName"; "name"; \
		"allData"; $areas; \
		"dataclass"; "StepArea"\
		)
	
	$winRef:=Open form window:C675("select1toN"; Pop up form window:K39:11; $l; $b+1)
	DIALOG:C40("select1toN"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If ((ok=1) & ($form.item#Null:C1517))
		Form:C1466.step.area:=$form.item.name
		Form:C1466.step.UUID_StepArea:=$form.item.UUID
	End if 
	
	This:C1470.drawSfArea()
	This:C1470.touchLbSelectedSteps()
	
	
Function toggleSfSpecificationsPanel()
	
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	If (Undefined:C82(Form:C1466.sf_specificationsPanelOpen))
		Form:C1466.sf_specificationsPanelOpen:=False:C215
	End if 
	If (Not:C34(Bool:C1537(Form:C1466.sf_specificationsPanelOpen)))
		Form:C1466.sf_stepRulesPanelOpen:=False:C215
		Form:C1466.sf_specificationsSearch:=""
	End if 
	Form:C1466.sf_specificationsPanelOpen:=Not:C34(Bool:C1537(Form:C1466.sf_specificationsPanelOpen))
	This:C1470.manageStepDefinitionEditor()
	This:C1470.redrawAndSetVisible()
	
	
Function redrawAndSetVisible()
	
	Case of 
		: (FORM Get current page:C276(*)=1)  // Lot Steps
			OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubForm; $heightSubform)
			OBJECT GET COORDINATES:C663(*; "lb_steps"; $left_l; $top_l; $right_l; $bottom_l)
			OBJECT SET COORDINATES:C1248(*; "lb_steps"; $left_l; $top_l; $widthSubform; $bottom_l)
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $left_r; $top_r; $right_r; $bottom_r)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $left_r; $top_r; $right_r; $heightSubform)
			
			OBJECT GET COORDINATES:C663(*; "bAction_delete"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			$offset:=4
			$offset_bAc:=10
			$height_bAc:=$bottom_bAc-$top_bAc
			OBJECT SET COORDINATES:C1248(*; "bAction_delete"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			
			
			OBJECT GET COORDINATES:C663(*; "lb_selectedSteps"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "btnMoveTop"; $left_mt; $top_mt; $right_mt; $bottom_mt)
			OBJECT GET COORDINATES:C663(*; "btnMoveUp"; $left_mu; $top_mu; $right_mu; $bottom_mu)
			OBJECT GET COORDINATES:C663(*; "btnMoveDown"; $left_md; $top_md; $right_md; $bottom_md)
			OBJECT GET COORDINATES:C663(*; "btnMoveBottom"; $left_mb; $top_mb; $right_mb; $bottom_mb)
			OBJECT GET COORDINATES:C663(*; "btnDeleteRow"; $left_dr; $top_dr; $right_dr; $bottom_dr)
			
			$offset:=4
			$offset_r:=60
			$offset_btns_r:=15
			$offset_bAc:=10
			
			$width_mt:=$right_mt-$left_mt
			$width_mu:=$right_mu-$left_mu
			$width_md:=$right_md-$left_md
			$width_mb:=$right_mb-$left_mb
			$width_dr:=$right_dr-$left_dr
			
			$marginR:=12
			$editorColW:=352
			$btnBand:=52
			$labW:=118
			$rowH:=28
			$descH:=54
			$rowGap:=8
			
			// No row selected: stretch list across the area (detail panel hidden). With selection: split list | editor like panel_step.
			If (Form:C1466.step#Null:C1517)
				$split:=$widthSubform-$marginR-$editorColW
				If ($split<($left_lb+300))
					$split:=$left_lb+300
				End if 
				$listRight:=$split-$btnBand
			Else 
				$listRight:=$widthSubform-$marginR-$btnBand
			End if 
			If ($listRight<($left_lb+160))
				$listRight:=$left_lb+160
			End if 
			
			$bottomBoth:=$heightSubform-8
			
			OBJECT SET COORDINATES:C1248(*; "lb_selectedSteps"; $left_lb; $top_lb; $listRight; $bottomBoth)
			
			OBJECT GET COORDINATES:C663(*; "lb_selectedSteps"; $gL; $gT; $gR; $tbl)
			
			$yt:=$gT+8
			OBJECT SET COORDINATES:C1248(*; "btnMoveTop"; $listRight+6; $yt; $listRight+6+$width_mt; $yt+26)
			$yt:=$yt+32
			OBJECT SET COORDINATES:C1248(*; "btnMoveUp"; $listRight+6; $yt; $listRight+6+$width_mu; $yt+26)
			$yt:=$yt+32
			OBJECT SET COORDINATES:C1248(*; "btnMoveDown"; $listRight+6; $yt; $listRight+6+$width_md; $yt+26)
			$yt:=$yt+32
			OBJECT SET COORDINATES:C1248(*; "btnMoveBottom"; $listRight+6; $yt; $listRight+6+$width_mb; $yt+26)
			$yt:=$yt+32
			OBJECT SET COORDINATES:C1248(*; "btnDeleteRow"; $listRight+6; $yt; $listRight+6+$width_dr; $yt+26)
			
			If (Form:C1466.step#Null:C1517)
				$ctrlL:=$split+$labW+14
				$ctrlR:=$widthSubform-$marginR-8
				
				OBJECT SET COORDINATES:C1248(*; "rec_sf_editor"; $split; $top_lb; $widthSubform-$marginR; $bottomBoth)
				
				$y:=$top_lb+10
				
				OBJECT SET COORDINATES:C1248(*; "sf_lbl_stepEditor"; $split+8; $y; $ctrlR; $y+16)
				$y:=$y+24
				
				$rulesOpen:=False:C215
				If (Not:C34(Undefined:C82(Form:C1466.sf_stepRulesPanelOpen)))
					$rulesOpen:=Bool:C1537(Form:C1466.sf_stepRulesPanelOpen)
				End if 
				
				OBJECT SET COORDINATES:C1248(*; "sf_lab_stepRules"; $split+8; $y+4; $split+8+$labW; $y+18)
				OBJECT SET COORDINATES:C1248(*; "sf_pup_stepRules"; $ctrlL; $y-2; $ctrlR; $y+22)
				$y:=$y+$rowH
				
				If ($rulesOpen)
					$listPad:=4
					OBJECT SET COORDINATES:C1248(*; "lb_sf_stepRules"; $split+8; $y+$listPad; $ctrlR; $bottomBoth-$listPad)
					OBJECT SET COORDINATES:C1248(*; "sf_lab_specificationsSearch"; $split+8; $bottomBoth-5; $ctrlR; $bottomBoth-4)
					OBJECT SET COORDINATES:C1248(*; "sf_inp_specificationsSearch"; $ctrlL; $bottomBoth-5; $ctrlR; $bottomBoth-4)
					OBJECT SET COORDINATES:C1248(*; "lb_sf_specifications"; $split+8; $bottomBoth-2; $ctrlR; $bottomBoth-1)
				Else 
					OBJECT SET COORDINATES:C1248(*; "lb_sf_stepRules"; $split+8; $y; $ctrlR; $y+1)
					
					OBJECT SET COORDINATES:C1248(*; "sf_lab_description"; $split+8; $y+4; $split+8+$labW; $y+18)
					OBJECT SET COORDINATES:C1248(*; "sf_inp_description"; $ctrlL; $y; $ctrlR; $y+$descH)
					$y:=$y+$descH+$rowGap
					
					OBJECT SET COORDINATES:C1248(*; "sf_lab_stepTemplate"; $split+8; $y; $split+8+$labW; $y+14)
					OBJECT SET COORDINATES:C1248(*; "sf_pup_stepTemplate"; $ctrlL; $y-2; $ctrlR; $y+22)
					$y:=$y+$rowH
					
					OBJECT SET COORDINATES:C1248(*; "sf_lab_area"; $split+8; $y; $split+8+$labW; $y+14)
					OBJECT SET COORDINATES:C1248(*; "sf_pup_area"; $ctrlL; $y-2; $ctrlR; $y+22)
					$y:=$y+$rowH
					
					OBJECT SET COORDINATES:C1248(*; "sf_lab_specPick"; $split+8; $y; $split+8+$labW; $y+14)
					OBJECT SET COORDINATES:C1248(*; "sf_pup_specification"; $ctrlL; $y-2; $ctrlR; $y+22)
					$y:=$y+$rowH
					
					$specsOpen:=False:C215
					If (Not:C34(Undefined:C82(Form:C1466.sf_specificationsPanelOpen)))
						$specsOpen:=Bool:C1537(Form:C1466.sf_specificationsPanelOpen)
					End if 
					
					If ($specsOpen)
						$searchH:=22
						OBJECT SET COORDINATES:C1248(*; "sf_lab_specificationsSearch"; $split+8; $y+4; $split+8+$labW; $y+18)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_specificationsSearch"; $ctrlL; $y-1; $ctrlR; $y+17)
						$y:=$y+$searchH
						$listPad:=4
						OBJECT SET COORDINATES:C1248(*; "lb_sf_specifications"; $split+8; $y+$listPad; $ctrlR; $bottomBoth-$listPad)
					Else 
						OBJECT SET COORDINATES:C1248(*; "sf_lab_specificationsSearch"; $split+8; $bottomBoth-5; $ctrlR; $bottomBoth-4)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_specificationsSearch"; $ctrlL; $bottomBoth-5; $ctrlR; $bottomBoth-4)
						OBJECT SET COORDINATES:C1248(*; "lb_sf_specifications"; $split+8; $y; $ctrlR; $y+1)
						
						OBJECT SET COORDINATES:C1248(*; "sf_lab_time"; $split+8; $y; $split+8+$labW; $y+14)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_time"; $ctrlL; $y-1; $ctrlR; $y+18)
						$y:=$y+$rowH
						
						OBJECT SET COORDINATES:C1248(*; "sf_lab_yield"; $split+8; $y; $split+8+$labW; $y+14)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_yield"; $ctrlL; $y-1; $ctrlR; $y+18)
						$y:=$y+$rowH
						
						OBJECT SET COORDINATES:C1248(*; "sf_lab_tempC"; $split+8; $y; $split+8+$labW; $y+14)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_temp_c"; $ctrlL; $y-1; $ctrlR; $y+18)
						$y:=$y+$rowH
						
						OBJECT SET COORDINATES:C1248(*; "sf_lab_planHrs"; $split+8; $y; $split+8+$labW; $y+14)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_planned_hours"; $ctrlL; $y-1; $ctrlR; $y+18)
						$y:=$y+$rowH
						
						OBJECT SET COORDINATES:C1248(*; "sf_lab_alert"; $split+8; $y+4; $split+8+$labW; $y+18)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_alert"; $ctrlL; $y; $ctrlR; $y+$descH)
						$y:=$y+$descH+$rowGap
						
						OBJECT SET COORDINATES:C1248(*; "sf_lab_bom"; $split+8; $y; $split+8+$labW; $y+14)
						OBJECT SET COORDINATES:C1248(*; "sf_inp_bom_for_step"; $ctrlL; $y-1; $ctrlR; $y+18)
						
					End if 
					
				End if 
			End if 
			
			This:C1470.refreshStepDefinitionEditor()
			
	End case 
	
	
	This:C1470.drawPup_customer()
	//This.loadSteps()
	This:C1470.drawPup_process()
	OBJECT SET ENABLED:C1123(*; "pup_process"; Form:C1466.sfw.checkIsInModification())
	
	
Function toggleSfStepRulesPanel()
	
	If (Form:C1466.step=Null:C1517)
		return 
	End if 
	If (Undefined:C82(Form:C1466.sf_stepRulesPanelOpen))
		Form:C1466.sf_stepRulesPanelOpen:=False:C215
	End if 
	If (Not:C34(Bool:C1537(Form:C1466.sf_stepRulesPanelOpen)))
		Form:C1466.sf_specificationsPanelOpen:=False:C215
	End if 
	Form:C1466.sf_stepRulesPanelOpen:=Not:C34(Bool:C1537(Form:C1466.sf_stepRulesPanelOpen))
	This:C1470.manageStepDefinitionEditor()
	This:C1470.redrawAndSetVisible()
	
	
Function manageReOrderBtns()
	
	OBJECT SET VISIBLE:C603(*; "btnMoveTop"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnMoveUp"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnMoveDown"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnMoveBottom"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnDeleteRow"; Form:C1466.sfw.checkIsInModification())
	
	OBJECT SET ENABLED:C1123(*; "btnMoveTop"; (Form:C1466.step#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnMoveUp"; (Form:C1466.step#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnMoveDown"; (Form:C1466.step#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnMoveBottom"; (Form:C1466.step#Null:C1517))
	OBJECT SET ENABLED:C1123(*; "btnDeleteRow"; (Form:C1466.step#Null:C1517))
	
	If (Form:C1466.sfw.checkIsInModification() & (Form:C1466.step#Null:C1517))
		Case of 
			: (Form:C1466.stepPos=1)
				OBJECT SET ENABLED:C1123(*; "btnMoveTop"; False:C215)
				OBJECT SET ENABLED:C1123(*; "btnMoveUp"; False:C215)
				
			: (Form:C1466.stepPos=Form:C1466.selectedSteps.length)
				OBJECT SET ENABLED:C1123(*; "btnMoveBottom"; False:C215)
				OBJECT SET ENABLED:C1123(*; "btnMoveDown"; False:C215)
		End case 
	End if 
	
	This:C1470.manageStepDefinitionEditor()
	
	
Function dropSelectedStepFromActions()
	var $step : Object
	var $i : Integer
	
	This:C1470.ensureStepsDefinition()
	Form:C1466.current_item.stepsDefinition.items.remove(Form:C1466.stepPos)
	
	$i:=1
	For each ($step; Form:C1466.current_item.stepsDefinition.items)
		$step.order:=$i
		$i+=1
	End for each 
	
	
Function btnReOrderSteps($from : Integer; $to : Integer)
	var $sorted : Collection
	var $r : Object
	var $i : Integer
	
	If (Form:C1466.step#Null:C1517)
		$coef:=1
		
		If (($to-$from)>0)
			$coef:=-1
		End if 
		
		If ($coef>0)
			$stepsToReOrder:=Form:C1466.selectedSteps.query("order >= :1 AND order < :2"; Choose:C955(($from>$to); $to; $from); Choose:C955(($from>$to); $from; $to))
		Else 
			$stepsToReOrder:=Form:C1466.selectedSteps.query("order > :1 AND order <= :2"; Choose:C955(($from>$to); $to; $from); Choose:C955(($from>$to); $from; $to))
		End if 
		
		For each ($step; $stepsToReOrder)
			$step.order:=$step.order+$coef
			
		End for each 
		
		Form:C1466.step.order:=$to
		$sorted:=Form:C1466.selectedSteps.orderBy("order")
		$i:=1
		For each ($r; $sorted)
			$r.order:=$i
			$i+=1
		End for each 
		
		Form:C1466.current_item.stepsDefinition.items:=$sorted
		Form:C1466.selectedSteps:=$sorted
		
		This:C1470.loadSelectedSteps()
		
		Form:C1466.step:=Form:C1466.selectedSteps.query("order = :1"; $to).first()
		LISTBOX SELECT ROW:C912(*; "lb_selectedSteps"; $to)
		This:C1470.manageReOrderBtns()
		This:C1470.redrawAndSetVisible()
	End if 
	
Function bAction_deleteStep()
	
	$refMenus:=New collection:C1472
	$mainMenu:=Create menu:C408
	$refMenus.push($mainMenu)
	
	APPEND MENU ITEM:C411($mainMenu; "Drop Step"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--drop")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.step=Null:C1517)
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($mainMenu)
	RELEASE MENU:C978($mainMenu)
	
	Case of 
		: ($choose="")
		: ($choose="--drop")
			This:C1470.dropSelectedStepFromActions()
			
	End case 
	
	This:C1470.loadSelectedSteps()
	This:C1470.redrawAndSetVisible()
	
	