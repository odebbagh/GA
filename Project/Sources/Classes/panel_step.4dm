// ============================================
// Class: panel_step
// ============================================

singleton Class constructor
	// It's a singleton class
	
	
	// ----------------------------------------------
	// _activate_save_cancel_button
	// ----------------------------------------------
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
	// ----------------------------------------------
	// formMethod
	// ----------------------------------------------
Function formMethod()
	// This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities
	If (Form:C1466.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary to refresh
		This:C1470.loadStepProperties()
		This:C1470.loadStepSpecifications()
		This:C1470.drawPup_stepTemplate()
		This:C1470.drawPup_process()
		This:C1470.drawPup_stepArea()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  // A page is displayed so it's time to load the data sources
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadStepProperties()
				This:C1470.loadStepSpecifications()
				This:C1470.drawPup_stepTemplate()
				This:C1470.drawPup_process()
				This:C1470.drawPup_stepArea()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visibility
		This:C1470.redrawAndSetVisible()
	End if 
	
	
	// ----------------------------------------------
	// redrawAndSetVisible
	// ----------------------------------------------
Function redrawAndSetVisible()
	// Adjusts the layout and visibility of form elements based on the current page and modification state to be implemented
	This:C1470.drawPup_stepTemplate()
	This:C1470.drawPup_process()
	This:C1470.drawPup_stepArea()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Case of 
		: (FORM Get current page:C276(*)=1)
			// Match panel_stepTemplate: blue section header + gray well + listbox; gear inline in header.
			OBJECT GET COORDINATES:C663(*; "header_bkgd_stepProperties"; $margin; $secTop; $tmpR; $tmpB)
			
			$offset:=4
			$gapCols:=8
			$headerH:=30
			$gapBlueGray:=3
			$gapGrayList:=3
			$inset:=3
			$gearW:=26
			$gearH:=21
			$gearPadTop:=4
			$lblPadLeft:=6
			$lblPadTop:=7
			
			$contentRight:=$widthSubform-$offset
			$halfW:=Int:C8(($contentRight-$margin-$gapCols)/2)
			
			$leftColLeft:=$margin
			$leftColRight:=$margin+$halfW-1
			
			$rightColLeft:=$leftColRight+$gapCols+1
			$rightColRight:=$contentRight
			
			$headerBottom:=$secTop+$headerH-1
			$grayTop:=$secTop+$headerH+$gapBlueGray
			$listTop:=$grayTop+$gapGrayList
			
			OBJECT SET COORDINATES:C1248(*; "header_bkgd_stepProperties"; $leftColLeft; $secTop; $leftColRight; $headerBottom)
			OBJECT SET COORDINATES:C1248(*; "panel_bkgd_stepProperties"; $leftColLeft; $grayTop; $leftColRight; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_stepProperties"; $leftColLeft+$inset; $listTop; $leftColRight-$inset; $heightSubform-$offset-1)
			
			$gearRightP:=$leftColRight-5
			$gearLeftP:=$gearRightP-$gearW+1
			OBJECT SET COORDINATES:C1248(*; "bActionStepProperties"; $gearLeftP; $secTop+$gearPadTop; $gearRightP; $secTop+$gearPadTop+$gearH-1)
			
			$lblRightP:=$gearLeftP-$lblPadLeft-2
			If ($lblRightP<($leftColLeft+$lblPadLeft+80))
				$lblRightP:=$leftColLeft+180
			End if 
			OBJECT SET COORDINATES:C1248(*; "lbl_stepProperties"; $leftColLeft+$lblPadLeft; $secTop+$lblPadTop; $lblRightP; $secTop+$lblPadTop+16)
			
			OBJECT SET COORDINATES:C1248(*; "header_bkgd_stepSpecifications"; $rightColLeft; $secTop; $rightColRight; $headerBottom)
			OBJECT SET COORDINATES:C1248(*; "panel_bkgd_stepSpecifications"; $rightColLeft; $grayTop; $rightColRight; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_stepSpecifications"; $rightColLeft+$inset; $listTop; $rightColRight-$inset; $heightSubform-$offset-1)
			
			$gearRightS:=$rightColRight-5
			$gearLeftS:=$gearRightS-$gearW+1
			OBJECT SET COORDINATES:C1248(*; "bActionStepSpecifications"; $gearLeftS; $secTop+$gearPadTop; $gearRightS; $secTop+$gearPadTop+$gearH-1)
			
			$lblRightS:=$gearLeftS-$lblPadLeft-2
			If ($lblRightS<($rightColLeft+$lblPadLeft+80))
				$lblRightS:=$rightColLeft+180
			End if 
			OBJECT SET COORDINATES:C1248(*; "lbl_stepSpecifications"; $rightColLeft+$lblPadLeft; $secTop+$lblPadTop; $lblRightS; $secTop+$lblPadTop+16)
	End case 
	
	If (FORM Get current page:C276(*)=1)
		OBJECT SET ENTERABLE:C238(*; "lb_stepProperties"; Form:C1466.sfw.checkIsInModification())
		OBJECT SET ENTERABLE:C238(*; "lb_stepSpecifications"; False:C215)
		OBJECT SET VISIBLE:C603(*; "bActionStepProperties"; True:C214)
		OBJECT SET VISIBLE:C603(*; "bActionStepSpecifications"; True:C214)
	Else 
		OBJECT SET ENTERABLE:C238(*; "lb_stepProperties"; False:C215)
		OBJECT SET ENTERABLE:C238(*; "lb_stepSpecifications"; False:C215)
		OBJECT SET VISIBLE:C603(*; "bActionStepProperties"; False:C215)
		OBJECT SET VISIBLE:C603(*; "bActionStepSpecifications"; False:C215)
	End if 
	
	Form:C1466.sfw.drawHTab()
	
	
Function drawPup_stepTemplate()
	If ((Form:C1466.current_item#Null:C1517) & (FORM Get current page:C276(*)=1))
		$stepTemplateName:=Form:C1466.current_item.stepTemplate.name
		Form:C1466.sfw.drawButtonPup("pup_stepTemplate"; $stepTemplateName; ""; (Form:C1466.current_item.stepTemplate=Null:C1517))
	End if 
	
Function drawPup_process()
	If ((Form:C1466.current_item#Null:C1517) & (FORM Get current page:C276(*)=1))
		$processName:=""
		If (Form:C1466.current_item.stepProcess#Null:C1517)
			$processName:=Form:C1466.current_item.stepProcess.name
		Else 
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_StepProcess)=False:C215)
				$process:=ds:C1482.StepProcess.query("UUID = :1"; Form:C1466.current_item.UUID_StepProcess).first()
				If ($process#Null:C1517)
					$processName:=$process.name
				End if 
			End if 
		End if 
		If ($processName="")
			If (Form:C1466.current_item.moreData#Null:C1517)
				$processName:=Form:C1466.current_item.moreData.processName
			End if 
		End if 
		Form:C1466.sfw.drawButtonPup("pup_process"; $processName; ""; ($processName=""))
	End if 
	
Function drawPup_stepArea()
	var $areaName : Text
	var $areaEnt : 4D:C1709.Entity
	
	If ((Form:C1466.current_item#Null:C1517) & (FORM Get current page:C276(*)=1))
		$areaName:=""
		If (Form:C1466.current_item.stepArea#Null:C1517)
			$areaName:=String:C10(Form:C1466.current_item.stepArea.name)
		Else 
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_StepArea)=False:C215)
				$areaEnt:=ds:C1482.StepArea.query("UUID = :1"; Form:C1466.current_item.UUID_StepArea).first()
				If ($areaEnt#Null:C1517)
					$areaName:=String:C10($areaEnt.name)
				End if 
			End if 
		End if 
		If ($areaName="")
			$areaName:=String:C10(Form:C1466.current_item.areas)
		End if 
		Form:C1466.sfw.drawButtonPup("pup_stepArea"; $areaName; ""; ($areaName=""))
	End if 
	
Function pup_process()
	If (Form:C1466.sfw.checkIsInModification())
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorOperationProcess"; "operationProcess")
		$selector.setTitle("Choose an Operation Process")
		
		If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_StepProcess)=False:C215)
			$currentProcess:=ds:C1482.StepProcess.query("UUID = :1"; Form:C1466.current_item.UUID_StepProcess).first()
			If ($currentProcess#Null:C1517)
				$selector.setCurrentItem($currentProcess)
			End if 
		End if 
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSelected:=$selector.getCurrentItem()
				If ($itemSelected#Null:C1517)
					Form:C1466.current_item.UUID_StepProcess:=$itemSelected.UUID
					If (Form:C1466.current_item.moreData=Null:C1517)
						Form:C1466.current_item.moreData:=New object:C1471()
					End if 
					Form:C1466.current_item.moreData.processName:=$itemSelected.name
					Form:C1466.current_item.moreData.Process:=$itemSelected.name
				End if 
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_StepProcess:=16*"00"
				If (Form:C1466.current_item.moreData#Null:C1517)
					Form:C1466.current_item.moreData.processName:=""
					Form:C1466.current_item.moreData.Process:=""
				End if 
		End case 
	End if 
	
	This:C1470.drawPup_process()
	This:C1470._activate_save_cancel_button()
	
	
Function pup_stepTemplate()
	If (Form:C1466.sfw.checkIsInModification())
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorStepTemplate"; "stepTemplate")
		$selector.setTitle("Choose a Step Template")
		$selector.setCurrentItem(Form:C1466.current_item.stepTemplate)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSelected:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSelected=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSelected.UUID)=False:C215)
						Form:C1466.current_item.UUID_StepTemplate:=$itemSelected.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_StepTemplate)=True:C214)
							Form:C1466.current_item.UUID_StepTemplate:=16*"00"
						End if 
				End case 
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_StepTemplate:=16*"00"
		End case 
	End if 
	
	This:C1470.drawPup_stepTemplate()
	
	
Function pup_stepArea()
	var $selector : cs:C1710.sfw_definitionSelector
	var $itemSelected : 4D:C1709.Entity
	var $currentArea : 4D:C1709.Entity
	
	If (Form:C1466.sfw.checkIsInModification())
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorStepArea"; "stepArea")
		$selector.setTitle("Choose an Area")
		
		$currentArea:=Null:C1517
		If (Form:C1466.current_item.stepArea#Null:C1517)
			$currentArea:=Form:C1466.current_item.stepArea
		Else 
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_StepArea)=False:C215)
				$currentArea:=ds:C1482.StepArea.query("UUID = :1"; Form:C1466.current_item.UUID_StepArea).first()
			End if 
		End if 
		If ($currentArea#Null:C1517)
			$selector.setCurrentItem($currentArea)
		End if 
		
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSelected:=$selector.getCurrentItem()
				If ($itemSelected#Null:C1517)
					Form:C1466.current_item.UUID_StepArea:=$itemSelected.UUID
					Form:C1466.current_item.areas:=String:C10($itemSelected.name)
				End if 
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_StepArea:=16*"00"
				Form:C1466.current_item.areas:=""
		End case 
	End if 
	
	This:C1470.drawPup_stepArea()
	This:C1470._activate_save_cancel_button()
	
	
Function loadStepProperties()
	var $property : Object
	var $stepPropertyMaster : 4D:C1709.Entity
	Form:C1466.selectedStepProperty:=Null:C1517
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.lb_stepProperties:=New collection:C1472
	Else 
		If (Form:C1466.current_item.stepProperties=Null:C1517)
			Form:C1466.current_item.stepProperties:=New object:C1471("items"; New collection:C1472)
		End if 
		If (Form:C1466.current_item.stepProperties.items=Null:C1517)
			Form:C1466.current_item.stepProperties.items:=New collection:C1472
		End if 
		If (Form:C1466.current_item.stepProperties.items.length=0)
			For each ($stepPropertyMaster; ds:C1482.StepProperty.all().orderBy("levelID"))
				Form:C1466.current_item.stepProperties.items.push(New object:C1471(\
					"id"; $stepPropertyMaster.UUID; \
					"name"; $stepPropertyMaster.name; \
					"description"; $stepPropertyMaster.description; \
					"bit"; $stepPropertyMaster.moreData.bit; \
					"enable"; False:C215\
					))
			End for each 
		End if 
		For each ($property; Form:C1466.current_item.stepProperties.items)
			If ($property.enable=Null:C1517)
				$property.enable:=False:C215
			End if 
			If ($property.id=Null:C1517)
				$property.id:=""
			End if 
			If ($property.bit=Null:C1517)
				$property.bit:=""
			End if 
		End for each 
		Form:C1466.lb_stepProperties:=Form:C1466.current_item.stepProperties.items
	End if 
	
	
Function loadStepSpecifications()
	var $link : 4D:C1709.Entity
	var $disp : Text
	
	Form:C1466.selectedStepSpecification:=Null:C1517
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.lb_stepSpecifications:=New collection:C1472()
	Else 
		Form:C1466.lb_stepSpecifications:=New collection:C1472()
		For each ($link; ds:C1482.StepSpecification.query("UUID_Step = :1"; Form:C1466.current_item.UUID).orderBy("specification.spec"))
			If ($link.specification=Null:C1517)
				$disp:=""
			Else 
				$disp:=String:C10($link.specification.title)
				If ($disp="")
					$disp:=String:C10($link.specification.spec)
				End if 
			End if 
			Form:C1466.lb_stepSpecifications.push(New object:C1471(\
				"UUID"; $link.UUID; \
				"UUID_Specification"; $link.UUID_Specification; \
				"title"; $link.specification.title; \
				"spec"; $link.specification.spec\
				))
		End for each 
	End if 
	
	
Function syncStepPrimarySpecificationFromLinks()
	var $first : 4D:C1709.Entity
	
	If (Form:C1466.current_item#Null:C1517)
		$first:=ds:C1482.StepSpecification.query("UUID_Step = :1"; Form:C1466.current_item.UUID).orderBy("specification.spec").first()
		If ($first#Null:C1517)
			Form:C1466.current_item.UUID_Specification:=$first.UUID_Specification
		Else 
			Form:C1466.current_item.UUID_Specification:=16*"00"
		End if 
	End if 
	
	
Function bActionStepSpecifications()
	var $choose : Text
	var $form : Object
	var $winRef : Integer
	var $linkedUUIDs : Collection
	var $available : 4D:C1709.EntitySelection
	var $specRow : 4D:C1709.Entity
	var $lbVals : Collection
	var $specEntity : 4D:C1709.Entity
	var $linkEntity : 4D:C1709.Entity
	var $res : Object
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Add specification")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Remove specification")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/delete.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	Else 
		If (Form:C1466.selectedStepSpecification=Null:C1517)
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--add")
			If (Form:C1466.current_item#Null:C1517)
				If (Form:C1466.lb_stepSpecifications.length=0)
					$available:=ds:C1482.Specification.all().orderBy("spec")
				Else 
					$linkedUUIDs:=Form:C1466.lb_stepSpecifications.extract("UUID_Specification")
					$available:=ds:C1482.Specification.query("NOT(UUID IN :1)"; $linkedUUIDs).orderBy("spec")
				End if 
				
				$lbVals:=New collection:C1472()
				For each ($specRow; $available)
					$lbVals.push(New object:C1471(\
						"UUID"; $specRow.UUID; \
						"name"; $specRow.spec; \
						"description"; $specRow.spec+" "+$specRow.title\
						))
				End for each 
				
				$form:=New object:C1471(\
					"windowTitle"; "Add specification"; \
					"inputPlaceholder"; "Specification search ..."; \
					"lb_values"; $lbVals\
					)
				
				$winRef:=Open form window:C675("searchOnList_v2"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("searchOnList_v2"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If ((OK=1) & ($form.selectedItem#Null:C1517))
					$specEntity:=ds:C1482.Specification.get($form.selectedItem.UUID)
					If ($specEntity#Null:C1517)
						$linkEntity:=ds:C1482.StepSpecification.new()
						$linkEntity.UUID_Step:=Form:C1466.current_item.UUID
						$linkEntity.UUID_Specification:=$specEntity.UUID
						$res:=$linkEntity.save()
						If ($res.success)
							This:C1470.loadStepSpecifications()
							This:C1470.syncStepPrimarySpecificationFromLinks()
							This:C1470._activate_save_cancel_button()
						End if 
					End if 
				End if 
			End if 
			
		: ($choose="--delete")
			If ((Form:C1466.selectedStepSpecification#Null:C1517) & (Form:C1466.current_item#Null:C1517))
				$linkEntity:=ds:C1482.StepSpecification.get(Form:C1466.selectedStepSpecification.UUID)
				If ($linkEntity#Null:C1517)
					$res:=$linkEntity.drop()
					If ($res.success)
						This:C1470.loadStepSpecifications()
						This:C1470.syncStepPrimarySpecificationFromLinks()
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
			End if 
	End case 
	
	
Function bActionStepProperties()
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Add step property")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Delete step property")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/delete.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	Else 
		If (Form:C1466.selectedStepProperty=Null:C1517)
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--add")
			$form:=New object:C1471
			$existingNames:=Form:C1466.current_item.stepProperties.items.extract("name")
			$properties:=ds:C1482.StepProperty.query("NOT(name IN :1)"; $existingNames)
			$form.data:=$properties
			$form.dataSelected:=New collection:C1472
			
			$winRef:=Open form window:C675("_ga_multiSelectListbox"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			SET WINDOW TITLE:C213("Select step properties to add"; $winRef)
			DIALOG:C40("_ga_multiSelectListbox"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				
				$cleanedSelectedData:=$form.dataSelected.toCollection().map(Formula:C1597(New object:C1471("description"; $1.value.description; "name"; $1.value.name)))
				
				For each ($property; $cleanedSelectedData)  // $form.dataSelected)
					Form:C1466.current_item.stepProperties.items.push($property)
				End for each 
				
				This:C1470.loadStepProperties()
				This:C1470._activate_save_cancel_button()
			End if 
			
		: ($choose="--delete")
			Form:C1466.current_item.stepProperties.items:=Form:C1466.current_item.stepProperties.items.filter(Formula:C1597($1.value.name#Form:C1466.selectedStepProperty.name))
			
			This:C1470.loadStepProperties()
			This:C1470._activate_save_cancel_button()
	End case 
	
	