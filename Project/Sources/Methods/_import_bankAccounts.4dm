//%attributes = {}
// _import_bankAccounts($options)
// The legacy bank accounts on the chart of accounts: reads Project/imports/bankAccounts_export.json
// (legacy _export_bankAccounts, [Bank]) and, on the GL account of each bank (GLAccount.glac):
//   moreData.bank   bank name, account number, currency, next check number, last check date,
//                   clearing flag, and the last reconciled statement (where Phase 4
//                   reconciliation starts again)
//   defaultKey      "DefaultBank" on the legacy default account, when it has no other role
// The account must be of type Bank (reported otherwise, never changed here).
// Re-runnable. Step of _import_accounting / _import_all, after _import_glAccounts.
// $options (optional): {unattended: True} - no dialog, the summary goes to import_messages.txt.
#DECLARE($options : Object)

var $file : 4D.File
var $rows; $report : Collection
var $row : Object
var $account; $holder : cs.GLAccountEntity
var $found; $missing; $notBank : Integer

$file:=Folder(fk database folder).folder("Project/imports").file("bankAccounts_export.json")
If (Not($file.exists))
	_import_notify($options; "Import file not found: "+$file.platformPath+"\r\rRun _export_bankAccounts (or _export_accounting) in the legacy application and copy the file here.")
	return
End if
$rows:=JSON Parse($file.getText())
$report:=["BANK ACCOUNTS - "+String(Current date)+" "+String(Current time; HH MM); ""]

For each ($row; $rows)
	$account:=cs.ga_ledger.me.accountByGlac(String($row.glac))
	If ($account=Null)
		$missing+=1
		$report.push("NOT FOUND  "+String($row.bank)+" - GL account \""+String($row.glac)+"\" is not in the chart of accounts")
		continue
	End if
	$found+=1
	If ($account.accountType#"Bank")
		$notBank+=1
		$report.push("TYPE       "+$account.label+" is of type "+$account.accountType+", not Bank: check it in Chart of Accounts")
	End if
	$account.moreData:=$account.moreData || {}
	$account.moreData.bank:={\
		bankName: String($row.bank); \
		accountNumber: String($row.accountNumber); \
		currency: String($row.currency); \
		nextCheckNumber: Num($row.nextCheckNumber); \
		lastCheckDate: String($row.lastCheckDate); \
		isClearing: Bool($row.isClearing); \
		isDefault: Bool($row.isDefault); \
		begReconciliationBalance: Num($row.begReconciliationBalance); \
		reconStartDate: String($row.reconStartDate); \
		lastReconciled: $row.lastReconciled; \
		importedAt: cs.sfw_stmp.me.now()}
	If (Bool($row.isDefault))
		$holder:=ds.GLAccount.query("defaultKey = :1 AND UUID # :2"; "DefaultBank"; $account.UUID).first()
		Case of
			: ($account.defaultKey="DefaultBank")
			: ($account.defaultKey#"")
				$report.push("ROLE       "+$account.label+" is the legacy default bank but already has the role "+$account.defaultKey+": give \"Default bank\" by hand")
			Else
				If ($holder#Null)
					$holder.defaultKey:=""
					$holder.save()
				End if
				$account.defaultKey:="DefaultBank"
		End case
	End if
	$account.save()
	$report.push("OK         "+$account.label+" - "+String($row.bank)+" #"+String($row.accountNumber)+Choose(Bool($row.isDefault); " (default)"; ""))
End for each

$report.insert(1; "Banks: "+String($rows.length)+" - on their GL account: "+String($found)+" - GL account missing: "+String($missing)+" - not of type Bank: "+String($notBank))
$file.parent.file("bank_accounts.txt").setText($report.join("\r\n"))
_import_notify($options; $report[1]+"\rReport: Project/imports/bank_accounts.txt")
