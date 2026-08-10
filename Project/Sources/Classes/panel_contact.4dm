singleton Class constructor
	
	// It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	
	// This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  // The main body of the form method and basic sfw functionalities
	
	If (Form:C1466.sfw.updateOfPanelNeeded())  // The current item is changed or reloaded, so it's necessary ti refresh
		
		Form:C1466.companyType:=Form:C1466.current_item.companyType
		
	End if 
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  // a page is displayed so it's time to load the sources of data to display
		
		Case of 
				
				//________________________________________
			: (FORM Get current page:C276(*)=1)
				
				// add load functions
				// This.loadContact()
				
				//________________________________________
		End case 
	End if 
	
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  // It's time to resize the object or set visible
		
		This:C1470.redrawAndSetVisible()
		
	End if 
	
Function drawPup_XXX()
	
	// This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
Function drawPup_Company()
	
	If (Form:C1466.current_item#Null:C1517)
		
		// Customer & Vendor are both stored in the Customer dataclass
		$company:=ds:C1482.Customer.query("UUID =:1"; Form:C1466.current_item.UUID_Company).first() || New object:C1471(\
			)
		
		$companyName:=$company.name
		
		If ($companyName=Null:C1517)
			
			$companyName:=""
			
		End if 
		
		$color:="#FFFFFF"  //cs.sfw_htmlColor.me.getName($company.color)
		$pathIcon:=(Length:C16($color)#0) ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_company"; $companyName; $pathIcon; ($company=Null:C1517))
		
	End if 
	
Function pup_company()
	
	
	// Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_company"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		Case of

				//________________________________________
			: (Form:C1466.companyType="Vendor")

				$form:=New object:C1471(\
					"colName"; "name"; \
					"allData"; ds:C1482.Customer.vendors(); \
					"dataclass"; "Customer"\
					)

				//________________________________________
			Else

				$form:=New object:C1471(\
					"colName"; "name"; \
					"allData"; ds:C1482.Customer.all(); \
					"dataclass"; "Customer"\
					)

				//________________________________________
		End case
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			
			Form:C1466.current_item.UUID_Company:=$form.item.UUID
			cs:C1710.panel_contact.me._activate_save_cancel_button()
			
		End if 
	End if 
	
	This:C1470.drawPup_Company()
	
	
Function drawPup_companyType()
	
	If (Form:C1466.current_item#Null:C1517)
		
		$companyType:=New object:C1471
		$companyTypeName:=Form:C1466.companyType || ""  // Form.companyType
		$color:=""
		$pathIcon:=""
		Form:C1466.sfw.drawButtonPup("pup_companyType"; $companyTypeName; $pathIcon; ($companyType=Null:C1517))
		
	End if 
	
Function pup_companyType()
	
	// Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		
		$menu:=Create menu:C408
		
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.companyTypes=Null:C1517)
			
			ds:C1482.Contact.cacheLoad()
			
		End if 
		
		$count:=0
		
		For each ($eCompanyType; Storage:C1525.cache.companyTypes)
			
			$count:=$count+1
			APPEND MENU ITEM:C411($menu; $eCompanyType; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eCompanyType)
			
		End for each 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
				
				//________________________________________
			: (Length:C16($choose)#0)
				
				Form:C1466.companyType:=$choose
				Form:C1466.current_item.UUID_Company:=""
				OBJECT SET TITLE:C194(*; "pup_company"; "")
				
				//________________________________________
		End case 
	End if 
	
	This:C1470.drawPup_companyType()
	
Function redrawAndSetVisible()
	
	// Adjusts the layout and visibility of form elements based on the current page and modification state
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	
	Case of 
			
			//________________________________________
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "subFormAddress"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "subFormAddress"; $g; $h; $widthSubform; $b)
			
			//________________________________________
	End case 
	
	This:C1470.contactDetails()
	This:C1470.drawPup_Company()
	This:C1470.drawPup_companyType()
	
	OBJECT SET VISIBLE:C603(*; "bActionContact"; Form:C1466.sfw.checkIsInModification())
	
	Case of

			//________________________________________
		: (Form:C1466.companyType="Vendor")

			OBJECT SET TITLE:C194(*; "label_company"; "Vendor Name")

			//________________________________________
		Else

			OBJECT SET TITLE:C194(*; "label_company"; "Customer Name")

			//________________________________________
	End case
	
Function contactDetails()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.subFormAddress:=New object:C1471(\
			)
		Form:C1466.subFormAddress.address:=Form:C1466.current_item.rebuildAddress()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
		
		Form:C1466.subFormCommunication:=New object:C1471
		
		If (Form:C1466.current_item.contactDetails.communications=Null:C1517)
			
			Form:C1466.current_item.contactDetails.communications:=New collection:C1472
			
		End if 
		
		Form:C1466.subFormCommunication.communications:=Form:C1466.current_item.contactDetails.communications
		Form:C1466.subFormCommunication.situation:=Form:C1466.situation
		Form:C1466.subFormCommunication:=Form:C1466.subFormCommunication
		
	End if 
	
Function btnOpenCompany()
	
	$es:=ds:C1482.Customer.query("UUID =:1"; Form:C1466.current_item.UUID_Company)

	If ($es.length>0)

		Case of

				//________________________________________
			: (Form:C1466.companyType="Vendor")

				Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "vendor")

				//________________________________________
			Else

				Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "customer")

				//________________________________________
		End case
	End if