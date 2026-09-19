Class extends DataClass

// Library of standard Buy Order quality terms & conditions (QTC01..QTCnn).
// code    : the QTC reference
// content : 4D Write Pro document holding the clause text (code in bold,
//           body in normal weight) - filled by _import_boTerms

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("boTerm"; ["buying"]; "BO Terms"; "BO Term")
	$entry.setDataclass("BOTerm")
	$entry.setDisplayOrder(-500)
	$entry.setIcon("image/entry/terms-50x50-W.png"; "image/entry/terms-50x50-B.png")
	
	$entry.setSearchboxField("code")
	
	$entry.setPanel("panel_BOTerm")
	$entry.setPanelPage(1; ""; "Main")
	
	$entry.setLBItemsColumn("code"; "Code"; "width:150")
	
	$entry.setLBItemsOrderBy("code")
	
	$entry.setLBItemsCounter("###0###0##0^1;;"; "unit1:term"; "unitN:terms")
	
	$entry.enableTransaction()
