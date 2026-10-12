//%attributes = {}
// InventoryPullForm_savePull
// A production pull at Punch In / Punch OUT: the line (lot, step, cost, reason "Production") and
// the stock left, saved together by ga_stock.move.

#DECLARE($lot : 4D:C1709.Entity; $inventory_e : 4D:C1709.Entity; $qtyToPull : Real; $performedBy : Text; $lotStep : 4D:C1709.Entity)->$result : Object

If ($lot=Null:C1517)
	$result:=New object:C1471("success"; False:C215; "message"; "Invalid pull data.")
	return
End if

$result:=cs:C1710.ga_stock.me.move($inventory_e; "Pull"; $qtyToPull; New object:C1471(\
"performedBy"; $performedBy; \
"reason"; "Production"; \
"lot"; $lot; \
"lotStep"; $lotStep; \
"reload"; True:C214))
