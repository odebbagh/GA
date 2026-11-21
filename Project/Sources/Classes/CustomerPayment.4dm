// CustomerPayment: money received from a customer (QuickBooks "Receive Payment"), applied to
// one or more of its invoices (CustomerPaymentLine). See ga_receivables for the accounting.
// - amount: the money received (0 for an "Apply credit" payment that only uses a credit the
//   customer already has); method / reference: check, wire, ACH, card, cash and the check number.
// - UUID_DepositAccount: where the money goes: Undeposited funds (role UndepositedFunds) until it
//   is taken to the bank with a deposit (Phase 1c), or straight to a bank account.
// - unappliedAmount: what was applied to no invoice, kept as a credit of the customer (Customer
//   advances); negative for an "Apply credit" payment (the credit it used).
// - status: Posted (in the books: saved = posted) or Void. isLegacy: a credit imported from the
//   legacy application (_import_customerCredits), with no entry here.
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	var $view : cs:C1710.sfw_definitionView

	$entry:=cs:C1710.sfw_definitionEntry.new("receivePayment"; ["accounting"]; "Receive payment"; "Payment")
	$entry.setDataclass("CustomerPayment")
	$entry.setDisplayOrder(-150)
	$entry.setIcon("image/entry/invoice-white-50x50.png")

	$entry.setSearchboxField("reference")
	$entry.setSearchboxField("memo")
	$entry.setSearchField("path:customer.name"; "tag:Customer"; "placeholder:customerName"; "popupDescription:the customer name")
	$entry.setSearchField("path:lines.invoice.invoiceNumber"; "tag:Invoice"; "placeholder:invoiceNumber"; "popupDescription:an invoice the payment pays")

	$entry.setPanel("panel_customerPayment")
	$entry.setPanelPage(1; ""; "Invoices")

	$entry.setLBItemsColumn("number"; "#"; "width:60"; "right"; "headerRight")
	$entry.setLBItemsColumn("paymentDate"; "Date"; "width:90"; "type:date")
	$entry.setLBItemsColumn("customer.name"; "Customer"; "width:220")
	$entry.setLBItemsColumn("methodText"; "Method"; "width:90")
	$entry.setLBItemsColumn("reference"; "Reference"; "width:110")
	$entry.setLBItemsColumn("amount"; "Amount"; "width:110"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00")
	$entry.setLBItemsColumn("unappliedAmount"; "Credit left"; "width:100"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00;-###,###,##0.00;")
	$entry.setLBItemsColumn("stateText"; "Status"; "width:80")

	$entry.setLBItemsOrderBy("number desc")
	$entry.setLBItemsOrderBy("paymentStmp desc")
	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:payment"; "unitN:payments")

	$entry.setSubset("activePayments")
	$entry.setMainViewLabel("Payments")

	$entry.setItemAction("Void the payment..."; "CustomerPayment_void"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification()) && Form.current_item.canVoid")

	$entry.enableTransaction()
	$entry.activateFavorite()

	// MARK: -Views
	$view:=cs:C1710.sfw_definitionView.new("customerCredits"; "Credits not used yet"; "derivedFrom:main"; $entry)
	$view.setSubset("customerCredits")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("legacyCustomerCredits"; "Credits from legacy"; "derivedFrom:main"; $entry)
	$view.setSubset("legacyCredits")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("voidCustomerPayments"; "Void payments"; "derivedFrom:main"; $entry)
	$view.setSubset("voidPayments")
	$entry.setView($view)


Function activePayments()->$payments : cs:C1710.CustomerPaymentSelection
	$payments:=This:C1470.query("status # :1"; "Void")

Function customerCredits()->$payments : cs:C1710.CustomerPaymentSelection
	$payments:=This:C1470.query("status = :1 AND unappliedAmount > :2"; "Posted"; 0)

Function legacyCredits()->$payments : cs:C1710.CustomerPaymentSelection
	$payments:=This:C1470.query("isLegacy = :1"; True:C214)

Function voidPayments()->$payments : cs:C1710.CustomerPaymentSelection
	$payments:=This:C1470.query("status = :1"; "Void")

	// the ways a customer pays (method stored, label shown)
Function methods()->$methods : Collection
	$methods:=New collection:C1472(\
		New object:C1471("method"; "Check"; "label"; "Check"); \
		New object:C1471("method"; "Wire"; "label"; "Wire transfer"); \
		New object:C1471("method"; "ACH"; "label"; "ACH"); \
		New object:C1471("method"; "Card"; "label"; "Credit card"); \
		New object:C1471("method"; "Cash"; "label"; "Cash"); \
		New object:C1471("method"; "Credit"; "label"; "Apply credit (no money)"))
