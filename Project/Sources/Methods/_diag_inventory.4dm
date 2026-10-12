//%attributes = {}
// _diag_inventory
// READ-ONLY. The state of the inventory data in this database, to set beside the legacy audits
// (__ga_InventoryAudit / __ga_InventoryAudit2) before the inventory module is fixed. Nothing is
// saved. Writes Project/imports/inventory_diag.txt and .json: send both.
//   - records: imported from the legacy app or created here, IDs and codes
//   - quantities: qtyInStock against availableQty, availableQty against initialQty and the pulls
//   - pulls: by type and reason, linked to a lot / step, without their inventory
//   - bins: linked, text only, linked to a missing bin; every location text and every bin path
//   - owner: customer, lot (the legacy StockGroup is a lot's UniqueID, which is the lot's UUID
//     here), job, buy order line
//   - classification and units: text against the linked records, the two pairs of tables
//   - expiration and IQA, and which legacy fields the import kept in moreData.legacy

var $report; $o; $pulledById; $p; $q; $lotKeys : Object
var $lines; $values : Collection
var $inv; $pull; $bin; $lot : 4D:C1709.Entity
var $key; $kind; $candidate : Text
var $net : Real

$report:=New object("date"; String(Current date))

// ---------------------------------------------------------------- the pulls, per inventory
$pulledById:=New object
$o:=New object("pulls"; 0; "types"; New collection; "reasons"; New collection; "withLot"; 0; "withStep"; 0; "inventoryMissing"; 0)
For each ($pull; ds.InventoryPull.all())
	$o.pulls:=$o.pulls+1
	$o.types.push($pull.type)
	$o.reasons.push($pull.reason)
	If (Not(cs.sfw_string.me.isAnEmptyUUID($pull.UUID_Lot)))
		$o.withLot:=$o.withLot+1
	End if
	If (Not(cs.sfw_string.me.isAnEmptyUUID($pull.UUID_LotStep)))
		$o.withStep:=$o.withStep+1
	End if
	If ($pull.inventory=Null)
		$o.inventoryMissing:=$o.inventoryMissing+1
	End if
	$key:=$pull.UUID_Inventory
	If ($pulledById[$key]=Null)
		$pulledById[$key]:=New object("pulled"; 0; "putBack"; 0; "initial"; 0; "count"; 0)
	End if
	$p:=$pulledById[$key]
	$p.count:=$p.count+1
	Case of
		: ($pull.type="Pull")
			$p.pulled:=$p.pulled+$pull.qty
		: ($pull.type="Put Back")
			$p.putBack:=$p.putBack+$pull.qty
		: ($pull.type="Initial Stock")
			$p.initial:=$p.initial+1
	End case
End for each
$o.types:=_diag_inventoryTop($o.types; 20)
$o.reasons:=_diag_inventoryTop($o.reasons; 20)
$report.pulls:=$o

