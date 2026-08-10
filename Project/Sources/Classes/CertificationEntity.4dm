Class extends Entity


local Function loadAfterCreation()
	// Invoked by sfw after ds.Certification.new() when adding a record — assign next Ref # (same idea as JobEntity.jobNumber).
	var $max : Variant
	
	If (This:C1470.ref#0)
		return 
	End if 
	
	$max:=ds:C1482.Certification.all().max("ref")
	If ($max=Null:C1517)
		This:C1470.ref:=1
	Else 
		This:C1470.ref:=Num:C11($max)+1
	End if 
