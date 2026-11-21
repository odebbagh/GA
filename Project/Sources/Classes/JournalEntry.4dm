// JournalEntry: one event written in the books (see ga_ledger for the words). An entry is a date,
// a memo and lines (JournalLine) whose debits equal their credits.
// - Manual entries (type "Manual") and opening balances (type "Opening") are typed here, in the
//   Journal Entries panel. Their source is themselves (sourceDataclass "JournalEntry").
// - The other entries are written by the modules through ga_ledger.post when a document is saved
//   (invoice, payment, bill...). They are shown here read-only and change only with their document.
// An entry is never deleted: it is voided (its lines are removed, its number stays).
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	var $view : cs:C1710.sfw_definitionView

	$entry:=cs:C1710.sfw_definitionEntry.new("journalEntries"; ["accounting"]; "Journal Entries"; "Journal Entry")
	$entry.setDataclass("JournalEntry")
	$entry.setDisplayOrder(-130)
	$entry.setIcon("image/entry/journalEntry-white-50x50.png")

	$entry.setSearchboxField("memo")
	$entry.setSearchboxField("type")

	$entry.setPanel("panel_journalEntry")
	$entry.setPanelPage(1; ""; "Entry")

	$entry.setLBItemsColumn("number"; "#"; "width:60"; "right"; "headerRight")
	$entry.setLBItemsColumn("date"; "Date"; "width:90"; "type:date")
	$entry.setLBItemsColumn("typeText"; "Type"; "width:110")
	$entry.setLBItemsColumn("memo"; "Memo"; "width:320")
	$entry.setLBItemsColumn("totalAmount"; "Amount"; "width:110"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00")
	$entry.setLBItemsColumn("statusText"; "Status"; "width:70")

	$entry.setLBItemsOrderBy("number desc")
	$entry.setLBItemsOrderBy("entryStmp desc")
	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:entry"; "unitN:entries")

	$entry.setMainViewLabel("All entries")

	$entry.setItemAction("Void the entry"; "_ga_voidJournalEntry"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification()) && Form.current_item.canBeVoided")
	$entry.setItemListAction("Trial balance..."; "_ga_trialBalance")
	$entry.setItemListAction("Closing date..."; "_ga_setClosingDate")

	$entry.enableTransaction()
	$entry.activateFavorite()

	// MARK: -Views
	$view:=cs:C1710.sfw_definitionView.new("manualJournalEntries"; "Manual entries"; "derivedFrom:main"; $entry)
	$view.setSubset("manualEntries")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("openingJournalEntries"; "Opening balances"; "derivedFrom:main"; $entry)
	$view.setSubset("openingEntries")
	$entry.setView($view)

	$view:=cs:C1710.sfw_definitionView.new("voidJournalEntries"; "Void entries"; "derivedFrom:main"; $entry)
	$view.setSubset("voidEntries")
	$entry.setView($view)


Function manualEntries()->$entries : cs:C1710.JournalEntrySelection
	$entries:=This:C1470.query("type = :1"; "Manual")

Function openingEntries()->$entries : cs:C1710.JournalEntrySelection
	$entries:=This:C1470.query("type = :1"; "Opening")

Function voidEntries()->$entries : cs:C1710.JournalEntrySelection
	$entries:=This:C1470.query("isVoid = :1"; True:C214)

	// the types a user may give an entry typed in the panel
Function manualTypes()->$types : Collection
	$types:=New collection:C1472(\
		New object:C1471("type"; "Manual"; "label"; "Manual entry"; "help"; "A correction or an event no document records (a bank fee, a reclassification...)."); \
		New object:C1471("type"; "Opening"; "label"; "Opening balance"; "help"; "The balances taken over from the legacy books on the start date: one line per account, the difference on Opening balance equity."))
