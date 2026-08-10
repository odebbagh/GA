Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("certifications"; ["housekeeping"]; "Certification")
	$entry.setDataclass("Certification")
	$entry.setDisplayOrder(-400)
	$entry.setIcon("image/entry/certification-white-50x50.png")
	
	$entry.setSearchboxField("ref")
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_certification")
	$entry.setPanelPage(1; ""; "Main")
	
	
	//$entry.setLBItemsColumn("ref"; "Ref #"; "width:50"; "center")
	$entry.setLBItemsColumn("name"; "Name"; "width:400")
	
	$entry.setLBItemsOrderBy("ref")
	
	$entry.enableTransaction()
	
	$entry.setItemListAction("Import Certifications"; "certification_import")
	$entry.setItemListAction("Export Certifications"; "certification_export")
	