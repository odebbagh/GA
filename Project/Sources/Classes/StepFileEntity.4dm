Class extends Entity


local Function loadAfterCreation()
	// Invoked by sfw (callbackOnCurrentItem) after ds.StepFile.new() when adding a new record,
	// before the panel is shown — same pattern as LotEntity / JobEntity.
	This:C1470.status:=True:C214
