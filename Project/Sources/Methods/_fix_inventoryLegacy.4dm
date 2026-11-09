//%attributes = {}
// _fix_inventoryLegacy
// One-time repair of the stock imported from the legacy app (_import_inventory), after the legacy
// audits of Oct 2026 (Inventory_audit / Inventory_audit2 / _diag_inventory). Asks first: "Report only"
// changes nothing and writes Project/imports/inventory_fix.txt; "Apply" does the same and saves.
// Safe to run again (it only fills what is missing) - for instance once the legacy lots are imported.
// For each material:
//   - ID, code INV00001, stock number and barcode when missing (InventoryEntity.assignIdentity)
//   - the customer / job / received-by links that point to no record are emptied: these fields were
//     declared "autogenerate" and every record got a random value
//   - Received By from the legacy employee code (moreData.legacy.recdBy)
//   - the lot (and its job) from the legacy StockGroup, which holds the old lot's UniqueID - kept by
//     _import_lotinfo in Lot.moreData.legacyUniqueID: only once the old lots are imported
//   - the customer: the lot's customer, else the Vendor text when it is a customer's name
//   - the bin from the legacy location text ("WareHouseCBNT1 B1" -> "Warehouse/CBNT/CBNT1/B1");
//     a bin path that does not exist yet is created (the few the warehouse import missed)
//   - classification and units from their text, case and plural variants merged
//   - qtyInStock and the value follow the stock left (ga_stock.syncFigures)
// What cannot be matched is listed in the report and left as it is.

var $apply : Boolean
var $report; $staffByCode; $customerByName; $lotByKey; $binByPath; $classByKey; $unitByKey; $missing; $o : Object
var $lines; $created : Collection
var $inv; $lot; $bin; $e : 4D:C1709.Entity
var $key; $path; $text; $name : Text
var $save : Object
var $changed; $hasCustomer; $hasJob; $hasReceiver; $hasBin : Boolean
var $emptyUUID : Text
var $count : Integer

$emptyUUID:="0"*32  // an empty link, as the rest of the app writes it
$apply:=cs:C1710.sfw_dialog.me.confirm("Repair the stock imported from the legacy app?\r\r"+\
"Report only: writes Project/imports/inventory_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the materials (a few minutes)."; "Apply"; "Report only")

$report:=New object:C1471(\
"materials"; 0; "saved"; 0; "saveFailed"; 0; \
"identity"; 0; "danglingCleared"; 0; "receivedBy"; 0; "lot"; 0; "job"; 0; \
"customerFromLot"; 0; "customerFromVendor"; 0; "bin"; 0; "classification"; 0; "units"; 0; "figures"; 0)
$missing:=New object:C1471("location"; New object:C1471; "classification"; New object:C1471; "units"; New object:C1471; "customer"; New object:C1471; "receivedBy"; New object:C1471)
$created:=New collection:C1472

