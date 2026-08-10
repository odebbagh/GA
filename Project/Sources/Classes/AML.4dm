
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Equipment
	$entry:=cs:C1710.sfw_definitionEntry.new("AML"; ["qualityAssurance"]; "AML")
	$entry.setDataclass("AML")
	$entry.setDisplayOrder(-600)
	$entry.setIcon("image/entry/aml-white-50x50.png")
	
	$entry.setSearchboxField("ourPartNum"; "placeholder:internalPartNum")
	
	$entry.setPanel("panel_AML")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Address")
	$entry.setPanelPage(3; ""; "Documents")
	
	$entry.setLBItemsColumn("ourPartNum"; "Internal Part#"; "width:150")
	$entry.setLBItemsColumn("vendorPartnum"; "Vendor Part#"; "width:150")
	$entry.setLBItemsColumn("supplier.name"; "Supplier"; "width:250")
	$entry.setLBItemsOrderBy("ourPartNum")
	
	$entry.setItemListAction("Export selection to excel"; "_ga_exportAmlList")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction("Print selection"; "_ga_printAmlList")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.activateFavorite()
	
	// MARK: -Filters
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterAMLSupplier")
	$filter.setDefaultTitle("All suppliers")
	$filter.setFilterByLinkedEntity("Supplier"; "UUID_Supplier"; ""; "supplier")
	$filter.setDynamicTitle("name"; "## AML  supplier")
	$entry.addFilter($filter)
	
	//$filter:=cs.sfw_definitionFilter.new("filterAMLPartNum")
	//$filter.setDefaultTitle("All Part Numbers")
	//$filter.setFilterByLinkedEntity("PartData"; "UUID_PartData"; ""; "partNumber")
	//$filter.setDynamicTitle("internalPartNum"; "## AML  ParNumber")
	//$filter.setOrderForItems("internalPartNum")
	//$filter.setAttributeLabelForItem("internalPartNum")
	//$entry.addFilter($filter)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterEquipmentDivision")
	$filter.setDefaultTitle("All divisions")
	$filter.setFilterByLinkedEntity("Division"; "UUID_Division"; ""; "division")
	$filter.setDynamicTitle("name"; "## equipment division")
	$entry.addFilter($filter)
	
	
	
	// MARK: - Views Definition
	
	
	// MARK: All  product Suppliers
	$view:=cs:C1710.sfw_definitionView.new("productSuppliers"; "All Products")
	$view.setLBItemsColumn("ourPartNum"; "Internal Part#"; "width:150")
	$view.setLBItemsColumn("vendorPartnum"; "Vendor Part#"; "width:150")
	$view.setLBItemsColumn("supplier.name"; "Supplier"; "width:250")
	$view.setLBItemsOrderBy("ourPartNum")
	$view.setSubset("productSuppliers")
	$entry.setView($view)
	
	// MARK: All  service Suppliers
	$view:=cs:C1710.sfw_definitionView.new("serviceSuppliers"; "All Services")
	$view.setLBItemsColumn("ourPartNum"; "Internal Part#"; "width:150")
	$view.setLBItemsColumn("vendorPartnum"; "Vendor Part#"; "width:150")
	$view.setLBItemsColumn("supplier.name"; "Supplier"; "width:250")
	$view.setLBItemsOrderBy("ourPartNum")
	$view.setSubset("serviceSuppliers")
	$entry.setView($view)
	
	// MARK: All  critical product Suppliers
	$view:=cs:C1710.sfw_definitionView.new("criticalProductSuppliers"; "Criticals Products")
	$view.setLBItemsColumn("ourPartNum"; "Internal Part#"; "width:150")
	$view.setLBItemsColumn("vendorPartnum"; "Vendor Part#"; "width:150")
	$view.setLBItemsColumn("supplier.name"; "Supplier"; "width:250")
	$view.setLBItemsOrderBy("ourPartNum")
	$view.setSubset("criticalProductSuppliers")
	$entry.setView($view)
	
	// MARK: All  critical service Suppliers
	$view:=cs:C1710.sfw_definitionView.new("criticalServicesSuppliers"; "Criticals Services")
	$view.setLBItemsColumn("ourPartNum"; "Internal Part#"; "width:150")
	$view.setLBItemsColumn("vendorPartnum"; "Vendor Part#"; "width:150")
	$view.setLBItemsColumn("supplier.name"; "Supplier"; "width:250")
	$view.setLBItemsOrderBy("ourPartNum")
	$view.setSubset("criticalServiceSuppliers")
	$entry.setView($view)
	
	
	
Function productSuppliers()->$amls : cs:C1710.AMLSelection
	$amls:=ds:C1482.AML.query("service =:1"; False:C215)
	
	
Function serviceSuppliers()->$amls : cs:C1710.AMLSelection
	$amls:=ds:C1482.AML.query("service =:1"; True:C214)
	
	
Function criticalProductSuppliers()->$amls : cs:C1710.AMLSelection
	$amls:=ds:C1482.AML.query("service =:1 & critical =:2"; False:C215; True:C214)
	
	
Function criticalServiceSuppliers()->$amls : cs:C1710.AMLSelection
	$amls:=ds:C1482.AML.query("service =:1 & critical =:2"; True:C214; True:C214)
	
	