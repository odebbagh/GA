singleton Class constructor
	
	
Function formMethod()
	
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of 
			: (FORM Get current page:C276(*)=1)
				
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
	