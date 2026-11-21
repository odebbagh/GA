// PaymentTerm: when a customer must pay an invoice (QuickBooks "Terms"). "Net 30" means the
// invoice is due 30 days after its date; "2% 10 Net 30" also gives a 2% discount if the customer
// pays within 10 days. The term of a customer (Customer.UUID_PaymentTerm) gives the due date of
// its invoices when they are posted (ga_invoicePosting); the default term is used otherwise.
// Legacy kept only a number of days per customer ([Customer_Log]InvPaymentTermsinDays):
// _import_customerAR turns each number into a "Net N" term.
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("paymentTerm"; "administration"; "Payment terms"; "Payment term")
	$entry.setDataclass("PaymentTerm")
	$entry.setIcon("image/entry/invoice-white-50x50.png")
	$entry.setDisplayOrder(-20700)

	$entry.setSearchboxField("code")
	$entry.setSearchboxField("name")

	$entry.setPanel("panel_paymentTerm")
	$entry.setPanelPage(1; ""; "Term")

	$entry.setLBItemsColumn("code"; "Code"; "width:80")
	$entry.setLBItemsColumn("name"; "Name"; "width:180")
	$entry.setLBItemsColumn("netDays"; "Due after (days)"; "width:110"; "right"; "headerRight")
	$entry.setLBItemsColumn("discountText"; "Early payment discount"; "width:180")
	$entry.setLBItemsColumn("isDefault"; "Default"; "type:boolean"; "width:60")
	$entry.setLBItemsColumn("active"; "Active"; "type:boolean"; "width:60")

	$entry.setLBItemsOrderBy("netDays")
	$entry.setLBItemsOrderBy("code")
	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:term"; "unitN:terms")

	$entry.setValidationRule("code"; "entryField_code"; "mandatory"; "trimSpace"; "uppercase"; "unique"; "message:The code is mandatory and unique")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "message:The name is mandatory")

	$entry.setItemListAction("Create the usual terms"; "_ga_seedPaymentTerms")
	$entry.setAllowedProfilesForDeletion("admin")

	$entry.enableTransaction()


	// the term used when a customer has none (the one ticked Default, else Net 30, else none)
Function defaultTerm()->$term : cs:C1710.PaymentTermEntity
	$term:=This:C1470.query("isDefault = :1 AND active = :1"; True:C214).first()
	If ($term=Null:C1517)
		$term:=This:C1470.query("code = :1"; "NET30").first()
	End if

Function activeTerms()->$terms : cs:C1710.PaymentTermSelection
	$terms:=This:C1470.query("active = :1"; True:C214).orderBy("netDays asc, discountPercent desc")

	// the "Net N" term (no discount), created when missing - legacy only had a number of days
Function forDays($days : Integer)->$term : cs:C1710.PaymentTermEntity
	$term:=This:C1470.query("netDays = :1 AND discountPercent = :2"; $days; 0).first()
	If ($term=Null:C1517)
		$term:=This:C1470.new()
		$term.code:=($days=0) ? "RECEIPT" : "NET"+String:C10($days)
		$term.name:=($days=0) ? "Due on receipt" : "Net "+String:C10($days)
		$term.netDays:=$days
		$term.active:=True:C214
		$term.save()
	End if

	// the usual terms, created when missing; the default is Net 30. Returns how many were created.
Function seed()->$created : Integer
	var $def : Object
	var $term : cs:C1710.PaymentTermEntity
	For each ($def; New collection:C1472(\
		New object:C1471("code"; "RECEIPT"; "name"; "Due on receipt"; "netDays"; 0; "discountPercent"; 0; "discountDays"; 0); \
		New object:C1471("code"; "NET15"; "name"; "Net 15"; "netDays"; 15; "discountPercent"; 0; "discountDays"; 0); \
		New object:C1471("code"; "NET30"; "name"; "Net 30"; "netDays"; 30; "discountPercent"; 0; "discountDays"; 0); \
		New object:C1471("code"; "NET45"; "name"; "Net 45"; "netDays"; 45; "discountPercent"; 0; "discountDays"; 0); \
		New object:C1471("code"; "NET60"; "name"; "Net 60"; "netDays"; 60; "discountPercent"; 0; "discountDays"; 0); \
		New object:C1471("code"; "2/10NET30"; "name"; "2% 10 Net 30"; "netDays"; 30; "discountPercent"; 2; "discountDays"; 10)))
		If (This:C1470.query("code = :1"; $def.code).length>0)
			continue
		End if
		$term:=This:C1470.new()
		$term.code:=$def.code
		$term.name:=$def.name
		$term.netDays:=$def.netDays
		$term.discountPercent:=$def.discountPercent
		$term.discountDays:=$def.discountDays
		$term.active:=True:C214
		$term.isDefault:=False:C215
		$term.save()
		$created:=$created+1
	End for each
	If (This:C1470.query("isDefault = :1"; True:C214).length=0)
		$term:=This:C1470.query("code = :1"; "NET30").first()
		If ($term#Null:C1517)
			$term.isDefault:=True:C214
			$term.save()
		End if
	End if
