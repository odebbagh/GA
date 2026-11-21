//%attributes = {}
// _import_openingBalances
// Starts the new books where the legacy ones stop: reads Project/imports/openingBalances_export.json
// (legacy _export_openingBalances: the balance of every account at a month end) and writes ONE
// journal entry of type "Opening", dated that month end, with one line per balance sheet account.
//
// For someone new to accounting:
// - Balance sheet accounts (asset, liability, equity) carry their balance from one day to the next
//   (the money in the bank on 30 April is still there on 1 May), so they are taken over.
// - Income and expense accounts measure a period: they start at 0 in the new books. The profit
//   made before the cutover is already inside the equity accounts (retained earnings, net income).
// - The legacy amount is on the account's natural side, so it goes in the account's normal column:
//   a positive asset becomes a debit, a positive liability or equity a credit. A negative amount
//   (a contra account such as accumulated depreciation) goes in the other column.
// - Assets = liabilities + equity, so the debits equal the credits. A difference of a few cents
//   (rounding) goes on the account with the role "Opening balance equity"; a bigger one stops.
//
// Re-runnable: the entry it wrote before is replaced (same number). Report only / Apply, and the
// report is written to Project/imports/opening_balances.txt. After Apply it offers to set the
// closing date on the month end, so the opening balances cannot be changed by mistake.
// Needs the chart of accounts imported first (_import_glAccounts).
//
// $options (optional): {unattended: True} (_import_accounting, _import_all) - applies without
// asking, locks the books on the month end, and writes its messages to
// Project/imports/import_messages.txt. When the only thing in the way is the lock this import
// set on a previous run (closing date = the date of its own opening entry), it lifts it first.
#DECLARE($options : Object)

var $file : 4D:C1709.File
var $auto : Boolean
var $liftedLock : Date
var $data; $row; $line; $result; $save : Object
var $lines; $problems; $warnings; $report; $existing : Collection
var $periodEnd : Date
var $account; $equity : cs:C1710.GLAccountEntity
var $entry : cs:C1710.JournalEntryEntity
var $code; $sign; $plSkipped; $zeroSkipped : Integer
var $amount; $net; $totalDebit; $totalCredit; $difference : Real
var $byFamily : Object
var $summary; $key; $debitText; $creditText : Text
var $others : cs:C1710.JournalEntrySelection