// ---------------------------------------------------------------- the lookups, built once
$staffByCode:=New object:C1471
For each ($e; ds:C1482.Staff.all())
	If (String:C10($e.code)#"")
		$staffByCode[String:C10($e.code)]:=$e.UUID
	End if
End for each
$customerByName:=New object:C1471
For each ($e; ds:C1482.Customer.all())
	$key:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace(String:C10($e.name)))
	If ($key#"")
		$customerByName[$key]:=$e.UUID
	End if
End for each
$lotByKey:=New object:C1471
For each ($e; ds:C1482.Lot.all())
	If ($e.moreData#Null:C1517)
		If (String:C10($e.moreData.legacyUniqueID)#"")
			$lotByKey[String:C10($e.moreData.legacyUniqueID)]:=$e.UUID
		End if
	End if
End for each
$binByPath:=New object:C1471
For each ($e; ds:C1482.Bin.all())
	If ($binByPath[String:C10($e.binLocationPath)]=Null:C1517)  // two bins can share a path: the first
		$binByPath[String:C10($e.binLocationPath)]:=$e.UUID
	End if
End for each
$classByKey:=_fix_inventoryNameKeys(ds:C1482.InventoryClassification.all())
$unitByKey:=_fix_inventoryNameKeys(ds:C1482.InventoryUnits.all())

// ---------------------------------------------------------------- every material
For each ($inv; ds:C1482.Inventory.all())
	$report.materials:=$report.materials+1
	$changed:=False:C215

	// identity
	If ($inv.inventoryID=0) || ($inv.code="") || ($inv.stockNum="") || ($inv.moreData=Null:C1517) || (String:C10($inv.moreData.barcodeData)="")
		If ($apply)
			$inv.assignIdentity()
		End if
		$report.identity:=$report.identity+1
		$changed:=True:C214
	End if

	// the links as they stand, read once BEFORE anything changes (reading a link after its field was
	// emptied in the same pass is what failed): a link is "set" only when it points to a record - the
	// customer, job and received-by fields were "autogenerate" and hold random values otherwise
	$hasCustomer:=(Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Customer))) && ($inv.customer#Null:C1517)
	$hasJob:=(Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Job))) && ($inv.job#Null:C1517)
	$hasReceiver:=(Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Staff))) && ($inv.receiver#Null:C1517)
	$hasBin:=(Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Location))) && ($inv.bin#Null:C1517)
	$lot:=Null:C1517
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Lot)))
		$lot:=$inv.lot
	End if 
	If (Not:C34($hasCustomer)) && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Customer)))
		$inv.UUID_Customer:=$emptyUUID
		$report.danglingCleared:=$report.danglingCleared+1
		$changed:=True:C214
	End if
	If (Not:C34($hasJob)) && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Job)))
		$inv.UUID_Job:=$emptyUUID
		$report.danglingCleared:=$report.danglingCleared+1
		$changed:=True:C214
	End if
	If (Not:C34($hasReceiver)) && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_Staff)))
		$inv.UUID_Staff:=$emptyUUID
		$report.danglingCleared:=$report.danglingCleared+1
		$changed:=True:C214
	End if

	// received by: the legacy employee code
	If (Not:C34($hasReceiver)) && ($inv.moreData#Null:C1517)
		If ($inv.moreData.legacy#Null:C1517)
			$key:=String:C10($inv.moreData.legacy.recdBy)
			If ($key#"")
				If ($staffByCode[$key]#Null:C1517)
					$inv.UUID_Staff:=$staffByCode[$key]
					$report.receivedBy:=$report.receivedBy+1
					$changed:=True:C214
				Else
					$missing.receivedBy[$key]:=Num:C11($missing.receivedBy[$key])+1
				End if
			End if
		End if
	End if

	// the lot, through the old lot's UniqueID kept in StockGroup
	If ($lot=Null:C1517) && ($inv.moreData#Null:C1517)
		If ($inv.moreData.legacy#Null:C1517)
			$key:=String:C10($inv.moreData.legacy.stockGroup)
			If ($key#"") && ($lotByKey[$key]#Null:C1517)
				$inv.UUID_Lot:=$lotByKey[$key]
				$lot:=ds:C1482.Lot.get($lotByKey[$key])
				$report.lot:=$report.lot+1
				$changed:=True:C214
			End if
		End if
	End if
	If ($lot#Null:C1517) && (Not:C34($hasJob))
		If ($lot.job#Null:C1517)
			$inv.UUID_Job:=$lot.job.UUID
			$report.job:=$report.job+1
			$changed:=True:C214
		End if
	End if

	// the customer: the lot's, else the Vendor text when it names a customer
	If (Not:C34($hasCustomer))
		$e:=Null:C1517
		If ($lot#Null:C1517)
			If ($lot.job#Null:C1517)
				$e:=$lot.job.customer
			End if
		End if
		Case of
			: ($e#Null:C1517)
				$inv.UUID_Customer:=$e.UUID
				$report.customerFromLot:=$report.customerFromLot+1
				$changed:=True:C214
			: ($inv.customerSpecific)
				$key:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace(String:C10($inv.vendor)))
				If ($customerByName[$key]#Null:C1517)
					$inv.UUID_Customer:=$customerByName[$key]
					$report.customerFromVendor:=$report.customerFromVendor+1
					$changed:=True:C214
				Else
					$missing.customer[String:C10($inv.vendor)]:=Num:C11($missing.customer[String:C10($inv.vendor)])+1
				End if
		End case
	End if

	// the bin, from the location text
	If (Not:C34($hasBin)) && (cs:C1710.sfw_string.me.trimSpace(String:C10($inv.location))#"")
		$path:=_fix_inventoryBinPath($inv.location)
		If ($path="")
			$missing.location[$inv.location]:=Num:C11($missing.location[$inv.location])+1
		Else
			If ($binByPath[$path]=Null:C1517)
				// a bin the warehouse import did not have: created (Apply) once
				If ($apply)
					$bin:=ds:C1482.Bin.new()
					$bin.binLocationPath:=$path
					$bin.assignBarcode()
					$save:=$bin.save()
					If ($save.success)
						$binByPath[$path]:=$bin.UUID
					End if
				Else
					$binByPath[$path]:="(to create)"
				End if
				$created.push($path)
			End if
			If ($binByPath[$path]#Null:C1517)
				If ($apply)
					$inv.UUID_Location:=$binByPath[$path]
					$inv.location:=$path
				End if
				$report.bin:=$report.bin+1
				$changed:=True:C214
			End if
		End if
	End if

	// classification and units, by name
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_InventoryClassification)) && (String:C10($inv.classification)#"")
		$o:=_fix_inventoryNameFind($classByKey; $inv.classification)
		If ($o#Null:C1517)
			$inv.UUID_InventoryClassification:=$o.UUID
			$inv.classification:=$o.name
			$report.classification:=$report.classification+1
			$changed:=True:C214
		Else
			$missing.classification[$inv.classification]:=Num:C11($missing.classification[$inv.classification])+1
		End if
	End if
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($inv.UUID_InventoryUnits)) && (String:C10($inv.units)#"")
		$o:=_fix_inventoryNameFind($unitByKey; $inv.units)
		If ($o#Null:C1517)
			$inv.UUID_InventoryUnits:=$o.UUID
			$inv.units:=$o.name
			$report.units:=$report.units+1
			$changed:=True:C214
		Else
			$missing.units[$inv.units]:=Num:C11($missing.units[$inv.units])+1
		End if
	End if

	// one stock figure, and the value that follows it
	If ($inv.qtyInStock#$inv.availableQty) || ($inv.actualValue#Round:C94($inv.availableQty*Num:C11($inv.unitCost); 2))
		cs:C1710.ga_stock.me.syncFigures($inv)
		$report.figures:=$report.figures+1
		$changed:=True:C214
	End if

	If ($apply) && ($changed)
		$save:=$inv.save()
		If ($save.success)
			$report.saved:=$report.saved+1
		Else
			$report.saveFailed:=$report.saveFailed+1
		End if
	End if
End for each

// ---------------------------------------------------------------- the report
$lines:=New collection:C1472
$lines.push("INVENTORY REPAIR - "+($apply ? "APPLIED" : "REPORT ONLY, nothing changed")+" - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178))
For each ($key; New collection:C1472("materials"; "saved"; "saveFailed"; "identity"; "danglingCleared"; "receivedBy"; "lot"; "job"; "customerFromLot"; "customerFromVendor"; "bin"; "classification"; "units"; "figures"))
	$lines.push("  "+$key+": "+String:C10($report[$key]))
End for each
$lines.push("")
$lines.push("Bins "+($apply ? "created" : "to create")+" ("+String:C10($created.distinct().length)+"): "+$created.distinct().join(", "))
For each ($key; New collection:C1472("location"; "classification"; "units"; "customer"; "receivedBy"))
	$lines.push("")
	$lines.push("Not matched - "+$key+" ("+String:C10(OB Keys:C1719($missing[$key]).length)+" values):")
	For each ($o; _diag_inventoryTop(_fix_inventoryExpand($missing[$key]); 200))
		$lines.push("  "+String:C10($o.value)+": "+String:C10($o.count))
	End for each
End for each
$lines.push("")
$lines.push("Not repairable here: the expiration dates entered by hand in the legacy app (about 640) were not kept by the import.")

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("inventory_fix.txt").setText($lines.join("\r\n"))
If (Storage:C1525.cache#Null:C1517)
	Use (Storage:C1525.cache)
		Storage:C1525.cache.bins:=Null:C1517  // the bin picker reloads its list
	End use
End if
ALERT:C41(($apply ? "Repair applied" : "Report only (nothing changed)")+": Project/imports/inventory_fix.txt.\r"+String:C10($report.materials)+" materials, "+String:C10($report.saved)+" saved, "+String:C10($report.saveFailed)+" could not be saved.")
