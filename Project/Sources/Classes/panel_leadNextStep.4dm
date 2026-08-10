singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				// add load functions
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	If (Form:C1466.current_item#Null:C1517)
		$color:=cs:C1710.sfw_htmlColor.me.getName(Form:C1466.current_item.color) || ""
		If ($color#"")
			Form:C1466.sfw.drawButtonPup("pup_color"; $color; "sfw/colors/"+$color+"-circle.png"; (Form:C1466.current_item.color=Null:C1517))
		Else 
			Form:C1466.sfw.drawButtonPup("pup_color"; "choice color"; "sfw/colors/colors.png"; (Form:C1466.current_item.color=Null:C1517))
		End if 
	End if 