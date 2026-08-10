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
	This:C1470.drawPup_vendor()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "header_bkgd5"; $g; $h; $d; $b)
	OBJECT SET COORDINATES:C1248(*; "header_bkgd5"; $g; $h; $widthSubform; $heightSubform)
	
	$offset:=5
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			OBJECT GET COORDINATES:C663(*; "header_bkgd2"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "header_bkgd2"; $g; $h; $widthSubform; $b)
			
		: (FORM Get current page:C276(*)=2)
			OBJECT GET COORDINATES:C663(*; "entryField_deprecationHistory"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_deprecationHistory"; $g; $h; $d; $heightSubform-15)
			
	End case 
	
	OBJECT SET ENTERABLE:C238(*; "entryField_assetNumber"; False:C215)
	
	
Function drawPup_type()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("AssetType"; "UUID"; "UUID_AssetType"; "pup_type")
	End if 
	
	
Function selectType()
	Form:C1466.current_item.pup("assetTypes"; "AssetType"; "UUID"; "UUID_AssetType")
	This:C1470.drawPup_type()
	
	
	//mark:Customer
Function drawPup_vendor()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.vendor.name || " "
		Form:C1466.sfw.drawButtonPup("pup_vendor"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.vendor=Null:C1517))
	End if 
	
	
Function selectVendor()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorVendors"; "supplier")
		$selector.setTitle("Choose a Vendor")
		$selector.setCurrentItem(Form:C1466.current_item.vendor)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						Form:C1466.current_item.UUID_Vendor:=$itemSeleted.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Vendor)=True:C214)
							Form:C1466.current_item.UUID_Vendor:=16*"00"
						End if 
				End case 
				
				This:C1470.drawPup_vendor()
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Vendor:=16*"00"
				
			: ($selector.needCreation())
				
		End case 
	End if 
	
	
	