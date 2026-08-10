singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function setUserStaff($eStaff : cs:C1710.StaffEntity)
	// Link the PO to a staff member (the "User"), same pattern as the buying
	// order buyer/requestor: the staff resolved from a scan or entered user code.
	If ($eStaff#Null:C1517)
		Form:C1466.current_item.UUID_Staff:=$eStaff.UUID
	End if
	This:C1470._activate_save_cancel_button()
	
Function selectUserStaff()
	// Scan a user badge or enter a user code to resolve and link the staff member.
	var $result : Object
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$result:=cs:C1710.Util_ScannerManager.me.resolveStaffFromScanOrRequest()
	If ($result.cancelled)
		return
	End if
	If (Not:C34($result.success))
		Case of
			: ($result.failureReason="codeNotFound")
				cs:C1710.sfw_dialog.me.alert("The user code entered does not correspond to any existing user.")
			: ($result.failureReason="barcodeNotFound")
				cs:C1710.sfw_dialog.me.alert("The scanned barcode does not correspond to any existing user.")
			: ($result.failureReason="noUserAccount")
				cs:C1710.sfw_dialog.me.alert("This employee does not have an application user account.")
			Else
				cs:C1710.sfw_dialog.me.alert("Unable to identify the user.")
		End case
		return
	End if
	This:C1470.setUserStaff($result.staff)
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		Form:C1466.addressBilling:=1
		Form:C1466.addressShipping:=0
		
		This:C1470.loadAllTabs()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.initAddresses()
			: (FORM Get current page:C276(*)=2)  //PO -> line items
				OBJECT SET TITLE:C194(*; "pupFilter_status"; "All Status")
				This:C1470.loadPoLineItems()
				
			: (FORM Get current page:C276(*)=3)  //PO -> jobs
				OBJECT SET TITLE:C194(*; "pupFilter_jobs"; "All Status")
				This:C1470.loadPoJobs()
				
			: (FORM Get current page:C276(*)=4)  //PO -> Lots
				This:C1470.loadLots()
				
			: (FORM Get current page:C276(*)=5)  //PO -> Invoices
				This:C1470.loadInvoices()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	//Form.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form.current_item.xxxx=Null))
	
	
Function initAddresses()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.address:=Form:C1466.current_item.rebuildAddress()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
	End if 
	
	
Function pup_lineItemsStatus()
	//Create pop up menu
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "All status")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--all")
	APPEND MENU ITEM:C411($refMenu; "-")
	APPEND MENU ITEM:C411($refMenu; "Unreleased")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--unreleased")
	APPEND MENU ITEM:C411($refMenu; "Closed")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--closed")
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--all")
			$title:="All Status"
			Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems
			
		: ($choose="--unreleased")
			$title:="Status: Unreleased"
			Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems.query("unreleased = :1"; True:C214)
			
		: ($choose="--closed")
			$title:="Status: Closed"
			Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems.query("closed = :1"; True:C214)
		Else 
			$title:="All Status"
			Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems
	End case 
	
	OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; $title)
	
