Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("documentTemplate"; "documentManagement"; ds:C1482.sfw_readXliff("documentModel.entry.plural"); ds:C1482.sfw_readXliff("documentModel.entry.single"))
	$entry.setDataclass("sfw_DocumentModel")
	$entry.setXliffLabel("documentModel.entry.plural")
	$entry.setDisplayOrder(10900)
	$entry.setIcon("sfw/entry/DocumentTemplate-50x50.png")
	
	$entry.setSearchboxField("name")
	
	
	$entry.setPanel("sfw_panel_documentModel"; 1)
	$entry.setPanelPage(1; ""; ds:C1482.sfw_readXliff("documentModel.entry.single"))
	$entry.setPanelPage(2; ""; ds:C1482.sfw_readXliff("dfdTemplate.page.permissions"))
	$entry.setPanelPage(3; ""; ds:C1482.sfw_readXliff("dfdTemplate.page.docgeneration"))
	
	
	$entry.setLBItemsColumn("name"; "Name"; "xliff:documentModel.entry.field.name")
	
	$entry.setLBItemsOrderBy("name")
	
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:model"; "unitN:models"; "unit1xliff:documentModel.entry.counter.one"; "unitNxliff:documentModel.entry.counter.unitn")
	$entry.setMainViewLabel(ds:C1482.sfw_readXliff("documentModel.entry.alltemplate"))
	
	$entry.enableTransaction()
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "message:the name is mandatory")
	$entry.setValidationRule("type"; ""; "notZero"; "message:the type is mandatory")
	
	//$entry.setAllowedProfiles(cs.sfw_globalParameters.me.dfd.entryDocument.allowedProfiles || "admin")
	
	$entry.activateSubscription()
	
	