// ---------------------------------------------------------------- every inventory
$report.records:=New object("total"; 0; "legacy"; 0; "createdHere"; 0; "inventoryIdZero"; 0; "codeEmpty"; 0; "duplicateIds"; 0; "active"; 0; "legacyKeys"; New collection)
$report.quantities:=New object("qtyInStock_differs_available"; 0; "available_negative"; 0; "available_above_initial"; 0; "available_zero"; 0; "available_positive"; 0; "qtyInStock_positive"; 0; \
"withPulls"; 0; "available_is_initial_minus_pulls_plus_putBacks"; 0; "noInitialStockPull"; 0; "examples"; New collection)
$report.bins:=New object("linked"; 0; "linkedToAMissingBin"; 0; "textOnly"; 0; "none"; 0; "binsInTable"; ds.Bin.all().length)
$report.owner:=New object("customerLinked"; 0; "customerSpecific"; 0; "customerProvided"; 0; "lotLinked"; 0; "jobLinked"; 0; "boLineLinked"; 0; "stockGroupFilled"; 0; "stockGroupIsALot"; 0; "legacyStockGroupIsALot"; 0; "noOwnerAtAll"; 0)
$report.classification:=New object("textFilled"; 0; "linked"; 0; "textButNotLinked"; 0; "unitsTextFilled"; 0; "unitsLinked"; 0; \
"InventoryClassification"; ds.InventoryClassification.all().length; "Classification"; ds.Classification.all().length; "InventoryUnits"; ds.InventoryUnits.all().length; "Unit"; ds.Unit.all().length)
$report.expiry:=New object("expirationSet"; 0; "expirationZero"; 0; "iqaRequired"; 0; "iqaStatus"; New collection)
// the lots by their legacy UniqueID (_import_lotinfo keeps it in moreData.legacyUniqueID): what
// the legacy [Inventory]StockGroup holds for customer material
$lotKeys:=New object
For each ($lot; ds.Lot.all())
	If ($lot.moreData#Null)
		If (String($lot.moreData.legacyUniqueID)#"")
			$lotKeys[String($lot.moreData.legacyUniqueID)]:=True
		End if 
	End if 
End for each 
$values:=New collection  // location texts
$q:=New object  // inventoryID counts

For each ($inv; ds.Inventory.all())
	$report.records.total:=$report.records.total+1
	$kind:="createdHere"
	If ($inv.moreData#Null)
		If ($inv.moreData.legacy#Null)
			$kind:="legacy"
			For each ($key; OB Keys($inv.moreData.legacy))
				$report.records.legacyKeys.push($key)
			End for each
		End if
	End if
	If ($kind="createdHere") & ($inv.stockNum#"")
		$kind:="legacy"
	End if
	$report.records[$kind]:=$report.records[$kind]+1
	If ($inv.inventoryID=0)
		$report.records.inventoryIdZero:=$report.records.inventoryIdZero+1
	Else
		$q[String($inv.inventoryID)]:=Num($q[String($inv.inventoryID)])+1
	End if
	If ($inv.code="")
		$report.records.codeEmpty:=$report.records.codeEmpty+1
	End if
	If ($inv.active)
		$report.records.active:=$report.records.active+1
	End if

	// quantities
	$o:=$report.quantities
	If ($inv.qtyInStock#$inv.availableQty)
		$o.qtyInStock_differs_available:=$o.qtyInStock_differs_available+1
	End if
	If ($inv.availableQty<0)
		$o.available_negative:=$o.available_negative+1
	End if
	If ($inv.availableQty>$inv.initialQty)
		$o.available_above_initial:=$o.available_above_initial+1
	End if
	If ($inv.availableQty=0)
		$o.available_zero:=$o.available_zero+1
	Else
		$o.available_positive:=$o.available_positive+1
	End if
	If ($inv.qtyInStock>0)
		$o.qtyInStock_positive:=$o.qtyInStock_positive+1
	End if
	$p:=$pulledById[$inv.UUID]
	If ($p#Null)
		If (($p.pulled+$p.putBack)>0)
			$o.withPulls:=$o.withPulls+1
			$net:=$inv.initialQty-$p.pulled+$p.putBack
			If ($net=$inv.availableQty)
				$o.available_is_initial_minus_pulls_plus_putBacks:=$o.available_is_initial_minus_pulls_plus_putBacks+1
			Else
				If ($o.examples.length<20)
					$o.examples.push(New object("code"; $inv.code; "stockNum"; $inv.stockNum; "initial"; $inv.initialQty; "available"; $inv.availableQty; "qtyInStock"; $inv.qtyInStock; "pulled"; $p.pulled; "putBack"; $p.putBack))
				End if
			End if
		End if
		If ($p.initial=0)
			$o.noInitialStockPull:=$o.noInitialStockPull+1
		End if
	Else
		$o.noInitialStockPull:=$o.noInitialStockPull+1
	End if

	// bins
	$o:=$report.bins
	Case of
		: (Not(cs.sfw_string.me.isAnEmptyUUID($inv.UUID_Location)))
			$bin:=ds.Bin.get($inv.UUID_Location)
			If ($bin=Null)
				$o.linkedToAMissingBin:=$o.linkedToAMissingBin+1
			Else
				$o.linked:=$o.linked+1
			End if
		: ($inv.location#"")
			$o.textOnly:=$o.textOnly+1
		Else
			$o.none:=$o.none+1
	End case
	If ($inv.location#"")
		$values.push($inv.location)
	End if

	// owner
	$o:=$report.owner
	If (Not(cs.sfw_string.me.isAnEmptyUUID($inv.UUID_Customer)))
		$o.customerLinked:=$o.customerLinked+1
	End if
	If ($inv.customerSpecific)
		$o.customerSpecific:=$o.customerSpecific+1
	End if
	If ($inv.customer_provided)
		$o.customerProvided:=$o.customerProvided+1
	End if
	If (Not(cs.sfw_string.me.isAnEmptyUUID($inv.UUID_Lot)))
		$o.lotLinked:=$o.lotLinked+1
	End if
	If (Not(cs.sfw_string.me.isAnEmptyUUID($inv.UUID_Job)))
		$o.jobLinked:=$o.jobLinked+1
	End if
	If (Not(cs.sfw_string.me.isAnEmptyUUID($inv.UUID_BuyingOrderLine)))
		$o.boLineLinked:=$o.boLineLinked+1
	End if
	If ($inv.stockGroup#"")
		$o.stockGroupFilled:=$o.stockGroupFilled+1
		If (Bool($lotKeys[$inv.stockGroup]))
			$o.stockGroupIsALot:=$o.stockGroupIsALot+1
		End if
	End if
	$candidate:=""
	If ($inv.moreData#Null)
		If ($inv.moreData.legacy#Null)
			$candidate:=String($inv.moreData.legacy.stockGroup)
		End if
	End if
	If ($candidate#"")
		If (Bool($lotKeys[$candidate]))
			$o.legacyStockGroupIsALot:=$o.legacyStockGroupIsALot+1
		End if
	End if
	If (cs.sfw_string.me.isAnEmptyUUID($inv.UUID_Customer)) & (cs.sfw_string.me.isAnEmptyUUID($inv.UUID_Lot)) & (cs.sfw_string.me.isAnEmptyUUID($inv.UUID_Job)) & (cs.sfw_string.me.isAnEmptyUUID($inv.UUID_BuyingOrderLine))
		$o.noOwnerAtAll:=$o.noOwnerAtAll+1
	End if

	// classification and units
	$o:=$report.classification
	If ($inv.classification#"")
		$o.textFilled:=$o.textFilled+1
		If (cs.sfw_string.me.isAnEmptyUUID($inv.UUID_InventoryClassification))
			$o.textButNotLinked:=$o.textButNotLinked+1
		End if
	End if
	If (Not(cs.sfw_string.me.isAnEmptyUUID($inv.UUID_InventoryClassification)))
		$o.linked:=$o.linked+1
	End if
	If ($inv.units#"")
		$o.unitsTextFilled:=$o.unitsTextFilled+1
	End if
	If (Not(cs.sfw_string.me.isAnEmptyUUID($inv.UUID_InventoryUnits)))
		$o.unitsLinked:=$o.unitsLinked+1
	End if

	// expiration, IQA
	$o:=$report.expiry
	If ($inv.expirationDate=0)
		$o.expirationZero:=$o.expirationZero+1
	Else
		$o.expirationSet:=$o.expirationSet+1
	End if
	If ($inv.IQA_required)
		$o.iqaRequired:=$o.iqaRequired+1
	End if
	$o.iqaStatus.push($inv.IQA_status)
End for each

For each ($key; OB Keys($q))
	If ($q[$key]>1)
		$report.records.duplicateIds:=$report.records.duplicateIds+1
	End if
End for each
$report.records.legacyKeys:=_diag_inventoryTop($report.records.legacyKeys; 80)
$report.expiry.iqaStatus:=_diag_inventoryTop($report.expiry.iqaStatus; 20)
$report.locationTexts:=_diag_inventoryTop($values; 1000)
$report.binPaths:=ds.Bin.all().orderBy("binLocationPath asc").binLocationPath
$report.inventoryClassifications:=ds.InventoryClassification.all().orderBy("name asc").name
$report.classificationsOld:=ds.Classification.all().orderBy("name asc").name
$report.inventoryUnits:=ds.InventoryUnits.all().orderBy("name asc").name
$report.unitsOld:=ds.Unit.all().orderBy("name asc").name

// ---------------------------------------------------------------- the text version
$lines:=New collection
$lines.push("INVENTORY DIAG (new app) "+$report.date)
For each ($kind; New collection("records"; "quantities"; "pulls"; "bins"; "owner"; "classification"; "expiry"))
	$lines.push("")
	$lines.push(Uppercase($kind))
	For each ($key; OB Keys($report[$kind]))
		If (Value type($report[$kind][$key])=Is collection)
			$lines.push("  "+$key+": "+JSON Stringify($report[$kind][$key]))
		Else
			$lines.push("  "+$key+": "+String($report[$kind][$key]))
		End if
	End for each
End for each
For each ($kind; New collection("locationTexts"; "binPaths"; "inventoryClassifications"; "classificationsOld"; "inventoryUnits"; "unitsOld"))
	$lines.push("")
	$lines.push(Uppercase($kind)+" ("+String($report[$kind].length)+")")
	$lines.push("  "+JSON Stringify($report[$kind]))
End for each

Folder(fk database folder).folder("Project/imports").file("inventory_diag.txt").setText($lines.join("\r\n"))
Folder(fk database folder).folder("Project/imports").file("inventory_diag.json").setText(JSON Stringify($report; *))
ALERT("Inventory diagnostic written to Project/imports: inventory_diag.txt and inventory_diag.json.\rSend both to Claude.")
