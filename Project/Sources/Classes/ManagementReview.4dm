Class extends DataClass



local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Equipment
	$entry:=cs:C1710.sfw_definitionEntry.new("ManagementReview"; ["qualityAssurance"]; "Reviews"; "ManagementReview")
	$entry.setDataclass("ManagementReview")
	$entry.setDisplayOrder(-900)
	$entry.setIcon("image/entry/ManagementReview-50x50.png")
	
	$entry.setSearchboxField("managementReviewNumber")
	
	$entry.setPanel("panel_managementReview")
	$entry.setPanelPage(1; ""; "Document")
	
	$entry.setLBItemsColumn("managementReviewNumber"; "Management Review Number"; "width:100")
	$entry.setLBItemsColumn("title"; "Title"; "width:200")
	$entry.setLBItemsOrderBy("managementReviewNumber")
	
	// Purpose: Mandatory title with correct form widget (replaces miswired creationDate → entryField_name copy-paste).
	// modified by 4D/PS [2026-may-21]
	$entry.setValidationRule("title"; "entryField_title"; "mandatory"; "trimSpace")
	