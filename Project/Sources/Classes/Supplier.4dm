Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Supplier
	$entry:=cs:C1710.sfw_definitionEntry.new("Supplier"; ["qualityAssurance"]; "AVL")
	$entry.setDataclass("Supplier")
	$entry.setDisplayOrder(-700)
	$entry.setIcon("image/entry/avl-white-50x50.png")
	
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_supplier")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Contacts & Address")
	$entry.setPanelPage(3; ""; "Documents")
	$entry.setPanelPage(4; ""; "Rating")
	
	$entry.setLBItemsColumn("name"; "Supplier Name"; "width:250")
	$entry.setLBItemsColumn("approvedByQA?\"Approved\":\"Not Approved\""; "QA Approval"; "width:150"; "orderByFormula:this.approvedByQA")
	$entry.setLBItemsOrderBy("name")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.setItemListAction("Export selection to excel"; "_ga_exportSupplierList")
	$entry.setItemListAction("Export all ratings to Excel"; "_ga_exportAllSupplierRatings")
	
	
	
	// MARK: -Filters
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterSupplierDivision")
	$filter.setDefaultTitle("All divisions")
	$filter.setFilterByLinkedEntity("Division"; "UUID_Division"; ""; "division")
	$filter.setDynamicTitle("name"; "## supplier division")
	$entry.addFilter($filter)
	
	
	// MARK: - Views Definition
	
	
	// MARK: All approved, active and qualified suppliers
	$view:=cs:C1710.sfw_definitionView.new("approvedActiveQualifiedSuppliers"; "All approved, active and qualified suppliers")
	$view.setLBItemsColumn("name"; "Supplier Name"; "width:250")
	$view.setLBItemsColumn("approvedByQA?\"Approved\":\"Not Approved\""; "QA Approval"; "width:150"; "orderByFormula:this.approvedByQA")
	$view.setLBItemsOrderBy("name")
	$view.setSubset("approvedActiveQualifiedSuppliers")
	$entry.setView($view)
	
	// MARK: All non-approved and active suppliers
	$view:=cs:C1710.sfw_definitionView.new("nonApprovedActiveSuppliers"; "All non-approved and active suppliers")
	$view.setLBItemsColumn("name"; "Supplier Name"; "width:250")
	$view.setLBItemsColumn("approvedByQA?\"Approved\":\"Not Approved\""; "QA Approval"; "width:150"; "orderByFormula:this.approvedByQA")
	$view.setLBItemsOrderBy("name")
	$view.setSubset("nonApprovedActiveSuppliers")
	$entry.setView($view)
	
	// MARK: All critical suppliers. (Suppliers with products/services in AML)
	$view:=cs:C1710.sfw_definitionView.new("criticalSuppliers"; "All critical suppliers")
	$view.setLBItemsColumn("name"; "Supplier Name"; "width:250")
	$view.setLBItemsColumn("approvedByQA?\"Approved\":\"Not Approved\""; "QA Approval"; "width:150"; "orderByFormula:this.approvedByQA")
	$view.setLBItemsOrderBy("name")
	$view.setSubset("criticalSuppliers")
	$entry.setView($view)
	
	// MARK: All customer-approved and active suppliers
	$view:=cs:C1710.sfw_definitionView.new("customerApprovedSuppliers"; "All customer-approved and active suppliers")
	$view.setLBItemsColumn("name"; "Supplier Name"; "width:250")
	$view.setLBItemsColumn("approvedByQA?\"Approved\":\"Not Approved\""; "QA Approval"; "width:150"; "orderByFormula:this.approvedByQA")
	$view.setLBItemsOrderBy("name")
	$view.setSubset("customerApprovedSuppliers")
	$entry.setView($view)
	
	// Apr 22, 2026 4DFix: view title was "All in-activated Suppliers" but subset queries disqualified=true — corrected label
	// MARK: All Disqualified Suppliers
	$view:=cs:C1710.sfw_definitionView.new("disqualifiedSuppliers"; "All Disqualified Suppliers")
	$view.setLBItemsColumn("name"; "Supplier Name"; "width:250")
	$view.setLBItemsColumn("approvedByQA?\"Approved\":\"Not Approved\""; "QA Approval"; "width:150"; "orderByFormula:this.approvedByQA")
	$view.setLBItemsOrderBy("name")
	$view.setSubset("disqualifiedSuppliers")
	$entry.setView($view)
	
	// Apr 22, 2026 4DFix: view title was "All Disqualified Suppliers" but subset queries deactivated=true — corrected label
	// MARK: All In-activated Suppliers
	$view:=cs:C1710.sfw_definitionView.new("inactivatedSuppliers"; "All In-activated Suppliers")
	$view.setLBItemsColumn("name"; "Supplier Name"; "width:250")
	$view.setLBItemsColumn("approvedByQA?\"Approved\":\"Not Approved\""; "QA Approval"; "width:150"; "orderByFormula:this.approvedByQA")
	$view.setLBItemsOrderBy("name")
	$view.setSubset("inactivatedSuppliers")
	$entry.setView($view)
	
	
Function approvedActiveQualifiedSuppliers()->$suppliers : cs:C1710.SupplierSelection
	$suppliers:=ds:C1482.Supplier.query("approvedByQA =:1 & disqualified =:2 & deactivated =:3"; True:C214; False:C215; False:C215)
	
Function nonApprovedActiveSuppliers()->$suppliers : cs:C1710.SupplierSelection
	$suppliers:=ds:C1482.Supplier.query("approvedByQA =:1 & deactivated =:2"; False:C215; False:C215)
	
Function criticalSuppliers()->$suppliers : cs:C1710.SupplierSelection
	$criticalAmls:=ds:C1482.AML.query("critical =:1"; True:C214).toCollection().extract("UUID_Supplier")
	$suppliers:=ds:C1482.Supplier.query("UUID in :1"; $criticalAmls)
	
Function customerApprovedSuppliers()->$suppliers : cs:C1710.SupplierSelection
	$suppliers:=ds:C1482.Supplier.query("approvedByCustomer =:1"; True:C214)
	
Function disqualifiedSuppliers()->$suppliers : cs:C1710.SupplierSelection
	$suppliers:=ds:C1482.Supplier.query("disqualified =:1"; True:C214)
	
Function inactivatedSuppliers()->$suppliers : cs:C1710.SupplierSelection
	$suppliers:=ds:C1482.Supplier.query("deactivated =:1"; True:C214)
	
	