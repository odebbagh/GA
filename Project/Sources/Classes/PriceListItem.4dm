// PriceListItem: the master price list (Administration > Quote P. > Master Price List).
// One row = the price of one billable item - an operation process (StepProcess) or a charge that is
// not a process (engineering hour, setup, NRE: no process) - for every customer or for one, over a
// validity period:
// - unitPrice / unitCost: the base sell price and internal cost (the accounting floor)
// - flowPrices.rows [{UUID_PriceFlow; flowCode; unitPrice; unitCost}]: the prices of the flows that
//   differ from the base one (PriceFlow)
// - minLotCharge: the same for every flow
// - stmpEffectiveFrom / stmpEffectiveTo (0 = open): a price in use is not edited, it is closed and a
//   new version added ("New version..."). Quote lines keep the values they were given.
// The lookups used by the quotes are in ga_pricing. Imported by _import_priceList, checked by
// _diag_priceList.
Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	var $view : cs:C1710.sfw_definitionView
	var $filter : cs:C1710.sfw_definitionFilter

	$entry:=cs:C1710.sfw_definitionEntry.new("priceList"; "administration"; "Master Price List"; "Price")
	$entry.setDataclass("PriceListItem")
	$entry.setIcon("image/entry/quoteStatus-50x50-W.png"; "image/entry/quoteStatus-50x50-B.png")
	$entry.setDisplayOrder(-21100)

	$entry.setSearchboxField("code")
	$entry.setSearchboxField("description")

	$entry.setPanel("panel_priceListItem")

	$entry.setLBItemsColumn("code"; "Code"; "width:90")
	$entry.setLBItemsColumn("description"; "Description"; "width:220")
	$entry.setLBItemsColumn("processName"; "Process"; "width:140"; "orderByFormula:This.stepProcess.name")
	$entry.setLBItemsColumn("customerName"; "Customer"; "width:140"; "orderByFormula:This.customer.name")
	$entry.setLBItemsColumn("unit"; "Unit"; "width:50"; "center"; "headerCenter")
	$entry.setLBItemsColumn("unitPrice"; "Unit price"; "width:80"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00##")
	$entry.setLBItemsColumn("unitCost"; "Cost"; "width:80"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00##")
	$entry.setLBItemsColumn("minLotCharge"; "Min. lot"; "width:80"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00")
	$entry.setLBItemsColumn("effectiveFromText"; "From"; "width:80:fixed"; "center"; "headerCenter"; "orderByFormula:This.stmpEffectiveFrom")
	$entry.setLBItemsColumn("effectiveToText"; "To"; "width:80:fixed"; "center"; "headerCenter"; "orderByFormula:This.stmpEffectiveTo")
	$entry.setLBItemsColumn("active"; "Active"; "type:boolean"; "width:50")

	$entry.setLBItemsOrderBy("code")
	$entry.setLBItemsOrderBy("description")
	$entry.setLBItemsOrderBy("stmpEffectiveFrom"; True:C214)

	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:price"; "unitN:prices")

	$entry.setValidationRule("code"; "entryField_code"; "mandatory"; "trimSpace"; "uppercase")
	$entry.setValidationRule("description"; "entryField_description"; "mandatory"; "trimSpace")

	// a copy of the price, starting at a later date; the current one ends the day before
	$entry.setItemAction("New version..."; "PriceList_newVersion"; "activateIf:(Form.current_item#Null) && Not(Form.sfw.checkIsInModification())")

	$entry.setItemListPreconfigAction("exportReferenceRecords")
	$entry.setItemListPreconfigAction("importReferenceRecords")
	$entry.setItemListPreconfigAction("copyItemsListToPasteboard")
	// the price list is maintained by the admin profile only; the others may read it
	$entry.setAllowedProfilesForCreation("admin")
	$entry.setAllowedProfilesForModification("admin")
	$entry.setAllowedProfilesForDeletion("admin")

	$entry.setToolBarGroup("QuoteParameters")

	$entry.enableTransaction()

	$entry.activateEvent("PriceListItemEvent"; "UUID_PriceListItem")
	$entry.setEventOptions("dontCreateModifyEventIfNoTrackingAttribute")
	$entry.setAttributesToTrackInModificationEvent("code"; "description"; "unit"; "unitPrice"; "unitCost"; "minLotCharge"; "active")
	$entry.setLinkManyToOneToTrackInModificationEvent("Process"; "UUID_StepProcess"; "stepProcess.name")
	$entry.setLinkManyToOneToTrackInModificationEvent("Customer"; "UUID_Customer"; "customer.name")
	$entry.setAttributeStmpToTrackInModificationEvent("Effective from"; "stmpEffectiveFrom")
	$entry.setAttributeStmpToTrackInModificationEvent("Effective to"; "stmpEffectiveTo")

	//Mark:- Filters
	$filter:=cs:C1710.sfw_definitionFilter.new("filterActive")
	$filter.setDefaultTitle("Active and inactive")
	$filter.setFilterByBooleanExpression("active = :1"; "Active prices"; "Inactive prices")
	$entry.addFilter($filter)

	$filter:=cs:C1710.sfw_definitionFilter.new("filterProcess")
	$filter.setDefaultTitle("All processes")
	$filter.setFilterByLinkedEntity("StepProcess"; "UUID_StepProcess"; ""; "stepProcess")
	$filter.setDynamicTitle("name"; "## processes")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)

	$filter:=cs:C1710.sfw_definitionFilter.new("filterCustomer")
	$filter.setDefaultTitle("All customers")
	$filter.setFilterByLinkedEntity("Customer"; "UUID_Customer"; ""; "customer")
	$filter.setDynamicTitle("name"; "## customers")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)

	//Mark:- Views
	// the price of each flow next to the base price; the minimum is the same for every flow
	$view:=cs:C1710.sfw_definitionView.new("flowPrices"; "Prices by flow")
	$view.setLBItemsColumn("code"; "Code"; "width:90")
	$view.setLBItemsColumn("description"; "Description"; "width:200")
	$view.setLBItemsColumn("customerName"; "Customer"; "width:120"; "orderByFormula:This.customer.name")
	$view.setLBItemsColumn("unit"; "Unit"; "width:50"; "center"; "headerCenter")
	$view.setLBItemsColumn("unitPrice"; "Base price"; "width:80"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00##")
	$view.setLBItemsColumn("flowPricesText"; "Price by flow"; "width:260")
	$view.setLBItemsColumn("minLotCharge"; "Min. lot (all flows)"; "width:110"; "type:num"; "right"; "headerRight"; "format:###,###,##0.00")
	$view.setLBItemsColumn("effectiveFromText"; "From"; "width:80:fixed"; "center"; "headerCenter"; "orderByFormula:This.stmpEffectiveFrom")
	$view.setLBItemsOrderBy("code")
	$view.setLBItemsOrderBy("stmpEffectiveFrom"; True:C214)
	$entry.setView($view)


	// the rows that can price $processUUID ("0"*32 / "": the items that are not a process) on $date,
	// for $customerUUID and for every customer: active, and valid on that date
Function validOn($date : Date; $processUUID : Text; $customerUUID : Text)->$items : cs:C1710.PriceListItemSelection
	var $stmp : Integer
	var $empty : Text

	$empty:="0"*32
	$stmp:=cs:C1710.sfw_stmp.me.build(($date=!00-00-00!) ? Current date:C33 : $date; ?00:00:00?)
	$items:=This:C1470.query("active = :1 and UUID_StepProcess = :2 and (stmpEffectiveFrom = 0 or stmpEffectiveFrom <= :3) and (stmpEffectiveTo = 0 or stmpEffectiveTo >= :3)"; True:C214; ($processUUID="") ? $empty : $processUUID; $stmp)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($customerUUID))
		$items:=$items.query("UUID_Customer = :1"; $empty)
	Else
		$items:=$items.query("UUID_Customer = :1 or UUID_Customer = :2"; $customerUUID; $empty)
	End if
