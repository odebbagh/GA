singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function setBuyerStaff($eStaff : cs:C1710.StaffEntity)
	If ($eStaff#Null:C1517)
		Form:C1466.current_item.UUID_Buyer:=$eStaff.UUID
	End if 
	This:C1470._activate_save_cancel_button()
	
Function selectBuyerStaff()
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
	
	This:C1470.setBuyerStaff($result.staff)
	
Function setRequestorStaff($eStaff : cs:C1710.StaffEntity)
	If ($eStaff#Null:C1517)
		Form:C1466.current_item.UUID_Requestor:=$eStaff.UUID
	End if 
	This:C1470._activate_save_cancel_button()
	
Function selectRequestorStaff()
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
	
	This:C1470.setRequestorStaff($result.staff)
	
Function signApprover($slot : Integer)
	// Approver signature: scan or enter the user code; the code resolves a
	// [Staff] record, whose linked sfw_User must belong to the customer
	// service profile. Links UUID_Approver1/2 to the STAFF record and
	// displays the staff code in signature1/2.
	var $result : Object
	var $profileCheck : Object

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

	$profileCheck:=Staff_isInUserProfile($result.staff.code; "CS")
	If (Not:C34($profileCheck.isInProfile))
		cs:C1710.sfw_dialog.me.alert("This user is not part of the Customer Service profile and cannot sign.")
		return
	End if

	If ($slot=1)
		Form:C1466.current_item.UUID_Approver1:=$result.staff.UUID
		Form:C1466.current_item.signature1:=$result.staff.code
	Else
		Form:C1466.current_item.UUID_Approver2:=$result.staff.UUID
		Form:C1466.current_item.signature2:=$result.staff.code
	End if

	This:C1470._activate_save_cancel_button()

Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh
		Form:C1466.addressBilling:=1
		Form:C1466.addressShipping:=0
		Form:C1466.addressRemit:=0
		This:C1470.LoadAllTabs()
		This:C1470.loadContactCommunications()
		This:C1470.contactDetails()
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadContactCommunications()

			: (FORM Get current page:C276(*)=2)
				This:C1470.loadLineItems()

			: (FORM Get current page:C276(*)=3)
				This:C1470.loadTerms()
		End case
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	$isInModification:=Form:C1466.sfw.checkIsInModification()

	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4

	Case of
		: (FORM Get current page:C276(*)=1)
			// keep the Attention To communication list stretched to the bottom of the page
			// (object deliberately NOT named "communication_subform": the sfw framework
			// auto-stretches any object with that name to the full panel width)
			OBJECT GET COORDINATES:C663(*; "subFormCommunication"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "subFormCommunication"; $g; $h; $d; $heightSubform-$offset)

		: (FORM Get current page:C276(*)=2)
			// line items page: action rail + list stretch with the window
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_boLines"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_boLines"; $g; $h; $d; $heightSubform-$offset)

			OBJECT GET COORDINATES:C663(*; "bActionBuyItems"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bActionBuyItems"; $g; $heightSubform-$offset-27; $d; $heightSubform-$offset-6)

			OBJECT GET COORDINATES:C663(*; "lb_boLines"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_boLines"; $g; $h; $widthSubform-$offset; $heightSubform-$offset)
	End case

	OBJECT SET ENTERABLE:C238(*; "Field_boNumber"; False:C215)
	OBJECT SET RGB COLORS:C628(*; "Field_boNumber"; 0x00333333; Background color none:K23:10)
	OBJECT SET BORDER STYLE:C1262(*; "Field_boNumber"; Border None:K42:27)
	OBJECT SET VISIBLE:C603(*; "bScan_buyer"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "bScan_buyer"; $isInModification)
	OBJECT SET VISIBLE:C603(*; "bScan_requestor"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "bScan_requestor"; $isInModification)
	OBJECT SET VISIBLE:C603(*; "bScan_signature1"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "bScan_signature1"; $isInModification)
	OBJECT SET VISIBLE:C603(*; "bScan_signature2"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "bScan_signature2"; $isInModification)

	// "QA Not Approved" warning: shown only when the BO's vendor is not approved
	$vendorNotApproved:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.customer#Null:C1517) && Not:C34(Bool:C1537(Form:C1466.current_item.customer.approved))
	OBJECT SET VISIBLE:C603(*; "Texte"; $vendorNotApproved)

	This:C1470.contactDetails()

	This:C1470.drawPup_boStatus()

	// record count in the Line Items tab label, as in the other panels
	$linesCount:=(Form:C1466.lb_boLines#Null:C1517) ? Form:C1466.lb_boLines.length : 0

	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Line Items ("+String:C10($linesCount)+")"
	End use

	Form:C1466.sfw.drawHTab()

Function contactDetails()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
		Form:C1466.subFormAddress.address:=Form:C1466.current_item.rebuildAddress()
		Form:C1466.subFormAddress:=Form:C1466.subFormAddress
	End if
	
Function changeBOLimit($previousLimit : Real; $newLimit : Real)
	
	If ($newLimit>$previousLimit)
		//Signature Required for approval
		ALERT:C41("Signature Required to Change Limit")
		
		var $profileCheck : Object
		var $result : Object
		
		$result:=cs:C1710.Util_ScannerManager.me.resolveStaffFromScanOrRequest()
		
		If ($result.cancelled)
			Form:C1466.current_item.buyOrderLimit:=Form:C1466.PreviousLimit
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
			Form:C1466.current_item.buyOrderLimit:=Form:C1466.PreviousLimit
			return 
		End if 
		
		$profileCheck:=Staff_isInUserProfile($result.staff.code; "CS")
		If (Not:C34($profileCheck.isInProfile))
			cs:C1710.sfw_dialog.me.alert("This user is not part of the Customer Service profile and cannot be set as Approver.")
			Form:C1466.current_item.buyOrderLimit:=Form:C1466.PreviousLimit
			return 
		End if 
		
	End if 
	
Function selectCustomer()
	
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_customerName"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"allData"; ds:C1482.Customer.query("vendor = :1"; True:C214).orderBy("name asc"); \
					"dataclass"; "Customer"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Customer:=$form.item.UUID
					This:C1470.copyVendorAddresses($form.item.UUID)
				End if
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case

Function selectRequestor()
	// Same list-picker pattern as selectCustomer, but for the requestor Staff.
	If (Form:C1466.sfw.checkIsInModification())
		Case of
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_requestor"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

				$form:=New object:C1471(\
					"colName"; "fullName"; \
					"allData"; ds:C1482.Staff.all().orderBy("lastName asc"); \
					"dataclass"; "Staff"\
					)

				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)

				If (ok=1)
					Form:C1466.current_item.UUID_Requestor:=$form.item.UUID
					This:C1470._activate_save_cancel_button()
				End if
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case
	End if
	End if

Function drawPup_boStatus()
	// Status dropdown backed by the [BOStatus] table (via the status relation)
	If (Form:C1466.current_item#Null:C1517)
		$statusName:=(Form:C1466.current_item.status#Null:C1517) ? String:C10(Form:C1466.current_item.status.name) : ""
		Form:C1466.sfw.drawButtonPup("pup_boStatus"; $statusName; ""; False:C215)
	End if

Function bothApproversSigned()->$signed : Boolean
	// True only when both approvers have signed (UUID_Approver1 and 2 set)
	$signed:=False:C215
	If (Form:C1466.current_item#Null:C1517)
		$signed:=(Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Approver1)))) \
			 && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Approver2))))
	End if

Function pup_boStatus()

	If (Form:C1466.sfw.checkIsInModification())

		$statuses:=ds:C1482.BOStatus.all().orderBy("levelID")
		$currentUUID:=(Form:C1466.current_item.status#Null:C1517) ? String:C10(Form:C1466.current_item.status.UUID) : ""

		$menu:=Create menu:C408
		For each ($st; $statuses)
			APPEND MENU ITEM:C411($menu; $st.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $st.UUID)
			If (String:C10($st.UUID)=$currentUUID)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			End if
		End for each

		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)

		If ($choose#"")
			$target:=ds:C1482.BOStatus.query("UUID = :1"; $choose).first()
			If ($target#Null:C1517)
				Case of
					// Approved requires both approvers to have signed
					: ($target.name="Approved") && (Not:C34(This:C1470.bothApproversSigned()))
						cs:C1710.sfw_dialog.me.alert("Both approvers must approve before the buying order can be set to Approved.")
					Else
						Form:C1466.current_item.UUID_Status:=$target.UUID
						This:C1470._activate_save_cancel_button()
				End case
			End if
		End if
	End if

	This:C1470.drawPup_boStatus()

Function createAttentionContact()
	// + button next to Attention To: opens the contact entry's creation page
	If (Form:C1466.sfw.checkIsInModification())
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorAttentionContact"; "contact")
		$selector.createANewEntity("cs.panel_buyingOrder.me.callbackAfterCreationContact($1)")
	End if

Function callbackAfterCreationContact($key : Text)
	var $contact : cs:C1710.ContactEntity

	If (cs:C1710.sfw_string.me.isAnEmptyUUID($key)=False:C215)

		// link the new contact to the BO's vendor when it was left without a company
		$contact:=ds:C1482.Contact.query("UUID = :1"; $key).first()
		If ($contact#Null:C1517) && (Form:C1466.current_item#Null:C1517)
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($contact.UUID_Company))) && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Customer))))
				$contact.UUID_Company:=Form:C1466.current_item.UUID_Customer
				$contact.save()
			End if
		End if

		// set it as the Attention To of the buy order
		Form:C1466.current_item.UUID_AttentionTo:=$key
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	End if

	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_buyingOrder.me.loadContactCommunications()); *)

Function copyVendorAddresses($vendorUUID : Text)
	// Copy the vendor's billing/shipping/remit addresses into the buy order
	// record. It is a deep copy: the buy order keeps its own version, which
	// can be modified later without touching the vendor record.
	var $vendor : cs:C1710.CustomerEntity
	var $contactDetails : Object

	$vendor:=ds:C1482.Customer.query("UUID = :1"; $vendorUUID).first()

	$contactDetails:=Form:C1466.current_item.contactDetails || New object:C1471()
	$contactDetails.addresses:=New collection:C1472()

	If ($vendor#Null:C1517) && ($vendor.contactDetails#Null:C1517) && ($vendor.contactDetails.addresses#Null:C1517)
		$contactDetails.addresses:=$vendor.contactDetails.addresses.copy()
	End if

	Form:C1466.current_item.contactDetails:=$contactDetails

	Form:C1466.addressBilling:=1
	Form:C1466.addressShipping:=0
	Form:C1466.addressRemit:=0
	This:C1470.contactDetails()
	This:C1470._activate_save_cancel_button()

Function selectContact()
	
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_attentionTo"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "firstName"; \
					"allData"; ds:C1482.Contact.query("UUID_Company = :1"; Form:C1466.current_item.UUID_Customer); \
					"dataclass"; "Contact"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_AttentionTo:=$form.item.UUID
					This:C1470.loadContactCommunications()
				End if
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case
	End if

Function loadContactCommunications()
	// Display the Attention To contact's communication means (read-only:
	// they are managed from the Contacts entry, not from the buying order)
	var $contact : cs:C1710.ContactEntity

	Form:C1466.subFormCommunication:=New object:C1471()
	Form:C1466.subFormCommunication.readOnly:=True:C214
	Form:C1466.subFormCommunication.communications:=New collection:C1472()

	If (Form:C1466.current_item#Null:C1517)
		$contact:=Form:C1466.current_item.contact
		If ($contact#Null:C1517) && ($contact.contactDetails#Null:C1517) && ($contact.contactDetails.communications#Null:C1517)
			// a copy, so nothing done here can ever touch the contact record
			Form:C1466.subFormCommunication.communications:=$contact.contactDetails.communications.copy()
		End if
	End if

Function LoadAllTabs()
	This:C1470.loadLineItems()
	
Function loadLineItems()
	Form:C1466.lb_boLines:=ds:C1482.BuyingOrderLine.query("UUID_BuyingOrder = :1"; Form:C1466.current_item.UUID)
	
	
Function bActionTerms()
	
	
Function loadTerms()
	Form:C1466.lb_terms:=New collection:C1472(\
		New object:C1471("type"; "terms"; "name"; "Terms"); \
		New object:C1471("type"; "termsCriticalMaterials"; "name"; "Critical Materials"); \
		New object:C1471("type"; "termsCriticalService"; "name"; "Critical Service")\
		)
	
	
Function drawPup_supplier()
	If (Form:C1466.current_item#Null:C1517)
		//$supplier:=ds.Supplier.query("UUID= :1"; Form.current_item.UUID_Supplier).first() || New object()
		$supplier:=Form:C1466.current_item.supplier
		If ($supplier#Null:C1517)
			$supplierName:=$supplier.name
			If ($supplierName=Null:C1517)
				$supplierName:=""
			End if 
		Else 
			$supplierName:=""
		End if 
		
		$color:=""
		$pathIcon:=""
		Form:C1466.sfw.drawButtonPup("pup_supplier"; $supplierName; $pathIcon; ($supplier=Null:C1517))
		
	End if 
	
Function pup_supplier()
	//Create pop up menu
	
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_supplier"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "name"; \
			"allData"; ds:C1482.Supplier.all(); \
			"dataclass"; "Supplier"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.current_item.UUID_Supplier:=$form.item.UUID
			cs:C1710.panel_buyingOrder.me._activate_save_cancel_button()
		End if 
	End if 
	
	This:C1470.drawPup_supplier()
	
	
	
Function modifyBuyLine()
	// Opens the selected line in the edit dialog. Used by the Actions menu
	// and by double-clicking a row in the line items list.

	If (sfw_checkIsInModification=False:C215)
		return
	End if

	If (Form:C1466.selectedBoLine=Null:C1517) | (Undefined:C82(Form:C1466.selectedBoLine))
		return
	End if

	START TRANSACTION:C239
	$buyItem:=ds:C1482.BuyingOrderLine.query("UUID = :1"; Form:C1466.lb_boLines[Form:C1466.selectedBoLinePos-1].UUID).first()

	$form:=New object:C1471("details"; $buyItem)

	$winRef:=Open form window:C675("_ga_buyingOrderLine"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
	SET WINDOW TITLE:C213("Modify Buying Item"; $winRef)
	DIALOG:C40("_ga_buyingOrderLine"; $form)

	If (OK=1)

		$buyItem:=$form.details

		$res:=$buyItem.save()

		If ($res.success)

			VALIDATE TRANSACTION:C240

			This:C1470.loadLineItems()
			This:C1470._activate_save_cancel_button()
		Else
			CANCEL TRANSACTION:C241
		End if
	Else

		CANCEL TRANSACTION:C241
	End if

Function bActionBuyItems()
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "add an Item"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--add")
	If (sfw_checkIsInModification=False:C215)
		DISABLE MENU ITEM:C150($refMenu; 1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "modify an Itenm"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--modify")
	If (sfw_checkIsInModification=False:C215) | (Form:C1466.selectedBoLine=Null:C1517) | Undefined:C82(Form:C1466.selectedBoLine)
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "delete an Item"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 3; "--delete")
	If (sfw_checkIsInModification=False:C215) | (Form:C1466.selectedBoLine=Null:C1517) | Undefined:C82(Form:C1466.selectedBoLine)
		DISABLE MENU ITEM:C150($refMenu; 3)
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	Case of 
			
		: ($choice="--add")
			
			START TRANSACTION:C239
			$buyItem:=ds:C1482.BuyingOrderLine.new()
			$buyItem.UUID_BuyingOrder:=Form:C1466.current_item.UUID
			$buyItem.boNumber:=Form:C1466.current_item.boNumber
			$buyItem.orderDate:=Current date:C33(*)
			
			$form:=New object:C1471("details"; $buyItem)
			
			//$form.approverProfile:=New collection("qs"; "qm")  // only QC Team allowed to modify
			//$form.displayApprovalFields:=False
			
			$winRef:=Open form window:C675("_ga_buyingOrderLine"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
			SET WINDOW TITLE:C213("Add Buying Item"; $winRef)
			DIALOG:C40("_ga_buyingOrderLine"; $form)
			
			If (OK=1)
				//Form.lb_documents.push($form.details)
				
				//$buffer:=New object()
				//$buffer.event:="addDocument"
				//$buffer.label:="Document "+$form.details.sourcePath+" added"
				//$buffer.stmp:=cs.sfw_stmp.me.now()
				//Form.bufferOfEvents.push($buffer)
				
				$buyItem:=$form.details
				
				$res:=$buyItem.save()
				
				If ($res.success)
					
					VALIDATE TRANSACTION:C240
					
					This:C1470.loadLineItems()
					This:C1470._activate_save_cancel_button()
				Else 
					CANCEL TRANSACTION:C241
				End if 
			Else 
				CANCEL TRANSACTION:C241
				
			End if 
			
			
		: ($choice="--modify")

			This:C1470.modifyBuyLine()

		: ($choice="--delete")
			
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this Item? "; "Delete"; "CANCEL")
			If ($ok)
				
				
				//$buffer:=New object()
				//$buffer.event:="deleteDocument"
				//$buffer.label:="Document "+Form.current_item.RatingData.items[Form.selectedRatingItemPos-1].sourcePath+" deleted"
				//$buffer.stmp:=cs.sfw_stmp.me.now()
				//Form.bufferOfEvents.push($buffer)
				
				START TRANSACTION:C239
				$buyItem:=ds:C1482.BuyingOrderLine.query("UUID = :1"; Form:C1466.lb_boLines[Form:C1466.selectedBoLinePos-1].UUID).first()
				
				$res:=$buyItem.drop()
				
				If ($res.success)
					
					VALIDATE TRANSACTION:C240
					
					This:C1470.loadLineItems()
					This:C1470._activate_save_cancel_button()
				Else 
					CANCEL TRANSACTION:C241
				End if 
				
			End if 
			
			
	End case 
	
	