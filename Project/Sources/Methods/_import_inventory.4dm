//%attributes = {}
//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $inventory : cs:C1710.InventoryEntity
var $result : Object
var $uniqueID : Text
var $stockNum : Text
var $travellerLot : Text
var $lot : cs:C1710.LotEntity
var $classificationDataClass : 4D.DataClass
var $classification : 4D.Entity
var $classificationValue : Text
var $unitsDataClass : 4D.DataClass
var $unit : 4D.Entity
var $unitValue : Text
var $created : Integer
var $boLine : cs:C1710.BuyingOrderLineEntity
var $boLineByKey : Object
var $rootKey; $part0; $part1 : Text
var $parts : Collection
var $splitIndex : Integer
var $isBuyOrderStock : Boolean
var $linkedBO; $unmatchedBO; $splitRows : Integer
var $staff : cs:C1710.StaffEntity
var $staffByCode : Object
var $receiverCode : Text
var $linkedReceiver; $unmatchedReceiver : Integer
var $updated : Integer
var $lineUUID : Text
var $inventoryByLine : Object
var $linkedLine; $clearedLinks; $unparsedBO : Integer

TRUNCATE TABLE:C1051([Inventory:126])

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("inventory_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$records:=JSON Parse:C1218($file.getText())
	$classificationDataClass:=ds["InventoryClassification"]
	$unitsDataClass:=ds["InventoryUnits"]
	
	//---Buy-order provenance ------------------------------------------------
	// Every legacy stock number that does not start with man_ is a buy-order receipt,
	// built by Update_inventoryNew("recv") as <BO #>_<Seq_Number>, with __<n> added by
	// CreateSplitStocks for each further vendor lot of the same receipt (30507_1284,
	// 30507_1284__1, ...). The part after the first _ is the buy item's legacy
	// Seq_Number - legacySeqNum here - NOT its item number: checked against the export,
	// it matches Seq_Number on all 762 such rows and the item number on none.
	//
	// Two links come out of it:
	//   Inventory.UUID_BuyingOrderLine   on EVERY lot of the receipt, root and splits
	//   BuyingOrderLine.UUID_Inventory   the line's one-to-one stock record: the ROOT lot
	//                                    (no __n suffix), which is the record
	//                                    Update_inventoryNew made; the splits were copied
	//                                    from it. 60 of the 685 receipts have splits, so
	//                                    their further lots are reached through the first
	//                                    link only.
	$boLineByKey:=New object:C1471()
	$inventoryByLine:=New object:C1471()
	$clearedLinks:=0
	For each ($boLine; ds:C1482.BuyingOrderLine.all())
		$boLineByKey[String:C10($boLine.boNumber)+"_"+String:C10($boLine.legacySeqNum)]:=$boLine.UUID
		//---TRUNCATE TABLE above removed every stock record, so any one-to-one link left
		//   from a previous run points at nothing. Cleared here, rebuilt after the loop.
		If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($boLine.UUID_Inventory))))
			$boLine.UUID_Inventory:=""
			$result:=$boLine.save()
			$clearedLinks:=$clearedLinks+1
		End if
	End for each

	//---[Inventory] has no receivedBy column; the receiver is the UUID_Staff FK behind
	// the "receiver" relation. Legacy [Inventory]Recd_by holds the employee CODE, the
	// same value _import_buyOrders matches on for the buy line's receiver.
	$staffByCode:=New object:C1471()
	For each ($staff; ds:C1482.Staff.all())
		$receiverCode:=Replace string:C233(String:C10($staff.code); " "; "")
		If ($receiverCode#"")
			$staffByCode[$receiverCode]:=$staff.UUID
		End if
	End for each

	$linkedReceiver:=0
	$unmatchedReceiver:=0

	$linkedBO:=0
	$unmatchedBO:=0
	$splitRows:=0
	$unparsedBO:=0

	$created:=0
	$updated:=0
	
	For each ($record; $records)
		$uniqueID:=String:C10($record.UniqueID)
		$stockNum:=String:C10($record.Stock_Num)
		$travellerLot:=String:C10($record.travellerLot)
		
		$inventory:=Null:C1517
		
		// Try by unique id first, then fallback to stock number.
		If ($uniqueID#"")
			$inventory:=ds:C1482.Inventory.query("UUID = :1"; $uniqueID).first()
		End if 
		
		If ($inventory=Null:C1517)
			If ($stockNum#"")
				$inventory:=ds:C1482.Inventory.query("stockNum = :1"; $stockNum).first()
			End if 
		End if 
		
		If ($inventory=Null:C1517)
			$inventory:=ds:C1482.Inventory.new()
			$created:=$created+1
		Else 
			$updated:=$updated+1
		End if 
		
		// Map exported legacy keys -> current Inventory table fields.
		$inventory.partNumber:=$record.Part_Number
		$inventory.vendor:=$record.Vendor
		$inventory.description:=$record.Description
		$inventory.qtyInStock:=$record.Qty_in_Stock
		$inventory.units:=$record.Units
		$inventory.unitCost:=$record.Unit_Cost
		$inventory.division:=$record.Division
		$inventory.stockNum:=$record.Stock_Num
		$inventory.dateIn:=$record.Date_in
		//---expirationDate is a numeric stamp (see createManualInv_lot, which writes it
		//   with sfw_stmp.build), but the export sends an ISO date. Assigning the date
		//   straight in left the column holding nothing usable - dateIn just above is a
		//   real Date column, which is why that one was fine.
		$inventory.expirationDate:=(Value type:C1509($record.Expiration_Date)=Is date:K8:7) && ($record.Expiration_Date#!00-00-00!)\
			 ? cs:C1710.sfw_stmp.me.build($record.Expiration_Date) : 0
		//---receiver: resolve the legacy employee code to a [Staff] record. The raw code is
		//   kept in moreData.legacy below when it does not match anyone.
		$receiverCode:=Replace string:C233(String:C10($record.Recd_by); " "; "")
		If ($receiverCode#"")
			If ($staffByCode[$receiverCode]#Null:C1517)
				$inventory.UUID_Staff:=$staffByCode[$receiverCode]
				$linkedReceiver:=$linkedReceiver+1
			Else
				$unmatchedReceiver:=$unmatchedReceiver+1
			End if
		End if
		$inventory.location:=$record.Bin_Location
		$inventory.actualValue:=$record.Current_Actual_Value
		$inventory.initialQty:=$record.Original_Qty
		$inventory.partLotNumber:=$record.LotNumber
		$inventory.classification:=$record.Classification
		$inventory.currency:=$record.Currency
		$inventory.availableQty:=$record.AvailableQty
		$inventory.docsInServer:=$record.DocumentsinDocserver
		$inventory.customerSpecific:=$record.CustomerSpecific
		
		//---resolve the buy line this stock was received against: anything not man_
		$isBuyOrderStock:=($stockNum#"") && Not:C34($stockNum="man_@")
		$rootKey:=""
		$splitIndex:=0
		If ($isBuyOrderStock)
			//---"30507_1284__1" splits into 30507 / 1284 / "" / 1
			$parts:=Split string:C1554($stockNum; "_")
			$part0:=($parts.length>=2) ? String:C10($parts[0]) : ""
			$part1:=($parts.length>=2) ? String:C10($parts[1]) : ""
			If (($part0#"") && (String:C10(Num:C11($part0))=$part0)) && (($part1#"") && (String:C10(Num:C11($part1))=$part1))
				$rootKey:=$part0+"_"+$part1
				If ($parts.length>2)
					$splitIndex:=Num:C11(String:C10($parts[$parts.length-1]))
				End if
			Else
				//---not man_, but not <BO #>_<Seq_Number> either: reported, left unlinked
				$isBuyOrderStock:=False:C215
				$unparsedBO:=$unparsedBO+1
			End if
		End if

		$lineUUID:=""
		If ($isBuyOrderStock)
			//---stockGroup keeps the legacy grouping as a readable label; the FKs are what
			//   anything actually queries
			$inventory.stockGroup:=$rootKey
			If ($boLineByKey[$rootKey]#Null:C1517)
				$lineUUID:=$boLineByKey[$rootKey]
				$inventory.UUID_BuyingOrderLine:=$lineUUID
				$linkedBO:=$linkedBO+1
			Else
				$unmatchedBO:=$unmatchedBO+1
			End if
			If ($splitIndex>0)
				$splitRows:=$splitRows+1
			End if
		End if

		//---initialQty is the opening balance of THIS lot. Legacy does not hold that for a
		//   split receipt: Update_inventoryNew puts the whole received quantity on the first
		//   lot and CreateSplitStocks writes 0 on every further one. A zero with stock still
		//   on the shelf is corrected here - but ONLY on a non-split row. On a split the
		//   parent already carries the whole receipt total, so correcting a child's zero
		//   would double-count it in qtyReceivedDisplay, which sums initialQty per group.
		//   Verified: sum(initialQty) per group equals the legacy Qtyin on 679 of 685.
		If (($splitIndex=0) && (Num:C11($inventory.initialQty)=0)) && (Num:C11($record.Qty_in_Stock)>0)
			$inventory.initialQty:=Num:C11($record.Qty_in_Stock)
		End if

		$inventory.moreData:=New object:C1471(\
		"importedBy"; "_import_inventory"; \
		"legacy"; New object:C1471(\
		"recdBy"; $record.Recd_by; \
			"stockNum"; $record.Stock_Num; \
		"stockGroup"; $record.StockGroup; \
		"stockGroupRoot"; $rootKey; \
		"splitIndex"; $splitIndex; \
		"originalQty"; $record.Original_Qty; \
		"originalQtyIsReceiptTotal"; Bool:C1537($record.originalQtyIsReceiptTotal); \
		"buyItemNumber"; $record.buyItemNumber; \
		"buyItemUniqueID"; $record.buyItemUniqueID; \
		"iqaDone"; Bool:C1537($record.IQADone); \
		"iqaPass"; Bool:C1537($record.IQAPass); \
		"iqaNumber"; String:C10($record.IQA_Number); \
		"iqaDate"; $record.IQADATE; \
		"iqaDoneBy"; String:C10($record.IQADoneBY)\
		)\
		)

		// Link to InventoryClassification table when available.
		$classificationValue:=String:C10($record.Classification)
		If ($classificationDataClass#Null:C1517) && ($classificationValue#"")
			$classification:=$classificationDataClass.query("code = :1"; $classificationValue).first()
			If ($classification=Null:C1517)
				$classification:=$classificationDataClass.query("name = :1"; $classificationValue).first()
			End if 
			If ($classification#Null:C1517)
				$inventory["UUID_InventoryClassification"]:=$classification.UUID
			End if 
		End if 
		
		// Link to InventoryUnits table when available.
		$unitValue:=String:C10($record.Units)
		If ($unitsDataClass#Null:C1517) && ($unitValue#"")
			$unit:=$unitsDataClass.query("name = :1"; $unitValue).first()
			If ($unit#Null:C1517)
				$inventory["UUID_InventoryUnits"]:=$unit.UUID
			End if 
		End if 
		
		// Preserve source UUID when provided; otherwise keep existing/new autogenerated UUID.
		If ($uniqueID#"")
			$inventory.UUID:=$uniqueID
		End if 
		
		// Link inventory to lot using traveller lot number from import json.
		If ($travellerLot#"")
			$lot:=ds:C1482.Lot.query("lotNumber = :1"; $travellerLot).first()
			If ($lot#Null:C1517)
				$inventory.UUID_Lot:=$lot.UUID
				$inventory.UUID_Job:=$lot.UUID_Job
			End if 
		End if 
		
		$result:=$inventory.save()
		If (Not:C34($result.success))
			TRACE:C157
		Else
			//---read back after the save: UUID is autogenerated, and the legacy UniqueID
			//   assigned above is not a UUID
			If ($lineUUID#"") && ($splitIndex=0)
				$inventoryByLine[$lineUUID]:=$inventory.UUID
			End if
		End if
	End for each 
	
	//---the line's one-to-one link to its stock record (root lot)
	$linkedLine:=0
	For each ($lineUUID; $inventoryByLine)
		$boLine:=ds:C1482.BuyingOrderLine.get($lineUUID)
		If ($boLine#Null:C1517)
			$boLine.UUID_Inventory:=$inventoryByLine[$lineUUID]
			$result:=$boLine.save()
			If ($result.success)
				$linkedLine:=$linkedLine+1
			End if
		End if
	End for each

	ALERT:C41("Import termine - created: "+String:C10($created)+" | updated: "+String:C10($updated)+"\r"+"buy-order stock linked: "+String:C10($linkedBO)+" | buy line not found: "+String:C10($unmatchedBO)+" | of which lot splits: "+String:C10($splitRows)+"\r"+"receiver linked: "+String:C10($linkedReceiver)+" | receiver code not found: "+String:C10($unmatchedReceiver)+"\r"+"not man_ but unparseable stock numbers: "+String:C10($unparsedBO)+"\r"+"buy lines linked to their stock record (UUID_Inventory): "+String:C10($linkedLine)+" | stale links cleared first: "+String:C10($clearedLinks))
End if 
