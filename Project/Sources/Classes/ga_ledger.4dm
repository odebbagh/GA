// ga_ledger: the general ledger. This class is the ONLY code that writes journal lines
// (JournalLine), the same way ga_stock is the only code that moves stock.
//
// The words, for someone new to accounting:
// - An ACCOUNT (GLAccount) is a named bucket of money: "Bank", "Accounts receivable" (what
//   customers owe us), "Sales", "Rent"... Each has a family (accountTypeCode):
//     1 asset (what we own), 2 liability (what we owe), 4 equity (what belongs to the owners),
//     8 income (what we earn), 16 expense (what we spend).
// - A JOURNAL ENTRY (JournalEntry) is one event written in the books: a date, a memo and at
//   least two LINES. Each line puts an amount on one account, either in the DEBIT column (left)
//   or the CREDIT column (right). The debits of an entry always equal its credits: money always
//   comes from somewhere and goes somewhere ("double entry").
// - Assets and expenses grow with a debit; liabilities, equity and income grow with a credit.
//   So the BALANCE of an account is debits - credits for families 1 and 16, and
//   credits - debits for families 2, 4 and 8 (normalSign).
// - Balance sheet accounts (1, 2, 4) add up since the very beginning: the bank balance today
//   is everything that ever went in or out. Profit and loss accounts (8, 16) start again at 0
//   each fiscal year; the profit of the past years is in "retained earnings" (an equity account).
// - The CLOSING DATE locks the books: nothing dated on or before it can be written, changed or
//   voided, so the figures already reported stay as they were.
//
// Every entry remembers the document that created it (sourceDataclass + UUID_Source), so a
// report figure can be followed back to its invoice, bill or payment. Manual entries are their
// own source (sourceDataclass "JournalEntry").
//
// A plain .save() from a service or an import does not run the sfw callbacks, so the modules
// call ga_ledger themselves (post / unpost). Inside a panel, the lines are written in the sfw
// transaction of the panel: Cancel rolls them back with the rest.
singleton Class constructor
	This:C1470._noUUID:="0"*32


	// MARK: - Reference lists

	// The account types, with their family. These are the QuickBooks types the legacy chart of
	// accounts already used ([CHART_OF_AC]AccountType), so the imported accounts fit as they are.
Function accountTypes()->$types : Collection
	$types:=New collection:C1472(\
		New object:C1471("name"; "Bank"; "code"; 1); \
		New object:C1471("name"; "Accounts Receivable"; "code"; 1); \
		New object:C1471("name"; "Other Current Asset"; "code"; 1); \
		New object:C1471("name"; "Fixed Asset"; "code"; 1); \
		New object:C1471("name"; "Other Asset"; "code"; 1); \
		New object:C1471("name"; "Accounts Payable"; "code"; 2); \
		New object:C1471("name"; "Credit Card"; "code"; 2); \
		New object:C1471("name"; "Other Current Liability"; "code"; 2); \
		New object:C1471("name"; "Long Term Liability"; "code"; 2); \
		New object:C1471("name"; "Equity"; "code"; 4); \
		New object:C1471("name"; "Income"; "code"; 8); \
		New object:C1471("name"; "Other Income"; "code"; 8); \
		New object:C1471("name"; "Cost Of Goods Sold"; "code"; 16); \
		New object:C1471("name"; "Expense"; "code"; 16); \
		New object:C1471("name"; "Other Expense"; "code"; 16))

Function typeCode($accountType : Text)->$code : Integer
	var $type : Object
	$type:=This:C1470.accountTypes().query("name = :1"; $accountType).first()
	$code:=($type=Null:C1517) ? 0 : $type.code

Function familyName($code : Integer)->$name : Text
	Case of
		: ($code=1)
			$name:="Asset"
		: ($code=2)
			$name:="Liability"
		: ($code=4)
			$name:="Equity"
		: ($code=8)
			$name:="Income"
		: ($code=16)
			$name:="Expense"
		Else
			$name:="?"
	End case

	// +1: the balance is debits - credits (assets, expenses); -1: credits - debits (the others)
Function normalSign($code : Integer)->$sign : Integer
	$sign:=(($code=1) || ($code=16)) ? 1 : -1

	// balance sheet (adds up forever) or profit and loss (starts again each fiscal year)
