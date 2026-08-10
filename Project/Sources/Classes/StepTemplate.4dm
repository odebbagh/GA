Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("stepTemplate"; ["housekeeping"]; "Template Definition"; "Template Definitions")
	$entry.setDataclass("StepTemplate")
	$entry.setDisplayOrder(-200)
	$entry.setIcon("image/entry/step-template-white-52x52.png")
	
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_stepTemplate")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Steps")
	$entry.setPanelPage(3; ""; "Rules")
	$entry.setPanelPage(4; ""; "Bins Definition"; "disabled:Form.current_item.binning=False")
	$entry.setPanelPage(5; ""; "Data Table")
	
	$entry.setLBItemsColumn("templateNumber"; "Step Template ID")
	$entry.setLBItemsColumn("name"; "Step Template Name"; "width:100")
	
	$entry.setLBItemsOrderBy("name")
	$entry.enableTransaction()
	$entry.setItemListAction("Duplicate Steptemplate"; "duplicate_steptemplate"; "pathIcon:sfw/image/skin/rainbow/icon/duplicate-24x24.png")