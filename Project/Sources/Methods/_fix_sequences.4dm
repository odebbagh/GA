//%attributes = {"executedOnServer":true}
// _fix_sequences
// Lot.number, Job.jobNumber and Inventory.inventoryID are numbered by their table's counter
// (automatic numbering in the structure, and Sequence number in LotEntity / JobEntity /
// LotSplitService / InventoryEntity and every place that creates an inventory).
// When a counter is behind the highest number already in use - numbers written directly by the
// imports, or computed as "highest + 1" by older code - every new record gets a number that
// exists and cannot be saved: error 1115, duplicated key. This moves each counter past the
// highest number in use, so the next record gets a free number. Nothing else is changed.
// The sfw counters "quoteCode" and "leadCode" get the same treatment (see below).
// Safe to run any time; runs on the server, where the counters live. __import_data_quote calls it.
#DECLARE()->$result : Object
	
var $tables : Collection
var $t : Object
var $r : Object
var $current : Integer
var $highest : Integer
	
$tables:=New collection:C1472(\
New object:C1471("name"; "Lot"; "table"; ->[Lot:118]; "field"; "number"); \
New object:C1471("name"; "Job"; "table"; ->[Job:117]; "field"; "jobNumber"); \
New object:C1471("name"; "Inventory"; "table"; ->[Inventory:126]; "field"; "inventoryID"))
	
$result:=New object:C1471("tables"; New collection:C1472)
For each ($t; $tables)
	$current:=Get database parameter:C643($t.table->; Table sequence number:K37:31)
	$highest:=Num:C11(ds:C1482[$t.name].all().max($t.field))
	$r:=New object:C1471("table"; $t.name; "before"; $current; "highest"; $highest; "changed"; False:C215)
	If ($current<=$highest)
		// +1: whether 4D reads the value as the last number given or the next one, the next record is free
		SET DATABASE PARAMETER:C642($t.table->; Table sequence number:K37:31; $highest+1)
		$r.changed:=True:C214
	End if 
	$r.after:=Get database parameter:C643($t.table->; Table sequence number:K37:31)
	$result.tables.push($r)
End for each

// Quote.code ("Q" + number) and Lead.leadCode ("L" + 5 digits) come from sfw counters
// (ds.sfw_Counter.getNextValue in QuoteEntity / LeadEntity.beforeSaveCreation). The quote import
// writes the legacy codes (Q251...Q3040) without moving "quoteCode", so the counter is set to the
// highest number in use: the next getNextValue gives the one after it.
var $counters : Collection
var $c : Object
var $code : Text
var $eCounter : cs:C1710.sfw_CounterEntity
var $info : Object

$counters:=New collection:C1472(\
New object:C1471("ident"; "quoteCode"; "dataclass"; "Quote"; "field"; "code"); \
New object:C1471("ident"; "leadCode"; "dataclass"; "Lead"; "field"; "leadCode"))

$result.counters:=New collection:C1472
For each ($c; $counters)
	$highest:=0
	For each ($code; ds:C1482[$c.dataclass].all().extract($c.field))
		If (Num:C11($code)>$highest)
			$highest:=Num:C11($code)
		End if
	End for each
	$eCounter:=ds:C1482.sfw_Counter.query("ident = :1"; $c.ident).first()
	$current:=($eCounter=Null:C1517) ? 0 : $eCounter.currentValue
	$r:=New object:C1471("counter"; $c.ident; "before"; $current; "highest"; $highest; "changed"; False:C215)
	If ($current<$highest)
		If ($eCounter=Null:C1517)
			$eCounter:=ds:C1482.sfw_Counter.new()
			$eCounter.ident:=$c.ident
		End if
		$eCounter.currentValue:=$highest
		$info:=$eCounter.save()
		$r.changed:=$info.success
	End if
	$r.after:=($eCounter=Null:C1517) ? 0 : $eCounter.currentValue
	$result.counters.push($r)
End for each
