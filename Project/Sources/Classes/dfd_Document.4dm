Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("dfdDocument"; "documentManagement"; "Documents"; "Document")
	$entry.setDataclass("dfd_Document")
	$entry.setDisplayOrder(300)
	$entry.setIcon("dfd/image/entry/dfd_Document-50x50.png")
	
	$entry.setSearchboxField("name")
	
	
	$entry.setPanel("dfd_panel_document"; 2)
	$entry.setPanelPage(1; ""; "Definition")
	
	
	$entry.setLBItemsColumn("name"; "Name"; "xliff:documentFolder.form.name")
	
	$entry.setLBItemsOrderBy("name")
	
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:document"; "unitN:documents")
	$entry.setMainViewLabel(ds:C1482.sfw_readXliff("dfdDocument.entry.alldocuments"))  //"All documents")
	
	$entry.enableTransaction()
	
	//$entry.setItemListPreconfigAction("exportReferenceRecords")
	//$entry.setItemListPreconfigAction("importReferenceRecords")
	
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")
	
	$entry.setAllowedProfiles(cs:C1710.sfw_globalParameters.me.dfd.entryDocument.allowedProfiles || "admin")
	//$entry.setAllowedProfilesForCreation(cs.sfw_globalParameters.me.dfd.entryDocument.allowedProfilesForCreation || "admin")
	//$entry.setAllowedProfilesForDeletion(cs.sfw_globalParameters.me.dfd.entryDocument.allowedProfilesForDeletion || "admin")
	//$entry.setAllowedProfilesForModification(cs.sfw_globalParameters.me.dfd.entryDocument.allowedProfilesForModification || "admin")
	
	$entry.setItemListProjection("Projection to templates"; "projectionToTemplates"; "dfdTemplate"; "documentManagement")
	
	
local Function buildFromTemplate($name : Text; $templateParam : Variant; $data : Object; $optionText : Text; $options : Object)->$document : cs:C1710.dfd_DocumentEntity
	
	var $context : Object
	var $indices : Collection
	var $info : Object
	var $paperFormat : Text
	var $template : cs:C1710.dfd_TemplateEntity
	var $optionStrings : Collection
	
	
	//If (Not(Bool(Storage.DFD.check_databaseDefinition)))
	//databaseDefinition_verify
	//End if 
	//If (Bool(Storage.DFD.check_databaseDefinition))
	
	$context:=New object:C1471()
	
	$context.zoom:=100
	$context.portrait:=1
	$context.rulers:=0
	$context.landscape:=0
	$context.paper:=New object:C1471
	$context.paper.formats:=ds:C1482.dfd_Line.getFormatPapers()
	$context.paper.format:="A4"
	
	$context.document:=ds:C1482.dfd_Document.new()
	$context.document.name:=$name
	$context.document.stmp:=cs:C1710.sfw_stmp.me.now()
	$context.document.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
	Case of 
		: (Value type:C1509($templateParam)=Is text:K8:3)
			$template:=ds:C1482.dfd_Template.query("name = :1"; $templateParam).first()
			$context.document.template:=$template
		: (Value type:C1509($templateParam)=Is object:K8:27)
			$context.document.template:=$templateParam
	End case 
	
	$context.document.moreData:=New object:C1471
	If ($context.document.template.moreData.settings#Null:C1517)
		$context.document.moreData.settings:=OB Copy:C1225($context.document.template.moreData.settings)
	Else 
		$context.document.moreData.settings:=New object:C1471
	End if 
	
	$context.document.moreData.settings.printPreview:=$options.printPreview || False:C215
	$context.document.moreData.settings.printNbCopies:=$options.printNbCopies || 1
	$context.document.moreData.settings.printSettings:=$options.printSettings || False:C215
	
	$context.document.moreData.settings.pdfPrinter:=$options.pdfPrinter || Generic PDF driver:K47:15
	$context.document.moreData.settings.pdfPath:=$options.pdfPath || ""
	$context.document.moreData.settings.pdfDocumentName:=$options.pdfDocumentName || ""
	
	$paperFormat:=$context.document.moreData.settings.format || "A4"
	
	$indices:=$context.paper.formats.indices("name = :1"; $paperFormat)
	If ($indices.length>0)
		$context.paper.format:=$context.paper.formats[$indices[0]].name
	End if 
	
	$context.document.variableItems:=$data
	
	If (Count parameters:C259<4)
		$optionStrings:=New collection:C1472
	Else 
		$optionStrings:=Split string:C1554($optionText; ";")
	End if 
	
	If ($optionStrings.indexOf("print")>=0)
		cs:C1710.dfd_panel_document.me.redraw_preview($context; "--print")
	End if 
	
	If ($optionStrings.indexOf("pdf")>=0)
		cs:C1710.dfd_panel_document.me.redraw_preview($context; "--pdf")
	End if 
	
	
	If ($optionStrings.indexOf("save")>=0)
		$info:=$context.document.save()
	End if 
	
	$document:=$context.document
	
	//End if 
	
Function buildFromTemplateOnServer($name : Text; $templateParam : Variant; $data : Object; $optionText : Text; $options : Object)->$document : cs:C1710.dfd_DocumentEntity
	$params:=New collection:C1472()
	For ($p; 1; Count parameters:C259)
		$params.push(${$p})
	End for 
	$document:=This:C1470.buildFromTemplate.call(This:C1470; $params)
	
local Function print($document : cs:C1710.dfd_DocumentEntity)
	var $context : Object
	var $paperFormat : Text
	var $indices : Collection
	
	
	$context:=New object:C1471()
	
	$context.zoom:=100
	$context.portrait:=1
	$context.rulers:=0
	$context.landscape:=0
	$context.paper:=New object:C1471
	$context.paper.formats:=paper_get_formats
	$context.paper.format:="A4"
	
	$context.document:=$document
	
	$paperFormat:=$context.document.moreData.settings.format || "A4"
	
	$indices:=$context.paper.formats.indices("name = :1"; $paperFormat)
	If ($indices.length>0)
		$context.paper.format:=$context.paper.formats[$indices[0]].name
	End if 
	
	$context.copies:=Num:C11($context.document.moreData.settings.printNbCopies)=0 ? 1 : Num:C11($context.document.moreData.settings.printNbCopies)
	
	cs:C1710.dfd_panel_document.me.redraw_preview($context; "--print")
	
	
Function printOnServer($document : cs:C1710.dfd_DocumentEntity)
	This:C1470.print($document)
	
	
	