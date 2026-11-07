// QuoteStepSet: the standard step sets of the quotes (Standard commercial, Advanced, Class S, Military,
// Environmental...). A set is an ordered list of steps (Step, Housekeeping > Step Templates) that
// "Price from the price list..." (Quote_pickSteps, ga_quoteLinePricing) ticks in one click on a quote
// line. steps.UUIDs: the Step UUIDs in the order of the line description. UUID_PriceFlow: the price
// flow the set usually goes with ("0"*32 = none), offered when the quote has another one.
// Not to be confused with the price flows (PriceFlow): a flow changes the prices, a set picks the steps.
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("quoteStepSet"; "administration"; "Standard step sets"; "Standard step set")
	$entry.setDataclass("QuoteStepSet")
	$entry.setIcon("image/entry/process-50x50.png")
	$entry.setDisplayOrder(-20800)

	$entry.setSearchboxField("code")
	$entry.setSearchboxField("name")

	$entry.setPanel("panel_quoteStepSet")

	$entry.setLBItemsColumn("num"; "Order"; "width:50"; "right"; "headerRight")
	$entry.setLBItemsColumn("code"; "Code"; "width:80")
	$entry.setLBItemsColumn("name"; "Name"; "width:200")
	$entry.setLBItemsColumn("stepCount"; "Steps"; "width:60"; "right"; "headerRight")
	$entry.setLBItemsColumn("active"; "Active"; "type:boolean"; "width:60")

	$entry.setLBItemsOrderBy("num")
	$entry.setLBItemsOrderBy("code")
	$entry.setLBItemsOrderBy("name")

	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:step set"; "unitN:step sets")

	$entry.setValidationRule("code"; "entryField_code"; "mandatory"; "trimSpace"; "uppercase")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace")

	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	$entry.setAllowedProfilesForDeletion("admin")  // quote lines keep the code of the set they were built from

	$entry.setToolBarGroup("QuoteParameters")
	$entry.enableTransaction()


	// the sets offered on a quote line, in their order
Function activeSets()->$sets : cs:C1710.QuoteStepSetSelection
	$sets:=This:C1470.query("active = :1"; True:C214).orderBy("num asc, name asc")
