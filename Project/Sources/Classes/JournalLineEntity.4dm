// JournalLineEntity: one line of a journal entry, an amount on one account, in the debit OR the
// credit column (see ga_ledger). Written only by ga_ledger.
Class extends Entity

local Function get accountLabel()->$label : Text
	$label:=(This:C1470.account=Null:C1517) ? "" : This:C1470.account.label

local Function get date()->$date : Date
	$date:=(This:C1470.lineStmp=0) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.lineStmp)

	// the line as panel_journalEntry edits it (the same shape ga_ledger.writeLines reads)
Function rowForPanel()->$row : Object
	$row:=New object:C1471(\
		"UUID_GLAccount"; This:C1470.UUID_GLAccount; \
		"glac"; (This:C1470.account=Null:C1517) ? "" : This:C1470.account.glac; \
		"accountLabel"; This:C1470.accountLabel; \
		"debit"; This:C1470.debit; \
		"credit"; This:C1470.credit; \
		"memo"; This:C1470.memo; \
		"UUID_Division"; This:C1470.UUID_Division; \
		"UUID_Customer"; This:C1470.UUID_Customer; \
		"UUID_Supplier"; This:C1470.UUID_Supplier; \
		"cleared"; This:C1470.cleared)