$auto:=($options#Null:C1517) && Bool:C1537($options.unattended)
$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("openingBalances_export.json")
If (Not:C34($file.exists))
	_import_notify($options; "Import file not found: "+$file.platformPath+"\r\rRun _export_openingBalances in the legacy application and copy DataJson/openingBalances_export.json here.")
	return
End if
$data:=JSON Parse:C1218($file.getText())
$periodEnd:=Date:C102(Substring:C12(String:C10($data.periodEnd); 1; 10))

$problems:=New collection:C1472
$warnings:=New collection:C1472
$lines:=New collection:C1472
$byFamily:=New object:C1471

If ($periodEnd=!00-00-00!)
	$problems.push("The file has no valid periodEnd (\""+String:C10($data.periodEnd)+"\").")
End if

// MARK: - the lines
For each ($row; $data.accounts)
	$code:=Num:C11($row.accountTypeCode)
	$amount:=Round:C94(Num:C11($row.amount); 2)
	If (cs:C1710.ga_ledger.me.isProfitAndLoss($code))
		$plSkipped:=$plSkipped+1
		continue
	End if
	If ($amount=0)
		$zeroSkipped:=$zeroSkipped+1
		continue
	End if
	$account:=cs:C1710.ga_ledger.me.accountByGlac(String:C10($row.glac))
	Case of
		: ($account=Null:C1517)
			$problems.push("Account "+String:C10($row.glac)+" ("+String:C10($row.description)+", "+String:C10($amount)+") is not in the chart of accounts: run _import_glAccounts.")
			continue
		: ($account.removed)
			$problems.push("Account "+$account.label+" has a balance of "+String:C10($amount)+" but is inactive: make it active in Chart of Accounts.")
			continue
		: ($code=0)
			$problems.push("Account "+$account.label+": the legacy file gives no account type.")
			continue
		: ($account.accountTypeCode#$code)
			$problems.push("Account "+$account.label+" is "+cs:C1710.ga_ledger.me.familyName($account.accountTypeCode)+" here but "+cs:C1710.ga_ledger.me.familyName($code)+" in legacy.")
			continue
	End case
	$sign:=cs:C1710.ga_ledger.me.normalSign($code)
	$net:=$amount*$sign  // debit - credit
	$lines.push(New object:C1471(\
		"UUID_GLAccount"; $account.UUID; \
		"glac"; $account.glac; \
		"debit"; ($net>0) ? $net : 0; \
		"credit"; ($net<0) ? -$net : 0; \
		"memo"; "Legacy balance at "+String:C10($periodEnd); \
		"UUID_Division"; $account.UUID_Division))
	$key:=cs:C1710.ga_ledger.me.familyName($code)
	$byFamily[$key]:=Round:C94(Num:C11($byFamily[$key])+$amount; 2)
End for each

$totalDebit:=Round:C94($lines.sum("debit"); 2)
$totalCredit:=Round:C94($lines.sum("credit"); 2)
$difference:=Round:C94($totalDebit-$totalCredit; 2)
If ($difference#0)
	If (Abs:C99($difference)>1)
		$problems.push("The legacy balance sheet does not balance: debits "+String:C10($totalDebit; "###,###,##0.00")+" / credits "+String:C10($totalCredit; "###,###,##0.00")+" (difference "+String:C10($difference; "###,###,##0.00;-###,###,##0.00")+"). Post the month again in legacy, or ask the accountant.")
	Else
		$equity:=cs:C1710.ga_ledger.me.defaultAccount("DefaultEquity"; "")
		If ($equity=Null:C1517)
			$problems.push("A rounding difference of "+String:C10($difference)+" needs an account with the role Opening balance equity.")
		Else
			$lines.push(New object:C1471("UUID_GLAccount"; $equity.UUID; "glac"; $equity.glac; \
				"debit"; ($difference<0) ? -$difference : 0; "credit"; ($difference>0) ? $difference : 0; \
				"memo"; "Rounding difference of the legacy balances"; "UUID_Division"; $equity.UUID_Division))
			$warnings.push("Rounding difference of "+String:C10($difference)+" put on "+$equity.label+".")
		End if
	End if
End if

// MARK: - what is already in the books
$existing:=ds:C1482.JournalEntry.query("type = :1 AND isVoid = :2"; "Opening"; False:C215).toCollection("UUID,number")
If ($existing.length>1)
	$problems.push(String:C10($existing.length)+" opening entries exist (#"+$existing.extract("number").join(", #")+"): void the extra ones in Journal Entries first.")
End if
If ($existing.length=1)
	$entry:=ds:C1482.JournalEntry.get($existing[0].UUID)
	// unattended re-run: the lock this import set itself (on its own entry's date) is lifted, the
	// new import locks again on the new month end
	If ($auto) && (cs:C1710.ga_ledger.me.closingDate()=$entry.date) && ($entry.moreData#Null:C1517) && (String:C10($entry.moreData.importedBy)="_import_openingBalances")
		$liftedLock:=$entry.date
		cs:C1710.ga_ledger.me.setClosingDate(!00-00-00!)
		$warnings.push("The lock of the previous opening import ("+String:C10($entry.date)+") was lifted to replace it.")
	End if
	If ($entry.date#$periodEnd) && Not:C34(cs:C1710.ga_ledger.me.isOpen($entry.date))
		$problems.push("The current opening entry #"+String:C10($entry.number)+" is dated "+String:C10($entry.date)+", in a closed period: move the closing date back first (Closing date...).")
	End if
End if
If ($periodEnd#!00-00-00!) && Not:C34(cs:C1710.ga_ledger.me.isOpen($periodEnd))
	$problems.push("The books are closed up to "+String:C10(cs:C1710.ga_ledger.me.closingDate())+": move the closing date before "+String:C10($periodEnd)+" first (Closing date...), then run this again.")
End if
$others:=ds:C1482.JournalEntry.query("type # :1 AND isVoid = :2 AND entryStmp <= :3"; "Opening"; False:C215; cs:C1710.sfw_stmp.me.build($periodEnd; ?23:59:59?))
If ($others.length>0)
	$warnings.push(String:C10($others.length)+" other entr(y/ies) dated on or before "+String:C10($periodEnd)+" (#"+$others.extract("number").join(", #")+"): their amounts add to the legacy balances. The legacy books already contain that period.")
End if

// MARK: - report
$report:=New collection:C1472
$report.push("OPENING BALANCES - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178; HH MM:K7:2))
$report.push("File: "+$file.platformPath)
$report.push("Source: "+String:C10($data.source)+" - exported "+String:C10($data.exportedAt))
$report.push("Balances at the end of "+String:C10($periodEnd)+" (legacy books closed up to "+String:C10($data.lastClosedPeriodDate)+")")
$report.push("")
$report.push("Balance sheet accounts taken over: "+String:C10($lines.length)+" lines - zero balances skipped: "+String:C10($zeroSkipped)+" - income/expense accounts left at 0: "+String:C10($plSkipped))
For each ($key; New collection:C1472("Asset"; "Liability"; "Equity"))
	$report.push("  "+$key+": "+String:C10(Num:C11($byFamily[$key]); "###,###,##0.00;-###,###,##0.00"))
End for each
$report.push("  Check: assets - (liabilities + equity) = "+String:C10(Round:C94(Num:C11($byFamily.Asset)-Num:C11($byFamily.Liability)-Num:C11($byFamily.Equity); 2); "###,###,##0.00;-###,###,##0.00;0.00"))
$report.push("Entry: debits "+String:C10($totalDebit; "###,###,##0.00")+" / credits "+String:C10($totalCredit; "###,###,##0.00"))
If ($existing.length=1)  // not Choose: it evaluates both branches, and $existing[0] may not exist
	$report.push("Replaces opening entry #"+String:C10(Num:C11($existing[0].number)))
Else
	$report.push("Creates a new opening entry")
End if
$report.push("")
If ($problems.length>0)
	$report.push("PROBLEMS (nothing can be written until they are fixed):")
	For each ($summary; $problems)
		$report.push("  - "+$summary)
	End for each
	$report.push("")
End if
If ($warnings.length>0)
	$report.push("WARNINGS:")
	For each ($summary; $warnings)
		$report.push("  - "+$summary)
	End for each
	$report.push("")
End if
$report.push("LINES")
$report.push("  "+Substring:C12("Number"+(" "*12); 1; 12)+Substring:C12("Account"+(" "*42); 1; 42)+Substring:C12((" "*15)+"Debit"; 6; 15)+"  "+"Credit")
For each ($line; $lines)
	$account:=ds:C1482.GLAccount.get($line.UUID_GLAccount)
	$debitText:=($line.debit=0) ? "" : String:C10($line.debit; "###,###,##0.00")
	$creditText:=($line.credit=0) ? "" : String:C10($line.credit; "###,###,##0.00")
	$report.push("  "+Substring:C12($account.glac+(" "*12); 1; 12)+Substring:C12($account.description+(" "*42); 1; 42)+\
		Substring:C12((" "*15)+$debitText; Length:C16($debitText)+1; 15)+"  "+$creditText)
End for each
$file.parent.file("opening_balances.txt").setText($report.join("\r\n"))

// MARK: - apply
$summary:=$report.slice(3; 12).join("\r")  // from "Balances at..." to "Replaces / Creates..."
If ($problems.length>0)
	If ($liftedLock#!00-00-00!)
		cs:C1710.ga_ledger.me.setClosingDate($liftedLock)  // nothing written: the books stay locked as they were
	End if
	_import_notify($options; "The opening balances cannot be written:\r\r"+$problems.slice(0; 5).join("\r")+Choose:C955($problems.length>5; "\r..."; "")+"\r\rFull report: Project/imports/opening_balances.txt")
	return
End if
If (Not:C34($auto))
	If (Not:C34(cs:C1710.sfw_dialog.me.confirm($summary+Choose:C955($warnings.length=0; ""; "\r\r"+$warnings.join("\r"))+"\r\rReport: Project/imports/opening_balances.txt"; "Apply"; "Report only")))
		return
	End if
End if

ds:C1482.startTransaction()
If ($entry=Null:C1517)
	$entry:=cs:C1710.ga_ledger.me.newEntry("Opening")
End if
$entry.type:="Opening"
$entry.date:=$periodEnd
$entry.memo:="Opening balances taken over from the legacy books at the end of "+String:C10($periodEnd)
$entry.sourceDataclass:="JournalEntry"  // its own source: it can be corrected by hand in Journal Entries
$entry.UUID_Source:=$entry.UUID
$entry.UUID_Division:="0"*32
$entry.moreData:=New object:C1471("importedBy"; "_import_openingBalances"; "importedAt"; cs:C1710.sfw_stmp.me.now(); \
	"legacyPeriodEnd"; String:C10($data.periodEnd); "legacyExportedAt"; String:C10($data.exportedAt); "legacySource"; String:C10($data.source))
$result:=cs:C1710.ga_ledger.me.writeLines($entry; $lines)
If (Not:C34($result.success))
	ds:C1482.cancelTransaction()
	If ($liftedLock#!00-00-00!)
		cs:C1710.ga_ledger.me.setClosingDate($liftedLock)
	End if
	_import_notify($options; "Nothing was written:\r"+$result.errors.join("\r"))
	return
End if
ds:C1482.validateTransaction()

If ($auto)
	$save:=cs:C1710.ga_ledger.me.setClosingDate($periodEnd)
	_import_notify($options; "Opening entry #"+String:C10($entry.number)+" written: "+String:C10($lines.length)+" lines, "+String:C10($totalDebit; "###,###,##0.00")+" on each side. Books locked up to "+String:C10($periodEnd)+"."+\
		Choose:C955($warnings.length=0; ""; "\r"+$warnings.join("\r")))
	return
End if
If (cs:C1710.sfw_dialog.me.confirm("Opening entry #"+String:C10($entry.number)+" written: "+String:C10($lines.length)+" lines, "+String:C10($totalDebit; "###,###,##0.00")+" on each side.\r\r"+\
"Lock the books up to "+String:C10($periodEnd)+" (closing date), so the opening balances cannot be changed by mistake? It can be moved back later (Journal Entries > Closing date...)."; "Lock"; "Not now"))
	$save:=cs:C1710.ga_ledger.me.setClosingDate($periodEnd)
	If (Not:C34(Bool:C1537($save.success)))
		ALERT:C41("The closing date could not be saved: "+String:C10($save.statusText))
	End if
End if
