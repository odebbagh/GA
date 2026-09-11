Class extends DataClass



local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	
	
	$entry:=cs:C1710.sfw_definitionEntry.new("rma"; ["qualityAssurance"]; "RMA")
	
	$entry.setDataclass("RMA")
	
	$entry.setDisplayOrder(-500)
	
	$entry.setIcon("image/entry/rma-white-50x50.png")
	
	
	
	$entry.setSearchboxField("rmaNumber")
	
	$entry.setSearchField("path:dateReceived"; "tag:receivedYear"; "placeholder:receivedYear"; "date")
	
	
	
	$entry.setPanel("panel_rma"; 2)
	
	$entry.setPanelPage(1; ""; "Main")
	
	
	
	
	
	$entry.setLBItemsColumn("rmaNumber"; "#"; "width:40"; "center")
	
	$entry.setLBItemsColumn("qcar.customer.name"; "Customer"; "width:200")
	
	$entry.setLBItemsColumn("invoiceNumber"; "Invoice"; "width:140")
	
	// Apr 22, 2026 4DFix: "receivedDate" did not match the computed attribute name "dateReceived" in RMAEntity — column was always empty
	
	$entry.setLBItemsColumn("dateReceived"; "Received"; "width:70"; "center")
	
	
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	
	$entry.setLBItemsOrderBy("rmaNumber")
	
	
	
	$entry.enableTransaction()
	
	
	
	
	
	//Mark: - Filters
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCustomer")
	
	$filter.setDefaultTitle("All customers")
	
	$filter.setFilterByLinkedEntity("Customer"; "qcar.customer.UUID"; "customerUUID"; "qcar.customer")
	
	$filter.setDynamicTitle("name"; "## RMA customers")
	
	$entry.addFilter($filter)
	
	
	
	
	
	
	
	//Mark: - Views
	
	$view:=cs:C1710.sfw_definitionView.new("RmaByYear"; "RMA by Year"; "derivedFrom:main"; $entry)
	
	$view.setSubset("RmaByYear")
	
	$entry.setView($view)
	
	
	
	
	
	
	
	// Purpose: local subset — year picker via cs.Util.setYearPicker (client dialog), then ORDA query by received year.
	
	// Same pattern as RepairLog.problemsByInterval + Util.setDateInterval.
	
	// Returns: cs.RMASelection — RMAs received in the chosen year (empty if cancelled)
	
	// created by 4D/PS [2026-june-08]
	
local Function RmaByYear()->$rmas : cs:C1710.RMASelection
	
	
	
	var $years : Collection
	var $formula : Object
	var $selectedYear : Integer
	
	$years:=This:C1470.all().extract("dateReceived").map(Formula:C1597(_ga_yearOfFormula))
	cs:C1710.Util.me.setYearPicker("Select a Year"; $years)
	
	If (Storage:C1525.cache.selectedYear=0)
		$rmas:=This:C1470.newSelection()
	Else 
		// Purpose: Copy year into $selectedYear before Formula() — Storage is not read on the server during query();
		// the local variable value is captured into the formula when it is built on the client.
		// modified by 4D/PS [2026-june-08]
		$selectedYear:=Num:C11(Storage:C1525.cache.selectedYear)
		$formula:=Formula:C1597(Num:C11(Year of:C25(This:C1470.dateReceived))=$selectedYear)
		$rmas:=This:C1470.query($formula)
	End if 
	
	
	
	
	
	
	
	
	
	