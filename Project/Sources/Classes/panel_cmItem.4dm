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
	OBJECT GET COORDINATES:C663(*; "header_bkgd5"; $g; $h; $d; $b)
	OBJECT SET COORDINATES:C1248(*; "header_bkgd5"; $g; $h; $widthSubform; $heightSubform)
	
	$offset:=5
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "header_bkgd1"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "header_bkgd1"; $g; $h; $widthSubform; $b)
			
	End case 
	
	This:C1470.invoiceDetails()
	This:C1470.drawPup_customer()
	This:C1470.drawPup_invoice()
	
Function invoiceDetails()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.subFormInvoice:=New object:C1471()
		Form:C1466.subFormInvoice.data:=New object:C1471()
		Form:C1466.subFormInvoice.data:=Form:C1466.current_item.rebuildInvoices()
		Form:C1466.subFormInvoice.situation:=Form:C1466.situation
		Form:C1466.subFormInvoice:=Form:C1466.subFormInvoice
		
	End if 
	
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
	
	
	
Function selectInvoice()
	// Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_invoice"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "invoice"; \
			"allData"; ds:C1482.Invoice.query("purchaseOrder.customer.name = :1 & readyToDel = :2"; Form:C1466.current_item.customer.name; False:C215); \
			"dataclass"; "Invoice"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1) & ($form.item#Null:C1517)
			Form:C1466.current_item.UUID_Invoice:=$form.item.UUID
			cs:C1710.panel_cmItem.me._activate_save_cancel_button()
			
		End if 
	End if 
	
	This:C1470.drawPup_invoice()
	
Function drawPup_invoice()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.invoice.invoice || " "
		Form:C1466.sfw.drawButtonPup("pup_invoice"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.invoice=Null:C1517))
	End if 
	
	
Function btnOpenCustomer()
	
	If (Form:C1466.current_item.customer#Null:C1517)
		$es:=ds:C1482.Customer.query("name = :1"; Form:C1466.current_item.customer.name)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "customer")
		End if 
	End if 
	
	