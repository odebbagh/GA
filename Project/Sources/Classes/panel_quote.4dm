singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh

		// the code, date and owner of a new quote are set in QuoteEntity.loadAfterCreation: set here,
		// they were also written into every existing quote without a date or owner on display, and
		// after a save (sfw stays in Modify mode) that read as a change nobody made

		
		This:C1470.drawPup_staff()
		This:C1470.drawPup_quoteLead()
		This:C1470.loadAllTabs()
		This:C1470.loadTabCounts()
		This:C1470.loadQuoteOrder()
		// a voided quote cannot be changed: sfw's checkIsInModification() is False with notEditable
		// (Form is this panel's, kept from one quote to the next: set for every quote)
		Form:C1466.notEditable:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.voided)
	End if

	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470._refreshContactDisplay()
				This:C1470.loadContacts()
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadQuoteLines()
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadAssumptions()
				This:C1470.loadTermsConditions()
				
			: (FORM Get current page:C276(*)=5)
				This:C1470.buildQuotePreview()

			: (FORM Get current page:C276(*)=6)
				This:C1470.loadRevisions()

			: (FORM Get current page:C276(*)=7)
				This:C1470.loadFollowUps()

		End case
	End if 
	
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
	Case of 
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			This:C1470.onBoundVariableChange()
			
	End case 
	
	
Function btnDatePicker($object; $attribut)
	// the app's calendar (ga_datePicker), under the clicked button
	// Without parameters: the btnDatePicker button itself, called by sfw_dynamicForm_script
	// (the Documents page switches this panel to dynamic rendering)
	If (Count parameters:C259=0)
		If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.sfw.checkIsInModification())
			This:C1470.btnDatePicker(Form:C1466.current_item; "dateCreation")
		End if
		return
	End if
	If (cs:C1710.ga_datePicker.me.pickInto($object; $attribut))
		This:C1470._activate_save_cancel_button()
	End if 
	
Function btnOpenStaff()
	$entity:=Form:C1466.current_item.staff
	Form:C1466.sfw.openInANewWindow($entity; "qualityAssurance"; "staff")
	
Function btnOpenCustomer()
	$entity:=Form:C1466.current_item.customer
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "customer")
	
	
Function _refreshContactDisplay()
	// the "Quotation to" block: the main contact's address and communications, always rebuilt so a
	// contact without an address (or no main contact) clears what the previous quote showed
	Form:C1466.contactDetails:=This:C1470.contactInfo()
	Form:C1466.subFormAddress:=New object:C1471("address"; Form:C1466.contactDetails.address || New object:C1471)
	Form:C1466.subFormCommunication:=New object:C1471("communications"; Form:C1466.contactDetails.communications || New collection:C1472)

