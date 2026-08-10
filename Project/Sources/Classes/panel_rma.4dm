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
				// add load functions
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	This:C1470.hideDatePickers()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$approverProfile:=New collection:C1472("qs"; "qm")  // only QC Team allowed to modify
		
		$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		
		OBJECT SET ENABLED:C1123(*; "entryField_qaQc"; $hasAuthorizedProfile)
		
		
		
	End if 
	
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	
Function selectQcar()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_customerName"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "qcarNumber"; \
					"lb_items"; ds:C1482.Qcar.all(); \
					"allData"; ds:C1482.Qcar.all(); \
					"dataclass"; "Qcar"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Qcar:=$form.item.UUID
					This:C1470._activate_save_cancel_button()
				End if 
		End case 
	End if 
	
Function btnDatePicker($object; $attribut)
	If (Form:C1466.sfw.checkIsInModification())
		$form:=New object:C1471
		$form.date:=$object[$attribut]
		
		OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
		CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
		Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
		DIALOG:C40("_ga_calendar"; $form)
		
		If (OK=1)
			$object[$attribut]:=$form.calendar.display.date
			This:C1470._activate_save_cancel_button()
		End if 
	End if 
	