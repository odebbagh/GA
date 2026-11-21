Class extends Entity

	// Legacy [CHART_OF_AC]FullAccountName turned out to hold the account CODE, not a
	// name - it is identical to GLAC on all 404 rows, and the readable part lives in
	// Description. So neither column on its own is usable as a picker label, and this
	// builds the one people actually recognise: "1036-0 - INVENTORIES".
Function get label()->$label : Text
	var $description : Text
	$label:=String:C10(This:C1470.glac)
	$description:=String:C10(This:C1470.description)
	If ($description#"")
		$label:=($label="") ? $description : $label+" - "+$description
	End if

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.label

	// Asset, Liability, Equity, Income or Expense (ga_ledger)
local Function get familyName()->$name : Text
	$name:=cs:C1710.ga_ledger.me.familyName(This:C1470.accountTypeCode)

	// the balance at the end of today, on the account's normal side (ga_ledger.accountBalance)
local Function get balanceToday()->$balance : Real
	$balance:=cs:C1710.ga_ledger.me.accountBalance(This:C1470; Current date:C33; "")

local Function get defaultKeyLabel()->$label : Text
	$label:=(This:C1470.defaultKey="") ? "" : cs:C1710.ga_ledger.me.defaultKeyLabel(This:C1470.defaultKey)

	// a plain explanation of what the account is, for the panel
local Function get familyHelp()->$help : Text
	Case of
		: (This:C1470.accountTypeCode=1)
			$help:="Asset: something the company owns or will receive. Grows with a debit. Its balance adds up since the start."
		: (This:C1470.accountTypeCode=2)
			$help:="Liability: something the company owes. Grows with a credit. Its balance adds up since the start."
		: (This:C1470.accountTypeCode=4)
			$help:="Equity: what belongs to the owners. Grows with a credit. Its balance adds up since the start."
		: (This:C1470.accountTypeCode=8)
			$help:="Income: money earned by the work. Grows with a credit. Starts again at 0 each fiscal year (the profit goes to retained earnings)."
		: (This:C1470.accountTypeCode=16)
			$help:="Expense: money spent to run the business. Grows with a debit. Starts again at 0 each fiscal year."
		Else
			$help:="Choose a type: it decides the family of the account."
	End case

	// used by a journal line or a buy order (line): then it can only be made inactive
Function isUsed()->$used : Boolean
	$used:=(ds:C1482.JournalLine.query("UUID_GLAccount = :1"; This:C1470.UUID).length>0)
	$used:=$used || (ds:C1482.BuyingOrderLine.query("UUID_GLAccount = :1"; This:C1470.UUID).length>0)
	$used:=$used || (ds:C1482.BuyingOrder.query("UUID_GLAccount = :1"; This:C1470.UUID).length>0)


	// MARK: - sfw callbacks

local Function loadAfterCreation()
	This:C1470.accountType:="Expense"
	This:C1470.accountTypeCode:=16
	This:C1470.UUID_Division:="0"*32
	This:C1470.defaultKey:=""
	This:C1470.removed:=False:C215
	This:C1470.buyItemType:="consumable"
	This:C1470.allowsConsumable:=True:C214

local Function beforeSaveCreation()
	This:C1470._syncFromType()

local Function beforeSave()
	This:C1470._syncFromType()

local Function isDeletable()->$isDeletable : Boolean
	$isDeletable:=Not:C34(This:C1470.isUsed())

	// the family follows the type, and fullAccountName mirrors glac (as in the legacy data)
Function _syncFromType()
	This:C1470.accountTypeCode:=cs:C1710.ga_ledger.me.typeCode(This:C1470.accountType)
	This:C1470.fullAccountName:=This:C1470.glac
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(This:C1470.UUID_Division))
		This:C1470.UUID_Division:="0"*32
	End if
