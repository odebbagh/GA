singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		
		Form:C1466.allIssuesClosed:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_allIssuesClosed"))
		Form:C1466.someOpen:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_someOpen"))
		Form:C1466.furtherAction:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_furtherAction"))
		
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
				
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
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	This:C1470.drawPup_docType()
	
	OBJECT SET VISIBLE:C603(*; "bUploadDocument"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
	End case 
	
	Form:C1466.sfw.drawHTab()
	
	
Function drawPup_docType()
	If (Form:C1466.current_item#Null:C1517)
		$documentCategory:=ds:C1482.DocumentCategory.query("name =:1"; Form:C1466.current_item.document.code).first() || New object:C1471()
		
		$documentCategoryName:=$documentCategory.name
		If ($documentCategoryName=Null:C1517)
			$documentCategoryName:=""
		End if 
		$color:="#FFFFFF"
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_docType"; $documentCategoryName; $pathIcon; ($documentCategory=Null:C1517))
	End if 
	
	
Function pup_docType()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		var $hListItems : Collection
		var $hSousListItems : Collection
		
		$hListItems:=ds:C1482.DocumentCategory.all().toCollection().extract("name")
		
		$hList:=Create menu:C408
		
		$hListItemsLength:=$hListItems.length
		
		For ($i; 0; $hListItemsLength-1)
			
			APPEND MENU ITEM:C411($hList; $hListItems[$i]; *)
			SET MENU ITEM PARAMETER:C1004($hList; -1; $hListItems[$i])
			
		End for 
		
		$choose:=Dynamic pop up menu:C1006($hList)
		RELEASE MENU:C978($hList)
		Case of 
			: ($choose#"")
				Form:C1466.current_item.document.code:=$choose
		End case 
		
	End if 
	
	This:C1470.drawPup_docType()
	
	
	
	