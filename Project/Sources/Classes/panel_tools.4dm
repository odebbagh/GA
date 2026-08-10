

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
				This:C1470.loadTools()
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
	This:C1470.displayToolLine()
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	Case of 
		: (FORM Get current page:C276(*)=1)  // main
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_1"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_tools"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionTools"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_1"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_tools"; $left_lb; $top_lb; $right_lb; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionTools"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
	End case 
	
Function displayToolLine()
	OBJECT SET VISIBLE:C603(*; "label_ToolLine_@"; Not:C34(Form:C1466.currentTool=Null:C1517))
	OBJECT SET VISIBLE:C603(*; "entryField_toolLine@"; Not:C34(Form:C1466.currentTool=Null:C1517))
	
Function loadTools()
	//Loads and initializes a list
	Form:C1466.currentTool:=Null:C1517
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.lb_tools:=New collection:C1472()
	Else 
		Form:C1466.lb_tools:=ds:C1482.Tool.query("UUID_ToolType = :1"; Form:C1466.current_item.UUID).orderBy("name")
	End if 
	
Function bActionTools()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Add a Tool")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Edit a Tool")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/edit.png")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	Else 
		If (Form:C1466.currentTool=Null:C1517)
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--add")
			$form:=New object:C1471(\
				"toolDefinition"; New object:C1471("name"; ""; "date"; Current date:C33()); \
				"action"; "add"\
			)
			
			$winRef:=Open form window:C675("createTool_toolType"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createTool_toolType"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				$tool_e:=ds:C1482.Tool.new()
				$tool_e.UUID_ToolType:=Form:C1466.current_item.UUID
				$tool_e.name:=$form.toolDefinition.name
				$tool_e.date:=$form.toolDefinition.date
				
				$res:=$tool_e.save()
				If ($res.success)
					This:C1470.loadTools()
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
		
		: ($choose="--edit")
			$form:=New object:C1471(\
				"toolDefinition"; New object:C1471("name"; Form:C1466.currentTool.name; "date"; Form:C1466.currentTool.date); \
				"action"; "edit"\
			)
			
			$winRef:=Open form window:C675("createTool_toolType"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createTool_toolType"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				Form:C1466.currentTool.name:=$form.toolDefinition.name
				Form:C1466.currentTool.date:=$form.toolDefinition.date
				
				$res:=Form:C1466.currentTool.save()
				If ($res.success)
					This:C1470.loadTools()
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
	End case 
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID