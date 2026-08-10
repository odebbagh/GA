property functions : Collection

shared singleton Class constructor
	
	var $fonction : Object
	
	This:C1470.functions:=New shared collection:C1527()
	
	$fonction:=New object:C1471
	$fonction.title:="singleton Class constructor"
	$fonction.syntax:="singleton Class constructor"
	$fonction.comment:="It's a singleton class"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="formMethod"
	$fonction.syntax:="Function formMethod()"
	$fonction.comment:="This function manages the main logic for updating and refreshing the form"
	$fonction.code:="Form.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities \r"+\
		"If (Form.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh \r"+\
		"End if \r"+\
		"If (Form.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display\r"+\
		"Case of\r"+\
		": (FORM Get current page(*)=1) \r"+\
		"// add load functions\r"+\
		"End case \r"+\
		"End if \r"+\
		"If (Form.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible\r"+\
		"This.redrawAndSetVisible()\r"+\
		"End if\r"+\
		""
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="drawPup_XXX"
	$fonction.syntax:="Function drawPup_XXX()"
	$fonction.comment:="This function updates the dropdown by displaying the name"
	$fonction.code:="Form.sfw.drawButtonPup(\"pup_xxx\"; $xxxName; \"xxxx.png\"; (Form.current_item.xxxx=Null)) \r"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	
	$fonction:=New object:C1471
	$fonction.title:="pup_XXX"
	$fonction.syntax:="Function pup_XXX()"
	$fonction.comment:="Create pop up menu"
	$fonction.code:="If (Form.sfw.checkIsInModification())\r"+\
		"End if \r"+\
		"this.drawPup_XXX()\r"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="redrawAndSetVisible"
	$fonction.syntax:="Function redrawAndSetVisible()"
	$fonction.comment:="Adjusts the layout and visibility of form elements based on the current page and modification state"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	
	$fonction:=New object:C1471
	$fonction.title:="loadXXX"
	$fonction.syntax:="Function loadXXX()"
	$fonction.comment:="Loads and initializes a list"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))
	
	$fonction:=New object:C1471
	$fonction.title:="bActionXXX"
	$fonction.syntax:="Function bActionXXX()"
	$fonction.comment:="Manages actions: add, or remove, using dynamic menus and modification checks"
	This:C1470.functions.push(OB Copy:C1225($fonction; ck shared:K85:29))