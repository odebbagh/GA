//%attributes = {}

// Imports project/imports/glAccounts_export.json into [GLAccount].
//
// The legacy export ([CHART_OF_AC:31], _export_glAccounts) already resolved the
// rules that only exist in the old database, so nothing is re-derived here:
//   purchasable       the account appears in the buying picker
//   allowsInventory   the buyer may tick Inventory on a buy item
//   defaultAsset      the line is a fixed/other asset
//   allowsConsumable  the buyer may tick Consumable
//
// Updates the accounts in place, matched on GLAC (creates the missing ones, never deletes):
// journal lines (JournalLine) and buy lines point to the account UUIDs, so an account must keep
// its UUID across re-runs. Safe to re-run. An account no longer in the export is left as it is.
// defaultKey (the role of the account for the documents, ga_ledger.defaultKeys) comes from the
// legacy [CHART_OF_AC]DefaultKey.
//
// After loading the accounts it back-links the buy lines: BuyingOrderLine.glAccount
// is the legacy GLAC as text, so matching it against GLAccount.glac fills
// UUID_GLAccount and the "account" relation starts resolving. Both the table and
// the FK are optional here - the method reports what is missing instead of failing,
// so it can be installed before the structure changes are made.

// $options (optional): {unattended: True} - no message at the end (_import_accounting,
// _import_all); the report goes to Project/imports/import_messages.txt (_import_notify).
#DECLARE($options : Object)

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $accountClass : 4D:C1709.DataClass
var $account : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $updated : Integer
var $isNew : Boolean
var $failed : Integer
var $linked : Integer
var $unmatched : Integer
var $glac : Text
var $byGlac : Object
var $byDivision : Object
var $eDivision : cs:C1710.DivisionEntity
var $divisionName : Text
var $divisionLinked; $divisionUnmatched : Integer
var $lines : cs:C1710.BuyingOrderLineSelection
var $line : cs:C1710.BuyingOrderLineEntity
var $order : cs:C1710.BuyingOrderEntity
var $noValue : Integer
var $report : Text

$accountClass:=ds:C1482["GLAccount"]

If ($accountClass=Null:C1517)
	_import_notify($options; "Dataclass GLAccount not found. Create the table first - see Documentation/buyItems_field_migration.md.")
	return
End if

//---existing divisions, matched by name. Legacy [CHART_OF_AC]Division also carries
//   values like "ALL" that are not real divisions, so nothing is created here: an
//   unmatched account keeps its raw value in moreData.legacy.division and is counted
//   in the report.
$byDivision:=New object:C1471()
For each ($eDivision; ds:C1482.Division.all())
	$byDivision[Lowercase:C14(String:C10($eDivision.name))]:=$eDivision.UUID
End for each
$divisionLinked:=0
$divisionUnmatched:=0

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("glAccounts_export.json")

If (Not:C34($file.exists))
	_import_notify($options; "Import file not found: "+$file.platformPath)
	return
End if

$records:=JSON Parse:C1218($file.getText())

$created:=0
$updated:=0
$failed:=0
$byGlac:=New object:C1471()

For each ($record; $records)

	$glac:=String:C10($record.glac)
	If ($glac="")
		$failed:=$failed+1
		continue
	End if

	$account:=$accountClass.query("glac = :1"; $glac).first()
	If ($account=Null:C1517)
		$account:=$accountClass.new()
		$isNew:=True:C214
	Else
		$isNew:=False:C215
	End if
	$account.glac:=$glac
	$account.defaultKey:=String:C10($record.defaultKey)
	$account.UUID_Division:="0"*32  // "all divisions" until the name resolves below
	$account.description:=String:C10($record.description)
	$account.accountType:=String:C10($record.accountType)
	$account.accountTypeCode:=Num:C11($record.accountTypeCode)
	$account.fullAccountName:=String:C10($record.fullAccountName)
	$account.parentAccountName:=String:C10($record.parentAccountName)
	$account.subAccount:=Bool:C1537($record.subAccount)
	$account.subLevel:=Num:C11($record.subLevel)
	$account.removed:=Bool:C1537($record.removed)

	//---the four decisions, straight from the legacy rules
	$account.purchasable:=Bool:C1537($record.purchasable)
	$account.allowsInventory:=Bool:C1537($record.allowsInventory)
	$account.defaultAsset:=Bool:C1537($record.defaultAsset)
	$account.allowsConsumable:=Bool:C1537($record.allowsConsumable)
	$account.buyItemType:=String:C10($record.buyItemType)

	//---division by name; left empty when it does not resolve
	$divisionName:=Lowercase:C14(String:C10($record.division))
	If ($divisionName#"")
		If ($byDivision[$divisionName]#Null:C1517)
			$account.UUID_Division:=$byDivision[$divisionName]
			$divisionLinked:=$divisionLinked+1
		Else 
			$divisionUnmatched:=$divisionUnmatched+1
		End if 
	End if 

	//---kept for reconciliation: sort/report keys and the usage count the export
	//   measured against [BUY_ITEMS], which tells a live account from a dead one
	$account.moreData:=New object:C1471(\
		"importedBy"; "_import_glAccounts"; \
		"importedAt"; cs:C1710.sfw_stmp.me.now(); \
		"legacy"; New object:C1471(\
		"uniqueID"; $record.uniqueID; \
		"division"; $record.division; \
		"listExclusionCode"; $record.listExclusionCode; \
		"reportOrderSub"; $record.reportOrderSub; \
		"sortOrderByClassification"; $record.sortOrderByClassification; \
		"defaultKey"; $record.defaultKey; \
		"incomeTaxAccount"; $record.incomeTaxAccount; \
		"buyItemCount"; $record.buyItemCount\
		)\
		)

	$result:=$account.save()
	If ($result.success)
		If ($isNew)
			$created:=$created+1
		Else
			$updated:=$updated+1
		End if
		$byGlac[$glac]:=$account.UUID
	Else
		$failed:=$failed+1
	End if

End for each

$report:="GL accounts - created: "+String:C10($created)+" | updated: "+String:C10($updated)+" | failed: "+String:C10($failed)
$report:=$report+"\rWith a role (defaultKey): "+String:C10($accountClass.query("defaultKey # :1"; "").length)
$report:=$report+"\rDivision linked: "+String:C10($divisionLinked)+" | division name not found: "+String:C10($divisionUnmatched)

//---back-link the buy lines and the buy orders, ON THE SERVER (_import_glAccountsLinkSrv):
//   12,000 records no longer travel to a 4D Remote client and back, and a record the client
//   cannot load (an impossible number, see _diag_badNumbers) no longer stops the import.
$report:=$report+_import_glAccountsLinkSrv($byGlac)

_import_notify($options; $report)
