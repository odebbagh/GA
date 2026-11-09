Class extends DataClass

// A reusable set of Buy Order quality terms (see [BOTerm]) in a chosen order.
// name    : the model label
// boTerms : {"items": [{"UUID": <BOTerm UUID>; "order": <1..n>}; ...]}
// model   : 4D Write Pro document assembled from those terms, in that order.
//           Read-only in the panel - it is rebuilt whenever the list changes.

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry

	$entry:=cs:C1710.sfw_definitionEntry.new("boTermsModel"; ["buying"]; "BO Term Models"; "BO Term Model")
	$entry.setDataclass("BOTermsModel")
	$entry.setDisplayOrder(-510)
	$entry.setIcon("image/entry/terms-50x50-W.png"; "image/entry/terms-50x50-B.png")

	$entry.setSearchboxField("name")

	$entry.setPanel("panel_BOTermsModel")
	$entry.setPanelPage(1; ""; "Main")

	$entry.setLBItemsColumn("name"; "Name"; "width:250")

	$entry.setLBItemsOrderBy("name")

	$entry.setLBItemsCounter("###0###0##0^1;;"; "unit1:model"; "unitN:models")

	$entry.enableTransaction()
