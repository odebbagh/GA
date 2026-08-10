Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("stepArea"; ["housekeeping"]; "Area"; "Areas")
	$entry.setDataclass("StepArea")
	$entry.setDisplayOrder(-115000)
	$entry.setIcon("image/entry/area-50x50.png")
	
	$entry.setSearchboxField("name")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")
	
	$entry.setPanel("panel_stepArea")
	$entry.setPanelPage(1; ""; "Main")
	
	$entry.setLBItemsColumn("name"; "Name"; "width:400")
	$entry.setLBItemsOrderBy("name")
	$entry.enableTransaction()
	
	