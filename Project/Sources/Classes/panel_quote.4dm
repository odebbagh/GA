singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh
		
		If (Form:C1466.current_item.code="")
			Form:C1466.current_item.code:=This:C1470.calculateCode()
		End if 
		
		If (Form:C1466.current_item.dateCreation=!00-00-00!) || (Form:C1466.current_item.dateCreation=Null:C1517)
			Form:C1466.current_item.dateCreation:=Current date:C33()
		End if 
		
		If (Form:C1466.current_item.staff=Null:C1517)
			If (cs:C1710.sfw_userManager.me.info.UUID_Staff#Null:C1517)
				Form:C1466.current_item.staff:=ds:C1482.Staff.query("UUID = :1"; cs:C1710.sfw_userManager.me.info.UUID_Staff).first()
			Else 
				
			End if 
		End if 
		
		
		This:C1470.drawPup_staff()
		This:C1470.loadAllTabs()
	End if 
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				Form:C1466.contactDetails:=This:C1470.contactInfo()
				
				If (Form:C1466.contactDetails.address#Null:C1517)
					Form:C1466.subFormAddress:=New object:C1471
					Form:C1466.subFormAddress.address:=Form:C1466.contactDetails.address
				End if 
				If (Form:C1466.contactDetails.communications#Null:C1517)
					Form:C1466.subFormCommunication:=New object:C1471
					Form:C1466.subFormCommunication.communications:=Form:C1466.contactDetails.communications
				End if 
				
				If (Form:C1466.contactDetails.address#Null:C1517) || (Form:C1466.contactDetails.communications#Null:C1517)
					Form:C1466.subFormCommunication:=Form:C1466.subFormCommunication
				End if 
				
				This:C1470.loadContacts()
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadQuoteLines()
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadAssumptions()
				This:C1470.loadTermsConditions()
				
			: (FORM Get current page:C276(*)=5)
				This:C1470.buildQuotePreview()
				
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
	
	$form:=New object:C1471
	$form.date:=$object[$attribut]
	
	OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
	CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
	Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
	DIALOG:C40("_ga_calendar"; $form)
	
	If (OK=1)
		$object[$attribut]:=$form.calendar.display.date
		This:C1470._activate_save_cancel_button()
	End if 
	
	
Function calculateCode()->$leadCode : Text
	var $eQuoteCounter : cs:C1710.sfw_CounterEntity
	$leadCode:="Q"
	
	$eQuoteCounter:=ds:C1482.sfw_Counter.query("ident = :1"; "quoteCode").first()
	If ($eQuoteCounter=Null:C1517)
		$eQuoteCounter:=ds:C1482.sfw_Counter.new()
		$eQuoteCounter.ident:="quoteCode"
		$eQuoteCounter.currentValue:=1
		$info:=$eQuoteCounter.save()
	End if 
	$test:=$eQuoteCounter.currentValue+1
	
	$leadCode+=String:C10($test; "00000")
	
Function btnOpenStaff()
	$entity:=Form:C1466.current_item.staff
	Form:C1466.sfw.openInANewWindow($entity; "qualityAssurance"; "staff")
	
Function btnOpenCustomer()
	$entity:=Form:C1466.current_item.customer
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "customer")
	
	
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
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$verticalMargin:=3
	
	OBJECT SET VISIBLE:C603(*; "bActionQuoteLines"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "bActionAssumptions"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "bActionTerms"; Form:C1466.sfw.checkIsInModification())
	
	This:C1470.drawPup_quoteStatus()
	This:C1470.drawPup_quoteCustomer()
	This:C1470.drawPup_serviceType()
	This:C1470.drawPup_quoteRevision()
	This:C1470.drawPup_staff()
	
	Form:C1466.contactDetails:=This:C1470.contactInfo()
	
	If (Form:C1466.contactDetails.address#Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471
		Form:C1466.subFormAddress.address:=Form:C1466.contactDetails.address
	End if 
	If (Form:C1466.contactDetails.communications#Null:C1517)
		Form:C1466.subFormCommunication:=New object:C1471
		Form:C1466.subFormCommunication.communications:=Form:C1466.contactDetails.communications
	End if 
	
	If (Form:C1466.contactDetails.address#Null:C1517) || (Form:C1466.contactDetails.communications#Null:C1517)
		Form:C1466.subFormCommunication:=Form:C1466.subFormCommunication
	End if 
	
	
	Case of 
		: (FORM Get current page:C276(*)=1)
			OBJECT GET COORDINATES:C663(*; "communication_subform"; $g; $t; $r; $b)
			OBJECT GET COORDINATES:C663(*; "lb_contacts"; $gc; $tc; $rc; $bc)
			
			OBJECT SET COORDINATES:C1248(*; "lb_contacts"; $gc; $tc; $rc; $t)
			//OBJECT SET COORDINATES(*; "communication_subform"; $g; $t; $rc; $b)
			
		: (FORM Get current page:C276(*)=2)
			OBJECT GET COORDINATES:C663(*; "bkgd_lb_consumptions_detail"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "bkgd_lb_consumptions_detail"; $g; $t; $widthSubform; $b)
			
			
			OBJECT GET COORDINATES:C663(*; "bkgd_lb_consumptions1"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "bkgd_lb_consumptions1"; $g; $t; $widthSubform; $heightSubform)
			
			
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
	
	
	
	//Use (Form.sfw.entry.panel.pages)
	//Form.sfw.entry.panel.pages[0].label:="Lines ("+String(Form.lb_quoteLines.length)+")"
	//Form.sfw.entry.panel.pages[1].label:="Assumptions and Terms ("+String(Form.lb_assumptions.length)+")"
	//End use 
	//Form.sfw.drawHTab()
	
	
Function loadAllTabs()
	//This.loadQuoteLines()
	//This.loadAssumptions()
	
Function loadQuoteLines()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_quoteLines:=Form:C1466.current_item.lines
		This:C1470.displayQuoteLine()
	End if 
	
Function bActionQuoteLines()
	//var $selection : cs.QuoteLineSelection
	$mainMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($mainMenu; "Add quote line..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--addQuoteLine")
	SET MENU ITEM SHORTCUT:C423($mainMenu; -1; "L"; Command key mask:K16:1)
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
			$info:=$eQuoteLine.save()
			Form:C1466.current_quoteLine:=$eQuoteLine
			This:C1470.displayQuoteLine()
			This:C1470._activate_save_cancel_button()
			
			Form:C1466.lb_quoteLines:=ds:C1482.QuoteLine.query("UUID_Quote == :1"; Form:C1466.current_item.UUID)
			LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; Form:C1466.lb_quoteLines.length; lk replace selection:K53:1)
			GOTO OBJECT:C206(*; "entryField_quoteLineQuantity")
			
			
		: ($choose="--deleteQuoteLine")
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this quote line? "; "Delete"; "CANCEL")
			If ($ok)
				
				
				
				$info:=Form:C1466.current_quoteLine.drop()
				This:C1470._activate_save_cancel_button()
				LISTBOX SELECT ROW:C912(*; "lb_quoteLines"; 0; lk remove from selection:K53:3)
				Form:C1466.current_quoteLine:=Null:C1517
				This:C1470.displayQuoteLine()
			End if 
			
	End case 
	
Function displayQuoteLine()
	OBJECT SET VISIBLE:C603(*; "label_quoteLine@"; Form:C1466.current_quoteLine#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "entryField_quoteLine@"; Form:C1466.current_quoteLine#Null:C1517)
	
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
	$plurial:=Form:C1466.selected_assumptions.length>1 ? True:C214 : False:C215
	
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
	var $contact : cs:C1710.ContactEntity
	$preview:=New object:C1471()
	$contact:=Form:C1466.current_item._mainContact_prv()
	If ($contact#Null:C1517)
		$preview.contactFirstName:=String:C10($contact.firstName)
		$preview.contactName:=String:C10($contact.fullName)
		
		$customer:=ds:C1482.Customer.query("UUID = :1"; $contact.UUID_Company).first()
		
		$preview.contactCompany:=String:C10($customer.name)
		
		$preview.contactAddress:=""
		If ($contact.contactDetails#Null:C1517) && ($contact.contactDetails.addresses#Null:C1517) && ($contact.contactDetails.addresses.length#0)
			$address:=$contact.contactDetails.addresses[0]
			If (String:C10($address.detail.street_1)#"")
				$preview.contactAddress+=$address.detail.street_1+", "
			End if 
			
			If (String:C10($address.detail.street_2)#"")
				$preview.contactAddress+=$address.detail.street_2+", "
			End if 
			
			If (String:C10($address.detail.city)#"")
				$preview.contactAddress+=$address.detail.city+", "
			End if 
			
			If (String:C10($address.detail.state)#"") & (String:C10($address.detail.postcode)#"")
				$preview.contactAddress+=$address.detail.state+" "+$address.detail.postcode+", "
			End if 
			
			If (String:C10($address.detail.country)#"")
				$preview.contactAddress+=$address.detail.country
			End if 
		Else 
			$preview.contactAddress:=" - "
		End if 
		
		If ($contact.contactDetails#Null:C1517) && ($contact.contactDetails.communications#Null:C1517) && ($contact.contactDetails.communications.length#0)
			$comms:=$contact.contactDetails.communications
			
			$items:=$comms.query("type == :1"; "mobile")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactTel:=$items[0].contact
			Else 
				$preview.contactTel:=""
			End if 
			
			$items:=$comms.query("type == :1"; "ext")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactExt:=$items[0].contact
			Else 
				$preview.contactExt:=""
			End if 
			
			$items:=$comms.query("type == :1"; "fax")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactFax:=$items[0].contact
			Else 
				$preview.contactFax:=""
			End if 
			
			$items:=$comms.query("type == :1"; "mail")
			If ($items.length#0) && ($items[0].contact#"")
				$preview.contactEmail:=$items[0].contact
			Else 
				$preview.contactEmail:=""
			End if 
			
		Else 
			$preview.contactTel:=""
			$preview.contactExt:=""
			$preview.contactFax:=""
			$preview.contactEmail:=""
		End if 
	End if 
	$preview.preparerName:=Form:C1466.current_item.staff.fullName
	If (Form:C1466.current_item.staff.contactDetails#Null:C1517) && (Form:C1466.current_item.staff.contactDetails.communications#Null:C1517) && (Form:C1466.current_item.staff.contactDetails.communications.length#0)
		$comm:=Form:C1466.current_item.staff.contactDetails.communications[0]
		//TRACE
		$preview.preparerEmail:=String:C10($comm.email)
		$preview.preparerMobile:=String:C10($comm.mobile)
		$preview.preparerExt:=String:C10($comm.ext)
	Else 
		$preview.preparerEmail:=$comm.email
		$preview.preparerMobile:=$comm.mobile
		$preview.preparerExt:=$comm.ext
	End if 
	
	$preview.copyName:=""  // to get from the old database
	$preview.copyCommMeans:=""  // to get from the old database
	
	$preview.quoteNumber:=Form:C1466.current_item.code
	$preview.quoteRevision:=String:C10(Form:C1466.current_item.revision.name)
	$preview.quoteDate:=String:C10(cs:C1710.sfw_stmp.me.getDate(Form:C1466.current_item.stmpCreation))
	$preview.quoteSubject:=Form:C1466.current_item.subject
	$preview.quoteReference:=Form:C1466.current_item.reference
	
	$preview.quoteLines:=Form:C1466.current_item.lines
	$preview.optionalPreliminaryTxt_wr:=Form:C1466.current_item.optionalPreliminaryTxt_wr
	
	$preview.assumptions:=ds:C1482.Assumption.query("UUID in :1"; Form:C1466.current_item.assumptions.UUIDs)
	
	$preview.conditions:=ds:C1482.TermCondition.query("UUID in :1"; Form:C1466.current_item.termsConditions.UUIDs)
	
	
	
	
	
	
Function buildQuotePreview()
	$preview:=This:C1470.preview()
	
	
	Form:C1466.preview:=WP New:C1317()
	$headerLogoFile:=Folder:C1567(fk resources folder:K87:11).file("picts_GA/HeaderPortrait.jpeg")
	If ($headerLogoFile.exists)
		$headerLogoBlob:=$headerLogoFile.getContent()
		BLOB TO PICTURE:C682($headerLogoBlob; $headerLogoPict)
	End if 
	
	$section:=WP Get section:C1581(Form:C1466.preview; 1)
	
	$header:=WP New header:C1586($section)
	WP Insert picture:C1437($header; $headerLogoPict; wk append:K81:179)
	
	$footer:=WP New footer:C1587($section)
	WP SET TEXT:C1574($footer; "CONFIDENTIAL. For the exclusive use og the customer named herein. Please destroy or return to sender immediately if you are not the customer named."; wk append:K81:179)
	
	$leftTxtBox:=WP New text box:C1797(Form:C1466.preview; 1)
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk margin top:K81:13; "100pt")
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk margin left:K81:11; "11cm")
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk border color:K81:34; "white")
	WP SET ATTRIBUTES:C1342($leftTxtBox; wk width:K81:45; "9cm")
	WP SET TEXT:C1574($leftTxtBox; "Quotation#: "+$preview.quoteNumber+"\tRevision: "+$preview.quoteRevision+"\tDated: "+$preview.quoteDate; wk append:K81:179)
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
	$tableHeaders:=WP Table append row:C1474($table; "Item#"; "Description"; "Qty"; "Unit-Price"; "Amount")
	
	$numCol:=WP Table get columns:C1476($table; 1)
	$descCol:=WP Table get columns:C1476($table; 2)
	$qtyCol:=WP Table get columns:C1476($table; 3)
	$amountcols:=WP Table get columns:C1476($table; 4; 2)
	
	WP SET ATTRIBUTES:C1342($numCol; wk width:K81:45; "1cm")
	WP SET ATTRIBUTES:C1342($descCol; wk width:K81:45; "9cm")
	WP SET ATTRIBUTES:C1342($qtyCol; wk width:K81:45; "1.5cm")
	WP SET ATTRIBUTES:C1342($amountcols; wk width:K81:45; "2.5cm")
	$index:=1
	For each ($line; $preview.quoteLines)
		$row:=WP Table append row:C1474($table; String:C10($index); $line.description; $line.quantity; $line.unitPrice; $line.quantity*$line.unitPrice)
		$index+=1
	End for each 
	
	
	WP Insert break:C1413($section; wk paragraph break:K81:259; wk append:K81:179)
	$paragraphs:=WP Get elements:C1550($section; wk type paragraph:K81:191)
	$paragraph:=$paragraphs[$paragraphs.length-1]
	WP SET ATTRIBUTES:C1342($paragraph; wk width:K81:45; "auto")
	If (Form:C1466.current_item.optionalPreliminaryTxt_wr.title#Null:C1517)
		WP Insert document body:C1411($paragraph; Form:C1466.current_item.optionalPreliminaryTxt_wr; wk append:K81:179)
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
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function onBoundVariableChange()
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
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.quoteRevision=Null:C1517)
			ds:C1482.Revision.cacheLoad()
		End if 
		
		For each ($eRvision; Storage:C1525.cache.quoteRevision)
			APPEND MENU ITEM:C411($menu; $eRvision.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eRvision.UUID)
			If ($eRvision.code=Form:C1466.current_item.revision.code)
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
				Form:C1466.current_item.UUID_Revision:=$choose
				cs:C1710.panel_quote.me._activate_save_cancel_button()
		End case 
		
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
			If ($eQuoteStatus.statusID=Form:C1466.current_item.currentStatusID)
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
				This:C1470._clearInfoAfterChangingCustomer()
				This:C1470.drawPup_quoteCustomer()
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Customer:=16*"00"
				This:C1470._clearInfoAfterChangingCustomer()
			: ($selector.needCreation())
				$selector.createANewEntity("cs.panel_quote.me.callbackAfterCreationCustomer($1)")
				This:C1470._clearInfoAfterChangingCustomer()
		End case 
		
	End if 
	
Function callbackAfterCreationCustomer($key : Text)
	Form:C1466.current_item.UUID_Customer:=$key
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer)=True:C214)
		Form:C1466.current_item.UUID_Customer:=16*"00"
	End if 
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
	
Function _clearInfoAfterChangingCustomer()
	Form:C1466.current_item.moreData:=New object:C1471()
	
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
				cs:C1710.panel_lead.me._activate_save_cancel_button()
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
				cs:C1710.panel_lead.me._activate_save_cancel_button()
			End if 
			
			
		: ($choice="--deleteContact")
			
			If (Form:C1466.contact.type="Main")
				Form:C1466.current_item.moreData.mainContact:=Null:C1517
			Else 
				$index:=Form:C1466.current_item.moreData.secondaryContacts.indexOf(Form:C1466.contact.UUID)
				If ($indexOf#-1)
					Form:C1466.current_item.moreData.secondaryContacts.remove($index)
				End if 
			End if 
			This:C1470.loadContacts()
			cs:C1710.panel_lead.me._activate_save_cancel_button()
	End case 
	
	
	
	
	
	
Function drawPup_quoteLead()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.leads[0].leadCode || " "
		Form:C1466.sfw.drawButtonPup("pup_lead"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.Form.current_item.leads[0]=Null:C1517))
	End if 
	
Function selectLead()
	var $selection : cs:C1710.LeadSelection
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorLeads"; "lead")
		$selector.setTitle("Choose a Lead")
		//$selector.setCurrentItem(Form.current_item.leads[0])
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						
						$selection:=ds:C1482.Lead.newSelection()
						$selection:=$selection.add(Form:C1466.current_item.leads)
						$selection:=$selection.add($itemSeleted)
						
						Form:C1466.current_item.leads:=$selection
						
				End case 
				This:C1470.drawPup_quoteCustomer()
				
			: ($selector.asCutTheLink())
				
				$selection:=ds:C1482.Lead.newSelection()
				$selection:=$selection.add(Form:C1466.current_item.leads)
				$selection:=$selection.drop($itemSeleted)
				
				Form:C1466.current_item.leads:=$selection
		End case 
		
	End if 
	
	
Function drawPup_staff()
	If (Form:C1466.current_item#Null:C1517)
		$staffName:=Form:C1466.current_item.staff.fullName || " "
		Form:C1466.sfw.drawButtonPup("pup_staff"; $staffName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.staff=Null:C1517))
	End if 
	
Function selectStaff()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorOwners"; "staff")
		$selector.setTitle("Choose a Owner")
		$selector.setCurrentItem(Form:C1466.current_item.staff)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						Form:C1466.current_item.UUID_Staff:=$itemSeleted.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Staff)=True:C214)
							Form:C1466.current_item.UUID_Staff:=16*"00"
						End if 
				End case 
				This:C1470.drawPup_staff()
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Staff:=16*"00"
				
				//: ($selector.needCreation())
				//$selector.createANewEntity("cs.panel_lead.me.callbackAfterCreationOwner($1)")
				
		End case 
	End if 
	
	
	
Function WParea_opt()
	WP UpdateWidget("WPtoolbar_opt"; "WParea_opt")
	
	
Function WParea_preview()
	WP UpdateWidget("WPtoolbar_opt"; "WParea_opt")