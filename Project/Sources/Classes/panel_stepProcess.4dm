singleton Class constructor
	// It's a singleton class
	
Function formMethod()
	If (Undefined:C82(Form:C1466.lb_items) | (Form:C1466.lb_items=Null:C1517))
		Form:C1466.lb_items:=New collection:C1472()
	End if 
	
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadSteps()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		This:C1470.loadSteps()
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	Use (Form:C1466.sfw.entry.panel.pages)
		If (Form:C1466.sfw.entry.panel.pages.length>0)
			Form:C1466.sfw.entry.panel.pages[0].label:="Steps ("+String:C10(Form:C1466.lb_items.length)+")"
		End if 
	End use 
	
	Case of 
		: (FORM Get current page:C276(*)=1)
			OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_items"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			$offset:=4
			$offset_r:=5
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_items"; $left_lb; $top_lb; $widthSubform-$offset_r; $heightSubform-$offset)
	End case 
	
Function loadSteps()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_items:=ds:C1482.Step.query("UUID_StepProcess = :1"; Form:C1466.current_item.UUID).orderBy("description")
	Else 
		Form:C1466.lb_items:=New collection:C1472()
	End if 
	
	