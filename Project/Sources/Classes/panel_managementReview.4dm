singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		
		If (Form:C1466.current_item#Null:C1517)
			Form:C1466.allIssuesClosed:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_allIssuesClosed"))
			Form:C1466.someOpen:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_someOpen"))
			Form:C1466.furtherAction:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_furtherAction"))
		End if 
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
	
	var $eAttach : cs:C1710.sfw_DocumentEntity
	var $caption : Text
	var $uuidDoc : Text
	var $normalized : Text
	var $parts : Collection
	
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	This:C1470.drawPup_docType()
	
	// Purpose: Keep file name label aligned with framework attachment metadata or legacy sourcePath (no embedded blob dependency).
	// modified by 4D/PS [2026-may-08]
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.document#Null:C1517)
		$caption:=""
		$uuidDoc:=String:C10(Form:C1466.current_item.document.UUID_sfwDocument)
		If ($uuidDoc#"") && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($uuidDoc)))
			$eAttach:=ds:C1482.sfw_Document.get($uuidDoc)
			If ($eAttach#Null:C1517)
				$caption:=String:C10($eAttach.name)
				If (String:C10($eAttach.extension)#"")
					If (Position:C15("."; $caption)=0)
						$caption:=$caption+"."+Lowercase:C14(String:C10($eAttach.extension))
					End if 
				End if 
			End if 
		End if 
		If ($caption="")
			$normalized:=Replace string:C233(String:C10(Form:C1466.current_item.document.sourcePath); "\\"; "/")
			$parts:=Split string:C1554($normalized; "/"; sk trim spaces:K86:2)
			If ($parts.length>0)
				$caption:=String:C10($parts[$parts.length-1])
			Else 
				$caption:=String:C10(Form:C1466.current_item.document.sourcePath)
			End if 
		End if 
		OBJECT SET TITLE:C194(*; "fileName"; $caption)
	End if 
	
	OBJECT SET VISIBLE:C603(*; "bUploadDocument"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
	End case 
	
	//Form.sfw.drawHTab()
	
	
Function drawPup_docType()
	
	// Purpose: Avoid dereferencing a missing embedded document object when drawing the category picker.
	// modified by 4D/PS [2026-may-08]
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.document#Null:C1517)
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
	
	
	
	