singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		
	End if 
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	This:C1470.drawPup_type()
	This:C1470.drawPup_typeDetail()
	This:C1470.drawPup_subAccount()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=5
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "header_bkgd5"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "header_bkgd5"; $g; $h; $widthSubform; $heightSubform)
			
			OBJECT GET COORDINATES:C663(*; "header_bkgd2"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "header_bkgd2"; $g; $h; $widthSubform; $b)
			
	End case 
	
	OBJECT SET ENABLED:C1123(*; "pup_@"; Not:C34(Form:C1466.current_item.isInacActive))
	OBJECT SET ENABLED:C1123(*; "entryField_@"; Not:C34(Form:C1466.current_item.isInacActive))
	OBJECT SET ENABLED:C1123(*; "entryField_isInactive"; True:C214)
	//OBJECT SET ENABLED(*; "pup_subAccount"; (Form.current_item.isSubaccount) & Not(Form.current_item.isInacActive))
	OBJECT SET VISIBLE:C603(*; "pup_subAccount"; (Form:C1466.current_item.isSubaccount) & Not:C34(Form:C1466.current_item.isInacActive))
	OBJECT SET VISIBLE:C603(*; "label_parentAccount"; (Form:C1466.current_item.isSubaccount) & Not:C34(Form:C1466.current_item.isInacActive))
	
Function drawPup_type()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CAOType"; "UUID"; "UUID_CAOType"; "pup_type")
	End if 
	
Function selectType()
	Form:C1466.current_item.pup("CAOTypes"; "CAOType"; "UUID"; "UUID_CAOType")
	This:C1470.drawPup_type()
	
Function drawPup_typeDetail()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CAOTypeDetail"; "UUID"; "UUID_CAOTypeDetail"; "pup_typeDetail")
	End if 
	
Function selectTypeDetail()
	Form:C1466.current_item.pup("CAOTypeDetails"; "CAOTypeDetail"; "UUID"; "UUID_CAOTypeDetail")
	This:C1470.drawPup_typeDetail()
	
	
Function drawPup_subAccount()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CAO"; "UUID"; "UUID_ParentAccount"; "pup_subAccount")
	End if 
	
Function selectSubAccount()
	Form:C1466.current_item.pup("parentAccounts"; "CAO"; "UUID"; "UUID_ParentAccount")
	This:C1470.drawPup_subAccount()
	
	
	