Function pup_jobsStatus()
	ALERT:C41("TODO: Add filters !")
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Line Items ("+String:C10(Form:C1466.lb_lineItems.length)+")"
		Form:C1466.sfw.entry.panel.pages[2].label:="Jobs ("+String:C10(Form:C1466.lb_jobs.length)+")"
		Form:C1466.sfw.entry.panel.pages[3].label:="Lots ("+String:C10(Form:C1466.lb_lots.length)+")"
		Form:C1466.sfw.entry.panel.pages[4].label:="Invoices ("+String:C10(Form:C1466.lb_invoices.length)+")"
	End use 
	Form:C1466.sfw.drawHTab()
	Case of 
		: (FORM Get current page:C276(*)=1)  // main
			$minHeight:=566
			
			OBJECT GET COORDINATES:C663(*; "filler_hos"; $left; $top; $right; $bottom)
			
			$offset:=4
			
			OBJECT SET COORDINATES:C1248(*; "filler_hos"; $left; $top; $widthSubform-$offset; $heightSubform-$offset)
			
			OBJECT SET VISIBLE:C603(*; "filler_ver"; ($heightSubform>$minHeight))
			
			If ($heightSubform>$minHeight)
				OBJECT GET COORDINATES:C663(*; "filler_ver"; $left; $top; $right; $bottom)
				
				OBJECT SET COORDINATES:C1248(*; "filler_ver"; $left; $top; $right; $heightSubform-$offset)
			End if 
			
		: (FORM Get current page:C276(*)=2)  // po lines
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_poLinesItems"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionLineItems"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_poLinesItems"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionLineItems"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			
		: (FORM Get current page:C276(*)=3)  // jobs
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_3"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_jobs"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			
			$offset:=4
			$offset_bAc:=10
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_3"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_jobs"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=4)  // lots
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_4"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_lots"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			
			$offset:=4
			$offset_bAc:=10
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_4"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_lots"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=5)  // invoices
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_5"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_invoices"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionInvoices"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_5"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_invoices"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionInvoices"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
	End case 
	
	//OBJECT SET ENTERABLE(*; "entryField_poNumber"; False)
	
	If (Form:C1466.current_item.quote#Null:C1517)
		OBJECT SET VISIBLE:C603(*; "amountError"; (Form:C1466.current_item.poAmount#Form:C1466.current_item.quote.amountNumber))
	Else 
		OBJECT SET VISIBLE:C603(*; "amountError"; False:C215)
	End if 
	
	OBJECT SET VISIBLE:C603(*; "label_taxPercentage"; Form:C1466.current_item.taxApplied)
	OBJECT SET VISIBLE:C603(*; "label_taxPercentage2"; Form:C1466.current_item.taxApplied)
	OBJECT SET VISIBLE:C603(*; "entryField_taxPercentage"; Form:C1466.current_item.taxApplied)

	// the user badge scan button and the log date picker are only available while editing
	var $isInModification : Boolean
	$isInModification:=Form:C1466.sfw.checkIsInModification()
	OBJECT SET VISIBLE:C603(*; "bScan_user"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "bScan_user"; $isInModification)
	OBJECT SET VISIBLE:C603(*; "btnDatePicker_logDate"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "btnDatePicker_logDate"; $isInModification)
	
	
	
Function loadDpAddress()
	Form:C1466.dpAddress:=New object:C1471(\
		"values"; New collection:C1472("billing"; "shipping"); \
		"index"; 0; \
		"currentValue"; "Billing Address"\
		)
	
Function loadAllTabs()
	This:C1470.loadPoLineItems()
	This:C1470.loadPoJobs()
	This:C1470.loadLots()
	This:C1470.loadInvoices()
	
	
Function loadPoLineItems()
	Form:C1466.lb_lineItems:=ds:C1482.PurchaseOrderLine.query("UUID_PurchaseOrder = :1"; Form:C1466.current_item.UUID)
	
Function applyPoLineTotal($poLine : 4D:C1709.Entity)
	// A line's stored total is quantity x unit price, plus sales tax when the line is
	// taxable and the purchase order applies tax. Nothing else in the application was
	// computing it (only the imports set it), so a line created here used to stay at 0
	// and the PO amount summed to 0.
	var $base : Real
	var $tax : Real

	If ($poLine=Null:C1517)
		return
	End if

	$base:=Num:C11($poLine.qtyOrdered)*Num:C11($poLine.unitPrice)

	$tax:=0
	If (Bool:C1537($poLine.taxable))
		If (Bool:C1537(Form:C1466.current_item.taxApplied))
			$tax:=$base*(Num:C11(Form:C1466.current_item.taxPercentage)/100)
		End if
	End if

	$poLine.saleTax:=$tax
	$poLine.total:=$base+$tax

Function recalcPoAmount()
	// PO Amount is a read-only calculated value: the sum of the line item totals.
	// Kept in sync whenever a line is created, edited or deleted so the stored
	// poAmount stays authoritative for downstream billing (panel_jobInvoice) and
	// the quote-mismatch warning.
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	var $sum : Real
	$sum:=ds:C1482.PurchaseOrderLine.query("UUID_PurchaseOrder = :1"; Form:C1466.current_item.UUID).sum("total")
	If (Form:C1466.current_item.poAmount#$sum)
		Form:C1466.current_item.poAmount:=$sum
		Form:C1466.current_item.save()
	End if
	
Function loadPoJobs()
	Form:C1466.lb_jobs:=Form:C1466.current_item.jobs
	
Function loadLots()
	Form:C1466.lb_lots:=Form:C1466.current_item.lineItems.job.lots
	
Function loadInvoices()
	Form:C1466.lb_invoices:=ds:C1482.Invoice.query("UUID_PurchaseOrder = :1"; Form:C1466.current_item.UUID)
	
Function poLineDialogData($poLine : 4D:C1709.Entity)->$form : Object
	// Data handed to the createPoLine dialog: the line itself, the quote lines to
	// pick from (empty when the PO has no related quote, which disables the quote
	// line selection) and the PO shipping address used as the default for the
	// line's own editable shipping address.
	var $shipping : Object
	
	$quoteLines:=New collection:C1472()
	If (Form:C1466.current_item.quote#Null:C1517)
		If (Form:C1466.current_item.quote.lines#Null:C1517)
			$quoteLines:=Form:C1466.current_item.quote.lines
		End if
	End if

	$shipping:=Null:C1517
	If (Form:C1466.current_item.address#Null:C1517)
		If (Form:C1466.current_item.address.addresses#Null:C1517)
			$shipping:=Form:C1466.current_item.address.addresses.query("type = :1"; "shipping").first()
		End if
	End if

	// jobs of this PO (the customer's jobs attached to it): the Shipping Job picker
	$poJobs:=ds:C1482.Job.query("UUID_PurchaseOrder = :1"; Form:C1466.current_item.UUID).orderBy("jobNumber")

	$form:=New object:C1471(\
		"poLine"; $poLine; \
		"quoteLines"; $quoteLines; \
		"poShippingAddress"; $shipping; \
		"poJobs"; $poJobs; \
		"searchQuoteLine"; ""\
		)

	// The address subform asks its host window to redraw the panel buttons
	// (CALL FORM -> sfw_main_draw_button -> Form.sfw.drawButtons()). The host here is a
	// dialog, not a panel, so it has no such buttons: expose a no-op so the framework
	// callback stays harmless instead of failing on a missing Form.sfw.
	$form.sfw:=New object:C1471("drawButtons"; Formula:C1597(0))
	
Function bActionLineItems()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "Create Line Item")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "Edit Line Item")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--create")
				$lineItem:=ds:C1482.PurchaseOrderLine.new()
				
				$lineItem.UUID_PurchaseOrder:=Form:C1466.current_item.UUID
				If (Form:C1466.lb_lineItems.length>0)
					$lineItem.itemNum:=Form:C1466.lb_lineItems.max("itemNum")+1
				Else 
					$lineItem.itemNum:=1
				End if 
				
				$form:=This:C1470.poLineDialogData($lineItem)
				
				$winRef:=Open form window:C675("createPoLine"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createPoLine"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (OK=1)
					$lineItem:=$form.poLine
					This:C1470.applyPoLineTotal($lineItem)
					
					$res:=$lineItem.save()
					
					If ($res.success)
						This:C1470.loadPoLineItems()
						This:C1470.recalcPoAmount()
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
				
			: ($choose="--edit")
				$form:=This:C1470.poLineDialogData(Form:C1466.selectedPoLine)
				
				$winRef:=Open form window:C675("createPoLine"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createPoLine"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (OK=1)
					$lineItem:=$form.poLine
					This:C1470.applyPoLineTotal($lineItem)
					
					$res:=$lineItem.save()
					
					If ($res.success)
						This:C1470.loadPoLineItems()
						This:C1470.recalcPoAmount()
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
				
			: ($choose="--delete")
				If (Form:C1466.selectedPoLine#Null:C1517)
					CONFIRM:C162("Are you sure ?")
					If (OK=1)
						$res:=Form:C1466.selectedPoLine.drop()
						
						If ($res.success)
							This:C1470.loadPoLineItems()
							This:C1470.recalcPoAmount()
							This:C1470._activate_save_cancel_button()
						End if 
					End if 
				Else 
					ALERT:C41("Select a PO line item !")
				End if 
		End case 
	Else 
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "(Create Line Item")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "(Edit Line Item")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "(Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--all")
				$title:="All Status"
				Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems
				
			: ($choose="--unreleased")
				$title:="Status: Unreleased"
				Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems.query("unreleased = :1"; True:C214)
				
			: ($choose="--closed")
				$title:="Status: Closed"
				Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems.query("closed = :1"; True:C214)
		End case 
	End if 
	
	
Function bActionInvoices()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "Create new Invoice")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		
		APPEND MENU ITEM:C411($refMenu; "Edit Invoice")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
		
		APPEND MENU ITEM:C411($refMenu; "-")
		
		APPEND MENU ITEM:C411($refMenu; "Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--create")
				$invoice:=ds:C1482.Invoice.new()
				
				$invoice.UUID_PurchaseOrder:=Form:C1466.current_item.UUID
				
				$form:=New object:C1471("invoice"; $invoice)
				
				$winRef:=Open form window:C675("createInvoice_po"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createInvoice_po"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (OK=1)
					$invoice:=$form.invoice
					
					$res:=$invoice.save()
					
					If ($res.success)
						This:C1470.loadInvoices()
						This:C1470._activate_save_cancel_button()
					End if 
				End if 
				
			: ($choose="--edit")
				If (Form:C1466.selectedInv#Null:C1517)
					$form:=New object:C1471("invoice"; Form:C1466.selectedInv)
					
					$winRef:=Open form window:C675("createInvoice_po"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
					DIALOG:C40("createInvoice_po"; $form)
					CLOSE WINDOW:C154($winRef)
					
					If (OK=1)
						$invoice:=$form.invoice
						
						$res:=$invoice.save()
						
						If ($res.success)
							This:C1470.loadInvoices()
							This:C1470._activate_save_cancel_button()
						End if 
					End if 
				Else 
					cs:C1710.sfw_dialog.me.alert("No Inventory selected !")
				End if 
				
			: ($choose="--delete")
				If (Form:C1466.selectedInv#Null:C1517)
					cs:C1710.sfw_dialog.me.confirm("No Inventory selected !")
					
					If (ok=1)
						$res:=Form:C1466.selectedInv.drop()
						
						If ($res.success)
							This:C1470.loadInvoices()
							This:C1470._activate_save_cancel_button()
						End if 
					End if 
				Else 
					cs:C1710.sfw_dialog.me.alert("No Inventory selected !")
				End if 
		End case 
	Else 
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "(Create new Invoice")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "(Edit Invoice")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit")
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "(Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--all")
				$title:="All Status"
				Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems
				
			: ($choose="--unreleased")
				$title:="Status: Unreleased"
				Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems.query("unreleased = :1"; True:C214)
				
			: ($choose="--closed")
				$title:="Status: Closed"
				Form:C1466.lb_lineItems:=Form:C1466.current_item.lineItems.query("closed = :1"; True:C214)
		End case 
	End if 
	
Function selectCustomer()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_customerName"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"allData"; ds:C1482.Customer.all(); \
					"dataclass"; "Customer"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Customer:=$form.item.UUID
					
					Form:C1466.current_item.address.addresses:=$form.item.contactDetails.addresses
					Form:C1466.current_item.rebuildAddress()
					
					cs:C1710.panel_purchaseOrder.me._activate_save_cancel_button()
				End if 
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case 
	End if 
	
Function btnOpenCustomer()
	$entity:=Form:C1466.current_item.customer
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "customer")
	
	
	
Function btnOpenQuote()
	// Open the quote currently linked to this PO in its own window
	$entity:=Form:C1466.current_item.quote
	If ($entity=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No quote is linked to this purchase order.")
		return
	End if
	Form:C1466.sfw.openInANewWindow($entity; "salesAndQuotes"; "quote")


Function selectQuote()
	// Quote is picked through the standard selectNto1 list (searched and displayed
	// on the quote code), same pattern as the customer and user fields. The list is
	// limited to the quotes of the PO's customer. The linked quote is then displayed
	// by Field_quoteNumber (current_item.quote.code).
	var $quotes : cs:C1710.QuoteSelection

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	If (Form:C1466.current_item.customer=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("Please select a customer first.")
		return
	End if

	$quotes:=Form:C1466.current_item.customer.quotes.orderBy("code")

	If ($quotes.length=0)
		cs:C1710.sfw_dialog.me.alert("This customer has no quote.")
		return
	End if

	OBJECT GET COORDINATES:C663(*; "Field_quoteNumber"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

	$form:=New object:C1471(\
		"colName"; "code"; \
		"allData"; $quotes; \
		"dataclass"; "Quote"\
		)

	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)

	If (OK=1)
		Form:C1466.current_item.UUID_Quote:=$form.item.UUID
		This:C1470._activate_save_cancel_button()
	End if
	
	