Function loadContacts()
	var $e_mainContact : cs:C1710.ContactEntity
	var $secondaryContacts : cs:C1710.ContactSelection
	
	$contacts:=New collection:C1472()
	If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.mainContact#Null:C1517)
		$e_mainContact:=ds:C1482.Contact.get(Form:C1466.current_item.moreData.mainContact.UUID)
		If ($e_mainContact#Null:C1517)
			$mainContact:=$e_mainContact.toObject()
			$mainContact.type:="Main"
			$contacts.push($mainContact)
		End if 
	End if 
	
	If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.secondaryContacts#Null:C1517)
		$secondaryContacts:=ds:C1482.Contact.query("UUID in :1"; Form:C1466.current_item.moreData.secondaryContacts)
		For each ($e_contact; $secondaryContacts)
			$contact:=$e_contact.toObject()
			$contact.type:="Secondary"
			$contacts.push($contact)
		End for each 
	End if 
	Form:C1466.lb_contacts:=$contacts  //Form.current_item.contacts()
	
Function redrawAndSetVisible()
	var $descRight; $descBottom : Integer
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$verticalMargin:=3
	
	OBJECT SET VISIBLE:C603(*; "bActionQuoteLines"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "bActionAssumptions"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "bActionTerms"; Form:C1466.sfw.checkIsInModification())
	
	This:C1470.drawPup_quoteStatus()
	This:C1470.drawPup_quoteCustomer()
	This:C1470.drawPup_serviceType()
	This:C1470.drawPup_priceFlow()
	This:C1470.drawPup_quoteRevision()
	This:C1470.drawPup_staff()
	This:C1470.drawPup_quoteLead()

	This:C1470._refreshContactDisplay()

	// lifecycle (QuoteEntity "Lifecycle"): the validity date and its calendar in Modify, the
	// sent / won / lost / voided line in red once the quote has expired; the Order block (PO and
	// job, loadQuoteOrder) and the W/L reason once won or lost
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET VISIBLE:C603(*; "btnDatePickerValidUntil"; Form:C1466.sfw.checkIsInModification())
		OBJECT SET RGB COLORS:C628(*; "lifecycleText"; Choose:C955(Form:C1466.current_item.isExpired; "red"; "#808080"))
		OBJECT SET VISIBLE:C603(*; "btnOpenQuotePO"; (Form:C1466.quoteOrder#Null:C1517) && (Form:C1466.quoteOrder.po#Null:C1517))
		OBJECT SET VISIBLE:C603(*; "btnOpenQuoteJob"; (Form:C1466.quoteOrder#Null:C1517) && (Form:C1466.quoteOrder.job#Null:C1517))
		OBJECT SET VISIBLE:C603(*; "@quoteReasonWL"; (Form:C1466.current_item.outcome#"") || (Form:C1466.current_item.reasonWL#""))
		If (Form:C1466.current_item.voided)  // sfw makes entryField objects enterable in Modify
			OBJECT SET ENTERABLE:C238(*; "entryField@"; False:C215)
		End if
	End if

	
	Case of 
		: (FORM Get current page:C276(*)=1)
			OBJECT GET COORDINATES:C663(*; "communication_subform"; $g; $t; $r; $b)
			OBJECT GET COORDINATES:C663(*; "lb_contacts"; $gc; $tc; $rc; $bc)
			
			OBJECT SET COORDINATES:C1248(*; "lb_contacts"; $gc; $tc; $rc; $t)
			//OBJECT SET COORDINATES(*; "communication_subform"; $g; $t; $rc; $b)
			
		: (FORM Get current page:C276(*)=2)
			// same layout as the Lead Interactions page: ruban on the left with Actions at its bottom,
			// list in the middle, the line details on the right
			OBJECT GET COORDINATES:C663(*; "bActionQuoteLines"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bActionQuoteLines"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)

			OBJECT GET COORDINATES:C663(*; "rect_linesRuban"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "rect_linesRuban"; $g; $t; $r; $heightSubform)

			OBJECT GET COORDINATES:C663(*; "lb_quoteLines"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_quoteLines"; $g; $t; $r; $heightSubform)

			// the description takes the rest of the detail area, never less than in the form
			// (left 936, top 260, right 1341, 200 high)
			$descRight:=Num:C11($widthSubform)-20
			If ($descRight<1341)
				$descRight:=1341
			End if
			$descBottom:=Num:C11($heightSubform)-20
			If ($descBottom<(260+200))
				$descBottom:=260+200
			End if
			OBJECT SET COORDINATES:C1248(*; "entryField_quoteLineDescription"; 936; 260; $descRight; $descBottom)

		: (FORM Get current page:C276(*)=3)
			OBJECT GET COORDINATES:C663(*; "bkgd_lb_consumptions2"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "bkgd_lb_consumptions2"; $g; $t; $widthSubform; $b)
			
			OBJECT GET COORDINATES:C663(*; "bActionTerms"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bActionTerms"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)
			
			OBJECT GET COORDINATES:C663(*; "bkgd_lb_consumptions3"; $g; $h; $d; $b)
			OBJECT GET COORDINATES:C663(*; "lb_terms"; $gt; $ht; $dt; $bt)
			OBJECT SET COORDINATES:C1248(*; "lb_terms"; $g+1; $ht; $dt; $heightSubform-$verticalMargin-$heightButton-$verticalMargin)
			
			OBJECT GET COORDINATES:C663(*; "description"; $gt; $ht; $rt; $bt)
			OBJECT SET COORDINATES:C1248(*; "description"; $gt; $ht; $widthSubform-20; $heightSubform-$verticalMargin-$heightButton-$verticalMargin)
			
			OBJECT SET COORDINATES:C1248(*; "bkgd_lb_consumptions3"; $g; $h; $widthSubform; $heightSubform)
			
		: (FORM Get current page:C276(*)=5)  // Preview
			// ruban on the left with Actions at its bottom (as on Lines), the document on the right
			OBJECT GET COORDINATES:C663(*; "bActionPreview"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bActionPreview"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)

			OBJECT GET COORDINATES:C663(*; "rect_previewRuban"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "rect_previewRuban"; $g; $t; $r; $heightSubform)

			// the toolbar across the rest of the width, the document filling everything under it
			OBJECT GET COORDINATES:C663(*; "WPtoolbar_preview"; $gTB; $hTB; $dTB; $bTB)
			OBJECT SET COORDINATES:C1248(*; "WPtoolbar_preview"; $gTB; $hTB; $widthSubform; $bTB)
			OBJECT GET COORDINATES:C663(*; "WParea_preview"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "WParea_preview"; $g; $bTB; $widthSubform; $heightSubform)

		: (FORM Get current page:C276(*)=6)  // Revisions: ruban and Actions as on Lines, the note on the right
			OBJECT GET COORDINATES:C663(*; "bActionRevisions"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bActionRevisions"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)

			OBJECT GET COORDINATES:C663(*; "rect_revisionsRuban"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "rect_revisionsRuban"; $g; $t; $r; $heightSubform)

			OBJECT GET COORDINATES:C663(*; "lb_revisions"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_revisions"; $g; $t; $r; $heightSubform)

			// the note of the selected revision takes the rest of the width and height
			OBJECT GET COORDINATES:C663(*; "revisionNote"; $g; $t; $r; $b)
			$descRight:=Num:C11($widthSubform)-20
			If ($descRight<($g+200))
				$descRight:=$g+200
			End if
			$descBottom:=Num:C11($heightSubform)-20
			If ($descBottom<($t+100))
				$descBottom:=$t+100
			End if
			OBJECT SET COORDINATES:C1248(*; "revisionNote"; $g; $t; $descRight; $descBottom)

		: (FORM Get current page:C276(*)=7)  // Follow-ups: ruban and Actions as on Revisions, the notes on the right
			OBJECT GET COORDINATES:C663(*; "bActionFollowUps"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bActionFollowUps"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)

			OBJECT GET COORDINATES:C663(*; "rect_followUpsRuban"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "rect_followUpsRuban"; $g; $t; $r; $heightSubform)

			OBJECT GET COORDINATES:C663(*; "lb_followUps"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_followUps"; $g; $t; $r; $heightSubform)

			OBJECT GET COORDINATES:C663(*; "followUpNotes"; $g; $t; $r; $b)
			$descRight:=Num:C11($widthSubform)-20
			If ($descRight<($g+200))
				$descRight:=$g+200
			End if
			$descBottom:=Num:C11($heightSubform)-20
			If ($descBottom<($t+100))
				$descBottom:=$t+100
			End if
			OBJECT SET COORDINATES:C1248(*; "followUpNotes"; $g; $t; $descRight; $descBottom)

		: (FORM Get current page:C276(*)=4)  // Resume
			OBJECT GET COORDINATES:C663(*; "WPToolbar_opt"; $gTB; $hTB; $dTB; $bTB)
			OBJECT GET COORDINATES:C663(*; "WPArea_opt"; $g; $h; $d; $b)
			If (Form:C1466.sfw.checkIsInModification())
				OBJECT SET VISIBLE:C603(*; "WPToolbar_opt"; True:C214)
				
				OBJECT SET ENTERABLE:C238(*; "WParea_opt"; True:C214)
				OBJECT SET ENTERABLE:C238(*; "WPtoolbar_opt"; True:C214)
				
				OBJECT SET COORDINATES:C1248(*; "WPArea_opt"; $g; $bTB; $widthSubform; $heightSubform)
				OBJECT SET COORDINATES:C1248(*; "WPToolbar_opt"; $gTB; $hTB; $widthSubform; $bTB)
			Else 
				OBJECT SET VISIBLE:C603(*; "WPToolbar_opt"; False:C215)
				
				OBJECT SET ENTERABLE:C238(*; "WParea_opt"; False:C215)
				OBJECT SET ENTERABLE:C238(*; "WPtoolbar_opt"; False:C215)
				
				OBJECT SET COORDINATES:C1248(*; "WPArea_opt"; $g; $hTB; $widthSubform; $heightSubform)
			End if 
			
			
			
	End case 
	
	
	
	// record counts in the tab labels, as in the other panels. Read from Form.tabCounts and
	// Form.nb_sfw_Documents (loadTabCounts): this runs on nearly every form event, no query here
	var $counts : Object
	$counts:=Form:C1466.tabCounts || New object:C1471()
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Lines ("+String:C10(Num:C11($counts.lines))+")"
		Form:C1466.sfw.entry.panel.pages[5].label:="Revisions ("+String:C10(Num:C11($counts.revisions))+")"
		Form:C1466.sfw.entry.panel.pages[6].label:="Follow-ups ("+String:C10(Num:C11($counts.followUps))+")"
		Form:C1466.sfw.entry.panel.pages[7].label:="Documents ("+String:C10(Num:C11(Form:C1466.nb_sfw_Documents))+")"
	End use
	Form:C1466.sfw.drawHTab()


Function loadAllTabs()
	//This.loadQuoteLines()
	//This.loadAssumptions()

Function loadTabCounts()
	// Row counts for the tab labels, worked out once per quote (formMethod) and not on every redraw:
	// lengths of entity selections only, nothing is loaded. Documents: Form.nb_sfw_Documents, which
	// the framework then keeps up to date on every upload, model or delete (counted here as in
	// sfw_definitionPageDocuments.refreshHTab)
	Form:C1466.tabCounts:=New object:C1471("lines"; 0; "revisions"; 0; "followUps"; 0)
	Form:C1466.nb_sfw_Documents:=0
	If (Form:C1466.current_item#Null:C1517)
		This:C1470._countQuoteLines()
		This:C1470._countDocuments()
		Form:C1466.tabCounts.revisions:=Form:C1466.current_item.revisions.length
		Form:C1466.tabCounts.followUps:=cs:C1710.ga_followUps.me.list(Form:C1466.current_item).length
	End if

Function _countQuoteLines()
	If (Form:C1466.tabCounts=Null:C1517)
		Form:C1466.tabCounts:=New object:C1471("lines"; 0)
	End if
	Form:C1466.tabCounts.lines:=(Form:C1466.current_item=Null:C1517) ? 0 : Form:C1466.current_item.lines.length

Function _countDocuments()
	Form:C1466.nb_sfw_Documents:=ds:C1482.sfw_Document.query("UUID_target = :1"; Form:C1466.current_item.UUID).length
	Form:C1466.nb_sfw_Documents+=ds:C1482.dfd_Document.query("UUID_target = :1"; Form:C1466.current_item.UUID).length

Function loadQuoteLines()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_quoteLines:=Form:C1466.current_item.lines.orderBy("num asc")
		This:C1470.displayQuoteLine()
	End if
	This:C1470._countQuoteLines()  // a line added or deleted, or a Cancel that drops them
	
Function bActionQuoteLines()
	//var $selection : cs.QuoteLineSelection
	var $index : Integer
	$mainMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($mainMenu; "Add quote line..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--addQuoteLine")
	SET MENU ITEM SHORTCUT:C423($mainMenu; -1; "L"; Command key mask:K16:1)
	// the unit price from the Master Price List for the steps ticked (ga_quoteLinePricing): the
	// selected line, or a new one when none is selected
	APPEND MENU ITEM:C411($mainMenu; "Price from the price list..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--priceFromList")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if
	APPEND MENU ITEM:C411($mainMenu; "-")
	
	// moving needs a selected line that is not already first (up) or last (down)
	$index:=-1
	If (Form:C1466.current_quoteLine#Null:C1517) && (Form:C1466.lb_quoteLines#Null:C1517)
		$index:=Form:C1466.current_quoteLine.indexOf(Form:C1466.lb_quoteLines)
	End if
	APPEND MENU ITEM:C411($mainMenu; "Move line up"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--moveQuoteLineUp")
	If ($index<=0)
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if
	APPEND MENU ITEM:C411($mainMenu; "Move line down"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--moveQuoteLineDown")
	If ($index=-1) || ($index>=(Form:C1466.lb_quoteLines.length-1))
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if
	APPEND MENU ITEM:C411($mainMenu; "-")
	
	// a typed or imported minimum back to the price list (ga_quoteMinCharge), or to none
	APPEND MENU ITEM:C411($mainMenu; "Reset minimum lot charge"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--resetMinLotCharge")
	If (Form:C1466.current_quoteLine=Null:C1517) || (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($mainMenu; -1)
	Else
		If (New collection:C1472("manual"; "legacy").indexOf(cs:C1710.ga_quoteMinCharge.me.sourceOf(Form:C1466.current_quoteLine))=-1)
			DISABLE MENU ITEM:C150($mainMenu; -1)
		End if
	End if
	APPEND MENU ITEM:C411($mainMenu; "-")

	APPEND MENU ITEM:C411($mainMenu; "Delete quote line..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--deleteQuoteLine")
	If (Form:C1466.current_quoteLine=Null:C1517)
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($mainMenu)
	RELEASE MENU:C978($mainMenu)
	
	
	Case of 
		: ($choose="--addQuoteLine")
			
			
			$eQuoteLine:=ds:C1482.QuoteLine.new()
			$eQuoteLine.UUID_Quote:=Form:C1466.current_item.UUID
			$eQuoteLine.num:=Num:C11(Form:C1466.current_item.lines.max("num"))+1  // lines are shown in "num" order
			$info:=$eQuoteLine.save()
			Form:C1466.current_quoteLine:=$eQuoteLine
			This:C1470.displayQuoteLine()
			This:C1470._activate_save_cancel_button()

			Form:C1466.lb_quoteLines:=ds:C1482.QuoteLine.query("UUID_Quote == :1"; Form:C1466.current_item.UUID).orderBy("num asc")
			This:C1470._countQuoteLines()
			LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; Form:C1466.lb_quoteLines.length; lk replace selection:K53:1)
			GOTO OBJECT:C206(*; "entryField_quoteLineQuantity")


		: ($choose="--priceFromList")
			This:C1470._priceLineFromList()

		: ($choose="--resetMinLotCharge")
			cs:C1710.ga_quoteMinCharge.me.resetToDefault(Form:C1466.current_quoteLine)
			This:C1470._saveQuoteLine()
			cs:C1710.ga_quoteMinCharge.me.alertIfUnder(Form:C1466.current_quoteLine)
			Form:C1466.lb_quoteLines:=Form:C1466.lb_quoteLines  // the row colour follows (QuoteLineEntity.meta)

		: ($choose="--moveQuoteLineUp")
			This:C1470._moveQuoteLine(-1)

		: ($choose="--moveQuoteLineDown")
			This:C1470._moveQuoteLine(1)

		: ($choose="--deleteQuoteLine")
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this quote line? "; "Delete"; "CANCEL")
			If ($ok)



				$info:=Form:C1466.current_quoteLine.drop()
				Form:C1466.current_item.renumberLines()  // no gap left in the line numbers
				This:C1470._activate_save_cancel_button()
				LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; 0; lk remove from selection:K53:3)
				Form:C1466.current_quoteLine:=Null:C1517
				This:C1470.loadQuoteLines()
			End if

	End case

	// "Price from the price list...": the steps of the line ticked in Quote_pickSteps give its unit
	// price (ga_quoteLinePricing); its minimum goes back to the price list for those steps, then the
	// usual path of a typed unit price runs (floor check, save). A new line when none is selected;
	// a new line left unpriced (Cancel) is removed again.
Function _priceLineFromList()
	var $data; $info : Object
	var $window; $index : Integer
	var $isNew : Boolean
	var $eQuoteLine : cs:C1710.QuoteLineEntity

	If (Form:C1466.current_quoteLine=Null:C1517)
		$eQuoteLine:=ds:C1482.QuoteLine.new()
		$eQuoteLine.UUID_Quote:=Form:C1466.current_item.UUID
		$eQuoteLine.num:=Num:C11(Form:C1466.current_item.lines.max("num"))+1
		$eQuoteLine.quantity:=1
		$info:=$eQuoteLine.save()
		Form:C1466.current_quoteLine:=$eQuoteLine
		$isNew:=True:C214
	End if

	$data:=cs:C1710.ga_quoteLinePricing.me.dialogData(Form:C1466.current_item; Form:C1466.current_quoteLine)
	$window:=Open form window:C675("Quote_pickSteps"; Sheet form window:K39:12)
	DIALOG:C40("Quote_pickSteps"; $data)
	CLOSE WINDOW:C154($window)

	If (OK=1) && (cs:C1710.ga_quoteLinePricing.me.applyToLine(Form:C1466.current_quoteLine; $data))
		// a step set's usual flow, accepted in the dialog: the quote takes it (before the floor check,
		// which reads the quote's flow); its other lines keep their prices
		If ($data.newFlowUUID#"")
			Form:C1466.current_item.UUID_PriceFlow:=$data.newFlowUUID
			This:C1470.drawPup_priceFlow()
		End if
		cs:C1710.ga_quoteMinCharge.me.resetToDefault(Form:C1466.current_quoteLine)  // the minimum of these steps
		This:C1470.entryField_quoteLineUnitPrice()  // floor check, save, row colour
	Else
		If ($isNew)
			$info:=Form:C1466.current_quoteLine.drop()
			Form:C1466.current_quoteLine:=Null:C1517
		End if
	End if

	This:C1470.loadQuoteLines()
	If (Form:C1466.current_quoteLine#Null:C1517)
		Form:C1466.current_quoteLine:=Form:C1466.lb_quoteLines.query("UUID = :1"; Form:C1466.current_quoteLine.UUID).first()
		If (Form:C1466.current_quoteLine#Null:C1517)
			$index:=Form:C1466.current_quoteLine.indexOf(Form:C1466.lb_quoteLines)
			LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; $index+1; lk replace selection:K53:1)
		End if
	End if
	This:C1470.displayQuoteLine()
	This:C1470._activate_save_cancel_button()

Function _moveQuoteLine($delta : Integer)
	// one place up (-1) or down (1); the lines are renumbered 1..n and saved inside the quote's
	// Modify, so Cancel puts them back. The moved line is taken again from the reloaded list:
	// the old reference holds the number from before the save and would no longer save
	var $UUID : Text
	var $index : Integer
	$UUID:=Form:C1466.current_quoteLine.UUID
	If (Form:C1466.current_item.moveLine($UUID; $delta))
		This:C1470._activate_save_cancel_button()
	End if
	This:C1470.loadQuoteLines()
	Form:C1466.current_quoteLine:=Form:C1466.lb_quoteLines.query("UUID = :1"; $UUID).first()
	If (Form:C1466.current_quoteLine#Null:C1517)
		$index:=Form:C1466.current_quoteLine.indexOf(Form:C1466.lb_quoteLines)
		LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; $index+1; lk replace selection:K53:1)
	End if
	This:C1470.displayQuoteLine()

Function displayQuoteLine()
	OBJECT SET VISIBLE:C603(*; "label_quoteLine@"; Form:C1466.current_quoteLine#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "entryField_quoteLine@"; Form:C1466.current_quoteLine#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "input_quoteLine@"; Form:C1466.current_quoteLine#Null:C1517)
	// "Built from": only on the lines priced from steps (ga_quoteLinePricing)
	OBJECT SET VISIBLE:C603(*; "input_quoteLineBuiltFrom"; (Form:C1466.current_quoteLine#Null:C1517) && (Form:C1466.current_quoteLine.builtFromText#""))

Function loadAssumptions()
	If (Form:C1466.current_item.assumptions.UUIDs#Null:C1517)
		Form:C1466.lb_assumptions:=ds:C1482.Assumption.query("UUID in :1"; Form:C1466.current_item.assumptions.UUIDs)
	End if 
	
	
Function bActionAssumptions()
	$mainMenu:=Create menu:C408
	$plurial:=Form:C1466.selected_assumptions.length>1 ? True:C214 : False:C215
	
	APPEND MENU ITEM:C411($mainMenu; "Add assumption..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--addAssumption")
	APPEND MENU ITEM:C411($mainMenu; "-")
	
	APPEND MENU ITEM:C411($mainMenu; "Remove the assumption"+($plurial ? "s" : "")+"..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--deleteAssumption")
	If (Form:C1466.current_assumption=Null:C1517)
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($mainMenu)
	RELEASE MENU:C978($mainMenu)
	
	
	Case of 
		: ($choose="--addAssumption")
			$form:=New object:C1471()
			
			$form.lb_assumptions:=New collection:C1472()
			For each ($eAssumption; ds:C1482.Assumption.query("not(UUID in :1)"; Form:C1466.current_item.assumptions.UUIDs))
				$assumption:=$eAssumption.toObject()
				$selected:=(Form:C1466.current_item.assumptions.UUIDs.indexOf($eAssumption.UUID)#-1)
				$assumption.selected:=False:C215
				
				$form.lb_assumptions.push($assumption)
			End for each 
			$ref:=Open form window:C675("Quote_chooseAssumption"; Sheet form window:K39:12)
			DIALOG:C40("Quote_chooseAssumption"; $form)
			CLOSE WINDOW:C154($ref)
			If (ok=1)
				For each ($assumption; $form.lb_assumptions)
					If ($assumption.selected)
						Form:C1466.current_item.assumptions.UUIDs.push($assumption.UUID)
					End if 
				End for each 
				This:C1470.loadAssumptions()
				cs:C1710.panel_quote.me._activate_save_cancel_button()
			End if 
			
		: ($choose="--deleteAssumption")
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to remove the assumption"+($plurial ? "s" : "")+" from the quote? "; "Delete"; "CANCEL")
			
			If ($ok)
				For each ($selected_assumption; Form:C1466.selected_assumptions)
					$index:=Form:C1466.current_item.assumptions.UUIDs.indexOf($selected_assumption.UUID)
					If ($index#-1)
						Form:C1466.current_item.assumptions.UUIDs.remove($index)
					End if 
				End for each 
				This:C1470.loadAssumptions()
				cs:C1710.panel_quote.me._activate_save_cancel_button()
			End if 
			
	End case 
	
Function loadTermsConditions()
	If (Form:C1466.current_item.termsConditions.UUIDs#Null:C1517)
		Form:C1466.lb_terms:=ds:C1482.TermCondition.query("UUID in :1"; Form:C1466.current_item.termsConditions.UUIDs)
	End if 
	
	
Function bActionTerms()
	$mainMenu:=Create menu:C408
	$plurial:=Form:C1466.selected_terms.length>1 ? True:C214 : False:C215
	
	APPEND MENU ITEM:C411($mainMenu; "Add term and condition..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--addTermCondition")
	APPEND MENU ITEM:C411($mainMenu; "-")
	
	APPEND MENU ITEM:C411($mainMenu; "Remove the term"+($plurial ? "s" : "")+"..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--deleteTermCondition")
	If (Form:C1466.current_term=Null:C1517)
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($mainMenu)
	RELEASE MENU:C978($mainMenu)
	
	
	Case of 
		: ($choose="--addTermCondition")
			$form:=New object:C1471()
			
			$form.lb_terms:=New collection:C1472()
			For each ($eTerm; ds:C1482.TermCondition.query("not(UUID in :1)"; Form:C1466.current_item.termsConditions.UUIDs))
				$term:=$eTerm.toObject()
				$selected:=(Form:C1466.current_item.termsConditions.UUIDs.indexOf($eTerm.UUID)#-1)
				$term.selected:=False:C215
				
				$form.lb_terms.push($term)
			End for each 
			$ref:=Open form window:C675("Quote_chooseTerm"; Sheet form window:K39:12)
			DIALOG:C40("Quote_chooseTerm"; $form)
			CLOSE WINDOW:C154($ref)
			If (ok=1)
				For each ($term; $form.lb_terms)
					If ($term.selected)
						Form:C1466.current_item.termsConditions.UUIDs.push($term.UUID)
					End if 
				End for each 
				This:C1470.loadTermsConditions()
				cs:C1710.panel_quote.me._activate_save_cancel_button()
			End if 
			
		: ($choose="--deleteTermCondition")
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to remove the term"+($plurial ? "s" : "")+" from the quote? "; "Delete"; "CANCEL")
			
			If ($ok)
				For each ($selected_term; Form:C1466.selected_terms)
					$index:=Form:C1466.current_item.termsConditions.UUIDs.indexOf($selected_term.UUID)
					If ($index#-1)
						Form:C1466.current_item.termsConditions.UUIDs.remove($index)
					End if 
				End for each 
				This:C1470.loadTermsConditions()
				cs:C1710.panel_quote.me._activate_save_cancel_button()
			End if 
			
	End case 
	
Function preview()->$preview : Object
	// the quote being edited, as the document prints it (QuoteEntity.preview: also what a
	// revision freezes)
	$preview:=Form:C1466.current_item.preview()
	
Function buildQuotePreview()
	// the Preview tab: the quote being edited
	Form:C1466.preview:=This:C1470.quoteDocument(This:C1470.preview())

	// The quote document (Write Pro) from a preview object: QuoteEntity.preview() for the quote as
	// it is, QuoteRevisionEntity.preview() for a frozen revision. Also used by Quote_savePreviewPdf
	// and Quote_revisionView, so a revision prints with the same layout
Function quoteDocument($preview : Object)->$wp : Object
	var $prelim : Object
	var $withMinCharge : Boolean

	$wp:=WP New:C1317()
	$headerLogoFile:=Folder:C1567(fk resources folder:K87:11).file("picts_GA/HeaderPortrait.jpeg")
	If ($headerLogoFile.exists)
		$headerLogoBlob:=$headerLogoFile.getContent()
		BLOB TO PICTURE:C682($headerLogoBlob; $headerLogoPict)
	End if 
	
	$section:=WP Get section:C1581($wp; 1)
	
	$header:=WP New header:C1586($section)
	WP Insert picture:C1437($header; $headerLogoPict; wk append:K81:179)
	
	$footer:=WP New footer:C1587($section)
	WP SET TEXT:C1574($footer; "CONFIDENTIAL. For the exclusive use of the customer named herein. Please destroy or return to sender immediately if you are not the customer named."; wk append:K81:179)
	
	$leftTxtBox:=WP New text box:C1797($wp; 1)
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk margin top:K81:13; "100pt")
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk margin left:K81:11; "11cm")
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk border color:K81:34; "white")
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk width:K81:45; "9cm")
	WP SET TEXT:C1574($leftTxtBox; "Quotation#: "+$preview.quoteNumber+"\tRevision: "+$preview.quoteRevision+"\tDated: "+$preview.quoteDate+Choose:C955(String:C10($preview.validUntil)=""; ""; "\tValid until: "+String:C10($preview.validUntil)); wk append:K81:179)
	WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	WP SET TEXT:C1574($leftTxtBox; "From: "+$preview.preparerName; wk append:K81:179)
	WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	If ($preview.preparerEmail#"")
		$preparerEmail:=$preview.preparerEmail || ""
		WP SET TEXT:C1574($leftTxtBox; "\t"+$preparerEmail; wk append:K81:179)
		WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	End if 
	If ($preview.preparerMobile#"")
		$preparerMobile:=$preview.preparerMobile || ""
		WP SET TEXT:C1574($leftTxtBox; "\tTel: "+$preparerMobile; wk append:K81:179)
		WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	End if 
	If ($preview.preparerExt#"")
		$preparerExt:=$preview.preparerExt || ""
		WP SET TEXT:C1574($leftTxtBox; "\t"+$preparerExt; wk append:K81:179)
		WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	End if 
	WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	WP SET TEXT:C1574($leftTxtBox; "Copy: "+$preview.copyName; wk append:K81:179)
	WP Insert break:C1413($leftTxtBox; wk line break:K81:186; wk append:K81:179)
	WP SET TEXT:C1574($leftTxtBox; "\t"+$preview.copyCommMeans; wk append:K81:179)
	
	$paragraph:=WP Get elements:C1550($section; wk type paragraph:K81:191)[0]
	WP SET ATTRIBUTES:C1342($paragraph; wk width:K81:45; "7cm")
	If ($preview.contactName#Null:C1517)
		WP SET TEXT:C1574($paragraph; $preview.contactName; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP SET TEXT:C1574($paragraph; $preview.contactCompany; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP SET TEXT:C1574($paragraph; $preview.contactAddress; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP SET TEXT:C1574($paragraph; "Tel: "+$preview.contactTel+" ext: "+$preview.contactExt+" Fax: "+$preview.contactFax; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP SET TEXT:C1574($paragraph; "Email: "+$preview.contactEmail; wk append:K81:179)
	Else 
		cs:C1710.sfw_dialog.me.alert("You need to add a main contact in order to include contact information in your document.")
	End if 
	
	WP Insert break:C1413($section; wk paragraph break:K81:259; wk append:K81:179)
	$paragraph:=WP Get elements:C1550($section; wk type paragraph:K81:191)[1]
	WP SET ATTRIBUTES:C1342($paragraph; wk width:K81:45; "auto")
	
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP SET TEXT:C1574($paragraph; "Subject:\t"+$preview.quoteSubject; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP SET TEXT:C1574($paragraph; "Reference:\t"+$preview.quoteReference; wk append:K81:179)
	
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	$contactFirstName:=$preview.contactFirstName || ""
	WP SET TEXT:C1574($paragraph; "  Dear "+$contactFirstName; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	WP SET TEXT:C1574($paragraph; "We are pleased to submit to you the following quotation:"; wk append:K81:179)
	WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
	
	$table:=WP Insert table:C1473($paragraph; wk append:K81:179; wk include in range:K81:180)
	// the "Min. lot charge" column only when a line has one (revisions frozen before it have none)
	$withMinCharge:=False:C215
	For each ($line; $preview.quoteLines)
		$withMinCharge:=$withMinCharge || (Num:C11($line.minLotCharge)>0)
	End for each
	If ($withMinCharge)
		$tableHeaders:=WP Table append row:C1474($table; "Item#"; "Description"; "Qty"; "Unit-Price"; "Min. lot charge"; "Amount")
	Else
		$tableHeaders:=WP Table append row:C1474($table; "Item#"; "Description"; "Qty"; "Unit-Price"; "Amount")
	End if

	$numCol:=WP Table get columns:C1476($table; 1)
	$descCol:=WP Table get columns:C1476($table; 2)
	$qtyCol:=WP Table get columns:C1476($table; 3)
	$amountcols:=WP Table get columns:C1476($table; 4; $withMinCharge ? 3 : 2)

	WP SET ATTRIBUTES:C1342($numCol; wk width:K81:45; "1cm")
	WP SET ATTRIBUTES:C1342($descCol; wk width:K81:45; $withMinCharge ? "6.5cm" : "9cm")
	WP SET ATTRIBUTES:C1342($qtyCol; wk width:K81:45; "1.5cm")
	WP SET ATTRIBUTES:C1342($amountcols; wk width:K81:45; "2.5cm")
	$index:=1
	For each ($line; $preview.quoteLines)
		Case of
			: (Not:C34($withMinCharge))
				$row:=WP Table append row:C1474($table; String:C10($index); $line.description; $line.quantity; $line.unitPrice; $line.amount)
			: (Num:C11($line.minLotCharge)>0)
				$row:=WP Table append row:C1474($table; String:C10($index); $line.description; $line.quantity; $line.unitPrice; $line.minLotCharge; $line.amount)
			Else
				// an empty cell rather than 0 on the lines without a minimum
				$row:=WP Table append row:C1474($table; String:C10($index); $line.description; $line.quantity; $line.unitPrice; ""; $line.amount)
		End case
		$index+=1
	End for each
	
	
	WP Insert break:C1413($section; wk paragraph break:K81:259; wk append:K81:179)
	$paragraphs:=WP Get elements:C1550($section; wk type paragraph:K81:191)
	$paragraph:=$paragraphs[$paragraphs.length-1]
	WP SET ATTRIBUTES:C1342($paragraph; wk width:K81:45; "auto")
	// included when it holds something (text, a table or a picture): it used to test a "title"
	// property that a Write Pro document never has, so the preliminary text was never printed
	// a frozen revision has it as 4D Write Pro HTML (QuoteEntity.snapshot)
	$prelim:=$preview.optionalPreliminaryTxt_wr
	If (Value type:C1509($prelim)#Is object:K8:27) && (String:C10($preview.preliminaryText)#"")
		$prelim:=WP New:C1317($preview.preliminaryText)
	End if
	If (_ga_wpHasContent($prelim))
		WP Insert document body:C1411($paragraph; $prelim; wk append:K81:179)
	End if
	
	$paragraphs:=WP Get elements:C1550($section; wk type paragraph:K81:191)
	$paragraph:=$paragraphs[$paragraphs.length-1]
	
	If ($preview.assumptions.length#0)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP SET TEXT:C1574($paragraph; "Assumptions:"; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		
		For each ($assumption; $preview.assumptions)
			WP SET TEXT:C1574($paragraph; " - "+$assumption.value; wk append:K81:179)
			WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		End for each 
	End if 
	
	
	If ($preview.conditions.length#0)
		WP Insert break:C1413($section; wk page break:K81:188; wk append:K81:179)
		WP Insert break:C1413($section; wk paragraph break:K81:259; wk append:K81:179)
		$paragraphs:=WP Get elements:C1550($section; wk type paragraph:K81:191)
		$paragraph:=$paragraphs[$paragraphs.length-1]
		WP SET TEXT:C1574($paragraph; "GOLDEN ALTOS"; wk append:K81:179)
		WP SET ATTRIBUTES:C1342($paragraph; wk text align:K81:49; wk center:K81:99)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		WP SET TEXT:C1574($paragraph; "Terms and conditions of sales"; wk append:K81:179)
		WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
		
		WP SET ATTRIBUTES:C1342($paragraph; wk text color:K81:64; "grey")
		
		WP Insert break:C1413($section; wk paragraph break:K81:259; wk append:K81:179)
		$paragraphs:=WP Get elements:C1550($section; wk type paragraph:K81:191)
		$paragraph:=$paragraphs[$paragraphs.length-1]
		
		$index:=1
		For each ($condition; $preview.conditions)
			WP SET TEXT:C1574($paragraph; String:C10($index)+".  "+$condition.code+": "+$condition.value; wk append:K81:179)
			WP Insert break:C1413($paragraph; wk line break:K81:186; wk append:K81:179)
			$index+=1
		End for each 
		WP SET ATTRIBUTES:C1342($paragraph; wk text align:K81:49; wk left:K81:95)
	End if 
	
Function refreshDocumentsTab()
	// the file count on the Documents tab after a document is added from code (the framework's
	// refreshHTab only counts with "showCountInTab", which this entry does not use: the label is
	// written by redrawAndSetVisible)
	If (Form:C1466.current_item#Null:C1517)
		This:C1470._countDocuments()
	End if
	This:C1470.redrawAndSetVisible()

Function bActionPreview()
	// Actions of the Preview tab. Also the dynamic-rendering mirror of the button (it has onClick only)
	var $choose; $menu : Text
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Save PDF to Documents"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--savePdf")
	// the PDF is made from the saved quote (Quote_savePreviewPdf)
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.sfw.checkIsInModification())
		DISABLE MENU ITEM:C150($menu; -1)
	End if

	$choose:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choose="--savePdf")
			Quote_savePreviewPdf
	End case

Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function onBoundVariableChange()
	// set by Quote_savePreviewPdf run from the item action, outside this panel
	If (Bool:C1537(Form:C1466.refreshDocumentsTab))
		Form:C1466.refreshDocumentsTab:=False:C215
		This:C1470.refreshDocumentsTab()
	End if
	// set by Quote_newRevision run from the item action
	If (Bool:C1537(Form:C1466.refreshRevisions))
		Form:C1466.refreshRevisions:=False:C215
		This:C1470.refreshAfterNewRevision()
	End if
	// set by Quote_lifecycleAction (Mark as sent, Close as won / lost, Reopen, Void / Restore)
	If (Bool:C1537(Form:C1466.refreshLifecycle))
		Form:C1466.refreshLifecycle:=False:C215
		This:C1470.refreshAfterLifecycle()
	End if

	This:C1470.loadQuoteLines()
	
	If (Form:C1466.current_quoteLine#Null:C1517)
		$index:=Form:C1466.current_quoteLine.indexOf()
		If ($index=-1)
			LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; 0; lk remove from selection:K53:3)
		Else 
			LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; $index+1; lk replace selection:K53:1)
		End if 
	Else 
		LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; 0; lk remove from selection:K53:3)
	End if 
	
Function pup_revision()
	// read-only: the revision only moves on with "New revision...", which freezes the quote first
	// (Quote_newRevision), so the label and the Revisions tab always agree
	If (Form:C1466.sfw.checkIsInModification())
		cs:C1710.sfw_dialog.me.info("The revision changes with \"New revision...\" (Actions of the Revisions tab, or the item actions), once the quote is saved: it keeps a copy of the quote as it is, then moves it to the next revision.")
	End if
	This:C1470.drawPup_quoteRevision()
	
Function drawPup_quoteRevision()
	var $quoteRevision : cs:C1710.RevisionEntity
	If (Form:C1466.current_item#Null:C1517)
		$quoteRevision:=Form:C1466.current_item.revision
		If ($quoteRevision#Null:C1517)
			$parts:=New collection:C1472($quoteRevision.code; $quoteRevision.name)
			$revisionName:=$parts.join(" - "; ck ignore null or empty:K85:5)
			$color:=cs:C1710.sfw_htmlColor.me.getName($quoteRevision.color)
		Else 
			$revisionName:=" "
			$color:=""
		End if 
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_QuoteRevision"; $revisionName; $pathIcon; ($quoteRevision=Null:C1517))
	End if 
	
Function pup_status()
	var $eQuoteStatus : cs:C1710.QuoteStatusEntity
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.quoteStatus=Null:C1517)
			ds:C1482.QuoteStatus.cacheLoad()
		End if 
		
		For each ($eQuoteStatus; Storage:C1525.cache.quoteStatus)
			APPEND MENU ITEM:C411($menu; $eQuoteStatus.code+" - "+$eQuoteStatus.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eQuoteStatus.UUID)
			If ($eQuoteStatus.UUID=Form:C1466.current_item.UUID_Status)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				$eQuoteStatus:=ds:C1482.QuoteStatus.get($choose)
				Form:C1466.current_item.UUID_Status:=$eQuoteStatus.UUID
				cs:C1710.panel_quote.me._activate_save_cancel_button()
		End case 
		
	End if 
	This:C1470.drawPup_quoteStatus()
	
Function drawPup_quoteStatus()
	If (Form:C1466.current_item#Null:C1517)
		$quoteStatus:=Form:C1466.current_item.status || New object:C1471()
		$parts:=New collection:C1472($quoteStatus.code; $quoteStatus.name)
		$statusName:=$parts.join(" - "; ck ignore null or empty:K85:5)
		If ($statusName="")
			$statusName:=""
		End if 
		$color:=cs:C1710.sfw_htmlColor.me.getName($quoteStatus.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_quoteStatus"; $statusName; $pathIcon; ($quoteStatus=Null:C1517))
	End if 
	
Function drawPup_quoteCustomer()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.customer.name || " "
		Form:C1466.sfw.drawButtonPup("pup_customer"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.customer=Null:C1517))
	End if 
	
Function selectCustomer()
	var $previousCustomer : Text
	If (Form:C1466.sfw.checkIsInModification())
		$previousCustomer:=Form:C1466.current_item.UUID_Customer

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
				This:C1470._clearInfoAfterChangingCustomer($previousCustomer)
				This:C1470.drawPup_quoteCustomer()
				This:C1470._activate_save_cancel_button()

			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Customer:=16*"00"
				This:C1470._clearInfoAfterChangingCustomer($previousCustomer)
			: ($selector.needCreation())
				// the contacts are cleared in the callback, once the new customer is set
				$selector.createANewEntity("cs.panel_quote.me.callbackAfterCreationCustomer($1)")
		End case

	End if

Function callbackAfterCreationCustomer($key : Text)
	var $previousCustomer : Text
	$previousCustomer:=Form:C1466.current_item.UUID_Customer
	Form:C1466.current_item.UUID_Customer:=$key
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer)=True:C214)
		Form:C1466.current_item.UUID_Customer:=16*"00"
	End if
	// run in the panel (this callback comes from the main window), like the redraw below
	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_quote.me._clearInfoAfterChangingCustomer($1)); *; $previousCustomer)
	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_quote.me.drawPup_quoteCustomer()); *)
	
	
	
	
	
	//Case of 
	//: (FORM Event.code=On Getting Focus) | (FORM Event.code=On Clicked)
	
	//OBJECT GET COORDINATES(*; "entryField_customer"; $l; $t; $r; $b)
	//CONVERT COORDINATES($l; $b; XY Current form; XY Main window)
	//$form:=New object()
	//$form.lb_items:=ds.Customer.all()
	
	
	//$winRef:=Open form window("selectCustomer"; Pop up form window; $l; $b+1)
	//DIALOG("selectCustomer"; $form)
	//CLOSE WINDOW($winRef)
	//If (ok=1)
	//Form.current_item.UUID_Customer:=$form.item.UUID
	//cs.panel_quote.me._activate_save_cancel_button()
	//This._clearInfoAfterChangingCustomer()
	//End if 
	//End case 
	
Function _clearInfoAfterChangingCustomer($previousCustomer : Text)
	// the contacts belong to the customer: cleared when it really changes; the other moreData keys
	// (barcode data, legacy fields of imported quotes) are kept
	var $moreData : Object
	If (Form:C1466.current_item.UUID_Customer=$previousCustomer)
		return
	End if
	$moreData:=(Form:C1466.current_item.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225(Form:C1466.current_item.moreData)
	OB REMOVE:C1226($moreData; "mainContact")
	$moreData.secondaryContacts:=New collection:C1472
	Form:C1466.current_item.moreData:=$moreData
	Form:C1466.contact:=Null:C1517
	This:C1470.loadContacts()
	This:C1470._refreshContactDisplay()

Function pup_serviceType()
	var $eServiceType : cs:C1710.ServiceTypeEntity
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.serviceType=Null:C1517)
			ds:C1482.ServiceType.cacheLoad()
		End if 
		
		For each ($serviceType; Storage:C1525.cache.serviceType)
			APPEND MENU ITEM:C411($menu; $serviceType.code+" - "+$serviceType.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $serviceType.UUID)
			If ($serviceType.UUID=Form:C1466.current_item.UUID_ServiceType)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		
		Case of 
			: ($choose#"")
				Form:C1466.current_item.UUID_ServiceType:=$choose
				This:C1470._activate_save_cancel_button()
		End case 
	End if 
	This:C1470.drawPup_serviceType()
	
Function drawPup_serviceType()
	If (Form:C1466.current_item#Null:C1517)
		$parts:=New collection:C1472(Form:C1466.current_item.serviceType.code; Form:C1466.current_item.serviceType.name)
		$serviceName:=$parts.join(" - "; ck ignore null or empty:K85:5)
		If ($serviceName="")
			$serviceName:=" "
		End if 
		$color:=cs:C1710.sfw_htmlColor.me.getName(Form:C1466.current_item.serviceType.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_serviceType"; $serviceName; $pathIcon; (Form:C1466.current_item.serviceType=Null:C1517))
	End if

	// The flow of the quote (PriceFlow: Commercial, MIL, Space...): which price of the Master Price
	// List its lines take (ga_pricing). No flow: the default one, shown "COM (default)". Changing it
	// does not reprice the lines already there; their floor follows the new flow.
	// Called by its object method and by sfw_dynamicForm_script (every event: only the click acts)
Function pup_priceFlow()
	var $flow : cs:C1710.PriceFlowEntity
	var $menu; $choice : Text

	If (Form event code:C388#On Clicked:K2:4) || Not:C34(Form:C1466.sfw.checkIsInModification())
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Default flow"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "0"*32)
	APPEND MENU ITEM:C411($menu; "-")
	For each ($flow; ds:C1482.PriceFlow.all().orderBy("levelID asc"))
		APPEND MENU ITEM:C411($menu; $flow.code+" - "+$flow.name; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $flow.UUID)
		If ($flow.UUID=Form:C1466.current_item.UUID_PriceFlow)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.UUID_PriceFlow)
		Form:C1466.current_item.UUID_PriceFlow:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_priceFlow()
	End if

Function drawPup_priceFlow()
	var $flow : cs:C1710.PriceFlowEntity
	var $title : Text

	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$flow:=cs:C1710.ga_pricing.me.priceFlowOf(Form:C1466.current_item)
	$title:=($flow=Null:C1517) ? " " : $flow.code+" - "+$flow.name
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_PriceFlow)) && ($flow#Null:C1517)
		$title:=$flow.code+" (default)"
	End if
	Form:C1466.sfw.drawButtonPup("pup_priceFlow"; $title; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

Function selectItem($items)->$UUIDItemSelected : Text
	$obectName:=OBJECT Get name:C1087(Object current:K67:2)
	OBJECT GET COORDINATES:C663(*; $obectName; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	$form:=New object:C1471()
	$form.lb_items:=$items
	
	$winRef:=Open form window:C675("selectItem"; Pop up form window:K39:11; $l; $b)
	DIALOG:C40("selectItem"; $form)
	CLOSE WINDOW:C154($winRef)
	If (ok=1)
		$UUIDItemSelected:=$form.item.UUID
	Else 
		$UUIDItemSelected:=""
	End if 
	
Function contactInfo()->$contactInfo : Object
	var $contact : cs:C1710.ContactEntity
	$contactInfo:={mainContact: Null:C1517; addressMainContact: Null:C1517}
	If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.mainContact#Null:C1517)
		$contact:=ds:C1482.Contact.get(Form:C1466.current_item.moreData.mainContact.UUID)
		If ($contact#Null:C1517)
			$contactInfo.mainContact:=$contact
			$contactInfo.address:=$contact.rebuildAddress()
			$contactInfo.communications:=$contact.rebuidComunications()
		End if 
	End if 
	
Function btnActionContacts()
	//mark: better code 
	$refMenu:=Create menu:C408()
	
	APPEND MENU ITEM:C411($refMenu; "Add main contact"; *)
	
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item.customer#Null:C1517)
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--addMainContact")
	Else 
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Add secondary contact"; *)
	
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item.customer#Null:C1517)
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--addSeconaryContact")
	Else 
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	// the selected secondary contact becomes the main one (ga_sales.makeMainContact)
	APPEND MENU ITEM:C411($refMenu; "Make main contact"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--makeMainContact")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.contact=Null:C1517) || (String:C10(Form:C1466.contact.type)#"Secondary")
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if

	APPEND MENU ITEM:C411($refMenu; "Delete contact"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--deleteContact")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.contact=Null:C1517)
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if

	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	
	
	Case of 
		: ($choice="")
			
		: ($choice="--addMainContact")
			$uuids:=New collection:C1472()
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.mainContact#Null:C1517)
				$uuids.push(Form:C1466.current_item.moreData.mainContact.UUID)
			End if 
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.secondaryContacts#Null:C1517)
				$uuids:=$uuids.concat(Form:C1466.current_item.moreData.secondaryContacts)
			End if 
			
			$form:=New object:C1471()
			$form.lb_contacts:=ds:C1482.Contact.query("UUID_Company == :1 and not(UUID in :2)"; Form:C1466.current_item.customer.UUID; $uuids)
			//If ($form.lb_contacts.length>0)
			$ref:=Open form window:C675("Lead_chooseMainContact"; Sheet form window:K39:12)
			DIALOG:C40("Lead_chooseMainContact"; $form)
			CLOSE WINDOW:C154($ref)
			//End if 
			If (ok=1)
				If (Form:C1466.current_item.moreData=Null:C1517)
					Form:C1466.current_item.moreData:=New object:C1471()
				End if 
				
				If (Form:C1466.current_item.moreData.mainContact=Null:C1517)
					Form:C1466.current_item.moreData.mainContact:=New object:C1471()
				End if 
				
				Form:C1466.current_item.moreData.mainContact:={UUID: $form.current_contact.UUID}
				This:C1470.loadContacts()
				This:C1470._activate_save_cancel_button()
			End if 
			
		: ($choice="--addSeconaryContact")
			$uuids:=New collection:C1472()
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.mainContact#Null:C1517)
				$uuids.push(Form:C1466.current_item.moreData.mainContact.UUID)
			End if 
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.secondaryContacts#Null:C1517)
				$uuids:=$uuids.concat(Form:C1466.current_item.moreData.secondaryContacts)
			End if 
			
			$form:=New object:C1471()
			$form.lb_contacts:=ds:C1482.Contact.query("UUID_Company == :1 and not(UUID in :2)"; Form:C1466.current_item.customer.UUID; $uuids).toCollection()
			For each ($contact; $form.lb_contacts)
				$contact.selected:=False:C215
			End for each 
			//If ($form.lb_contacts.length>0)
			$ref:=Open form window:C675("Lead_chooseSecondaryContacts"; Sheet form window:K39:12)
			DIALOG:C40("Lead_chooseSecondaryContacts"; $form)
			CLOSE WINDOW:C154($ref)
			//End if 
			If (ok=1)
				If (Form:C1466.current_item.moreData=Null:C1517)
					Form:C1466.current_item.moreData:=New object:C1471()
				End if 
				
				If (Form:C1466.current_item.moreData.secondaryContacts=Null:C1517)
					Form:C1466.current_item.moreData.secondaryContacts:=New collection:C1472()
				End if 
				
				For each ($contact; $form.lb_contacts)
					If ($contact.selected)
						Form:C1466.current_item.moreData.secondaryContacts.push($contact.UUID)
					End if 
				End for each 
				
				This:C1470.loadContacts()
				This:C1470._activate_save_cancel_button()
			End if

		: ($choice="--makeMainContact")
			If (cs:C1710.ga_sales.me.makeMainContact(Form:C1466.current_item; Form:C1466.contact.UUID))
				Form:C1466.contact:=Null:C1517
				This:C1470.loadContacts()
				This:C1470._refreshContactDisplay()  // the "Quotation to" block shows the new main contact
				This:C1470._activate_save_cancel_button()
			End if

		: ($choice="--deleteContact")

			If (Form:C1466.contact.type="Main")
				Form:C1466.current_item.moreData.mainContact:=Null:C1517
			Else 
				$index:=Form:C1466.current_item.moreData.secondaryContacts.indexOf(Form:C1466.contact.UUID)
				If ($index#-1)  // tested $indexOf, a variable never set
					Form:C1466.current_item.moreData.secondaryContacts.remove($index)
				End if 
			End if 
			This:C1470.loadContacts()
			This:C1470._activate_save_cancel_button()
	End case 
	
	
	
	
	
	
	//mark:Revisions
	// "New revision..." (Quote_newRevision) freezes the saved quote into a QuoteRevision: lines,
	// assumptions, terms and the rest as values, so later edits of the quote or of the Assumption /
	// TermCondition records don't change it. Then the quote moves on to the next revision. The
	// Revisions tab (page 6) lists them, newest first; a double-click opens one (Quote_revisionView)
Function loadRevisions()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_revisions:=Form:C1466.current_item.revisions.orderBy("num desc")
		If (Form:C1466.tabCounts#Null:C1517)
			Form:C1466.tabCounts.revisions:=Form:C1466.lb_revisions.length
		End if 
	Else
		Form:C1466.lb_revisions:=New collection:C1472
	End if
	This:C1470.displayRevision()

Function displayRevision()
	Form:C1466.revisionNote:=(Form:C1466.current_revision=Null:C1517) ? "" : Form:C1466.current_revision.note
	OBJECT SET VISIBLE:C603(*; "@revisionNote"; Form:C1466.current_revision#Null:C1517)

Function bActionRevisions()
	// Actions of the Revisions tab
	var $menu; $choose : Text
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "New revision..."; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--newRevision")
	If (Form:C1466.current_item=Null:C1517) || (Form:C1466.sfw.checkIsInModification())  // from the saved quote
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "Open the revision..."; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--openRevision")
	If (Form:C1466.current_revision=Null:C1517)
		DISABLE MENU ITEM:C150($menu; -1)
	End if

	$choose:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choose="--newRevision")
			// run by the sfw window, as the item action is: it resets the window's copy of the quote
			// (current_clone) and tells this panel to refresh through its bound variable
			CALL FORM:C1391(Current form window:C827; "Quote_newRevision")
		: ($choose="--openRevision")
			Quote_revisionView(Form:C1466.current_revision)
	End case

Function lb_revisions()
	// also the dynamic-rendering mirror of the list (it gets every event of the list)
	Case of
		: (FORM Event:C1606.code=On Double Clicked)
			If (Form:C1466.current_revision#Null:C1517)
				Quote_revisionView(Form:C1466.current_revision)
			End if
		: (FORM Event:C1606.code=On Selection Change) || (FORM Event:C1606.code=On Clicked:K2:4)
			This:C1470.displayRevision()
	End case

Function refreshAfterNewRevision()
	// Quote_newRevision has saved the quote (new revision label) and its frozen copy
	This:C1470.loadTabCounts()
	If (FORM Get current page:C276(*)=6)
		This:C1470.loadRevisions()
	End if
	This:C1470.drawPup_quoteRevision()
	This:C1470.redrawAndSetVisible()

Function refreshAfterLifecycle()
	// Quote_lifecycleAction has saved the quote (status, dates, reason), its lead and follow-ups
	Form:C1466.notEditable:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.voided)
	This:C1470.loadTabCounts()
	If (FORM Get current page:C276(*)=7)
		This:C1470.loadFollowUps()
	End if
	This:C1470.drawPup_quoteStatus()
	This:C1470.redrawAndSetVisible()


	//mark:Lifecycle (header and Order block of the Main page)
	// Valid until: typed or picked; the setter of QuoteEntity.validUntil writes stmpValidUntil
Function entryField_validUntil()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470._activate_save_cancel_button()
		This:C1470.redrawAndSetVisible()  // "Expired" may come or go
	End if

Function btnDatePickerValidUntil()
	If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.sfw.checkIsInModification())
		This:C1470.btnDatePicker(Form:C1466.current_item; "validUntil")
		This:C1470.redrawAndSetVisible()
	End if

Function entryField_quoteReasonWL()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470._activate_save_cancel_button()
	End if

	// the customer POs entered on this quote (PurchaseOrder.UUID_Quote) and their jobs
	// (ga_sales.jobsOfPurchaseOrders), shown read-only in the Order block: the first one, "(+n)"
	// when there are more. Form.quoteOrder: {po; job; poText; jobText}
Function loadQuoteOrder()
	var $pos : cs:C1710.PurchaseOrderSelection
	var $jobs : cs:C1710.JobSelection
	var $po : cs:C1710.PurchaseOrderEntity

	Form:C1466.quoteOrder:=New object:C1471("po"; Null:C1517; "job"; Null:C1517; "poText"; ""; "jobText"; "")
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$pos:=Form:C1466.current_item.purchaseOrders.orderBy("logDate asc")
	$jobs:=cs:C1710.ga_sales.me.jobsOfPurchaseOrders($pos).orderBy("jobNumber asc")
	$po:=$pos.first()
	If ($po#Null:C1517)
		Form:C1466.quoteOrder.po:=$po
		Form:C1466.quoteOrder.poText:=String:C10($po.poNum)+Choose:C955($po.logDate=!00-00-00!; ""; " - "+String:C10($po.logDate))+Choose:C955($pos.length>1; "  (+"+String:C10($pos.length-1)+")"; "")
	Else
		Form:C1466.quoteOrder.poText:="No PO yet"
	End if
	If ($jobs.length>0)
		Form:C1466.quoteOrder.job:=$jobs.first()
		Form:C1466.quoteOrder.jobText:=String:C10($jobs.first().jobNumber)+Choose:C955($jobs.length>1; "  (+"+String:C10($jobs.length-1)+")"; "")
	End if

Function btnOpenQuotePO()
	If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.quoteOrder#Null:C1517) && (Form:C1466.quoteOrder.po#Null:C1517)
		Form:C1466.sfw.openInANewWindow(Form:C1466.quoteOrder.po; "customerService"; "purchaseOrders")
	End if

Function btnOpenQuoteJob()
	If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.quoteOrder#Null:C1517) && (Form:C1466.quoteOrder.job#Null:C1517)
		Form:C1466.sfw.openInANewWindow(Form:C1466.quoteOrder.job; "customerService"; "jobs")
	End if


	//mark:Follow-ups (page 7)
	// the quote's follow-ups and its lead's (ga_followUps.list), newest first. The actions (schedule,
	// log, complete, cancel) are those of the lead's Interactions tab, in Modify
Function loadFollowUps()
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.lb_followUps:=ds:C1482.Interaction.newSelection()
	Else
		Form:C1466.lb_followUps:=cs:C1710.ga_followUps.me.list(Form:C1466.current_item).orderBy("stmpCreation desc, number desc")
	End if
	Form:C1466.current_followUp:=Null:C1517
	If (Form:C1466.tabCounts#Null:C1517)
		Form:C1466.tabCounts.followUps:=Form:C1466.lb_followUps.length
	End if

Function bActionFollowUps()
	If (FORM Event:C1606.code=On Clicked:K2:4) || (FORM Event:C1606.code=On Alternative Click:K2:36)
		If (cs:C1710.ga_followUps.me.actionMenu(Form:C1466.current_item; Form:C1466.current_followUp; Form:C1466.sfw.checkIsInModification()))
			This:C1470.loadFollowUps()
			This:C1470._activate_save_cancel_button()
			This:C1470.redrawAndSetVisible()  // the tab count
		End if
	End if

Function lb_followUps()
	// the notes of the selected follow-up show on the right (bound to Form.current_followUp)


	//mark:Lead
	// The lead of the quote: picked on the Main page (pup_lead). The link is Lead.UUID_Quote, the
	// one the lead's Quote button uses, so both sides always agree. Picking a lead fills the quote's
	// customer and contacts from it, never the service (the client, June 2025: a customer can buy
	// any service). The lead is saved inside the quote's Modify: Cancel undoes the link.
Function _quoteLeads()->$leads : cs:C1710.LeadSelection
	// a query, not current_item.leads: the relation finds nothing while a new quote is not saved yet
	$leads:=ds:C1482.Lead.query("UUID_Quote = :1"; Form:C1466.current_item.UUID)

Function drawPup_quoteLead()
	var $lead : cs:C1710.LeadEntity
	If (Form:C1466.current_item#Null:C1517)
		$lead:=This:C1470._quoteLeads().first()
		Form:C1466.sfw.drawButtonPup("pup_lead"; ($lead#Null:C1517) ? $lead.leadCode : " "; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)
	End if 
	
Function selectLead()
	// the light list picker of the Owner (selectNto1), under the Lead button: "(no lead)" to
	// unlink, then "code - customer" lines, the quote's customer's leads when it has a customer
	var $form : Object
	var $items : Collection
	var $leads : cs:C1710.LeadSelection
	var $lead : cs:C1710.LeadEntity
	var $label : Text
	var $winRef; $l; $t; $r; $b : Integer
	If (Form:C1466.sfw.checkIsInModification())
		If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer))
			$leads:=ds:C1482.Lead.all()
		Else 
			$leads:=ds:C1482.Lead.query("UUID_Customer = :1"; Form:C1466.current_item.UUID_Customer)
		End if 
		$items:=New collection:C1472(New object:C1471("UUID"; ""; "label"; "(no lead)"))
		For each ($lead; $leads.orderBy("leadCode desc"))
			$label:=$lead.leadCode+" - "+String:C10($lead.customer.name)
			If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_Quote))) && ($lead.UUID_Quote#Form:C1466.current_item.UUID)
				$label+="  (quote "+String:C10($lead.quote.code)+")"
			End if 
			$items.push(New object:C1471("UUID"; $lead.UUID; "label"; $label))
		End for each 
		OBJECT GET COORDINATES:C663(*; "pup_lead"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		$form:=New object:C1471("colName"; "label"; "allData"; $items; "dataclass"; "Lead")
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		If (OK=1) && ($form.item#Null:C1517)
			If (String:C10($form.item.UUID)="")
				This:C1470._unlinkLeads("")
			Else 
				This:C1470._linkLead(ds:C1482.Lead.get($form.item.UUID))
			End if 
		End if 
		This:C1470.drawPup_quoteLead()
	End if 
	
Function _linkLead($lead : cs:C1710.LeadEntity)
	var $info; $moreData : Object
	var $previousCustomer : Text
	var $leadHasContacts; $quoteHasContacts : Boolean
	If ($lead=Null:C1517)
		return 
	End if 
	// a lead goes with one quote: ask before taking it from another one
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_Quote))) && ($lead.UUID_Quote#Form:C1466.current_item.UUID)
		If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Lead "+$lead.leadCode+" is linked to quote "+String:C10($lead.quote.code)+".\rLink it to this quote instead?"; "Link"; "Cancel")))
			return 
		End if 
	End if 
	This:C1470._unlinkLeads($lead.UUID)  // one lead per quote
	$lead.UUID_Quote:=Form:C1466.current_item.UUID
	$info:=$lead.save()
	If (Not:C34($info.success))
		cs:C1710.sfw_dialog.me.alert("The lead "+$lead.leadCode+" could not be linked (it may be open in Modify elsewhere).")
		return 
	End if 
	
	// the customer: the lead's, when the quote has none or when the user agrees to replace it
	$previousCustomer:=Form:C1466.current_item.UUID_Customer
	Case of 
		: (cs:C1710.sfw_string.me.isAnEmptyUUID($lead.UUID_Customer))
		: ($lead.UUID_Customer=$previousCustomer)
		: (cs:C1710.sfw_string.me.isAnEmptyUUID($previousCustomer))
			Form:C1466.current_item.UUID_Customer:=$lead.UUID_Customer
		Else 
			If (cs:C1710.sfw_dialog.me.confirm("Replace the customer "+String:C10(Form:C1466.current_item.customer.name)+" with "+String:C10($lead.customer.name)+" (the lead's customer)?"; "Replace"; "Keep"))
				Form:C1466.current_item.UUID_Customer:=$lead.UUID_Customer
			End if 
	End case 
	This:C1470._clearInfoAfterChangingCustomer($previousCustomer)  // contacts of another customer go
	
	// the contacts: the lead's, when it is for the quote's customer
	If (Form:C1466.current_item.UUID_Customer=$lead.UUID_Customer) && ($lead.moreData#Null:C1517)
		$leadHasContacts:=($lead.moreData.mainContact#Null:C1517) || (($lead.moreData.secondaryContacts#Null:C1517) && ($lead.moreData.secondaryContacts.length>0))
		$quoteHasContacts:=(Form:C1466.current_item.moreData#Null:C1517) && ((Form:C1466.current_item.moreData.mainContact#Null:C1517) || ((Form:C1466.current_item.moreData.secondaryContacts#Null:C1517) && (Form:C1466.current_item.moreData.secondaryContacts.length>0)))
		If ($leadHasContacts) && ((Not:C34($quoteHasContacts)) || (cs:C1710.sfw_dialog.me.confirm("Replace the quote's contacts with the lead's?"; "Replace"; "Keep")))
			$moreData:=(Form:C1466.current_item.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225(Form:C1466.current_item.moreData)
			If ($lead.moreData.mainContact#Null:C1517)
				$moreData.mainContact:=OB Copy:C1225($lead.moreData.mainContact)
			Else 
				OB REMOVE:C1226($moreData; "mainContact")
			End if 
			$moreData.secondaryContacts:=($lead.moreData.secondaryContacts=Null:C1517) ? New collection:C1472 : $lead.moreData.secondaryContacts.copy()
			Form:C1466.current_item.moreData:=$moreData
			Form:C1466.contact:=Null:C1517
		End if 
	End if 
	
	This:C1470.drawPup_quoteCustomer()
	This:C1470.loadContacts()
	This:C1470._refreshContactDisplay()
	This:C1470._activate_save_cancel_button()
	
Function _unlinkLeads($keepUUID : Text)
	// the leads linked to this quote lose the link, except $keepUUID
	var $other : cs:C1710.LeadEntity
	var $info : Object
	For each ($other; This:C1470._quoteLeads())
		If ($other.UUID#$keepUUID)
			$other.UUID_Quote:="0"*32
			$info:=$other.save()
		End if 
	End for each 
	This:C1470._activate_save_cancel_button()
	
Function btnOpenLead()
	var $lead : cs:C1710.LeadEntity
	If (Form:C1466.current_item#Null:C1517)
		$lead:=This:C1470._quoteLeads().first()
		If ($lead#Null:C1517)
			Form:C1466.sfw.openInANewWindow($lead; "salesAndQuotes"; "lead")
		End if 
	End if 
	
Function pup_lead()
	This:C1470.selectLead()
	
Function drawPup_staff()
	If (Form:C1466.current_item#Null:C1517)
		$staffName:=Form:C1466.current_item.staff.fullName || " "
		Form:C1466.sfw.drawButtonPup("pup_staff"; $staffName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.staff=Null:C1517))
	End if 
	
Function selectStaff()
	
	// the light list picker of the buy orders (selectNto1): the sfw selector was slow to open
	var $form : Object
	var $winRef; $l; $t; $r; $b : Integer

	If (Form:C1466.sfw.checkIsInModification())
		OBJECT GET COORDINATES:C663(*; "pup_staff"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		$form:=New object:C1471(\
			"colName"; "fullName"; \
			"allData"; ds:C1482.Staff.query("terminated = :1 and inactive = :2"; False:C215; False:C215).orderBy("lastName asc"); \
			"dataclass"; "Staff")
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		If (OK=1) && ($form.item#Null:C1517)
			Form:C1466.current_item.UUID_Staff:=$form.item.UUID
			This:C1470._activate_save_cancel_button()
		End if
		This:C1470.drawPup_staff()
	End if
	
	
	
// WPArea_opt is spelt like the form object (capital A): sfw_dynamicForm_script looks the
// function up by the object's name, and that lookup is case-sensitive
Function WPArea_opt()
	WP UpdateWidget("WPtoolbar_opt"; "WParea_opt")
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function WParea_preview()
	WP UpdateWidget("WPtoolbar_opt"; "WParea_opt")
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


//Mark:- Dynamic-rendering mirrors of the form object methods
// activateDocument() on the Quotes entry adds the framework Documents page, which switches the
// panel to dynamic-source rendering: every object method of the form is replaced by
// sfw_dynamicForm_script, which calls cs.panel_quote.me[objectName]() - and does nothing, without
// an error, when there is no function of that name. Each function below is named after a form
// object; the object method calls it too, so both modes run the same code. Objects whose
// function already exists above: bActionAssumptions, bActionPreview, bActionQuoteLines, bActionRevisions, bActionTerms,
// btnDatePicker (no parameter), lb_revisions, pup_serviceType, WPArea_opt, WParea_preview.

Function bActionQuoteLines1()
	This:C1470.btnActionContacts()

Function btnForward()
	This:C1470.btnOpenCustomer()

Function btnForward2()
	This:C1470.btnOpenStaff()

Function entryField_quoteLineDescription()
	This:C1470._saveQuoteLine()

Function entryField_quoteLineMinLotCharge()
	// the amount is quantity x unit price, or this charge when it is higher (Amount is read-only).
	// Going below the price list's minimum needs the price override profile (ga_quoteMinCharge);
	// refused: the stored value comes back
	var $stored : cs:C1710.QuoteLineEntity

	If (Form event code:C388#On Data Change:K2:15)  // dynamic rendering sends every event
		return
	End if
	$stored:=ds:C1482.QuoteLine.get(Form:C1466.current_quoteLine.UUID)
	If (Not:C34(cs:C1710.ga_quoteMinCharge.me.confirmTyped(Form:C1466.current_quoteLine; ($stored=Null:C1517) ? 0 : $stored.minLotCharge)))
		Form:C1466.current_quoteLine.reload()
		GOTO OBJECT:C206(*; "entryField_quoteLineMinLotCharge")
		return
	End if
	Form:C1466.current_quoteLine.clearAmountOverride()
	This:C1470._saveQuoteLine()
	cs:C1710.ga_quoteMinCharge.me.alertIfUnder(Form:C1466.current_quoteLine)
	Form:C1466.lb_quoteLines:=Form:C1466.lb_quoteLines  // the row colour follows (QuoteLineEntity.meta)

Function entryField_quoteLineQuantity()
	// a new quantity, unit price or minimum lot charge recalculates the amount
	If (Not:C34(This:C1470._checkQuoteLinePrice("entryField_quoteLineQuantity")))
		return
	End if
	Form:C1466.current_quoteLine.clearAmountOverride()
	cs:C1710.ga_quoteMinCharge.me.applyDefault(Form:C1466.current_quoteLine)  // the price list's minimum
	This:C1470._saveQuoteLine()
	If (Form event code:C388=On Data Change:K2:15)  // not on the other events that dynamic rendering sends
		cs:C1710.ga_quoteMinCharge.me.alertIfUnder(Form:C1466.current_quoteLine)
	End if
	Form:C1466.lb_quoteLines:=Form:C1466.lb_quoteLines  // the row colour follows (QuoteLineEntity.meta)

Function entryField_quoteLineUnitPrice()
	// also the path of the lines built from processes: their minimum is filled here
	If (Not:C34(This:C1470._checkQuoteLinePrice("entryField_quoteLineUnitPrice")))
		return
	End if
	Form:C1466.current_quoteLine.clearAmountOverride()
	cs:C1710.ga_quoteMinCharge.me.applyDefault(Form:C1466.current_quoteLine)  // the price list's minimum
	This:C1470._saveQuoteLine()
	If (Form event code:C388=On Data Change:K2:15)  // not on the other events that dynamic rendering sends
		cs:C1710.ga_quoteMinCharge.me.alertIfUnder(Form:C1466.current_quoteLine)
	End if
	Form:C1466.lb_quoteLines:=Form:C1466.lb_quoteLines  // the row colour follows (QuoteLineEntity.meta)

Function _checkQuoteLinePrice($objectName : Text)->$keep : Boolean
	// unit price below its floor, or a missing zero: ask (see ga_quotePriceFloor). On "Change" the
	// line goes back to its stored values, nothing is saved, and the cursor returns to the field.
	// The typed value is not saved yet, so a fresh get still has the previous price
	var $stored : cs:C1710.QuoteLineEntity

	$stored:=ds:C1482.QuoteLine.get(Form:C1466.current_quoteLine.UUID)
	$keep:=cs:C1710.ga_quotePriceFloor.me.confirmLine(Form:C1466.current_quoteLine; ($stored=Null:C1517) ? 0 : Num:C11($stored.unitPrice))
	If (Not:C34($keep))
		Form:C1466.current_quoteLine.reload()
		GOTO OBJECT:C206(*; $objectName)
	End if

Function _saveQuoteLine()
	var $info : Object
	$info:=Form:C1466.current_quoteLine.save()
	This:C1470._activate_save_cancel_button()

Function lb_quoteLines()
	This:C1470.displayQuoteLine()

Function pup_customer()
	This:C1470.selectCustomer()

Function pup_QuoteRevision()
	This:C1470.pup_revision()

Function pup_QuoteStatus()
	This:C1470.pup_status()

Function pup_staff()
	This:C1470.selectStaff()
