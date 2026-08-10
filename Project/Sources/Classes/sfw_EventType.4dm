Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("eventType"; "administration"; "Event types")
	$entry.setXliffLabel("eventtype.title")
	$entry.setDataclass("sfw_EventType")
	$entry.setDisplayOrder(-6500)
	$entry.setIcon("sfw/entry/eventType-50x50.png")
	
	
	$entry.setSearchField("attribute:ident"; "tag:ident")
	$entry.setSearchField("attribute:label"; "tag:label")
	
	
	$entry.setPanel("sfw_panel_eventType"; 2)
	$entry.setPanelPage(1; ""; "Détails"; "disabled")
	$entry.setLBItemsColumn("ident"; "Identifier"; "width:100"; "xliff:eventtype.field.ident")
	$entry.setLBItemsColumn("label"; "Label"; "xliff:eventtype.field.label")
	$entry.setLBItemsOrderBy("ident")
	
	
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:event type"; "unitN:event types")
	$entry.setValidationRule("ident"; "entryField_ident"; "mandatory"; "trimSpace"; "capitalize")
	$entry.setValidationRule("label"; "entryField_label"; "mandatory"; "trimSpace"; "capitalize")
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	
	$entry.activateFavorite(False:C215)