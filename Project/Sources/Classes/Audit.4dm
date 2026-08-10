Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Equipment
	$entry:=cs:C1710.sfw_definitionEntry.new("Audit"; ["qualityAssurance"]; "Audits")
	$entry.setDataclass("Audit")
	$entry.setDisplayOrder(-900)
	$entry.setIcon("image/entry/audit-50x50.png")
	
	$entry.setSearchboxField("auditNumber")
	
	$entry.setPanel("panel_audit")
	$entry.setPanelPage(1; ""; "Planning")
	$entry.setPanelPage(2; ""; "Objective Evidence Record")
	$entry.setPanelPage(3; ""; "Audit Findings")
	$entry.setPanelPage(4; ""; "Follow Up Review")
	$entry.setPanelPage(5; ""; "Preview")
	$entry.setPanelPage(6; ""; "Document")
	
	$entry.activateFavorite()
	
	$entry.setLBItemsColumn("auditNumber"; "Entry Number"; "width:100")
	$entry.setLBItemsColumn("title"; "Title"; "width:200")
	$entry.setLBItemsOrderBy("auditNumber")
	
	$entry.setItemAction("Print Audit Report"; "_ga_printAuditReport")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")