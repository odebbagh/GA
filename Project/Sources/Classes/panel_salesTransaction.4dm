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
	
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	//OBJECT GET COORDINATES(*; "header_bkgd5"; $g; $h; $d; $b)
	//OBJECT SET COORDINATES(*; "header_bkgd5"; $g; $h; $widthSubform; $heightSubform)
	
	$offset:=5
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
			//OBJECT GET COORDINATES(*; "header_bkgd1"; $g; $h; $d; $b)
			//OBJECT SET COORDINATES(*; "header_bkgd1"; $g; $h; $widthSubform; $b)
			
	End case 
	
	This:C1470.drawPup_customer()
	
Function selectCustomer()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorCustomers"; "customer")
		$selector.setTitle("Choose a Customer")
		$selector.setCurrentItem(Form:C1466.current_item.customer)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						Form:C1466.current_item.UUID_Customer:=$itemSeleted.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer)=True:C214)
							Form:C1466.current_item.UUID_Customer:=16*"00"
						End if 
				End case 
				
				This:C1470.drawPup_customer()
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Customer:=16*"00"
				
			: ($selector.needCreation())
				$selector.createANewEntity("cs.panel_lead.me.callbackAfterCreationCustomer($1)")
				
				
		End case 
	End if 
	
	
	//mark:Customer
Function drawPup_customer()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.customer.name || " "
		Form:C1466.sfw.drawButtonPup("pup_customer"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.customer=Null:C1517))
	End if 
	
	
	