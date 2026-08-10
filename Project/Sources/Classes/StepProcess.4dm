Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("operationProcess"; ["housekeeping"]; "Operation Process"; "Operation Processes")
	$entry.setDataclass("StepProcess")
	$entry.setDisplayOrder(-100000)
	$entry.setIcon("image/entry/process-50x50.png")
	
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_stepProcess")
	$entry.setPanelPage(1; ""; "Steps")
	
	$entry.setLBItemsColumn("name"; "Name"; "width:300")
	$entry.setLBItemsOrderBy("name")
	$entry.enableTransaction()
	