Function isProfitAndLoss($code : Integer)->$isPL : Boolean
	$isPL:=($code=8) || ($code=16)

	// The roles an account can play, so documents never ask "which account?". The keys are the
	// legacy [CHART_OF_AC]DefaultKey values (spelling kept, so the import matches), plus the
	// QuickBooks ones the legacy did not have (UndepositedFunds, DefaultFreightIncome,
	// DefaultSalesDiscounts).
Function defaultKeys()->$keys : Collection
	$keys:=New collection:C1472(\
		New object:C1471("key"; "DefaultA/R"; "label"; "Accounts receivable (what customers owe)"); \
		New object:C1471("key"; "DefaultA/P"; "label"; "Accounts payable (what we owe vendors)"); \
		New object:C1471("key"; "UndepositedFunds"; "label"; "Undeposited funds (payments not yet at the bank)"); \
		New object:C1471("key"; "DefaultBank"; "label"; "Default bank account (deposits, checks)"); \
		New object:C1471("key"; "DefaultSales"; "label"; "Sales (income of the invoices)"); \
		New object:C1471("key"; "DefaultFreightIncome"; "label"; "Freight billed to customers"); \
		New object:C1471("key"; "DefaultSalesTaxPayable"; "label"; "Sales tax payable (collected for the state)"); \
		New object:C1471("key"; "DefaultCreditMemos"; "label"; "Credit memos (income given back)"); \
		New object:C1471("key"; "DefaultCustomerReturns"; "label"; "Customer returns"); \
		New object:C1471("key"; "DefaultCustomerAdvance"; "label"; "Customer advances (paid before the invoice)"); \
		New object:C1471("key"; "DefaultSalesDiscounts"; "label"; "Sales discounts (early payment discounts customers take)"); \
		New object:C1471("key"; "UnassignedIncome"; "label"; "Unassigned income"); \
		New object:C1471("key"; "DefaultDisountIncome"; "label"; "Discounts earned (early payment of bills)"); \
		New object:C1471("key"; "DefaultBillCredits"; "label"; "Vendor credits"); \
		New object:C1471("key"; "DefaultPurchases"; "label"; "Purchases (expense of the bills)"); \
		New object:C1471("key"; "DefaultInventory"; "label"; "Inventory (stock we own)"); \
		New object:C1471("key"; "DefaultCOGS"; "label"; "Cost of goods sold (stock used on jobs)"); \
		New object:C1471("key"; "DefaultWIP"; "label"; "Work in progress"); \
		New object:C1471("key"; "DefaultFixedAssets"; "label"; "Fixed assets (equipment)"); \
		New object:C1471("key"; "DefaultAccumulatedDepreciation"; "label"; "Accumulated depreciation"); \
		New object:C1471("key"; "DefaultDepreciation"; "label"; "Depreciation expense"); \
		New object:C1471("key"; "DefaultAssetWriteOff"; "label"; "Asset write-off"); \
		New object:C1471("key"; "DefaultInterestExpense"; "label"; "Interest expense"); \
		New object:C1471("key"; "DefaultAccuredInterest"; "label"; "Accrued interest"); \
		New object:C1471("key"; "DefaultMiscExpense"; "label"; "Miscellaneous expense (reconciliation differences)"); \
		New object:C1471("key"; "DefaultClearingAccount"; "label"; "Internal clearing account"); \
		New object:C1471("key"; "DefaultEquity"; "label"; "Opening balance equity"); \
		New object:C1471("key"; "DefaultRetainedEarnings"; "label"; "Retained earnings (profit of past years)"); \
		New object:C1471("key"; "DefaultNetIncome"; "label"; "Net income"); \
		New object:C1471("key"; "DefaultFederalIncomeTaxExpense"; "label"; "Federal income tax expense"); \
		New object:C1471("key"; "DefaultFederalIncomeTaxPayable"; "label"; "Federal income tax payable"); \
		New object:C1471("key"; "DefaultStateIncomeTaxExpense"; "label"; "State income tax expense"); \
		New object:C1471("key"; "DefaultStateIncomeTaxPayable"; "label"; "State income tax payable"))

Function defaultKeyLabel($key : Text)->$label : Text
	var $o : Object
	$o:=This:C1470.defaultKeys().query("key = :1"; $key).first()
	$label:=($o=Null:C1517) ? $key : $o.label


	// MARK: - Accounts

	// The account that plays the role $key for the division: the one of the division first, then
	// one with no division (or a division that does not exist, as the legacy "ALL").
