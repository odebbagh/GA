//%attributes = {}
// Bin.isEmpty is now a computed attribute (see BinEntity.isEmpty) evaluated live from
// linked inventories (qtyInStock > 0), so there is no stored flag to recalculate anymore.
// This method now only refreshes the shared bin cache used by the location picker.

If (Storage:C1525.cache=Null:C1517)
	Use (Storage:C1525)
		Storage:C1525.cache:=New shared object:C1526
	End use
End if

// Invalidate and reload the bin cache
Use (Storage:C1525.cache)
	Storage:C1525.cache.bins:=Null:C1517
End use
ds:C1482.Bin.cacheLoad()
