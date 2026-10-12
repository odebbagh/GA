// Buy Items panel: the full purchasing / accounts-payable view of one [BuyingOrderLine].
//
// Field naming carries the read/write rule, so there is nothing to enforce here:
//   entryField_*  the ~20 fields backed by a real BuyingOrderLine column. The framework
//                 does OBJECT SET ENTERABLE(*; "@entryField@"; $isInModification), so
//                 they follow the panel in and out of modification mode.
//   Field_*       everything not editable: the legacy values carried in moreData by
//                 _import_buyOrders, plus the GL classification trio (inventory /
//                 consumable / asset), which is derived from the GL account and must
//                 never be typed. The price block is the exception that proves the rule:
//                 unit price, unit price with tax, taxable, quantity and freight all
//                 carry the entryField_ prefix precisely so the buyer can edit them.
// Field_hdr_* on page 0 is the identity strip repeated on every tab.

singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	//Touching the primary key marks the entity as touched so sfw enables Save/Cancel
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		//every page reads straight from current_item, nothing to load
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	// Page 1 is laid out as three fixed columns of sections:
	//   A  0-494      Item Info / Dates / GL Classification
	//   B  504-998    Pricing / Payment Data
	//   C  1008-...   Totals / Reference
	//
	// Only column C follows the panel width. Widening the window grows its bands
	// instead of leaving a strip of empty background; narrowing can never drag a band
	// back across column B, because the new right edge is floored below.
	var $widthSubform; $heightSubform; $g; $h; $d; $b; $offset; $newRight : Integer
	var $bandName : Text

	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=12

	Case of
		: (FORM Get current page:C276(*)=1)
			$newRight:=$widthSubform-$offset
			// column C starts at 1008 and its fields end at 1438; never let a band
			// finish short of its own contents
			If ($newRight<1450)
				$newRight:=1450
			End if

			For each ($bandName; New collection:C1472("bkgd_totals"; "bkgd_reference"))
				OBJECT GET COORDINATES:C663(*; $bandName; $g; $h; $d; $b)
				OBJECT SET COORDINATES:C1248(*; $bandName; $g; $h; $newRight; $b)
			End for each

		: (FORM Get current page:C276(*)=2)
			// the Receiving band is the only one on its page, so it takes the full width
			$newRight:=$widthSubform-$offset
			If ($newRight<940)
				$newRight:=940
			End if
			OBJECT GET COORDINATES:C663(*; "bkgd_receiving"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bkgd_receiving"; $g; $h; $newRight; $b)
	End case

	This:C1470._applyGLAccountLocks()

Function selectUnit()
	
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_unit"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"allData"; ds:C1482.Unit.all().orderBy("name asc"); \
					"dataclass"; "Unit"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Unit:=$form.item.UUID
				End if 
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case 
	End if 
	
	// ---- Approved part (AML) -------------------------------------------------
	// Legacy BI_EntryF carried two scrollable areas - our part numbers and the vendor's -
	// both calling subr_choose_partnum, over the list built by Field17:
	//     QUERY([AVL_Supplies]; Supplier = [BUY_ORDERS]VENDOR)
	//         & Service = False & MakeInactive = False
	// That scoping is the QA gate: a part can only be bought from a vendor approved to
	// supply it. Both fields open the same picker here, as they did there.
	//
	// Legacy also appended "Vendor Part#... / Internal Part#..." into the description.
	// Not reproduced: both numbers are their own fields now, fed through the aml
	// relation, so baking them into free text would re-create exactly the kind of
	// denormalisation this migration has been removing.
	//
	// Units are NOT cascaded either. Legacy copied AVL.ProcurementUnits (text, "Pcs" on
	// all 394 rows) straight into [BUY_ITEMS]Units, but GA's AML.procurementUnits is an
	// integer column while BuyingOrderLine.units is text with its own UUID_Unit relation
	// to [Unit] - a different table. There is no correct mapping to make yet, so the
	// buyer keeps picking units themselves.
Function selectAML()
	var $form : Object
	var $winRef : Integer
	var $l; $t; $r; $b : Integer
	var $line : cs:C1710.BuyingOrderLineEntity
	var $parts : cs:C1710.AMLSelection
	var $supplierUUID; $supplierName : Text

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	Case of
		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			SET CURSOR:C469(9000)
			return
		: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
		Else
			return
	End case

	$line:=Form:C1466.current_item
	If ($line=Null:C1517)
		return
	End if

	//---the list is scoped to the order's vendor, so the order has to exist first
	If ($line.buyingOrder=Null:C1517) | ($line.buyingOrder.supplier=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("Pick the buy order first - the approved parts list is specific to its vendor.")
		return
	End if

	$supplierUUID:=String:C10($line.buyingOrder.UUID_Supplier)
	$supplierName:=String:C10($line.buyingOrder.supplier.name)

	$parts:=ds:C1482.AML.query("UUID_Supplier = :1 and service = :2 and makeInactive = :3"; $supplierUUID; False:C215; False:C215)

	If ($parts.length=0)
		//---legacy: "QA has no entry for this part#"
		cs:C1710.sfw_dialog.me.alert("QA has no approved part for "+$supplierName+". Add it to the AML before buying from this vendor.")
		return
	End if

	OBJECT GET COORDINATES:C663(*; "Field_Part_num"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

	$form:=New object:C1471(\
		"colName"; "pickerLabel"; \
		"allData"; $parts.orderBy("ourPartNum asc"); \
		"dataclass"; "AML"\
		)

	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)

	If (ok=1)
		$line.UUID_AML:=$form.item.UUID
		//---description follows the part unless the buyer has already written one
		If (String:C10($line.description)="")
			$line.description:=String:C10($form.item.description)
		End if
		This:C1470._activate_save_cancel_button()
	End if

	// ---- mirror functions for the two part fields ----------------------------
	// This entry runs activateDocument, so sfw_dynamicForm_script dispatches to
	// cs.panel_boItem.me[objectName]() - same reason Field_unit / Field_hdr_bo exist.
Function Field_Part_num()
	This:C1470.selectAML()

Function Field_Vendor_partnum()
	This:C1470.selectAML()
Function selectJob()
	
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_jobNumber"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "jobNumber"; \
					"allData"; ds:C1482.Job.all().orderBy("jobNumber desc"); \
					"dataclass"; "Job"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Job:=$form.item.UUID
				End if 
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case 
	End if 
	
Function selectBuyingOrder()
	// Picking the buy order is what gives the line its item number: "number" is a
	// sequence WITHIN a buy order, so it is assigned here rather than on creation.
	var $eLines : cs:C1710.BuyingOrderLineSelection
	var $maxNumber : Integer
	var $boUUID : Text
	
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				OBJECT GET COORDINATES:C663(*; "Field_hdr_bo"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "boNumber"; \
					"allData"; ds:C1482.BuyingOrder.all().orderBy("boNumber desc"); \
					"dataclass"; "BuyingOrder"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					$boUUID:=String:C10($form.item.UUID)
					Form:C1466.current_item.UUID_BuyingOrder:=$boUUID
					
					// next item number for THAT buy order. The line itself is excluded so
					// re-picking a buy order on a saved line does not bump it past its
					// own value, and moving a line to another buy order renumbers it
					// inside the new one.
					$eLines:=ds:C1482.BuyingOrderLine.query("UUID_BuyingOrder = :1 and UUID # :2"; \
						$boUUID; String:C10(Form:C1466.current_item.UUID))
					$maxNumber:=($eLines.length>0) ? Num:C11($eLines.max("number")) : 0
					Form:C1466.current_item.number:=$maxNumber+1

					//---the line takes the order's GL account and its Inventory /
					//   Consumable / Asset rules - it is read-only on this panel
					Form:C1466.current_item.inheritGLAccountFromOrder(ds:C1482.BuyingOrder.get($boUUID))
					
					This:C1470._activate_save_cancel_button()
				End if 
			: (FORM Event:C1606.code=On Mouse Move:K2:35)
				SET CURSOR:C469(9000)
		End case 
	End if 

//Mark:- Dynamic-rendering mirrors of the form object methods
// activateDocument("showCountInTab") on the boItems entry switches this panel to
// dynamic-source rendering. In that mode sfw_foundations replaces every object method
// of the form with sfw_dynamicForm_script, which calls cs.panel_boItem.me[objectName]().
// That lookup is guarded by #Null, so an object with no matching function here simply
// does nothing - no error, no warning. The functions below carry the names of the form
// objects for exactly that reason. The ObjectMethods files are kept: they still run
// when the panel is rendered statically.

Function Field_hdr_bo()
	This:C1470.selectBuyingOrder()

Function Field_jobNumber()
	This:C1470.selectJob()

Function Field_unit()
	This:C1470.selectUnit()

Function btnDatePicker_commitDate1()
	This:C1470._pickDateInto("btnDatePicker_commitDate1"; "confirmationDate")

Function btnDatePicker_commitDate2()
	This:C1470._pickDateInto("btnDatePicker_commitDate2"; "requiredDate")

Function btnDatePicker_commitDate3()
	This:C1470._pickDateInto("btnDatePicker_commitDate3"; "orderDate")


	// ---- price editing ------------------------------------------------------
	// The four price inputs all feed the same recalculation, so they share one body.
	// Same shape as panel_poLines.lineAmountChanged for a purchase-order line.
	//
	// The rule itself lives on BuyingOrderLineEntity.recalcPrices, not here: the import
	// and anything added later need the same numbers, and the legacy application's habit
	// of scattering this across object methods is what the migration set out to undo.
Function lineAmountChanged()
	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	Form:C1466.current_item.recalcPrices()
	This:C1470._activate_save_cancel_button()

	// Object-name mirrors. Under dynamic-source rendering the ObjectMethods files are not
	// run - sfw_dynamicForm_script calls a class function carrying the object's name - so
	// each editable price field needs both. See the note above Field_hdr_bo.
Function entryField_Unit_Price()
	This:C1470._priceFieldChanged(On Data Change:K2:15)

Function entryField_UnitPriceWithSalesTax()
	This:C1470._priceFieldChanged(On Data Change:K2:15)

Function entryField_quantityOrdered()
	This:C1470._priceFieldChanged(On Data Change:K2:15)

Function entryField_Taxable()
	This:C1470._priceFieldChanged(On Clicked:K2:4)

	// Shared guard: only recalculate on the field's own event, and only while the panel is
	// actually in modification - otherwise merely displaying a line would rewrite its
	// stored totals.
Function _priceFieldChanged($expectedEvent : Integer)
	If (FORM Event:C1606.code#$expectedEvent)
		return
	End if
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	This:C1470.lineAmountChanged()
Function _pickDateInto($objectName : Text; $attribute : Text)
	// Shared body of the three date-picker buttons. The object is addressed by NAME
	// rather than through Self->: in dynamic mode this runs as a class function called
	// from sfw_dynamicForm_script, where Self does not resolve to the clicked button.
	If (FORM Event:C1606.code#On Clicked:K2:4)
		return
	End if
	If (Form:C1466.current_item=Null:C1517)
		return
	End if

	var $l; $t; $r; $b : Integer
	var $date : Date


	$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.current_item[$attribute]; $objectName)  // the app's calendar

	If ($date#!00-00-00!)
		Form:C1466.current_item[$attribute]:=$date
		This:C1470._activate_save_cancel_button()
	End if


	// ---- GL account ----------------------------------------------------------
	// Legacy picked the account from a hierarchical list built by
	// SubrCreateChartOfAccountList("PurchasingCategories"), which drops Income,
	// Equity, Bank, Accounts Payable and Accounts Receivable, then keeps only
	// Remove=False and SubAccount=False. _export_glAccounts resolved all of that into
	// GLAccount.purchasable, so the picker is a flat query on one boolean.

Function selectGLAccount()
	// Kept only so an old caller does nothing: the line's GL account is the order's now,
	// shown read-only here (BuyingOrderLineEntity.glAccountDisplay). It is changed on the
	// buy order, which pushes it to its lines.
	// Locking half of SetBuyingFieldsBasedonGLacc. Legacy called subr_lock /
	// subr_unlock on the Inventory and Consumable checkboxes the moment an account was
	// chosen, so the buyer could not flag an expense line as inventory. Before
	// _import_glAccounts has run there is no [GLAccount] to consult and both stay
	// open, which leaves an unconfigured database behaving as it does today.
Function _applyGLAccountLocks()
	var $line : cs:C1710.BuyingOrderLineEntity
	var $account : Object
	var $isInModification; $allowsInventory; $allowsConsumable : Boolean
	var $objectName : Text

	$line:=Form:C1466.current_item
	If ($line=Null:C1517)
		return
	End if

	$isInModification:=Form:C1466.sfw.checkIsInModification()

	//---resolved once: this runs on every redraw, and each entity accessor queries
	//   [GLAccount] on its own
	$account:=$line.glAccountRecord
	$allowsInventory:=($account=Null:C1517) ? True:C214 : Bool:C1537($account.allowsInventory)
	$allowsConsumable:=($account=Null:C1517) ? True:C214 : Bool:C1537($account.allowsConsumable)

	OBJECT SET ENTERABLE:C238(*; "Field_Inventory"; $isInModification & $allowsInventory)
	OBJECT SET ENABLED:C1123(*; "Field_Inventory"; $isInModification & $allowsInventory)
	OBJECT SET ENTERABLE:C238(*; "Field_Consumable"; $isInModification & $allowsConsumable)
	OBJECT SET ENABLED:C1123(*; "Field_Consumable"; $isInModification & $allowsConsumable)

	// Asset follows the account outright - legacy never let it be typed
	OBJECT SET ENTERABLE:C238(*; "Field_Asset"; False:C215)

	// The GL account is picker-only. It has to be forced shut here because the
	// framework does OBJECT SET ENTERABLE(*; "@entryField@"; $isInModification) on
	// every redraw, and this object carries the entryField_ prefix - so without this
	// the buyer could type a code that is not in the chart and defeat the locks above.
	OBJECT SET ENTERABLE:C238(*; "entryField_Glac"; False:C215)
	// Part # / Vendor Part #: 10,489 of 11,860 legacy lines have no part at all, so the
	// pair is hidden unless the line is an inventory line (where the buyer must pick one)
	// or already carries a value. See BuyingOrderLineEntity.showsPartNumber.
	var $showsPart : Boolean
	$showsPart:=$line.showsPartNumber
	For each ($objectName; New collection:C1472("label_Part_num"; "Field_Part_num"; "label_Vendor_partnum"; "Field_Vendor_partnum"))
		OBJECT SET VISIBLE:C603(*; $objectName; $showsPart)
	End for each

	// ---- mirror functions for the GL account field ---------------------------
	// This entry runs activateDocument, so sfw_dynamicForm_script replaces every object
	// method and dispatches to cs.panel_boItem.me[objectName]() instead - same reason
	// Field_hdr_bo / Field_unit / Field_jobNumber exist above.
Function entryField_Glac()
	// Read-only: the GL account comes from the buy order. Nothing to open here.
