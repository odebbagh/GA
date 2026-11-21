// panel_customerPayment: one customer payment (CustomerPayment), QuickBooks "Receive Payment".
// - Header: customer, date (calendar button), amount received, method, reference (check #),
//   deposit to (Undeposited funds or a bank), memo.
// - Invoices tab: the customer's open invoices (Form.cpRows), with the amount to Apply and the
//   Discount taken on each; the ribbon shows the totals, the problems and the Actions (auto-apply
//   oldest first, pay in full, take the early payment discount, clear).
// - Saved = posted: Save stays disabled while the payment has a problem; after the save,
//   CustomerPaymentEntity writes the lines and the journal entry (ga_receivables.writePayment).
// - Void payments, legacy credits and payments dated in a closed period are read-only
//   (Form.notEditable). While read-only, the tab shows only the invoices the payment paid.
singleton Class constructor


Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function formMethod()
	If (Form:C1466.cpRows=Null:C1517)
		Form:C1466.cpRows:=New collection:C1472
		Form:C1466.cpRowsAll:=False:C215
		Form:C1466.cpOwed:=0
		Form:C1466.cpCredit:=0
		Form:C1466.cpApplied:=0
		Form:C1466.cpDiscounts:=0
		Form:C1466.cpUnapplied:=0
		Form:C1466.cpUnappliedLabel:="Credit left"
		Form:C1466.cpProblems:=""
		Form:C1466.cpHelp:=""
		Form:C1466.cpTitle:=""
	End if
	// before panelFormMethod, so sfw already sees the right editable state
	Form:C1466.notEditable:=(Form:C1466.current_item#Null:C1517) && (String:C10(Form:C1466.situation.mode)#"add") && (String:C10(Form:C1466.situation.mode)#"duplicate") && Not:C34(Form:C1466.current_item.isEditable)
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadRows()
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		This:C1470.updateTotals()
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if


Function redrawAndSetVisible()
	var $editable : Boolean
	var $widthSubform; $heightSubform; $left; $top; $right; $bottom : Integer

	$editable:=This:C1470._editable()
	If ($editable#Bool:C1537(Form:C1466.cpRowsAll))
		// Modify / Cancel: all the open invoices while editing, only the paid ones otherwise
		This:C1470.loadRows()
	End if
	OBJECT SET ENTERABLE:C238(*; "Column_cpApply"; $editable)
	OBJECT SET ENTERABLE:C238(*; "Column_cpDiscount"; $editable)
	OBJECT SET VISIBLE:C603(*; "btnDatePickerDate"; $editable)
	This:C1470.drawPup_customer()
	This:C1470.drawPup_method()
	This:C1470.drawPup_depositAccount()

	// the list-tab layout: the ribbon down the left side, Actions at the bottom, the list filling
	// the rest (as the Step tab of the planning panel)
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $left; $top; $right; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "lb_cpRows"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "lb_cpRows"; $left; $top; $widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "bActionRows"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "bActionRows"; $left; $heightSubform-5-($bottom-$top); $right; $heightSubform-5)
	OBJECT GET COORDINATES:C663(*; "cp_help"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "cp_help"; $left; $top; $right; $heightSubform-35)


	// MARK: - Invoice rows

Function loadRows()
	Form:C1466.cpRowsAll:=This:C1470._editable()
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.cpRows:=New collection:C1472
	Else
		Form:C1466.cpRows:=cs:C1710.ga_receivables.me.rowsForPayment(Form:C1466.current_item; Form:C1466.cpRowsAll)
	End if
	Form:C1466.current_cpRow:=Null:C1517
	This:C1470.updateTotals()

	// totals, problems, help and the Save button
Function updateTotals()
	var $check : Object
	var $canValidate : Boolean
	var $payment : cs:C1710.CustomerPaymentEntity
	var $customerUUID : Text

	$payment:=Form:C1466.current_item
	Form:C1466.cpProblems:=""
	Form:C1466.cpHelp:=""
	If ($payment=Null:C1517)
		return
	End if
	Form:C1466.cpTitle:=(($payment.number=0) ? "New payment" : "Payment #"+String:C10($payment.number))+"  "+$payment.stateText
	$customerUUID:=String:C10($payment.UUID_Customer)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($customerUUID))
		Form:C1466.cpOwed:=0
		Form:C1466.cpCredit:=0
	Else
		Form:C1466.cpOwed:=cs:C1710.ga_receivables.me.customerOwed($customerUUID)
		Form:C1466.cpCredit:=cs:C1710.ga_receivables.me.customerCredit($customerUUID; String:C10($payment.UUID))
	End if
	Form:C1466.cpApplied:=Round:C94(Form:C1466.cpRows.sum("apply"); 2)
	Form:C1466.cpDiscounts:=Round:C94(Form:C1466.cpRows.sum("discount"); 2)
	Form:C1466.cpUnapplied:=Round:C94($payment.amount-Form:C1466.cpApplied; 2)
	Form:C1466.cpUnappliedLabel:=(Form:C1466.cpUnapplied<0) ? "Customer credit used" : "Credit left (not applied)"
	OBJECT SET RGB COLORS:C628(*; "cp_unapplied"; Choose:C955(Form:C1466.cpUnapplied=0; 0x00007A00; 0x00B06000); Background color none:K23:10)

	If (This:C1470._editable())
		$check:=cs:C1710.ga_receivables.me.checkPayment($payment; Form:C1466.cpRows)
		Form:C1466.cpProblems:=$check.errors.copy().combine($check.warnings).join("\r")
		$canValidate:=$check.success
		If (Bool:C1537(Form:C1466.canValidate)#$canValidate)
			Form:C1466.canValidate:=$canValidate
			Form:C1466.validationRulesPassedWithSuccess:=$canValidate
			Form:C1466.validationRulesMessages:=$check.errors
			Form:C1466.sfw.drawButtons()
		End if
		Form:C1466.cpHelp:="Type the amount received, then what each invoice gets in Apply (Actions > Auto-apply oldest first fills it). "+\
			"A discount is money the customer may keep (early payment term). What is applied to no invoice stays a credit of the customer. "+\
			"To use a credit the customer already has, make a payment of 0 with the method \"Apply credit\"."
	Else
		Case of
			: ($payment.status="Void")
				Form:C1466.cpProblems:="This payment is void: it no longer counts."
			: ($payment.isLegacy)
				Form:C1466.cpHelp:="A credit the customer had in the legacy application on the start date. Use it with a new payment of 0, method \"Apply credit\"."
			: ($payment.paymentStmp#0) && Not:C34(cs:C1710.ga_ledger.me.isOpen($payment.paymentDate))
				Form:C1466.cpProblems:="Dated on or before the closing date ("+String:C10(cs:C1710.ga_ledger.me.closingDate())+"): the payment is locked."
		End case
	End if

Function lb_cpRows()
	var $row : Object
	$row:=Form:C1466.current_cpRow
	Case of
		: ($row=Null:C1517)
			return
		: (FORM Event:C1606.code=On Double Clicked:K2:5) && (FORM Event:C1606.columnName="Column_cpInvoice")
			This:C1470._openInvoice($row)
		: (Not:C34(This:C1470._editable()))
			return
		: (FORM Event:C1606.code=On Double Clicked:K2:5) && (FORM Event:C1606.columnName="Column_cpApply")
			This:C1470._payInFull($row)
			This:C1470._rowsChanged()
		: (FORM Event:C1606.code=On Data Change:K2:15)
			$row.apply:=Round:C94(Num:C11($row.apply); 2)
			$row.discount:=Round:C94(Num:C11($row.discount); 2)
			This:C1470._rowsChanged()
	End case

Function bActionRows()
	var $menu; $choice : Text
	var $row : Object
	var $editable : Boolean
	var $left : Real

	$row:=Form:C1466.current_cpRow
	$editable:=This:C1470._editable()
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Auto-apply oldest first"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--auto")
	If (Not:C34($editable)) || (Form:C1466.cpRows.length=0)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "Pay this invoice in full"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--full")
	If (Not:C34($editable)) || ($row=Null:C1517)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "Take the early payment discount"+(($row=Null:C1517) ? "" : " ("+String:C10(Num:C11($row.suggestedDiscount); "###,###,##0.00")+")"); *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--discount")
	If (Not:C34($editable)) || ($row=Null:C1517)
		DISABLE MENU ITEM:C150($menu; -1)
	Else
		If (Num:C11($row.suggestedDiscount)=0)
			DISABLE MENU ITEM:C150($menu; -1)
		End if
	End if
	APPEND MENU ITEM:C411($menu; "Clear this invoice"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--clear")
	If (Not:C34($editable)) || ($row=Null:C1517)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "Clear all"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--clearAll")
	If (Not:C34($editable))
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "Open the invoice"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--open")
	If ($row=Null:C1517)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choice="--auto")
			$left:=cs:C1710.ga_receivables.me.autoApply(Form:C1466.current_item; Form:C1466.cpRows)
			This:C1470._rowsChanged()
		: ($choice="--full")
			This:C1470._payInFull($row)
			This:C1470._rowsChanged()
		: ($choice="--discount")
			$row.discount:=Num:C11($row.suggestedDiscount)
			If (Round:C94($row.apply+$row.discount; 2)>$row.open)
				$row.apply:=Round:C94($row.open-$row.discount; 2)
			End if
			This:C1470._rowsChanged()
		: ($choice="--clear")
			$row.apply:=0
			$row.discount:=0
			This:C1470._rowsChanged()
		: ($choice="--clearAll")
			For each ($row; Form:C1466.cpRows)
				$row.apply:=0
				$row.discount:=0
			End for each
			This:C1470._rowsChanged()
		: ($choice="--open")
			This:C1470._openInvoice($row)
	End case

	// what is open, less the discount on the row
Function _payInFull($row : Object)
	$row.apply:=Round:C94($row.open-$row.discount; 2)
	If ($row.apply<0)
		$row.apply:=0
	End if

Function _openInvoice($row : Object)
	var $invoice : cs:C1710.JobInvoiceEntity
	$invoice:=ds:C1482.JobInvoice.get($row.UUID_JobInvoice)
	If ($invoice#Null:C1517)
		Form:C1466.sfw.openInANewWindow($invoice; "customerService"; "JobInvoice")
	End if

Function _rowsChanged()
	Form:C1466.cpRows:=Form:C1466.cpRows
	This:C1470._activate_save_cancel_button()
	This:C1470.updateTotals()

	// the early payment discount depends on the payment date
Function _refreshSuggestions()
	var $row : Object
	var $invoice : cs:C1710.JobInvoiceEntity
	For each ($row; Form:C1466.cpRows)
		$invoice:=ds:C1482.JobInvoice.get($row.UUID_JobInvoice)
		$row.suggestedDiscount:=($invoice=Null:C1517) ? 0 : cs:C1710.ga_receivables.me.suggestedDiscount($invoice; Form:C1466.current_item.paymentDate; $row.open)
	End for each
	Form:C1466.cpRows:=Form:C1466.cpRows

Function _editable()->$editable : Boolean
	$editable:=(Form:C1466.current_item#Null:C1517) && Form:C1466.sfw.checkIsInModification() && Form:C1466.current_item.isEditable


	// MARK: - Header

Function entryField_amount()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		Form:C1466.current_item.amount:=Round:C94(Form:C1466.current_item.amount; 2)
		If (Form:C1466.current_item.amount#0) && (Form:C1466.current_item.method="Credit")
			Form:C1466.current_item.method:="Check"
			This:C1470.drawPup_method()
		End if
		This:C1470.updateTotals()
	End if

Function entryField_date()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470._refreshSuggestions()
		This:C1470.updateTotals()
	End if

	// the calendar next to the date (ga_datePicker); only while the payment can be changed
Function btnDatePickerDate()
	If (FORM Event:C1606.code=On Clicked:K2:4) && This:C1470._editable()
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_item; "paymentDate"; "entryField_date"))
			This:C1470._activate_save_cancel_button()
			This:C1470._refreshSuggestions()
			This:C1470.updateTotals()
		End if
	End if

Function drawPup_customer()
	var $customer : cs:C1710.CustomerEntity
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$customer:=Form:C1466.current_item.customer
	Form:C1466.sfw.drawButtonPup("pup_customer"; ($customer=Null:C1517) ? "Choose the customer" : $customer.name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($customer=Null:C1517))

	// the customers that owe something or have a credit, then "Other customer..." (search by name)
Function pup_customer()
	var $menu; $choice; $name : Text
	var $customer : Object
	var $found : cs:C1710.CustomerSelection
	var $one : cs:C1710.CustomerEntity
	var $answer : Object
	If (Not:C34(This:C1470._editable()))
		return
	End if
	$menu:=Create menu:C408
	For each ($customer; cs:C1710.ga_receivables.me.customersWithBalance())
		APPEND MENU ITEM:C411($menu; $customer.name+"  -  owes "+String:C10($customer.owed; "###,###,##0.00")+(($customer.credit#0) ? ", credit "+String:C10($customer.credit; "###,###,##0.00") : ""); *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $customer.UUID)
		If ($customer.UUID=Form:C1466.current_item.UUID_Customer)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "Other customer..."; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--other")
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	If ($choice="--other")
		$answer:=cs:C1710.sfw_dialog.me.request("Customer name (or its beginning):"; ""; "Find"; "Cancel"; "trimSpace"; "notEmpty")
		$choice:=""
		$name:=String:C10($answer.answer)
		If (Bool:C1537($answer.ok)) && ($name#"")
			$found:=ds:C1482.Customer.query("name = :1"; $name+"@").orderBy("name asc")
			Case of
				: ($found.length=0)
					cs:C1710.sfw_dialog.me.alert("No customer named \""+$name+"...\".")
				: ($found.length=1)
					$choice:=$found.first().UUID
				Else
					$menu:=Create menu:C408
					For each ($one; $found.slice(0; 40))
						APPEND MENU ITEM:C411($menu; $one.name; *)
						SET MENU ITEM PARAMETER:C1004($menu; -1; $one.UUID)
					End for each
					$choice:=Dynamic pop up menu:C1006($menu)
					RELEASE MENU:C978($menu)
			End case
		End if
	End if
	If ($choice#"") && ($choice#Form:C1466.current_item.UUID_Customer)
		Form:C1466.current_item.UUID_Customer:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_customer()
		This:C1470.loadRows()
	End if

Function drawPup_method()
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	Form:C1466.sfw.drawButtonPup("pup_method"; (Form:C1466.current_item.methodText="") ? " " : Form:C1466.current_item.methodText; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

Function pup_method()
	var $menu; $choice : Text
	var $method : Object
	If (Not:C34(This:C1470._editable()))
		return
	End if
	$menu:=Create menu:C408
	For each ($method; ds:C1482.CustomerPayment.methods())
		APPEND MENU ITEM:C411($menu; $method.label; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $method.method)
		If ($method.method=Form:C1466.current_item.method)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.method)
		Form:C1466.current_item.method:=$choice
		If ($choice="Credit")
			Form:C1466.current_item.amount:=0  // no money: the invoices get the customer's credit
		End if
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_method()
		This:C1470.updateTotals()
	End if

Function drawPup_depositAccount()
	var $account : cs:C1710.GLAccountEntity
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$account:=Form:C1466.current_item.depositAccount
	Form:C1466.sfw.drawButtonPup("pup_depositAccount"; ($account=Null:C1517) ? "Choose the account" : $account.label; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($account=Null:C1517) && (Form:C1466.current_item.amount#0))

	// Undeposited funds (the money waits there for a deposit, Phase 1c), or a bank account
Function pup_depositAccount()
	var $menu; $choice : Text
	var $account; $undeposited : cs:C1710.GLAccountEntity
	If (Not:C34(This:C1470._editable()))
		return
	End if
	$menu:=Create menu:C408
	$undeposited:=cs:C1710.ga_ledger.me.defaultAccount("UndepositedFunds"; "")
	If ($undeposited#Null:C1517)
		APPEND MENU ITEM:C411($menu; $undeposited.label+"  (to deposit later)"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $undeposited.UUID)
		If ($undeposited.UUID=Form:C1466.current_item.UUID_DepositAccount)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
		APPEND MENU ITEM:C411($menu; "-")
	End if
	For each ($account; ds:C1482.GLAccount.query("removed = :1 AND accountType = :2"; False:C215; "Bank").orderBy("glac asc"))
		APPEND MENU ITEM:C411($menu; $account.label; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $account.UUID)
		If ($account.UUID=Form:C1466.current_item.UUID_DepositAccount)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.UUID_DepositAccount)
		Form:C1466.current_item.UUID_DepositAccount:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_depositAccount()
		This:C1470.updateTotals()
	End if
