singleton Class constructor
	
	
// Purpose: Panel controller for RejectCriteriaItem administration entry (category link + color).
// created by 4D/PS [2026-may-19]
Function formMethod()
	
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.drawPup_category()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of 
			: (FORM Get current page:C276(*)=1)
				If (Form:C1466.current_item#Null:C1517)
					If (Form:C1466.current_item.moreData=Null:C1517)
						Form:C1466.current_item.moreData:=New object:C1471
					End if 
				End if 
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function pup_color()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.color:=cs:C1710.sfw_htmlColor.me.deployPup(Form:C1466.current_item.color).hex
	End if 
	
Function redrawAndSetVisible()
	If (Form:C1466.current_item#Null:C1517)
		$color:=cs:C1710.sfw_htmlColor.me.getName(Form:C1466.current_item.color) || ""
		If ($color#"")
			Form:C1466.sfw.drawButtonPup("pup_color"; $color; "sfw/colors/"+$color+"-circle.png"; (Form:C1466.current_item.color=Null:C1517))
		Else 
			Form:C1466.sfw.drawButtonPup("pup_color"; "choice color"; "sfw/colors/colors.png"; (Form:C1466.current_item.color=Null:C1517))
		End if 
	End if 
	This:C1470.drawPup_category()
	
	
Function drawPup_category()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.rejectCriteriaCategory.name
		If ($name="")
			$name:=" "
		End if 
		Form:C1466.sfw.drawButtonPup("pup_category"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.rejectCriteriaCategory=Null:C1517))
	End if 
	
	
Function selectCategory()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorRejectCriteriaCategory"; "rejectCriteriaCategory")
		$selector.setTitle("Choose a category")
		$selector.setCurrentItem(Form:C1466.current_item.rejectCriteriaCategory)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSelected:=$selector.getCurrentItem()
				Case of 
					: ($itemSelected=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSelected.UUID)=False:C215)
						Form:C1466.current_item.UUID_RejectCriteriaCategory:=$itemSelected.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_RejectCriteriaCategory)=True:C214)
							Form:C1466.current_item.UUID_RejectCriteriaCategory:=16*"00"
						End if 
				End case 
				This:C1470.drawPup_category()
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_RejectCriteriaCategory:=16*"00"
				This:C1470.drawPup_category()
		End case 
	End if 
