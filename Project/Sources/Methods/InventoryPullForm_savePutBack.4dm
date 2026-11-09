//%attributes = {}
// InventoryPullForm_savePutBack
// A production put back at Punch In / Punch OUT: at most what THIS lot pulled from the material
// and has not brought back yet (ga_stock.pulledForLot), saved with the stock by ga_stock.move.

#DECLARE($lot : 4D:C1709.Entity; $inventory_e : 4D:C1709.Entity; $qtyToPutBack : Real; $performedBy : Text; $lotStep : 4D:C1709.Entity)->$result : Object

var $netPulled : Real

If ($lot=Null:C1517) || ($inventory_e=Null:C1517)
	$result:=New object:C1471("success"; False:C215; "message"; "Invalid put back data.")
	return
End if

$netPulled:=cs:C1710.ga_stock.me.pulledForLot($inventory_e.UUID; $lot.UUID)
If ($qtyToPutBack>$netPulled)
	$result:=New object:C1471("success"; False:C215; "message"; "Quantity cannot exceed what this lot pulled and has not put back ("+String:C10($netPulled)+").")
	return
End if

$result:=cs:C1710.ga_stock.me.move($inventory_e; "Put Back"; $qtyToPutBack; New object:C1471(\
"performedBy"; $performedBy; \
"reason"; "Production"; \
"lot"; $lot; \
"lotStep"; $lotStep; \
"reload"; True:C214))
