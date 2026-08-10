Class extends Entity

local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	$all:=ds:C1482.RMA.all()
	
	This:C1470.rmaNumber:=($all.length>0) ? ($all.max("rmaNumber")+1) : 1
	