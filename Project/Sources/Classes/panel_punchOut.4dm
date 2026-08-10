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
		//This.loadBins()
		This:C1470.loadCurrentStep()
		This:C1470.displayBannerLotOnHold()
		
		Case of 
			: (FORM Get current page:C276(*)=1)
				// add load functions
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
	If (Form:C1466.subFormBins=Null:C1517)
		Form:C1466.subFormBins:=New object:C1471
	End if 
	// Trigger subform On Bound Variable Change when mode changes.
	Form:C1466.subFormBins.mode:=Form:C1466.situation.mode
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	Case of 
		: (FORM Get current page:C276(*)=1)  // Main page
			OBJECT GET COORDINATES:C663(*; "banner_lotOnHold_page"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $bottom)
			
			$width:=$right-$left
			$height:=$bottom-$top
			
			OBJECT SET COORDINATES:C1248(*; "banner_lotOnHold_page"+String:C10(FORM Get current page:C276(*)); $widthSubform-$width; $heightSubform-$height; $widthSubform; $heightSubform)
			
			
			
			If (Form:C1466.currentStep#Null:C1517)
				
				OBJECT SET VISIBLE:C603(*; "header_bkgd2"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "lb_qaApproval"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "header_bkgd1"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "label_approver"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "label_approvalDate"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "entryField_approvalDate"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "entryField_approver"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "entryField_isApproved"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "entryField_isApproved"; (Form:C1466.currentStep.areas="QC"))
				OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; ((Form:C1466.sfw.checkIsInModification()) & (Form:C1466.currentStep.areas="QC")))
				
			Else 
				OBJECT SET VISIBLE:C603(*; "header_bkgd2"; False:C215)
				OBJECT SET VISIBLE:C603(*; "lb_qaApproval"; False:C215)
				OBJECT SET VISIBLE:C603(*; "header_bkgd1"; False:C215)
				OBJECT SET VISIBLE:C603(*; "label_approver"; False:C215)
				OBJECT SET VISIBLE:C603(*; "label_approvalDate"; False:C215)
				OBJECT SET VISIBLE:C603(*; "entryField_approvalDate"; False:C215)
				OBJECT SET VISIBLE:C603(*; "entryField_approver"; False:C215)
				OBJECT SET VISIBLE:C603(*; "entryField_isApproved"; False:C215)
				OBJECT SET VISIBLE:C603(*; "entryField_isApproved"; False:C215)
				OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; False:C215)
				
				
			End if 
			
			
			//: (FORM Get current page(*)=2)
			//OBJECT SET VISIBLE(*; "bUploadDocument"; Form.sfw.checkIsInModification())
	End case 
	OBJECT SET ENABLED:C1123(*; "entryField_approvalDate"; False:C215)
	OBJECT SET ENABLED:C1123(*; "entryField_approver"; False:C215)
	
	This:C1470.loadBins()
	
	
Function loadCurrentStep()
	Form:C1466.currentStep:=Null:C1517
	$currentstep:=Form:C1466.current_item.steps.query("qtyIn # :1 AND qtyOut = :1 AND dateIn # :2 AND dateOut = :2"; 0; !00-00-00!).orderBy("order asc")
	
	If ($currentstep.length>0)
		Form:C1466.currentStep:=$currentstep[0]
		
		Form:C1466.currentStepOrder:=Form:C1466.currentStep.order
		FORM GOTO PAGE:C247(1; *)
	Else 
		//FORM GOTO PAGE(2; *)
	End if 
	
Function displayBannerLotOnHold
	var $pict : Picture
	
	If (Form:C1466.current_item.onHold)
		OBJECT SET VISIBLE:C603(*; "banner_lotOnHold"; True:C214)
		$bannerMessage:="Lot On Hold"
		
		$svg:=SVG_New(285; 184)
		$group:=SVG_New_group($svg; "onHold")
		$rect:=SVG_New_rect($group; 0; 0; 500; 30; 0; 0; "green:50"; "orangered:50"; 1)
		$text:=SVG_New_text($group; $bannerMessage; 175; 7; "helvetica"; 10; Bold:K14:2; 3)
		SVG_SET_TRANSFORM_ROTATE($group; -30; 250; 20)
		SVG_SET_TRANSFORM_TRANSLATE($group; -50; 50)
		SVG EXPORT TO PICTURE:C1017($svg; $pict)
		SVG_CLEAR($svg)
	Else 
		OBJECT SET VISIBLE:C603(*; "banner_lotOnHold"; False:C215)
	End if 
	
	Form:C1466.bannerOnHold:=$pict
	
Function loadBins()
	If (Form:C1466.currentStep#Null:C1517) && (Form:C1466.currentStep.bins#Null:C1517)
		Form:C1466.lb_bins:=Form:C1466.currentStep.bins.items
	Else 
		Form:C1466.lb_bins:=New collection:C1472()
	End if 
	Form:C1466.subFormBins:=New object:C1471
	
	Form:C1466.subFormBins.bins:=Form:C1466.lb_bins
	Form:C1466.subFormBins.situation:=Form:C1466.situation
	Form:C1466.subFormBins:=Form:C1466.subFormBins
	
	
Function bActionBins()
	If (Form:C1466.currentBin=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No Bin Selected !")
	Else 
		$refMenu:=Create menu:C408
		
		APPEND MENU ITEM:C411($refMenu; "Add a Bin value")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
		If (Not:C34(Form:C1466.sfw.checkIsInModification()))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--add")
				$value:=Request:C163("Add a Bin value to "+String:C10(Form:C1466.currentBin.num)+": "+Form:C1466.currentBin.definition+" :")
				
				If (ok=1)
					Form:C1466.currentBin.value:=$value
					
					$res:=Form:C1466.currentStep.save()
					
					If ($res.success)
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
		End case 
	End if 
	
	
	
	
	