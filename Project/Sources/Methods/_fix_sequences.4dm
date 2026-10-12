//%attributes = {"executedOnServer":true}
// _fix_sequences
// Lot.number, Job.jobNumber and Inventory.inventoryID are numbered by their table's counter
// (automatic numbering in the structure, and Sequence number in LotEntity / JobEntity /
// LotSplitService / InventoryEntity and every place that creates an inventory).
// When a counter is behind the highest number already in use - numbers written directly by the
// imports, or computed as "highest + 1" by older code - every new record gets a number that
// exists and cannot be saved: error 1115, duplicated key. This moves each counter past the
// highest number in use, so the next record gets a free number. Nothing else is changed.
// Safe to run any time; runs on the server, where the counters live. _demo_check calls it.
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
