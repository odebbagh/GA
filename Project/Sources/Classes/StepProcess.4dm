Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("operationProcess"; ["housekeeping"]; "Operation Process"; "Operation Processes")
	$entry.setDataclass("StepProcess")
	$entry.setDisplayOrder(-100000)
	$entry.setIcon("image/entry/process-50x50.png")
	
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_stepProcess")
	$entry.setPanelPage(1; ""; "Steps")
	$entry.setPanelPage(2; ""; "Forms & Specs")
	
	$entry.setLBItemsColumn("name"; "Name"; "width:300")
	$entry.setLBItemsOrderBy("name")
	
	// the standard processing time of each process (ga_processTime)
	$view:=cs:C1710.sfw_definitionView.new("standardTimes"; "Standard times"; "derivedFrom:main"; $entry)
	$view.setLBItemsColumn("standardHours"; "Std hours"; "width:80"; "right"; "headerRight"; "format:###,##0.00")
	$view.setLBItemsColumn("secondsPerUnit"; "s / unit"; "width:80"; "right"; "headerRight"; "format:###,##0.00")
	$entry.setView($view)
	$entry.enableTransaction()
	