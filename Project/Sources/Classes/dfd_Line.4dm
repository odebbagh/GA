Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("dfdLine"; "documentManagement"; "Lines"; "Line")
	$entry.setDataclass("dfd_Line")
	$entry.setDisplayOrder(100)
	$entry.setIcon("dfd/image/entry/dfd_Line-50x50.png")
	
	$entry.setSearchboxField("name")
	
	
	$entry.setPanel("dfd_panel_line"; 2)
	$entry.setPanelPage(1; ""; "Definition")
	
	
	$entry.setLBItemsColumn("name"; "Name"; "xliff:documentFolder.form.name")
	
	$entry.setLBItemsOrderBy("name")
	
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:line"; "unitN:lines")
	$entry.setMainViewLabel("All lines")
	
	$entry.enableTransaction()
	
	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")
	
	$entry.setAllowedProfiles(cs:C1710.sfw_globalParameters.me.dfd.entryLine.allowedProfiles || "admin")
	//$entry.setAllowedProfilesForCreation(cs.sfw_globalParameters.me.dfd.entryLine.allowedProfilesForCreation || "admin")
	//$entry.setAllowedProfilesForDeletion(cs.sfw_globalParameters.me.dfd.entryLine.allowedProfilesForDeletion || "admin")
	//$entry.setAllowedProfilesForModification(cs.sfw_globalParameters.me.dfd.entryLine.allowedProfilesForModification || "admin")
	
	
	
	
	
local Function getFormatPapers()->$formats : Collection
	
	var $format : Object
	
	$formats:=New collection:C1472
	
	$format:=New object:C1471
	$format.name:="A5"
	$format.width:=421
	$format.height:=595
	$formats.push($format)
	
	$format:=New object:C1471
	$format.name:="A4"
	$format.width:=595
	$format.height:=842
	$formats.push($format)
	
	$format:=New object:C1471
	$format.name:="A3"
	$format.width:=842
	$format.height:=1190
	$formats.push($format)
	
	