Function defaultAccount($key : Text; $divisionUUID : Text)->$account : cs:C1710.GLAccountEntity
	var $candidates : cs:C1710.GLAccountSelection
	var $candidate : cs:C1710.GLAccountEntity
	$candidates:=ds:C1482.GLAccount.query("defaultKey = :1 AND removed = :2"; $key; False:C215)
	If ($candidates.length=0)
		return
	End if
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($divisionUUID)))
		$account:=$candidates.query("UUID_Division = :1"; $divisionUUID).first()
	End if
	If ($account=Null:C1517)
		For each ($candidate; $candidates)
			If (cs:C1710.sfw_string.me.isAnEmptyUUID($candidate.UUID_Division)) || ($candidate.division=Null:C1517)
				$account:=$candidate
				break
			End if
		End for each
	End if
	If ($account=Null:C1517)
		$account:=$candidates.first()
	End if

Function accountByGlac($glac : Text)->$account : cs:C1710.GLAccountEntity
	If ($glac#"")
		$account:=ds:C1482.GLAccount.query("glac = :1"; $glac).first()
	End if


	// MARK: - Closing date and fiscal year (sfw_Setting)

	// The last locked day; !00-00-00! when the books were never closed
Function closingDate()->$date : Date
	var $setting : cs:C1710.sfw_SettingEntity
	$setting:=ds:C1482.sfw_Setting.query("ident = :1"; "AccountingClosingDate").first()
	If ($setting#Null:C1517) && ($setting.data#Null:C1517) && (Num:C11($setting.data.stmp)#0)
		$date:=cs:C1710.sfw_stmp.me.getDate(Num:C11($setting.data.stmp))
	End if

Function setClosingDate($date : Date)->$result : Object
	var $setting : cs:C1710.sfw_SettingEntity
	$setting:=ds:C1482.sfw_Setting.query("ident = :1"; "AccountingClosingDate").first()
	If ($setting=Null:C1517)
		$setting:=ds:C1482.sfw_Setting.new()
		$setting.ident:="AccountingClosingDate"
		$setting.name:="Accounting closing date"
	End if
	$setting.data:=New object:C1471("stmp"; ($date=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($date; ?00:00:00?); \
		"setBy"; String:C10(cs:C1710.sfw_userManager.me.info.name); "setAt"; cs:C1710.sfw_stmp.me.now())
	$setting.stmpLastModif:=cs:C1710.sfw_stmp.me.now()
	$result:=$setting.save()

	// True when an entry dated $date may be written, changed or voided
Function isOpen($date : Date)->$open : Boolean
	$open:=($date#!00-00-00!) && ($date>This:C1470.closingDate())

	// Month (1-12) the fiscal year starts with: sfw_Setting "AccountingFiscalYearStart",
	// data.month; January when not set
Function fiscalYearStartMonth()->$month : Integer
	var $setting : cs:C1710.sfw_SettingEntity
	$setting:=ds:C1482.sfw_Setting.query("ident = :1"; "AccountingFiscalYearStart").first()
	$month:=1
	If ($setting#Null:C1517) && ($setting.data#Null:C1517)
		If (Num:C11($setting.data.month)>=1) && (Num:C11($setting.data.month)<=12)
			$month:=Num:C11($setting.data.month)
		End if
	End if

	// The first day of the fiscal year $date is in
Function fiscalYearStart($date : Date)->$start : Date
	var $month; $year : Integer
	$month:=This:C1470.fiscalYearStartMonth()
	$year:=Year of:C25($date)
	If (Month of:C24($date)<$month)
		$year:=$year-1
	End if
	$start:=Add to date:C393(!2000-01-01!; $year-2000; $month-1; 0)


	// MARK: - Writing

	// A new journal entry, not saved: next number, today, no source, no division
Function newEntry($type : Text)->$entry : cs:C1710.JournalEntryEntity
	$entry:=ds:C1482.JournalEntry.new()
	If ($entry.UUID=Null:C1517) || ($entry.UUID="")
		$entry.UUID:=Generate UUID:C1066
	End if
	$entry.number:=ds:C1482.sfw_Counter.getNextValue("JournalEntry")
	$entry.type:=$type
	$entry.entryStmp:=cs:C1710.sfw_stmp.me.build(Current date:C33; ?00:00:00?)
	$entry.sourceDataclass:=""
	$entry.UUID_Source:=This:C1470._noUUID
	$entry.UUID_Division:=This:C1470._noUUID
	$entry.UUID_User:=This:C1470._currentUserUUID()

	// The problems of a set of lines dated $date ($result.errors, empty when they can be written).
	// A line is an object {UUID_GLAccount; debit; credit; memo; UUID_Division; UUID_Customer;
	// UUID_Supplier}; a line with no account and no amount (an empty row of the panel) is skipped.
Function checkLines($lines : Collection; $date : Date)->$result : Object
	var $line : Object
	var $debit; $credit; $totalDebit; $totalCredit : Real
	var $count; $num : Integer
	var $account : cs:C1710.GLAccountEntity
	var $errors : Collection

	$errors:=New collection:C1472
	If ($date=!00-00-00!)
		$errors.push("The entry has no date.")
	Else
		If (Not:C34(This:C1470.isOpen($date)))
			$errors.push("The books are closed up to "+String:C10(This:C1470.closingDate())+": nothing dated "+String:C10($date)+" can be written or changed.")
		End if
	End if

	For each ($line; $lines)
		$num:=$num+1
		$debit:=Round:C94(Num:C11($line.debit); 2)
		$credit:=Round:C94(Num:C11($line.credit); 2)
		If (This:C1470._isBlankLine($line))
			continue
		End if
		$count:=$count+1
		If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($line.UUID_GLAccount)))
			$errors.push("Line "+String:C10($num)+": no account.")
		Else
			$account:=ds:C1482.GLAccount.get($line.UUID_GLAccount)
			Case of
				: ($account=Null:C1517)
					$errors.push("Line "+String:C10($num)+": the account does not exist any more.")
				: ($account.removed)
					$errors.push("Line "+String:C10($num)+": account "+$account.label+" is inactive.")
			End case
		End if
		Case of
			: ($debit<0) || ($credit<0)
				$errors.push("Line "+String:C10($num)+": amounts are never negative (use the other column).")
			: ($debit#0) && ($credit#0)
				$errors.push("Line "+String:C10($num)+": a line is either a debit or a credit, not both.")
			: ($debit=0) && ($credit=0)
				$errors.push("Line "+String:C10($num)+": no amount.")
		End case
		$totalDebit:=$totalDebit+$debit
		$totalCredit:=$totalCredit+$credit
	End for each

	If ($count<2)
		$errors.push("An entry needs at least two lines (one account receives, another gives).")
	End if
	If (Round:C94($totalDebit-$totalCredit; 2)#0)
		$errors.push("Debits ("+String:C10($totalDebit; "###,###,##0.00")+") and credits ("+String:C10($totalCredit; "###,###,##0.00")+") differ by "+String:C10(Abs:C99($totalDebit-$totalCredit); "###,###,##0.00")+".")
	End if
	$result:=New object:C1471("success"; $errors.length=0; "errors"; $errors; "totalDebit"; Round:C94($totalDebit; 2); "totalCredit"; Round:C94($totalCredit; 2))

	// Replaces the lines of $entry with $lines and saves the entry. Nothing is written when the
	// lines have a problem ($result.success False, $result.errors).
Function writeLines($entry : cs:C1710.JournalEntryEntity; $lines : Collection)->$result : Object
	var $line : Object
	var $eLine : cs:C1710.JournalLineEntity
	var $save : Object
	var $num : Integer
	var $date : Date

	$date:=$entry.date
	$result:=This:C1470.checkLines($lines; $date)
	If (Not:C34($result.success))
		return
	End if
	If ($entry.UUID=Null:C1517) || ($entry.UUID="")
		$entry.UUID:=Generate UUID:C1066
	End if
	$entry.isVoid:=False:C215
	$entry.totalAmount:=$result.totalDebit
	$save:=$entry.save()
	If (Not:C34($save.success))
		$result.success:=False:C215
		$result.errors.push("The entry could not be saved: "+String:C10($save.statusText))
		return
	End if

	This:C1470._dropLines($entry)
	For each ($line; $lines)
		If (This:C1470._isBlankLine($line))
			continue
		End if
		$num:=$num+1
		$eLine:=ds:C1482.JournalLine.new()
		$eLine.UUID_JournalEntry:=$entry.UUID
		$eLine.UUID_GLAccount:=$line.UUID_GLAccount
		$eLine.lineNum:=$num
		$eLine.debit:=Round:C94(Num:C11($line.debit); 2)
		$eLine.credit:=Round:C94(Num:C11($line.credit); 2)
		$eLine.memo:=String:C10($line.memo)
		$eLine.UUID_Division:=This:C1470._uuidOr($line.UUID_Division; $entry.UUID_Division)
		$eLine.UUID_Customer:=This:C1470._uuidOr($line.UUID_Customer; This:C1470._noUUID)
		$eLine.UUID_Supplier:=This:C1470._uuidOr($line.UUID_Supplier; This:C1470._noUUID)
		$eLine.lineStmp:=$entry.entryStmp
		$eLine.cleared:=Bool:C1537($line.cleared)
		$save:=$eLine.save()
		If (Not:C34($save.success))
			$result.success:=False:C215
			$result.errors.push("Line "+String:C10($num)+" could not be saved: "+String:C10($save.statusText))
		End if
	End for each

	// The entry of a document, written or rewritten. The modules call this when a document is
	// saved (later phases: invoice, payment, bill...). $spec:
	//   type             "Invoice", "Payment"... (one document may have entries of several types)
	//   sourceDataclass  the dataclass of the document, e.g. "JobInvoice"
	//   sourceUUID       its UUID
	//   date             the accounting date
	//   memo, divisionUUID
	//   lines            the lines (see checkLines); an empty collection voids the entry
Function post($spec : Object)->$result : Object
	var $entry : cs:C1710.JournalEntryEntity

	$entry:=This:C1470.entriesOf($spec.sourceDataclass; $spec.sourceUUID).query("type = :1"; $spec.type).first()
	If (($spec.lines=Null:C1517) || ($spec.lines.length=0))
		If ($entry=Null:C1517)
			$result:=New object:C1471("success"; True:C214; "errors"; New collection:C1472)
		Else
			$result:=This:C1470.voidEntry($entry)
		End if
		return
	End if

	If ($entry=Null:C1517)
		$entry:=This:C1470.newEntry($spec.type)
		$entry.sourceDataclass:=$spec.sourceDataclass
		$entry.UUID_Source:=$spec.sourceUUID
	Else
		If (Not:C34(This:C1470.isOpen($entry.date)))
			$result:=New object:C1471("success"; False:C215; "errors"; New collection:C1472("The entry #"+String:C10($entry.number)+" is dated in a closed period ("+String:C10($entry.date)+"): it cannot be changed."))
			return
		End if
	End if
	$entry.date:=$spec.date
	$entry.memo:=String:C10($spec.memo)
	$entry.UUID_Division:=This:C1470._uuidOr($spec.divisionUUID; This:C1470._noUUID)
	$result:=This:C1470.writeLines($entry; $spec.lines)

	// Voids an entry: its lines are removed (the amounts no longer count), the entry stays with
	// its number, marked void, so the numbering has no hole. Refused in a closed period.
Function voidEntry($entry : cs:C1710.JournalEntryEntity)->$result : Object
	var $save : Object
	If (Not:C34(This:C1470.isOpen($entry.date)))
		$result:=New object:C1471("success"; False:C215; "errors"; New collection:C1472("The entry #"+String:C10($entry.number)+" is dated in a closed period ("+String:C10($entry.date)+"): it cannot be voided."))
		return
	End if
	This:C1470._dropLines($entry)
	$entry.isVoid:=True:C214
	$entry.totalAmount:=0
	$save:=$entry.save()
	$result:=New object:C1471("success"; $save.success; "errors"; New collection:C1472)
	If (Not:C34($save.success))
		$result.errors.push("The entry could not be saved: "+String:C10($save.statusText))
	End if

	// Voids the entries of a document (e.g. an invoice put back to draft)
Function unpost($sourceDataclass : Text; $sourceUUID : Text)->$result : Object
	var $entry : cs:C1710.JournalEntryEntity
	var $one : Object
	$result:=New object:C1471("success"; True:C214; "errors"; New collection:C1472)
	For each ($entry; This:C1470.entriesOf($sourceDataclass; $sourceUUID).query("isVoid = :1"; False:C215))
		$one:=This:C1470.voidEntry($entry)
		$result.success:=$result.success && $one.success
		$result.errors.combine($one.errors)
	End for each

Function entriesOf($sourceDataclass : Text; $sourceUUID : Text)->$entries : cs:C1710.JournalEntrySelection
	$entries:=ds:C1482.JournalEntry.query("sourceDataclass = :1 AND UUID_Source = :2"; $sourceDataclass; $sourceUUID)


	// MARK: - Reading

	// The balance of an account at the end of $asOf, on its normal side (a positive bank
	// balance is money in the bank). Profit and loss accounts count from the start of the
	// fiscal year of $asOf. $divisionUUID empty: every division.
Function accountBalance($account : cs:C1710.GLAccountEntity; $asOf : Date; $divisionUUID : Text)->$balance : Real
	var $lines : cs:C1710.JournalLineSelection
	$lines:=This:C1470._lines($account.UUID; $asOf; $divisionUUID)
	If (This:C1470.isProfitAndLoss($account.accountTypeCode))
		$lines:=$lines.query("lineStmp >= :1"; cs:C1710.sfw_stmp.me.build(This:C1470.fiscalYearStart($asOf); ?00:00:00?))
	End if
	$balance:=Round:C94(($lines.sum("debit")-$lines.sum("credit"))*This:C1470.normalSign($account.accountTypeCode); 2)

	// The trial balance at the end of $asOf: every account with a balance, in the debit or the
	// credit column. The two totals must be equal - that is the proof the books balance.
	// The profit of the past fiscal years (income - expenses before the start of the fiscal year)
	// is shown on the retained earnings account, as QuickBooks does.
	// $result: {asOf; fiscalYearStart; rows; totalDebit; totalCredit; balanced; priorYearsProfit}
Function trialBalance($asOf : Date; $divisionUUID : Text)->$result : Object
	var $lines : Collection
	var $line; $row; $byAccount : Object
	var $account; $retained : cs:C1710.GLAccountEntity
	var $fyStart : Integer
	var $net; $prior : Real
	var $key : Text
	var $rows : Collection

	$fyStart:=cs:C1710.sfw_stmp.me.build(This:C1470.fiscalYearStart($asOf); ?00:00:00?)
	$lines:=This:C1470._lines(""; $asOf; $divisionUUID).toCollection("UUID_GLAccount,debit,credit,lineStmp,account.accountTypeCode")
	$byAccount:=New object:C1471
	For each ($line; $lines)
		If ($line.account=Null:C1517)
			continue
		End if
		$net:=Num:C11($line.debit)-Num:C11($line.credit)
		If (This:C1470.isProfitAndLoss(Num:C11($line.account.accountTypeCode))) && ($line.lineStmp<$fyStart)
			$prior:=$prior+$net  // last years' profit, as a debit - credit: negative = profit
			continue
		End if
		$byAccount[$line.UUID_GLAccount]:=Num:C11($byAccount[$line.UUID_GLAccount])+$net
	End for each

	If (Round:C94($prior; 2)#0)
		$retained:=This:C1470.defaultAccount("DefaultRetainedEarnings"; $divisionUUID)
		If ($retained#Null:C1517)
			$byAccount[$retained.UUID]:=Num:C11($byAccount[$retained.UUID])+$prior
		End if
	End if

	$rows:=New collection:C1472
	For each ($key; OB Keys:C1719($byAccount))
		$net:=Round:C94($byAccount[$key]; 2)
		If ($net=0)
			continue
		End if
		$account:=ds:C1482.GLAccount.get($key)
		$row:=New object:C1471(\
			"UUID_GLAccount"; $key; \
			"glac"; ($account=Null:C1517) ? "?" : $account.glac; \
			"description"; ($account=Null:C1517) ? "(deleted account)" : $account.description; \
			"accountType"; ($account=Null:C1517) ? "" : $account.accountType; \
			"family"; This:C1470.familyName(($account=Null:C1517) ? 0 : $account.accountTypeCode); \
			"typeCode"; ($account=Null:C1517) ? 99 : $account.accountTypeCode; \
			"debit"; ($net>0) ? $net : 0; \
			"credit"; ($net<0) ? -$net : 0)
		$rows.push($row)
	End for each
	$rows:=$rows.orderBy("typeCode asc, glac asc")

	$result:=New object:C1471(\
		"asOf"; $asOf; \
		"fiscalYearStart"; This:C1470.fiscalYearStart($asOf); \
		"rows"; $rows; \
		"totalDebit"; Round:C94($rows.sum("debit"); 2); \
		"totalCredit"; Round:C94($rows.sum("credit"); 2); \
		"priorYearsProfit"; Round:C94(-$prior; 2); \
		"retainedEarningsMissing"; (Round:C94($prior; 2)#0) && ($retained=Null:C1517))
	$result.balanced:=($result.totalDebit=$result.totalCredit)

	// The register of an account between $from and $to: the opening balance, then each line
	// with a running balance (on the account's normal side). Each row carries the entry and its
	// source, to open them.
Function register($account : cs:C1710.GLAccountEntity; $from : Date; $to : Date; $divisionUUID : Text)->$result : Object
	var $sign : Integer
	var $opening; $running : Real
	var $before; $period : cs:C1710.JournalLineSelection
	var $eLine : cs:C1710.JournalLineEntity
	var $rows : Collection
	var $startStmp : Integer

	$sign:=This:C1470.normalSign($account.accountTypeCode)
	$startStmp:=cs:C1710.sfw_stmp.me.build($from; ?00:00:00?)
	$before:=This:C1470._lines($account.UUID; Add to date:C393($from; 0; 0; -1); $divisionUUID)
	If (This:C1470.isProfitAndLoss($account.accountTypeCode))
		$before:=$before.query("lineStmp >= :1"; cs:C1710.sfw_stmp.me.build(This:C1470.fiscalYearStart($from); ?00:00:00?))
	End if
	$opening:=Round:C94(($before.sum("debit")-$before.sum("credit"))*$sign; 2)

	$period:=This:C1470._lines($account.UUID; $to; $divisionUUID).query("lineStmp >= :1"; $startStmp).orderBy("lineStmp asc, journalEntry.number asc, lineNum asc")
	$rows:=New collection:C1472
	$running:=$opening
	For each ($eLine; $period)
		$running:=Round:C94($running+(($eLine.debit-$eLine.credit)*$sign); 2)
		$rows.push(New object:C1471(\
			"date"; cs:C1710.sfw_stmp.me.getDate($eLine.lineStmp); \
			"number"; $eLine.journalEntry.number; \
			"type"; $eLine.journalEntry.type; \
			"memo"; ($eLine.memo#"") ? $eLine.memo : $eLine.journalEntry.memo; \
			"debit"; $eLine.debit; \
			"credit"; $eLine.credit; \
			"balance"; $running; \
			"UUID_JournalEntry"; $eLine.UUID_JournalEntry; \
			"sourceDataclass"; $eLine.journalEntry.sourceDataclass; \
			"UUID_Source"; $eLine.journalEntry.UUID_Source))
	End for each
	$result:=New object:C1471("opening"; $opening; "closing"; $running; "rows"; $rows; \
		"totalDebit"; Round:C94($period.sum("debit"); 2); "totalCredit"; Round:C94($period.sum("credit"); 2))


	// MARK: - Private

	// the lines up to the end of $asOf, of one account ($accountUUID "": all) and one division
	// ("": all). Lines of void entries do not exist (voidEntry removes them).
Function _lines($accountUUID : Text; $asOf : Date; $divisionUUID : Text)->$lines : cs:C1710.JournalLineSelection
	var $endStmp : Integer
	$endStmp:=cs:C1710.sfw_stmp.me.build($asOf; ?23:59:59?)
	$lines:=ds:C1482.JournalLine.query("lineStmp <= :1"; $endStmp)
	If ($accountUUID#"")
		$lines:=$lines.query("UUID_GLAccount = :1"; $accountUUID)
	End if
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($divisionUUID)))
		$lines:=$lines.query("UUID_Division = :1"; $divisionUUID)
	End if

Function _dropLines($entry : cs:C1710.JournalEntryEntity)
	var $existing : cs:C1710.JournalLineSelection
	$existing:=ds:C1482.JournalLine.query("UUID_JournalEntry = :1"; $entry.UUID)
	If ($existing.length>0)
		$existing.drop()
	End if

Function _isBlankLine($line : Object)->$blank : Boolean
	$blank:=cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($line.UUID_GLAccount)) && (Round:C94(Num:C11($line.debit); 2)=0) && (Round:C94(Num:C11($line.credit); 2)=0)

Function _uuidOr($value : Variant; $default : Text)->$uuid : Text
	$uuid:=String:C10($value)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($uuid))
		$uuid:=$default
	End if

Function _currentUserUUID()->$uuid : Text
	$uuid:=This:C1470._noUUID
	If (cs:C1710.sfw_userManager.me.info#Null:C1517) && (String:C10(cs:C1710.sfw_userManager.me.info.UUID)#"")
		$uuid:=cs:C1710.sfw_userManager.me.info.UUID
	End if
