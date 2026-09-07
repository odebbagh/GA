singleton Class constructor
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary to refresh
		Form:C1466.addressBilling:=1
		Form:C1466.addressShipping:=0
		// Wire the address subform straight away (billing by default). Without this the
		// subform stayed empty until the Billing/Shipping button was clicked, because
		// contactDetails() was only reachable from redrawAndSetVisible().
		This:C1470.contactDetails()
		//Form.apContact:=1
		//Form.statusContact:=0
		//This.LoadContact()
		// Another customer is displayed: drop the tab contents (no query at all) and let
		// the page branch below rebuild only the tab that is actually visible.
		This:C1470.resetTabs()
		This:C1470.loadTabCounts()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				// Main page: refresh the address subform (same pattern as the other panels)
				This:C1470.contactDetails()
				//This.LoadContact()
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadPOs()
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadJobs()
				
			: (FORM Get current page:C276(*)=4)
				This:C1470.loadPlannings()
				
			: (FORM Get current page:C276(*)=5)
				This:C1470.loadCFMReceiving()
				
			: (FORM Get current page:C276(*)=6)
				This:C1470.loadInvoices()
				
			: (FORM Get current page:C276(*)=7)
				This:C1470.loadContacts()
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "subFormAddress"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "subFormAddress"; $g; $h; $widthSubform-5; $b)
			
		: (FORM Get current page:C276(*)=2)
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			
			OBJECT GET COORDINATES:C663(*; "lb_POs"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_POs"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=3)
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_3"; $left; $top; $right; $bottom)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_3"; $left; $top; $right; $heightSubform-$offset)
			
			OBJECT GET COORDINATES:C663(*; "lb_Jobs"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_Jobs"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=4)
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_4"; $left; $top; $right; $bottom)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_4"; $left; $top; $right; $heightSubform-$offset)
			
			OBJECT GET COORDINATES:C663(*; "lb_Planning"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_Planning"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=5)
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_5"; $left; $top; $right; $bottom)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_5"; $left; $top; $right; $heightSubform-$offset)
			
			OBJECT GET COORDINATES:C663(*; "lb_CFM_Receiving"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_CFM_Receiving"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=6)
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_6"; $left; $top; $right; $bottom)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_6"; $left; $top; $right; $heightSubform-$offset)
			
			OBJECT GET COORDINATES:C663(*; "lb_Invoices"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_Invoices"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=7)
			
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_7"; $left; $top; $right; $bottom)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_7"; $left; $top; $right; $heightSubform-$offset)
			
			OBJECT GET COORDINATES:C663(*; "lb_Contacts"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_Contacts"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
	End case 
	
	// Presentation only from here: this function runs on nearly every form event, so it
	// must stay free of queries and of any data (re)loading. contactDetails() used to be
	// called here and now lives in formMethod, where the record actually changes. The
	// carrier no longer needs drawing either: Field_customerCarrier binds its name.
	
	// Tab counts come from Form.tabCounts, computed once per customer by loadTabCounts().
	// They used to be read from the row collections, which are now built on demand and so
	// would have reported 0 for every tab not visited yet.
	var $counts : Object
	$counts:=Form:C1466.tabCounts || New object:C1471()
	
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="POs ("+String:C10(Num:C11($counts.POs))+")"
		Form:C1466.sfw.entry.panel.pages[2].label:="Jobs ("+String:C10(Num:C11($counts.Jobs))+")"
		Form:C1466.sfw.entry.panel.pages[3].label:="Planning ("+String:C10(Num:C11($counts.Planning))+")"
		Form:C1466.sfw.entry.panel.pages[4].label:="CFM Receiving ("+String:C10(Num:C11($counts.CFMReceiving))+")"
		Form:C1466.sfw.entry.panel.pages[5].label:="Invoices ("+String:C10(Num:C11($counts.Invoices))+")"
		Form:C1466.sfw.entry.panel.pages[6].label:="Contacts ("+String:C10(Num:C11($counts.Contacts))+")"
	End use 
	
	Form:C1466.sfw.drawHTab()
	
Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
Function selectCustomerCarrier()
	// Carrier is picked from the CustomerCarrier table through the standard selectNto1
	// list (searched and displayed on the name), like the other N-to-1 links in the app.
	// Field_customerCarrier displays it via current_item.customerCarrier.name.
	var $form : Object
	var $winRef : Integer
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	
	OBJECT GET COORDINATES:C663(*; "field_customerCarrier"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	
	$form:=New object:C1471(\
		"colName"; "name"; \
		"allData"; ds:C1482.CustomerCarrier.all().orderBy("name"); \
		"dataclass"; "CustomerCarrier"\
		)
	
	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1)
		Form:C1466.current_item.UUID_CustomerCarrier:=$form.item.UUID
		This:C1470._activate_save_cancel_button()
	End if 
	
Function contactDetails()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.address:=Form:C1466.current_item.rebuildAddress()
		//Form.lb_contact:=Form.current_item.rebuildContact()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
	End if 
	
Function bActionContact()
	
Function LoadContact()
	
Function loadXXX()
	
Function loadTabCounts()
	// Row counts for the tab labels. Entity selection lengths only: no entity is loaded
	// and no row collection is built, so this stays cheap. Computed once per customer
	// (from formMethod) instead of on every redraw.
	var $counts : Object
	var $jobs : cs:C1710.JobSelection
	
	$counts:=New object:C1471(\
		"POs"; 0; \
		"Jobs"; 0; \
		"Planning"; 0; \
		"CFMReceiving"; 0; \
		"Invoices"; 0; \
		"Contacts"; 0\
		)
	
	If (Form:C1466.current_item#Null:C1517)
		$jobs:=Form:C1466.current_item.jobs
		$counts.POs:=Form:C1466.current_item.purchaseOrders.length
		$counts.Jobs:=$jobs.length
		$counts.Planning:=$jobs.lots.length
		$counts.CFMReceiving:=Form:C1466.current_item.inventories.length
		$counts.Contacts:=ds:C1482.Contact.query("UUID_Company = :1"; Form:C1466.current_item.UUID).length
		// Invoices stays 0: that tab has no data source yet (see loadInvoices)
	End if 
	
	Form:C1466.tabCounts:=$counts
	
Function resetTabs()
	// Empties the tab collections and forgets which customer they were built for. Cheap:
	// no query is made here, each tab is rebuilt on demand when it becomes visible.
	Form:C1466.lb_POs:=New collection:C1472()
	Form:C1466.lb_Jobs:=New collection:C1472()
	Form:C1466.lb_Planning:=New collection:C1472()
	Form:C1466.lb_CFM_Receiving:=New collection:C1472()
	Form:C1466.lb_Invoices:=New collection:C1472()
	Form:C1466.lb_Contacts:=New collection:C1472()
	Form:C1466.tabsLoadedFor:=New object:C1471()
	
Function _tabNeedsLoad($tab : Text)->$needed : Boolean
	// The panel form method runs on every form event and the framework asks for a page
	// recalculation on each bound variable change, so a loader would otherwise rebuild
	// its whole collection over and over. Rebuild only when this tab has not been built
	// yet for the customer currently displayed.
	var $uuid : Text
	
	$needed:=False:C215
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Form:C1466.tabsLoadedFor=Null:C1517)
		Form:C1466.tabsLoadedFor:=New object:C1471()
	End if 
	
	$uuid:=String:C10(Form:C1466.current_item.UUID)
	If (String:C10(Form:C1466.tabsLoadedFor[$tab])=$uuid)
		return 
	End if 
	
	Form:C1466.tabsLoadedFor[$tab]:=$uuid
	$needed:=True:C214
	
Function loadPOs()
	var $pos : cs:C1710.PurchaseOrderSelection
	var $invoiceCounts : Object
	var $key : Text
	
	If (Not:C34(This:C1470._tabNeedsLoad("POs")))
		return 
	End if 
	
	Form:C1466.lb_POs:=New collection:C1472()
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	$pos:=Form:C1466.current_item.purchaseOrders.orderBy("poNumber")
	
	// Invoice count per purchase order in a single query. Reading $po.invoices.length
	// inside the loop below cost one query for every purchase order of the customer.
	$invoiceCounts:=New object:C1471()
	For each ($invoice; ds:C1482.Invoice.query("UUID_PurchaseOrder in :1"; $pos.extract("UUID")).toCollection("UUID_PurchaseOrder"))
		$key:=String:C10($invoice.UUID_PurchaseOrder)
		$invoiceCounts[$key]:=Num:C11($invoiceCounts[$key])+1
	End for each 
	
	For each ($po; $pos)
		$row:=New object:C1471()
		$row.UUID:=$po.UUID
		$row.division:=$po.division
		$row.PO_date:=$po.log_date
		$row.poNumber:=$po.poNumber
		$row.identifier:=$po.identifier
		$row.poAmount:=$po.poAmount
		$row.amountBilled:=$po.amountBilled
		$row.invoices:=Num:C11($invoiceCounts[String:C10($po.UUID)])
		Form:C1466.lb_POs.push($row)
	End for each 
	
Function loadJobs()
	//Loads the customer's jobs as display rows
	If (Not:C34(This:C1470._tabNeedsLoad("Jobs")))
		return 
	End if 
	
	Form:C1466.lb_Jobs:=New collection:C1472()
	If (Form:C1466.current_item#Null:C1517)
		For each ($job; Form:C1466.current_item.jobs.orderBy("jobNumber"))
			$row:=New object:C1471()
			$row.UUID:=$job.UUID
			$row.dateCreated:=$job.dateCreated
			$row.jobNumber:=$job.jobNumber
			$row.poNumber:=$job.poNumber
			$row.process:=$job.process
			$row.pr_qualifier:=$job.pr_qualifier
			Form:C1466.lb_Jobs.push($row)
		End for each 
	End if 
	
Function loadPlannings()
	//Loads the customer's lots (planning) as display rows
	var $jobs : cs:C1710.JobSelection
	var $jobNumbers : Object
	
	If (Not:C34(This:C1470._tabNeedsLoad("Planning")))
		return 
	End if 
	
	Form:C1466.lb_Planning:=New collection:C1472()
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	// The customer's jobs are resolved once, and their numbers kept in a map. Reading
	// $lot.job.jobNumber in the loop below resolved the relation for every single lot.
	$jobs:=Form:C1466.current_item.jobs
	$jobNumbers:=New object:C1471()
	For each ($job; $jobs.toCollection("UUID,jobNumber"))
		$jobNumbers[String:C10($job.UUID)]:=$job.jobNumber
	End for each 
	
	For each ($lot; $jobs.lots.orderBy("lotNumber"))
		$row:=New object:C1471()
		$row.UUID:=$lot.UUID
		$row.lotNumber:=$lot.lotNumber
		$row.jobNumber:=$jobNumbers[String:C10($lot.UUID_Job)]
		$row.poNumber:=$lot.poNumber
		$row.dateIn:=$lot.dateIn
		$row.dateOut:=$lot.dateOut
		$row.process:=$lot.process
		$row.ourCount:=$lot.ourCount
		Form:C1466.lb_Planning.push($row)
	End for each 
	
Function loadCFMReceiving()
	//Loads the customer's received material (inventory) as display rows
	If (Not:C34(This:C1470._tabNeedsLoad("CFMReceiving")))
		return 
	End if 
	
	Form:C1466.lb_CFM_Receiving:=New collection:C1472()
	If (Form:C1466.current_item#Null:C1517)
		For each ($inv; Form:C1466.current_item.inventories)
			$row:=New object:C1471()
			$row.UUID:=$inv.UUID
			$row.partNum:=$inv.partNum
			$row.stockNum:=$inv.stockNum
			$row.originalQty:=$inv.originalQty
			$row.availableQty:=$inv.availableQty
			$row.binLocation:=$inv.binLocation
			$row.description:=$inv.description
			Form:C1466.lb_CFM_Receiving.push($row)
		End for each 
	End if 
	
Function loadInvoices()
	//Invoices tab: layout only for now (no Invoice detail panel available yet).
	//TODO: populate from the Invoice table (matched on customer code) once its panel exists.
	If (Not:C34(This:C1470._tabNeedsLoad("Invoices")))
		return 
	End if 
	
	Form:C1466.lb_Invoices:=New collection:C1472()
	
Function loadContacts()
	// Load company contacts with key communication details for the last tab.
	If (Not:C34(This:C1470._tabNeedsLoad("Contacts")))
		return 
	End if 
	
	Form:C1466.lb_Contacts:=New collection:C1472()
	If (Form:C1466.current_item#Null:C1517)
		$contacts:=ds:C1482.Contact.query("UUID_Company = :1"; Form:C1466.current_item.UUID).orderBy("title, firstName, lastName")
		For each ($contact; $contacts)
			$item:=New object:C1471()
			$item.UUID:=$contact.UUID
			$item.contactType:=$contact.title
			$item.firstName:=$contact.firstName
			$item.lastName:=$contact.lastName
			$item.fullName:=$contact.firstName+" "+$contact.lastName
			$item.email:=""
			$item.phone:=""
			$communications:=$contact.contactDetails.communications
			If ($communications#Null:C1517)
				For each ($comm; $communications)
					If ($item.email="") && ($comm.type="email")
						$item.email:=$comm.contact
					End if 
					If ($item.phone="") && (($comm.type="phone") | ($comm.type="mobile"))
						$item.phone:=$comm.contact
					End if 
				End for each 
			End if 
			Form:C1466.lb_Contacts.push($item)
		End for each 
	End if 
	
	//If (Form.current_item#Null)
	//Form.lb_Contacts:=New collection()
	//$contacts:=ds.Contact.query("UUID_Company = :1"; Form.current_item.UUID).orderBy("title, firstName, lastName")
	
	//For each ($contact; $contacts)
	//$item:=New object()
	//$item.contactType:=$contact.title
	//$item.firstName:=$contact.firstName
	//$item.lastName:=$contact.lastName
	//$item.fullName:=$contact.firstName+" "+$contact.lastName
	//$item.email:=""
	//$item.phone:=""
	
	//$communications:=$contact.contactDetails.communications
	//If ($communications#Null)
	//For each ($comm; $communications)
	//If ($item.email="") && ($comm.type="email")
	//$item.email:=$comm.contact
	//End if 
	//If ($item.phone="") && (($comm.type="phone") | ($comm.type="mobile"))
	//$item.phone:=$comm.contact
	//End if 
	//End for each 
	//End if 
	
	//Form.lb_Contacts.push($item)
	//End for each 
	//End if 
	
Function bActionXXX()
	
Function loadDpAddress()
	Form:C1466.dpAddress:=New object:C1471(\
		"values"; New collection:C1472("billing"; "shipping"); \
		"index"; 0; \
		"currentValue"; "Billing Address"\
		)
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID