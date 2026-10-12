
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
	var $nominated : Text
	var $nominatedStaff : cs:C1710.StaffEntity
	
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
	var $nominated : Text
	var $nominatedStaff : cs:C1710.StaffEntity
	
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
	
	// Prints the current buy order. The same method the entry's Action menu calls - this
	// button exists because that framework button (bItemAction on sfw_main_new) is only
	// rendered when the entry declares item actions AND a record is open, which made it
	// hard to tell a missing action from a hidden button while testing.
Function printBuyOrder()
	If (FORM Event:C1606.code#On Clicked:K2:4)
		return 
	End if 
	If (Form:C1466.current_item=Null:C1517)
		cs:C1710.sfw_dialog.me.info("Open a buy order first.")
		return 
	End if 
	BuyingOrders_printBuyOrder
Function toggleSignature($slot : Integer)
	// The signature checkbox. Bound straight to signed1/signed2, so by the time this
	// runs 4D has already flipped the value - same shape as legacy Buy_Form/Field41,
	// which let you tick "Closed" and then put the box back if the rules refused.
	//
	// Ticking asks the chosen approver for their own password and signs.
	// Unticking withdraws the approval, after a confirmation.
	var $nowChecked : Boolean

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	$nowChecked:=Bool:C1537(($slot=1) ? Form:C1466.current_item.signed1 : Form:C1466.current_item.signed2)

	If ($nowChecked)
		//---signApprover puts the box back itself if anything refuses
		This:C1470.signApprover($slot)
	Else
		If (cs:C1710.sfw_dialog.me.confirm("Withdraw the level "+String:C10($slot)+" approval on this order?"; "Withdraw"; "Cancel"))
			This:C1470._setSigned($slot; False:C215)
			This:C1470._activate_save_cancel_button()
		Else
			This:C1470._setSigned($slot; True:C214)
		End if
	End if

local Function _setSigned($slot : Integer; $value : Boolean)
	If ($slot=1)
		Form:C1466.current_item.signed1:=$value
	Else
		Form:C1466.current_item.signed2:=$value
	End if
Function signApprover($slot : Integer)
	// Approver signature. The whole identify / profile / password sequence lives in
	// cs.Util_Authorizer; this function only says what an approver is here and where
	// the answer goes. Links UUID_Approver1/2 to the STAFF record and keeps the staff
	// code in signature1/2.
	var $result : Object
	var $nominated : Text
	var $nominatedStaff : cs:C1710.StaffEntity
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	
	//---The approver has to be chosen first; the checkbox is hidden until then, so this
	//   only fires if the panel was driven some other way.
	$nominated:=($slot=1) ? String:C10(Form:C1466.current_item.UUID_Approver1) : String:C10(Form:C1466.current_item.UUID_Approver2)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($nominated))
		cs:C1710.sfw_dialog.me.alert("Choose the level "+String:C10($slot)+" approver before signing.")
		This:C1470._setSigned($slot; False:C215)
		return 
	End if 

	//---The approver is already named on the order, so there is nobody to identify: this
	//   asks THAT PERSON for their password and nothing else. Legacy worked the same way
	//   round - your name in Approver1 loaded your [BO_Approvers] record, and the only
	//   thing you then typed was your own password.
	$nominatedStaff:=ds:C1482.Staff.query("UUID = :1"; $nominated).first()
	If ($nominatedStaff=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("The approver recorded for level "+String:C10($slot)+" no longer exists.")
		This:C1470._setSigned($slot; False:C215)
		return 
	End if 

	$result:=cs:C1710.Util_Authorizer.me.requestApprovalFromStaff($nominatedStaff; New object:C1471(\
		"profiles"; New collection:C1472(This:C1470.approverProfile($slot)); \
		"profileLabel"; "BO Approver "+String:C10($slot); \
		"requirePassword"; True:C214; \
		"title"; "Approver "+String:C10($slot)))
	
	//cancelled: the approver backed out. Failed: Util_Authorizer already said why.
	If (Not:C34($result.success))
		This:C1470._setSigned($slot; False:C215)
		return 
	End if 
	
	//---Third legacy gate: this approver's own ceiling, at this level.
	//   MatchSignature1/2 checked the order total against [BO_Approvers]MoneyLimit after
	//   the password and cleared the signature when it was exceeded. Util_Authorizer
	//   covers identity, profile and password; the ceiling is specific to buy orders, so
	//   it lives here rather than in the generic authorizer.
	//
	//   The table is optional: until [BOApprover] exists and has rows, holding the
	//   BOAPPROVER profile is authority enough, which is how the application behaved
	//   before this gate was added.
	var $approverClass : 4D:C1709.DataClass
	var $approver : 4D:C1709.Entity
	var $verdict : Object
	var $orderTotal : Real
	
	$approverClass:=ds:C1482["BOApprover"]
	If ($approverClass#Null:C1517)
		$approver:=$approverClass.query("UUID_Staff = :1 and level = :2"; String:C10($result.staff.UUID); $slot).first()
		
		If ($approver=Null:C1517) && ($approverClass.all().length>0)
			cs:C1710.sfw_dialog.me.alert(String:C10($result.staff.fullName)+" is not in the Buy-Order Approvers list for level "+String:C10($slot)+".")
			This:C1470._setSigned($slot; False:C215)
			return 
		End if 
		
		If ($approver#Null:C1517)
			//---lineItemsTotal is the goods total, legacy [BUY_ORDERS]T_Amt. Dollars only,
			//   by decision, so there is no currency conversion here.
			$orderTotal:=Num:C11(Form:C1466.current_item.lineItemsTotal)
			$verdict:=$approver.canApprove($orderTotal)
			If (Not:C34($verdict.ok))
				cs:C1710.sfw_dialog.me.alert($verdict.reason+"\r\r"+"Order total "+String:C10($orderTotal; "$###,###,##0.00")+", your limit is "+String:C10(Num:C11($approver.moneyLimit); "$###,###,##0.00")+".")
				This:C1470._setSigned($slot; False:C215)
				return 
			End if 
		End if 
	End if 
	
	//---signed1/signed2 are the live signal now. signature1/2 (text) are left alone:
	//   they still carry what imported orders brought over, and BuyingOrderEntity
	//   ._signature reads the boolean first and falls back to them.
	This:C1470._setSigned($slot; True:C214)
	
	This:C1470._activate_save_cancel_button()
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh
		Form:C1466.addressBilling:=1
		Form:C1466.addressShipping:=0
		Form:C1466.addressRemit:=0
		Form:C1466.remitSameAsVendor:=False:C215
		Form:C1466.remitBeforeSameAs:=Null:C1517
		This:C1470.LoadContact()
		This:C1470.LoadAllTabs()
		This:C1470.contactDetails()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
						
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
			OBJECT GET COORDINATES:C663(*; "lb_contact"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_contact"; $g; $h; $d; $heightSubform-$offset)
			
		: (FORM Get current page:C276(*)=2)
			// line items page: action rail + list stretch with the window
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_boLines"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_boLines"; $g; $h; $d; $heightSubform-$offset)
			
			OBJECT GET COORDINATES:C663(*; "bActionBuyItems"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bActionBuyItems"; $g; $heightSubform-$offset-27; $d; $heightSubform-$offset-6)
			
			OBJECT GET COORDINATES:C663(*; "lb_boLines"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_boLines"; $g; $h; $widthSubform-$offset; $heightSubform-$offset)
			
		: (FORM Get current page:C276(*)=3)
			// terms page: the model list keeps its width with the action button pinned
			// underneath it, the Write Pro zone takes all the remaining space
			OBJECT GET COORDINATES:C663(*; "header_bkgd11"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "header_bkgd11"; $g; $h; $widthSubform-$offset; $b)
			
			OBJECT GET COORDINATES:C663(*; "bActionTerms"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bActionTerms"; $g; $heightSubform-$offset-27; $d; $heightSubform-$offset-6)
			
			OBJECT GET COORDINATES:C663(*; "lb_terms"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_terms"; $g; $h; $d; $heightSubform-$offset-33)
			
			OBJECT GET COORDINATES:C663(*; "entryField_terms"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_terms"; $g; $h; $widthSubform-$offset; $heightSubform-$offset)
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
	
	// The signature checkboxes appear only once an approver has been chosen for that
	// slot - there is nobody to ask for a password until then.
	$hasApprover1:=(Form:C1466.current_item#Null:C1517) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Approver1)))
	$hasApprover2:=(Form:C1466.current_item#Null:C1517) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Approver2)))
	OBJECT SET VISIBLE:C603(*; "check_signed1"; $hasApprover1)
	OBJECT SET ENABLED:C1123(*; "check_signed1"; $hasApprover1 && $isInModification)
	OBJECT SET VISIBLE:C603(*; "check_signed2"; $hasApprover2)
	OBJECT SET ENABLED:C1123(*; "check_signed2"; $hasApprover2 && $isInModification)
	
	// "QA Not Approved" warning: shown only when the BO's vendor is not approved
	$vendorNotApproved:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.supplier#Null:C1517) && Not:C34(Bool:C1537(Form:C1466.current_item.supplier.approvedByQA))
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
	
	// Picks the buy order's VENDOR. The name is the project-wide convention for a
	// list-picker function and is kept for that reason, but since the Supplier decision
	// this reads [Supplier], not [Customer] with vendor=true - Supplier carries the QA
	// apparatus the buying rules depend on, and it is what AML points at.
	//
	// NOTE: pup_supplier / drawPup_supplier further down do the same job against the same
	// table, but "pup_supplier" is not on the form - that pair is an abandoned half of
	// this migration and never runs. Field_customerName is the live control.
	// Picks the order's VENDOR, which is a [Supplier] - not a [Customer], despite the
	// selectCustomer name this carried from the other panels. BuyingOrder.UUID_Supplier
	// is the FK, and Buying > Vendors now lists the same table.
Function selectSupplier()
	
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_customerName"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"allData"; ds:C1482.Supplier.all().orderBy("name asc"); \
					"dataclass"; "Supplier"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Supplier:=$form.item.UUID
					This:C1470.copyVendorAddresses($form.item.UUID)
					//---the attention contact belongs to the OLD vendor, so it is cleared
					//   rather than left pointing at someone at another company. The
					//   listbox empties with it, and fills again once a new one is chosen.
					Form:C1466.current_item.UUID_AttentionTo:=""
					This:C1470.LoadContact()
					
					//---the issue date, exactly as legacy Buy_Form/Field1 did it:
					//       If (ISSUE_DATE=!00-00-00!) ISSUE_DATE:=Current date(*)
					//   Only when it is still blank. Re-dating an order because someone
					//   corrected the vendor would move the rate date the approval limit is
					//   checked against and the cutoff the archive purge uses - which is why
					//   legacy locked this field outright once a line carried an invoice.
					If (Form:C1466.current_item.orderDate=!00-00-00!)
						Form:C1466.current_item.orderDate:=Current date:C33(*)
					End if 
				End if 
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case 
	End if 
	
Function btnOpenSupplier()
	// The arrow beside the Vendor field: open this order's SUPPLIER in its own window.
	//
	// It used to call cs.panel_purchaseOrder.me.btnOpenCustomer(), which belongs to the
	// sales-side panel and opens Form.current_item.customer in the customerService
	// vision - the wrong panel and the wrong entity. A buy order's counterparty is a
	// Supplier, whose entry is "Supplier" in the qualityAssurance vision (labelled AVL).
	var $supplier : cs:C1710.SupplierEntity

	$supplier:=Form:C1466.current_item#Null:C1517 ? Form:C1466.current_item.supplier : Null:C1517

	If ($supplier=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("No supplier is linked to this buy order.")
		return
	End if

	Form:C1466.sfw.openInANewWindow($supplier; "qualityAssurance"; "Supplier")
Function toggleClosed()
	// The Order Closed box, as legacy Buy_Form/Field41 worked it:
	//
	//     If (Self->=True)
	//         Self->:=IsBuyOrderClosable
	//     End if
	//
	// The box is bound to closed, so 4D has already flipped it by the time this runs.
	// Ticking asks the rules; a refusal puts the box back and says why. Unticking is
	// unguarded - re-opening an order was always allowed.
	var $reason : Text

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	If (Not:C34(Bool:C1537(Form:C1466.current_item.closed)))
		//---unticked: nothing to check
		This:C1470._activate_save_cancel_button()
		return
	End if

	$reason:=Form:C1466.current_item.closingBlockedReason()

	If ($reason#"")
		cs:C1710.sfw_dialog.me.alert($reason)
		Form:C1466.current_item.closed:=False:C215
		return
	End if

	This:C1470._activate_save_cancel_button()
Function selectGLAccount()
	// The order's GL account. Legacy picked it from the ChartOfAccPurchasing hierarchical
	// list; here it is the same 1toN form the other header fields use, filtered to the
	// accounts marked purchasable by _export_glAccounts.
	//
	// Only the link is stored. Choosing one re-applies the account's rules to the order
	// and warns when it belongs to a different division - legacy's
	//     "GL Account X does not belong to divison: Y"
	var $form : Object
	var $accounts : cs:C1710.GLAccountSelection
	var $winRef : Integer
	var $l; $t; $r; $b : Integer
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	Case of
		: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)

			$accounts:=ds:C1482.GLAccount.query("purchasable = :1 and removed = :2"; True:C214; False:C215).orderBy("glac asc")
			If ($accounts.length=0)
				cs:C1710.sfw_dialog.me.alert("No purchasable GL accounts are loaded."+"\r\rRun _import_glAccounts first.")
				return
			End if

			OBJECT GET COORDINATES:C663(*; "Field_glAccount"; $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

			$form:=New object:C1471(\
				"colName"; "label"; \
				"allData"; $accounts; \
				"dataclass"; "GLAccount"\
				)

			$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
			DIALOG:C40("selectNto1"; $form)
			CLOSE WINDOW:C154($winRef)

			If (ok=1)
				Form:C1466.current_item.UUID_GLAccount:=String:C10($form.item.UUID)

				//---the lines follow: a buy item's GL account is the order's, read-only on
				//   Buy Items
				This:C1470._cascadeGLAccountToLines()

				//---DIVISION CHECK DISABLED. Legacy SetInheritedBuyItemFields refused an
				//   account belonging to another division:
				//       "GL Account X does not belong to divison: Y"
				//   BuyingOrderEntity.glAccountBlockedReason() still implements it, but
				//   it is not called: the division data has not been reconciled yet, so
				//   it fires on accounts that are in fact fine. Re-enable by restoring:
				//
				//       $reason:=Form.current_item.glAccountBlockedReason()
				//       If ($reason#"") ... alert ... End if

				This:C1470._activate_save_cancel_button()
			End if

		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			SET CURSOR:C469(9000)
	End case
Function _cascadeGLAccountToLines()
	// Pushes the order's GL account to its lines, with the Inventory / Consumable / Asset
	// rules of the new account (BuyingOrderLineEntity.inheritGLAccountFromOrder). Saved
	// inside the order's transaction, so Cancel on the order undoes them too.
	//
	// Lines already received keep theirs: re-applying the rules could untick Inventory
	// on a line whose stock is already on the shelf.
	var $line : cs:C1710.BuyingOrderLineEntity
	var $skipped : Collection
	var $save : Object

	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	$skipped:=New collection:C1472
	For each ($line; ds:C1482.BuyingOrderLine.query("UUID_BuyingOrder = :1"; String:C10(Form:C1466.current_item.UUID)))
		If ($line.dateIn#!00-00-00!) || (Num:C11($line.qtyReceived)>0) || ($line.hasReceiptInventory)
			$skipped.push($line.displayNumber)
			continue
		End if
		$line.inheritGLAccountFromOrder(Form:C1466.current_item)
		$save:=$line.save()
	End for each

	This:C1470.loadLineItems()

	If ($skipped.length>0)
		cs:C1710.sfw_dialog.me.alert("Lines already received keep their GL account: item "+$skipped.join(", ")+".")
	End if

Function selectDivision()
	// Division picker, same 1toN form the supplier and buyer use.
	//
	// The order carries the division as TEXT (legacy [BUY_ORDERS]Division held "GAC"),
	// so the code is written, not the UUID. Choosing one re-reads the ship-to, because
	// that address belongs to the division - see BuyingOrderEntity.applyDivisionShipTo.
	var $form : Object
	var $winRef : Integer
	var $l; $t; $r; $b : Integer
	var $chosen : Text

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	Case of
		: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)

			If (ds:C1482.Division.all().length=0)
				cs:C1710.sfw_dialog.me.alert("No division exists yet."+"\r\rRun _ga_seedDivisionInfo, or add one in Administration.")
				return
			End if

			OBJECT GET COORDINATES:C663(*; "Field_division"; $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

			$form:=New object:C1471(\
				"colName"; "name"; \
				"allData"; ds:C1482.Division.all().orderBy("name asc"); \
				"dataclass"; "Division"\
				)

			$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
			DIALOG:C40("selectNto1"; $form)
			CLOSE WINDOW:C154($winRef)

			If (ok=1)
				$chosen:=(String:C10($form.item.code)#"") ? String:C10($form.item.code) : String:C10($form.item.name)
				Form:C1466.current_item.division:=$chosen

				//---the ship-to belongs to the division, so it follows the choice
				Form:C1466.current_item.applyDivisionShipTo()
				This:C1470.contactDetails()
				This:C1470._activate_save_cancel_button()
			End if

		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			SET CURSOR:C469(9000)
	End case
Function buyerProfile()->$ident : Text
	// The buyer list is the Purchasing profile. _import_userProfiles defines it as
	//     {"ident": "pu"; "name": "Purchasing"; "legacy": "buyers"}
	// - "buyers" being exactly what legacy called that group. One place to change it if
	// a dedicated BUYER profile is ever split out.
	$ident:="pu"

Function selectBuyer()
	// Same shape as selectApprover: the users holding the buyer profile, listed and
	// displayed by full name rather than by the six-digit staff code.
	//
	// Stores a Staff UUID - UUID_Buyer relates to Staff.UUID through the "staff"
	// relation, which was renamed off "buyer" because the order also carries a buyer
	// TEXT column and the two collided.
	var $form : Object
	var $staff : cs:C1710.StaffEntity
	var $candidates : cs:C1710.StaffSelection
	var $profile : Text
	var $winRef : Integer
	var $l; $t; $r; $b : Integer

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	Case of
		: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)

			$profile:=This:C1470.buyerProfile()

			//---built, not re-queried: Staff.UUID is store_as_UUID, so "UUID in :1"
			//   against a collection of UUID text matches nothing.
			$candidates:=ds:C1482.Staff.newSelection(dk keep ordered)
			For each ($staff; ds:C1482.Staff.query("terminated = :1 and inactive = :2"; False:C215; False:C215).orderBy("lastName asc"))
				If (cs:C1710.Util_Authorizer.me.isInAnyProfile($staff.user; New collection:C1472($profile)))
					$candidates:=$candidates.add($staff)
				End if
			End for each

			If ($candidates.length=0)
				cs:C1710.sfw_dialog.me.alert("No active user holds the \""+$profile+"\" (Purchasing) profile."\
					+"\r\rAssign it in Administration before choosing a buyer.")
				return
			End if

			OBJECT GET COORDINATES:C663(*; "Field_buyer"; $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

			$form:=New object:C1471(\
				"colName"; "fullName"; \
				"allData"; $candidates; \
				"dataclass"; "Staff"\
				)

			$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
			DIALOG:C40("selectNto1"; $form)
			CLOSE WINDOW:C154($winRef)

			If (ok=1)
				Form:C1466.current_item.UUID_Buyer:=String:C10($form.item.UUID)
				This:C1470._activate_save_cancel_button()
			End if

		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			SET CURSOR:C469(9000)
	End case
Function approverProfile($slot : Integer)->$ident : Text
	// One place that says how a level maps to a profile: BOAPPROVER1 / BOAPPROVER2.
	// Legacy held two separate tables for this, [BO_Approvers] and [BO_Approvers2].
	$ident:="BOAPPROVER"+String:C10($slot)

Function _isListedApprover($staff : cs:C1710.StaffEntity; $slot : Integer)->$listed : Boolean
	// The rule signApprover applies after the password, asked up front for the picker.
	// Once [BOApprover] has rows - _import_boApprovers loads legacy's approvers with their
	// money limits - a person must have an ACTIVE row for this level. Until the table is
	// used at all, holding the profile is enough, as signApprover also allows.
	var $approverClass : 4D:C1709.DataClass

	$listed:=True:C214
	$approverClass:=ds:C1482["BOApprover"]
	If ($approverClass=Null:C1517)
		return
	End if
	If ($approverClass.all().length=0)
		return
	End if
	$listed:=($approverClass.query("UUID_Staff = :1 and level = :2 and active = :3"; String:C10($staff.UUID); $slot; True:C214).length>0)

Function selectApprover($slot : Integer)
	// Choose who is to approve this order at this level, from the users holding the
	// BOAPPROVER<slot> profile.
	//
	// This records WHO IS EXPECTED TO SIGN. It is not the approval itself - that is
	// toggleSignature, which asks the chosen person for their own password.
	//
	// WHAT GETS STORED IS A STAFF UUID. UUID_Approver1/2 relate to Staff.UUID (the
	// approver1/approver2 relations), which is what approver1Name and the buy-order
	// print read.
	var $form : Object
	var $staff : cs:C1710.StaffEntity
	var $candidates : cs:C1710.StaffSelection
	var $profile : Text
	var $winRef : Integer
	var $l; $t; $r; $b : Integer

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	Case of
		: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)

			$profile:=This:C1470.approverProfile($slot)

			//---Membership is resolved through Util_Authorizer.isInAnyProfile rather than
			//   a query across user.userInscriptions.userProfile.ident, because that is
			//   the function the rest of the approval path already trusts and it folds
			//   case - this application spells profiles inconsistently. Staff is a small
			//   table, so walking it is cheap. The matches are turned back into a real
			//   entity selection because the picker's search box calls allData.query().
			//---The selection is BUILT, not re-queried.
			//
			//   This used to collect the UUIDs and then run
			//       ds.Staff.query("UUID in :1"; $uuids)
			//   which came back empty every time: Staff.UUID is store_as_UUID, and the
			//   "in" operator against a collection of UUID text does not match it. The
			//   membership test was right all along - _diagnose_boApprovers confirmed it
			//   resolves the right people - so the list was being thrown away on the way
			//   back into an entity selection.
			//
			//   newSelection(dk keep ordered) + add keeps the lastName order of the loop,
			//   and the picker's search box still has a real entity selection to query.
			$candidates:=ds:C1482.Staff.newSelection(dk keep ordered)
			For each ($staff; ds:C1482.Staff.query("terminated = :1 and inactive = :2"; False:C215; False:C215).orderBy("lastName asc"))
				//---the same two tests signApprover makes, so everyone offered here can
				//   actually sign: the profile, then the BO Approvers list
				If (cs:C1710.Util_Authorizer.me.isInAnyProfile($staff.user; New collection:C1472($profile))) && (This:C1470._isListedApprover($staff; $slot))
					$candidates:=$candidates.add($staff)
				End if
			End for each

			If ($candidates.length=0)
				cs:C1710.sfw_dialog.me.alert("Nobody can approve at level "+String:C10($slot)+" yet."\
					+"\r\rAn approver needs the "+$profile+" profile AND an active level "+String:C10($slot)+" entry in Administration > BO Approvers.")
				return
			End if

			OBJECT GET COORDINATES:C663(*; "Field_approver"+String:C10($slot); $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

			//---fullName is the existing computed attribute on StaffEntity
			//   (firstName + " " + lastName). colName must be ONE attribute: the picker
			//   binds This[Form.colName], so a dotted path renders empty.
			$form:=New object:C1471(\
				"colName"; "fullName"; \
				"allData"; $candidates; \
				"dataclass"; "Staff"\
				)

			$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
			DIALOG:C40("selectNto1"; $form)
			CLOSE WINDOW:C154($winRef)

			If (ok=1)
				//---changing the approver invalidates any signature already held for
				//   that slot, the way legacy cleared Signature1/2 when the ceiling moved
				If ($slot=1)
					Form:C1466.current_item.UUID_Approver1:=String:C10($form.item.UUID)
					Form:C1466.current_item.signed1:=False:C215
				Else
					Form:C1466.current_item.UUID_Approver2:=String:C10($form.item.UUID)
					Form:C1466.current_item.signed2:=False:C215
				End if
				This:C1470._activate_save_cancel_button()
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
				
				//---every staff member can be a requestor: no profile check, unlike the
				//   buyer (Purchasing) and the approvers (BOAPPROVER1/2). Only people who
				//   have left are left out, so a new order cannot be raised for someone
				//   who is terminated or inactive.
				$form:=New object:C1471(\
					"colName"; "fullName"; \
					"allData"; ds:C1482.Staff.query("terminated = :1 and inactive = :2"; False:C215; False:C215).orderBy("lastName asc"); \
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
		$signed:=(Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Approver1))))\
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
	
Function setPendingBuyingOrder($order : cs:C1710.BuyingOrderEntity)
	// The buy order a new line is being created for.
	//
	// It goes in Storage, not on this singleton: sfw_item.openForm starts a NEW PROCESS
	// for the entry unless sameProcess is set, and a plain 4D singleton is per-process.
	//
	// The VALUES are carried, not just the key. The order is in modification, which the
	// framework enters with cancelAndRestartTransaction, so it sits in an uncommitted
	// transaction belonging to THIS process - the new process cannot query it by UUID and
	// would get Null. That is why passing only the UUID left the new line empty.
	If (Storage:C1525.buyingOrder=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.buyingOrder:=New shared object:C1526
		End use
	End if

	Use (Storage:C1525.buyingOrder)
		If ($order=Null:C1517)
			Storage:C1525.buyingOrder.pendingUUID:=""
			Storage:C1525.buyingOrder.pendingNumber:=0
			Storage:C1525.buyingOrder.pendingSupplier:=""
			Storage:C1525.buyingOrder.pendingGLAccount:=""
		Else
			Storage:C1525.buyingOrder.pendingUUID:=String:C10($order.UUID)
			Storage:C1525.buyingOrder.pendingNumber:=Num:C11($order.boNumber)
			Storage:C1525.buyingOrder.pendingSupplier:=String:C10($order.UUID_Supplier)
			Storage:C1525.buyingOrder.pendingGLAccount:=String:C10($order.UUID_GLAccount)
		End if
	End use

Function pendingBuyingOrder()->$pending : Object
	// {uuid; boNumber; supplier; glAccount} - empty uuid means nothing is pending.
	$pending:=New object:C1471("uuid"; ""; "boNumber"; 0; "supplier"; ""; "glAccount"; "")

	If (Storage:C1525.buyingOrder=Null:C1517)
		return
	End if

	$pending.uuid:=String:C10(Storage:C1525.buyingOrder.pendingUUID)
	$pending.boNumber:=Num:C11(Storage:C1525.buyingOrder.pendingNumber)
	$pending.supplier:=String:C10(Storage:C1525.buyingOrder.pendingSupplier)
	$pending.glAccount:=String:C10(Storage:C1525.buyingOrder.pendingGLAccount)
Function callbackAfterCreationBuyItem($key : Text)
	// Fired by the framework AFTER the new buy item has been saved
	// (sfw_foundations, the "continue with the modify mode" branch). It arrives here
	// through CALL FORM on the starting window, so this runs in the buy order's own
	// process with Form pointing at its panel - but OUTSIDE the normal form event
	// cycle, which is why the listbox has to be told to repaint rather than just
	// having its source reassigned.
	This:C1470.setPendingBuyingOrder(Null:C1517)

	If (cs:C1710.sfw_string.me.isAnEmptyUUID($key))
		return
	End if
	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	//---re-query the lines and roll the totals up
	This:C1470.loadLineItems()

	//---reassign to trigger the listbox, then repaint. Between events the binding does
	//   not refresh on its own.
	Form:C1466.lb_boLines:=Form:C1466.lb_boLines
	If (Form:C1466.lb_boLines#Null:C1517)
		LISTBOX SELECT ROW:C912(*; "lb_boLines"; 0; lk remove from selection:K53:3)
	End if

	//---and the "Line Items (n)" tab label, which redrawAndSetVisible owns
	This:C1470.redrawAndSetVisible()

	This:C1470._activate_save_cancel_button()
Function callbackAfterCreationContact($key : Text)
	var $contact : cs:C1710.ContactEntity
	
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($key)=False:C215)
		
		// link the new contact to the BO's vendor when it was left without a company
		$contact:=ds:C1482.Contact.query("UUID = :1"; $key).first()
		If ($contact#Null:C1517) && (Form:C1466.current_item#Null:C1517)
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($contact.UUID_Company))) && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Supplier))))
				$contact.UUID_Company:=Form:C1466.current_item.UUID_Supplier
				$contact.save()
			End if 
		End if 
		
		// set it as the Attention To of the buy order
		Form:C1466.current_item.UUID_AttentionTo:=$key
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID

		//---and show the new contact's details straight away, as selectContact does
		This:C1470.LoadContact()
	End if 
	
	
Function toggleRemitSameAsVendor()
	// Legacy Buy_Form/Variable3: a toggle beside the address tabs.
	//
	//   ticked   -> the remit address becomes a copy of the vendor address
	//   unticked -> the previous remit address comes back
	//
	// Legacy restored it with Old(), which only works inside a record's modification
	// cycle. Here the displaced address is stashed on the form instead, so unticking
	// puts back exactly what was there rather than re-reading the vendor - which would
	// lose an address the buyer had edited by hand.
	var $contactDetails : Object
	var $billing : Object
	var $remit : Object
	var $copy : Object

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	$contactDetails:=Form:C1466.current_item.contactDetails
	If ($contactDetails=Null:C1517) || ($contactDetails.addresses=Null:C1517)
		return
	End if

	$billing:=$contactDetails.addresses.query("type = :1"; "vendor").first()
	$remit:=$contactDetails.addresses.query("type = :1"; "remit").first()

	If (Bool:C1537(Form:C1466.remitSameAsVendor))
		//---ticked: keep what is being replaced, then copy the vendor address over
		If ($billing=Null:C1517)
			cs:C1710.sfw_dialog.me.alert("There is no vendor address to copy from yet.")
			Form:C1466.remitSameAsVendor:=False:C215
			return
		End if

		Form:C1466.remitBeforeSameAs:=($remit#Null:C1517) ? OB Copy:C1225($remit) : Null:C1517

		If ($remit=Null:C1517)
			$copy:=OB Copy:C1225($billing)
			$copy.type:="remit"
			$contactDetails.addresses.push($copy)
		Else
			$remit.detail:=OB Copy:C1225($billing.detail)
		End if
	Else
		//---unticked: put back what the toggle displaced
		If ($remit#Null:C1517)
			If (Form:C1466.remitBeforeSameAs#Null:C1517)
				$remit.detail:=OB Copy:C1225(Form:C1466.remitBeforeSameAs.detail)
			Else
				//---there was no remit address before the toggle, so remove the copy
				$contactDetails.addresses:=$contactDetails.addresses.query("type # :1"; "remit")
			End if
		End if
	End if

	//---reassign so ORDA registers the nested change
	Form:C1466.current_item.contactDetails:=$contactDetails

	Form:C1466.addressBilling:=0
	Form:C1466.addressShipping:=0
	Form:C1466.addressRemit:=1
	This:C1470.contactDetails()
	This:C1470._activate_save_cancel_button()
Function _vendorAddressAs($vendor : cs:C1710.SupplierEntity; $wantedType : Text; $preference : Collection)->$address : Object
	// First of $preference the vendor actually has, deep-copied and re-typed as
	// $wantedType. A copy, not a reference: the buy order keeps its own version, so a
	// later change on the vendor record cannot rewrite the address an order was sent to.
	var $source : Object
	var $type : Text

	$address:=Null:C1517

	For each ($type; $preference)
		$source:=$vendor.contactDetails.addresses.query("type = :1"; $type).first()
		If ($source#Null:C1517)
			$address:=OB Copy:C1225($source)
			$address.type:=$wantedType
			return
		End if
	End for each
Function copyVendorAddresses($vendorUUID : Text)
	// Copy the vendor's billing/shipping/remit addresses into the buy order
	// record. It is a deep copy: the buy order keeps its own version, which
	// can be modified later without touching the vendor record.
	var $vendor : cs:C1710.SupplierEntity
	var $contactDetails : Object
	var $address : Object
	
	$vendor:=ds:C1482.Supplier.query("UUID = :1"; $vendorUUID).first()
	
	$contactDetails:=Form:C1466.current_item.contactDetails || New object:C1471()
	$contactDetails.addresses:=New collection:C1472()
	
	//---Map onto the three slots this order actually shows, instead of copying the
	//   vendor's collection verbatim.
	//
	//   The two vendor imports disagree about types: _import_vendors writes
	//   billing / shipping / remit, but __import_data_avl_aml writes only main and
	//   remit. A straight copy therefore left Billing and Shipping empty for every
	//   supplier that came through the second one - the radios query by type and found
	//   nothing to show.
	//
	//   Each slot falls back through the types that could reasonably stand in for it, so
	//   a vendor holding only "main" still fills all three.
	If ($vendor#Null:C1517) && ($vendor.contactDetails#Null:C1517) && ($vendor.contactDetails.addresses#Null:C1517)
		$address:=This:C1470._vendorAddressAs($vendor; "vendor"; New collection:C1472("billing"; "main"))
		If ($address#Null:C1517)
			$contactDetails.addresses.push($address)
		End if

		//---remit comes ONLY from the vendor's own remit address. No falling back to the
		//   billing one: legacy kept [Suppliers]remit_* separate and gave the buyer an
		//   explicit "same as" toggle for when they are identical, which is
		//   toggleRemitSameAsVendor below. Guessing here would take that choice away.
		$address:=This:C1470._vendorAddressAs($vendor; "remit"; New collection:C1472("remit"))
		If ($address#Null:C1517)
			$contactDetails.addresses.push($address)
		End if
	End if 

	Form:C1466.current_item.contactDetails:=$contactDetails

	//---SHIP TO IS NOT THE VENDOR'S ADDRESS. It is where the goods are delivered: our own
	//   site, from the division. Legacy built it in SubrGetBuyOrderShipAddr from
	//   [Housekeeping_div_add] SiteAdd1 / SiteAdd2 / Telmesg.
	//
	//   The entity owns that now, so creating an order and changing its vendor both go
	//   through the same code - see BuyingOrderEntity.applyDivisionShipTo.
	Form:C1466.current_item.applyDivisionShipTo()
	$contactDetails:=Form:C1466.current_item.contactDetails
	
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
					"colName"; "pickerLabel"; \
					"allData"; ds:C1482.Contact.query("UUID_Company = :1"; Form:C1466.current_item.UUID_Supplier).orderBy("title asc, lastName asc"); \
					"dataclass"; "Contact"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_AttentionTo:=$form.item.UUID
					This:C1470.LoadContact()
					This:C1470._activate_save_cancel_button()
				End if 
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case 
	End if 
	
Function LoadContact()
	// Rebuilds the supplier contact rows for whichever toggle is selected.
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_contact:=New collection:C1472()
		Form:C1466.lb_contact:=Form:C1466.current_item.rebuildContact()
	End if

Function LoadAllTabs()
	This:C1470.loadLineItems()
	
Function loadLineItems()
	// Roll the lines up onto the order, as legacy BO_totalupd did after every change to
	// a line. Guarded inside recalcTotals, so an order already correct is untouched.
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.recalcTotals())
			Form:C1466.current_item.save()
		End if
	End if
	Form:C1466.lb_boLines:=ds:C1482.BuyingOrderLine.query("UUID_BuyingOrder = :1"; Form:C1466.current_item.UUID)
	
	
Function bActionTerms()
	
	
Function loadTerms()
	//The Terms page lists the BO term models to pick from. Selecting one copies its
	//assembled document into current_item.terms, which stays freely editable afterwards.
	Form:C1466.lb_terms:=ds:C1482.BOTermsModel.all().orderBy("name")
	
Function lb_terms()
	//Clicking a model copies its content into the Terms zone. It is a plain copy:
	//the buy order keeps no link to the model afterwards.
	var $currentText : Text
	var $ok : Boolean
	
	If (FORM Event:C1606.code#On Clicked:K2:4)
		return 
	End if 
	If (Form:C1466.selectedTerm=Null:C1517) || (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	
	//never silently discard terms that have already been written
	$currentText:=""
	If (Form:C1466.current_item.terms#Null:C1517) && (Not:C34(OB Is empty:C1297(Form:C1466.current_item.terms)))
		$currentText:=WP Get text:C1575(Form:C1466.current_item.terms)
	End if 
	If ($currentText#"")
		$ok:=cs:C1710.sfw_dialog.me.confirm("Replace the current terms with the model "+String:C10(Form:C1466.selectedTerm.name)+"?"; "Replace"; "CANCEL")
		If (Not:C34($ok))
			return 
		End if 
	End if 
	
	If (Form:C1466.selectedTerm.model=Null:C1517)
		Form:C1466.current_item.terms:=WP New:C1317()
	Else 
		Form:C1466.current_item.terms:=WP New:C1317(Form:C1466.selectedTerm.model)
	End if 
	This:C1470._activate_save_cancel_button()
	
Function entryField_terms()
	//The Terms zone writes straight into current_item.terms, so every edit is saved
	//with the buy order
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			This:C1470._activate_save_cancel_button()
	End case 
	
	
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
	
Function selectCustomerCarrier()
	
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_customerCarrier"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"allData"; ds:C1482.CustomerCarrier.all(); \
					"dataclass"; "CustomerCarrier"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_CustomerCarrier:=$form.item.UUID
				End if 
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case 
	End if 
	
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
	var $selector : cs:C1710.sfw_definitionSelector
	
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

			//---Open the Buy Items entry in creation mode, rather than the standalone
			//   _ga_buyingOrderLine dialog: one screen for a buy item, whichever way it
			//   is reached, with the entry's own validation rules and actions.
			//
			//   The new line is pre-filled with this buy order - see
			//   BuyingOrderLineEntity.loadAfterCreation, which reads the property set
			//   just below. The item number is assigned there too, because it is a
			//   sequence WITHIN the order.
			This:C1470.setPendingBuyingOrder(Form:C1466.current_item)

			$selector:=cs:C1710.sfw_definitionSelector.new("selectorBuyItemFromOrder"; "boItems")
			$selector.createANewEntity("cs.panel_buyingOrder.me.callbackAfterCreationBuyItem($1)")
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

//Mark:- Dynamic-rendering mirrors of the form object methods
// activateDocument("showCountInTab") on the Buying Orders entry (BuyingOrder.entryDefinition)
// adds the framework's Documents tab, and with it switches this panel to dynamic-source
// rendering: sfw_foundations replaces every object method of the form with
// sfw_dynamicForm_script, which calls cs.panel_buyingOrder.me[objectName]() - and does
// nothing, silently, when there is no function of that name. Each function below carries
// the name of a form object and does exactly what its ObjectMethods file does; the files
// are kept for static rendering. Self does not resolve in this mode, so objects are
// addressed by name.
//
// No mirror for entryField_salesTaxRate, _currency, _discount, _discountDays, _netDays and
// _fob: their object methods are empty or comments only.

// ---- header ----------------------------------------------------------------

Function Field_customerName()
	This:C1470.selectSupplier()

Function btnForward()
	Case of
		: (FORM Event:C1606.code=On Clicked:K2:4)
			This:C1470.btnOpenSupplier()
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "btnForward"); 9000; 9019))
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469
	End case

Function btnDatePicker_commitDate()
	var $l; $t; $r; $b : Integer
	var $date : Date

	If (FORM Event:C1606.code#On Clicked:K2:4)
		return
	End if
	$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.current_item.orderDate; "btnDatePicker_commitDate")  // the app's calendar
	If ($date#!00-00-00!)
		Form:C1466.current_item.orderDate:=$date
	End if

Function Field_buyer()
	This:C1470.selectBuyer()

Function bScan_buyer()
	Case of
		: (FORM Event:C1606.code=On Clicked:K2:4)
			This:C1470.selectBuyerStaff()
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "bScan_buyer"); 9000; 9019))
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469
	End case

Function Field_requestor()
	This:C1470.selectRequestor()

Function entryField_buyOrderLimit()
	Case of
		: (FORM Event:C1606.code=On Before Keystroke:K2:6)
			Form:C1466.PreviousLimit:=Form:C1466.current_item.buyOrderLimit
		: (FORM Event:C1606.code=On Data Change:K2:15)
			//---Num() guards the first edit of a brand-new order - see the object method
			If (Num:C11(Form:C1466.PreviousLimit)#0)
				This:C1470.changeBOLimit(Num:C11(Form:C1466.PreviousLimit); Form:C1466.current_item.buyOrderLimit)
			End if
			This:C1470._activate_save_cancel_button()
	End case

Function Field_approver1()
	This:C1470.selectApprover(1)

Function Field_approver2()
	This:C1470.selectApprover(2)

Function check_signed1()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470.toggleSignature(1)
	End if

Function check_signed2()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470.toggleSignature(2)
	End if

Function Field_requisitionOnly1()
	// the Order Closed checkbox
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470.toggleClosed()
	End if

Function btnPrintBuyOrder()
	This:C1470.printBuyOrder()

// ---- Main tab --------------------------------------------------------------

Function Field_attentionTo()
	This:C1470.selectContact()

Function btnForward1()
	Case of
		: (FORM Event:C1606.code=On Clicked:K2:4)
			This:C1470.createAttentionContact()
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "btnForward1"); 9000; 9019))
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
			SET CURSOR:C469
	End case

Function rbBilling1()
	Form:C1466.current_item.rebuildAddress()

Function rbShipping1()
	Form:C1466.current_item.rebuildAddress()

Function rbRemit1()
	Form:C1466.current_item.rebuildAddress()

Function chkRemitSameAsVendor()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470.toggleRemitSameAsVendor()
	End if

Function Field_glAccount()
	This:C1470.selectGLAccount()

Function Field_division()
	This:C1470.selectDivision()

Function Field_customerCarrier()
	This:C1470.selectCustomerCarrier()

// ---- BO Line Items tab -------------------------------------------------------

Function lb_boLines()
	If (FORM Event:C1606.code=On Double Clicked:K2:5)
		This:C1470.modifyBuyLine()
	End if
