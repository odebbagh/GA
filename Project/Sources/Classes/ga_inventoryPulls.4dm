// ga_inventoryPulls
// Pulling material for a lot step and putting it back, from Punch In / Punch OUT. Built on how the
// old database was really used (Pull_audit, Oct 2026): material is pulled at the step that
// consumes it (incoming inspection, die attach, wafer mount, lid load...), most often all of it at
// once; the same pull was often recorded twice; reasons such as Variance or Scrap were stock
// corrections made from the inventory screen, not production pulls. So:
//   - each pull records its lot, its step, its cost and the reason "Production"
//   - the quantity proposed is everything still available
//   - pulling the same material again at the same step asks for confirmation
//   - expired material, or material whose incoming inspection is not done, asks for confirmation
//   - nothing goes back once the step is punched out (the old app's rule)
//   - when the lot's last step is punched out, the material still in stock for it is listed
singleton Class constructor
	
Function reasons()->$reasons : Collection
	// stock corrections made from Customer Service > Inventories (the old app's adjustment list)
	$reasons:=New collection:C1472("Load Line"; "Variance"; "Scrap"; "Recycle"; "Return per Customer"; "Engineering Samples"; "IQA")
	
Function pullForStep($lotStep : 4D:C1709.Entity)->$done : Boolean
	var $lot; $inv : 4D:C1709.Entity
	var $items : 4D:C1709.EntitySelection
	var $form; $result : Object
	var $winRef : Integer
	var $already : Real
	var $warning; $jobUUID : Text
	
	$done:=False:C215
	If ($lotStep=Null:C1517)
		return 
	End if 
	$lot:=$lotStep.lot
	If ($lot=Null:C1517)
		return 
	End if 
	$jobUUID:=""
	If ($lot.job#Null:C1517)
		$jobUUID:=$lot.job.UUID
	End if 
	$items:=InventoryPullForm_pullList($lot.UUID; $jobUUID)
	If ($items.length=0)
		cs:C1710.sfw_dialog.me.alert("No inventory with available quantity found for this lot.")
		return 
	End if 
	$form:=New object:C1471("inventoryItems"; $items; "selectedInventory"; Null:C1517; "inventoryDisplay"; ""; "availableQty"; 0; "qtyToPull"; 0; "performedBy"; "")
	$winRef:=Open form window:C675("pullFromInventory"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("pullFromInventory"; $form)
	CLOSE WINDOW:C154($winRef)
	If (OK#1)
		return 
	End if 
	$inv:=$form.selectedInventory
	
	// the same material already pulled at this step: the old database often recorded a pull twice
	$already:=ds:C1482.InventoryPull.query("UUID_LotStep = :1 AND UUID_Inventory = :2 AND type = :3"; $lotStep.UUID; $inv.UUID; "Pull").sum("qty")
	If ($already>0)
		If (Not:C34(cs:C1710.sfw_dialog.me.confirm(String:C10($inv.code)+" was already pulled at this step ("+String:C10($already)+"). Pull "+String:C10($form.qtyToPull)+" more?"; "Pull"; "Cancel")))
			return 
		End if 
	End if 
	// expired, or incoming inspection not done: allowed, after a confirmation
	$warning:=This:C1470.warning($inv)
	If ($warning#"")
		If (Not:C34(cs:C1710.sfw_dialog.me.confirm($warning+"\rPull it anyway?"; "Pull"; "Cancel")))
			return 
		End if 
	End if 
	
	$result:=InventoryPullForm_savePull($lot; $inv; $form.qtyToPull; $form.performedBy; $lotStep)
	If ($result.success)
		$done:=True:C214
	Else 
		cs:C1710.sfw_dialog.me.alert($result.message)
	End if 
	
Function putBackForStep($lotStep : 4D:C1709.Entity)->$done : Boolean
	var $lot; $stored : 4D:C1709.Entity
	var $items : Collection
	var $form; $result : Object
	var $winRef : Integer
	var $jobUUID : Text
	
	$done:=False:C215
	If ($lotStep=Null:C1517)
		return 
	End if 
	// nothing goes back once the step is punched out (the old app's rule): the stock is then
	// corrected from Customer Service > Inventories
	$stored:=ds:C1482.LotStep.get($lotStep.UUID)
	If ($stored#Null:C1517)
		If ($stored.dateOut#!00-00-00!) || ($stored.qtyOut>0)
			cs:C1710.sfw_dialog.me.alert("This step is punched out: material can no longer be put back from it.\rCorrect the stock from Customer Service > Inventories.")
			return 
		End if 
	End if 
	$lot:=$lotStep.lot
	If ($lot=Null:C1517)
		return 
	End if 
	$jobUUID:=""
	If ($lot.job#Null:C1517)
		$jobUUID:=$lot.job.UUID
	End if 
	$items:=InventoryPullForm_putBackList($lot.UUID; $jobUUID)
	If ($items.length=0)
		cs:C1710.sfw_dialog.me.alert("No pulled inventory available to put back for this lot.")
		return 
	End if 
	$form:=New object:C1471("inventoryItems"; $items; "selectedInventory"; Null:C1517; "inventoryDisplay"; ""; "maxQty"; 0; "qtyToPutBack"; 0; "performedBy"; ""; "lotUUID"; $lot.UUID)
	$winRef:=Open form window:C675("putBackToInventory"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("putBackToInventory"; $form)
	CLOSE WINDOW:C154($winRef)
	If (OK#1)
		return 
	End if 
	$result:=InventoryPullForm_savePutBack($lot; $form.selectedInventory; $form.qtyToPutBack; $form.performedBy; $lotStep)
	If ($result.success)
		$done:=True:C214
	Else 
		cs:C1710.sfw_dialog.me.alert($result.message)
	End if 
	
Function warning($inv : 4D:C1709.Entity)->$text : Text
	// what to confirm before pulling: expired material, incoming inspection (IQA) not done
	var $lines : Collection
	
	$lines:=New collection:C1472
	// expirationDate is a numeric stamp: InventoryEntity.expirationDate_d is the date it stands for
	If ($inv.expirationDate_d#!00-00-00!) && ($inv.expirationDate_d<Current date:C33)
		$lines.push(String:C10($inv.code)+" expired on "+String:C10($inv.expirationDate_d)+".")
	End if
	If (Bool:C1537($inv.IQA_required)) && (String:C10($inv.IQA_status)#"Done")
		$lines.push("The incoming inspection (IQA) of "+String:C10($inv.code)+" is not done.")
	End if 
	$text:=$lines.join("\r")
	
Function leftoverAtEnd($lotStep : 4D:C1709.Entity)
	// The lot's last step has just been punched out: its customer material still in stock is listed,
	// to be returned or written off now (the old database cleared it by batches, years later).
	var $left : 4D:C1709.EntitySelection
	var $inv : 4D:C1709.Entity
	var $lines : Collection
	
	If ($lotStep.lot=Null:C1517)
		return 
	End if 
	If ($lotStep.lot.lotSteps.query("order > :1"; $lotStep.order).length>0)
		return 
	End if 
	$left:=ds:C1482.Inventory.query("UUID_Lot = :1 AND availableQty > :2"; $lotStep.lot.UUID; 0).orderBy("code asc")
	If ($left.length=0)
		return 
	End if 
	$lines:=New collection:C1472
	For each ($inv; $left)
		$lines.push(String:C10($inv.code)+"  "+String:C10($inv.partNumber)+": "+String:C10($inv.availableQty)+" left")
	End for each 
	cs:C1710.sfw_dialog.me.alert("The last step of lot "+$lotStep.lot.displayNumber+" is punched out and some of its material is still in stock:\r"+$lines.join("\r")+"\rReturn it to the customer or write it off from Customer Service > Inventories (reason Return per Customer or Scrap).")
	
