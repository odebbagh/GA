singleton Class constructor
	
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()
	
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Case of 
		: (FORM Get current page:C276(*)=1)  // email exemple
			
			OBJECT GET COORDINATES:C663(*; "WPToolbar_description_email"; $gTB; $hTB; $dTB; $bTB)
			OBJECT GET COORDINATES:C663(*; "WPArea_description_email"; $g; $h; $d; $b)
			If (sfw_checkIsInModification)
				OBJECT SET VISIBLE:C603(*; "WPToolbar_description_email"; True:C214)
				
				OBJECT SET ENTERABLE:C238(*; "WParea_description_email"; True:C214)
				OBJECT SET ENTERABLE:C238(*; "WPtoolbar_description_email"; True:C214)
				
				OBJECT SET COORDINATES:C1248(*; "WPArea_description_email"; $g; $bTB; $widthSubform; $heightSubform)
				OBJECT SET COORDINATES:C1248(*; "WPToolbar_description_email"; $gTB; $hTB; $widthSubform; $bTB)
			Else 
				OBJECT SET VISIBLE:C603(*; "WPToolbar_description_email"; False:C215)
				
				OBJECT SET ENTERABLE:C238(*; "WParea_description_email"; False:C215)
				OBJECT SET ENTERABLE:C238(*; "WPtoolbar_description_email"; False:C215)
				
				OBJECT SET COORDINATES:C1248(*; "WPArea_description_email"; $g; $hTB; $widthSubform; $heightSubform)
			End if 
	End case 
	
Function WParea_description()
	WP UpdateWidget("WPtoolbar_description_email"; "WParea_description_email")