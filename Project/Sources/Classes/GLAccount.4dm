// GLAccount: the chart of accounts, the list of the "buckets" of the books (see ga_ledger).
// glac is the account number (legacy [CHART_OF_AC]GLAC, e.g. "1030-0"), description its name,
// accountType the QuickBooks type ("Bank", "Income"...) and accountTypeCode its family
// (1 asset, 2 liability, 4 equity, 8 income, 16 expense), set from the type on save.
// defaultKey is the role the account plays for the documents ("DefaultA/R"...; ga_ledger.defaultKeys).
// The buying flags (purchasable, allowsInventory, defaultAsset, allowsConsumable) drive the
// buy order lines (BuyingOrderLineEntity.applyGLAccountRules).
// The CAO entry (an older, separate chart of accounts) is not used by the ledger.
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	var $view : cs:C1710.sfw_definitionView

	$entry:=cs:C1710.sfw_definitionEntry.new("chartOfAccounts"; ["accounting"]; "Chart of Accounts"; "Account")
	$entry.setDataclass("GLAccount")
	$entry.setDisplayOrder(-140)
	$entry.setIcon("image/entry/charOfAccount-white-50x50.png")

	$entry.setSearchboxField("glac")
	$entry.setSearchboxField("description")

	$entry.setPanel("panel_glAccount")
	$entry.setPanelPage(1; ""; "Account")
	$entry.setPanelPage(2; ""; "Register")

	$entry.setLBItemsColumn("glac"; "Number"; "width:90")
	$entry.setLBItemsColumn("description"; "Name"; "width:260")
	$entry.setLBItemsColumn("accountType"; "Type"; "width:160")
	$entry.setLBItemsColumn("defaultKeyLabel"; "Role"; "width:220")
	$entry.setLBItemsColumn("balanceToday"; "Balance"; "width:110"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00;-###,###,##0.00;")

	$entry.setLBItemsOrderBy("glac")
	$entry.setLBItemsOrderBy("description")
	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:account"; "unitN:accounts")

	$entry.setSubset("activeAccounts")
	$entry.setMainViewLabel("Active accounts")

	$entry.setValidationRule("glac"; "entryField_glac"; "mandatory"; "trimSpace"; "unique"; "message:The account number is mandatory and unique")
	$entry.setValidationRule("description"; "entryField_description"; "mandatory"; "trimSpace"; "message:The account name is mandatory")

	$entry.setItemListAction("Trial balance..."; "_ga_trialBalance")
	$entry.setItemListAction("Closing date..."; "_ga_setClosingDate")

	$entry.enableTransaction()
	$entry.activateFavorite()

	// MARK: -Views
	$view:=cs:C1710.sfw_definitionView.new("balanceSheetAccounts"; "Balance sheet accounts"; "derivedFrom:main"; $entry)
	$view.setSubset("balanceSheetAccounts")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("profitAndLossAccounts"; "Profit and loss accounts"; "derivedFrom:main"; $entry)
	$view.setSubset("profitAndLossAccounts")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("accountsWithARole"; "Accounts with a role"; "derivedFrom:main"; $entry)
	$view.setSubset("accountsWithARole")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("inactiveAccounts"; "Inactive accounts"; "derivedFrom:main"; $entry)
	$view.setSubset("inactiveAccounts")
	$entry.setView($view)


Function activeAccounts()->$accounts : cs:C1710.GLAccountSelection
	$accounts:=This:C1470.query("removed = :1"; False:C215)

Function inactiveAccounts()->$accounts : cs:C1710.GLAccountSelection
	$accounts:=This:C1470.query("removed = :1"; True:C214)

Function balanceSheetAccounts()->$accounts : cs:C1710.GLAccountSelection
	$accounts:=This:C1470.query("removed = :1 AND accountTypeCode in :2"; False:C215; New collection:C1472(1; 2; 4))

Function profitAndLossAccounts()->$accounts : cs:C1710.GLAccountSelection
	$accounts:=This:C1470.query("removed = :1 AND accountTypeCode in :2"; False:C215; New collection:C1472(8; 16))

Function accountsWithARole()->$accounts : cs:C1710.GLAccountSelection
	$accounts:=This:C1470.query("defaultKey # :1"; "")

	// The active accounts as a pop-up menu, one sub-menu per type, each item's parameter being
	// the account UUID. $selectedUUID gets the check mark.
Function accountMenu($selectedUUID : Text)->$menu : Text
	var $type : Object
	var $sub : Text
	var $account : cs:C1710.GLAccountEntity
	var $accounts : cs:C1710.GLAccountSelection

	$menu:=Create menu:C408
	For each ($type; cs:C1710.ga_ledger.me.accountTypes())
		$accounts:=This:C1470.query("removed = :1 AND accountType = :2"; False:C215; $type.name).orderBy("glac asc")
		If ($accounts.length=0)
			continue
		End if
		$sub:=Create menu:C408
		For each ($account; $accounts)
			APPEND MENU ITEM:C411($sub; $account.label; *)
			SET MENU ITEM PARAMETER:C1004($sub; -1; $account.UUID)
			If ($account.UUID=$selectedUUID)
				SET MENU ITEM MARK:C208($sub; -1; Char:C90(18))
			End if
		End for each
		APPEND MENU ITEM:C411($menu; $type.name+" - "+String:C10($accounts.length); $sub)
		RELEASE MENU:C978($sub)
	End for each
