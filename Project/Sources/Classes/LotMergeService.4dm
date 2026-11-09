singleton Class constructor
	// Lot merge: one lot of the same job is merged WHOLE into the current lot, at the current
	// step. Rules taken from the legacy app (erp2020v18: merge_dialog, mergeLot,
	// CreateAcquiringStep / CreateMergingStep / SaveMergingLot):
	// - candidates: lots of the same job, not merged, not shipped, not the lot itself
	// - warnings only: other device, other process, other current area, several devices in the job
	// - the merged lot ("dying" lot) keeps nothing: count 0, date out today, location "merged",
	//   carrier / tracking cleared, comment "Acquired by lot# X Job# J By U On D"
	// - the receiving lot gets the count, the date codes, the serial numbers and the bin quantities
	//   of its current step; incompatible bins or a serial number active in both lots refuse it
	// The new app documents the merge in the lot histories (ga_events) and in moreData
	// (mergedInto / merges) instead of the legacy 501 / 502 / 503 steps, so the traveler orders
	// and the punch in / out "current step" stay untouched.
	
Function canMerge($lot : Variant; $ctx : Object)->$result : Object
	var $inModification : Boolean
	var $currentStep : cs:C1710.LotStepEntity
	
	$result:=New object:C1471("allowed"; False:C215; "message"; ""; "currentStep"; Null:C1517)
	
	If ($lot=Null:C1517)
		$result.message:="No lot is selected."
		return 
	End if 
	$inModification:=True:C214
	If (($ctx#Null:C1517) && ($ctx.inModification#Null:C1517))
		$inModification:=Bool:C1537($ctx.inModification)
	End if 
	Case of 
		: (Not:C34($inModification))
			$result.message:="You must be in modification mode to merge lots."
		: ($lot.isNew())
			$result.message:="Save the lot before merging another lot into it."
		: ($lot.dateIn=!00-00-00!)
			$result.message:="This lot is not active yet (no date in)."
		: ($lot.dateOut#!00-00-00!)
			$result.message:="Cannot merge into a lot that has already shipped (date out is set)."
		: (Bool:C1537($lot.onHold))
			$result.message:="Cannot merge into a lot that is on hold."
		: (This:C1470.isMerged($lot))
			$result.message:="This lot was merged into lot "+String:C10($lot.moreData.mergedInto.lotNumber)+": it cannot receive another lot."
		: (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($lot.UUID_Job)))
			$result.message:="This lot has no job: only lots of the same job can be merged."
		Else 
			$currentStep:=cs:C1710.LotSplitService.me.resolveCurrentStep($lot)
			Case of 
				: ($currentStep=Null:C1517)
					$result.message:="You can't merge into a completed lot."
				: (Bool:C1537($currentStep.sample))
					$result.message:="Merge is not allowed on a sample step."
				: (cs:C1710.panel_planning.me.isLotStepPropertyEnabled($currentStep; "Outside Of Count Rules"))
					$result.message:="Merge is not allowed when Outside Of Count Rules applies to the current step."
				Else 
					$result.allowed:=True:C214
					$result.currentStep:=$currentStep
			End case 
	End case 
	
Function isMerged($lot : Variant)->$merged : Boolean
	$merged:=False:C215
	If ($lot#Null:C1517) && ($lot.moreData#Null:C1517)
		$merged:=($lot.moreData.mergedInto#Null:C1517)
	End if 
	
Function candidates($lot : Variant)->$rows : Collection
	// Lots of the same job that can be merged into $lot, with their warnings
	var $other : cs:C1710.LotEntity
	var $check : Object
	var $step : cs:C1710.LotStepEntity
	
	$rows:=New collection:C1472
	If ($lot=Null:C1517)
		return 
	End if 
	For each ($other; ds:C1482.Lot.query("UUID_Job = :1 AND UUID # :2 AND dateOut = :3"; $lot.UUID_Job; $lot.UUID; !00-00-00!).orderBy("lotNumber asc, subSequence asc"))
		If (Not:C34(This:C1470.isMerged($other)))
			$check:=This:C1470.checkMerge($lot; $other)
			$step:=cs:C1710.LotSplitService.me.resolveCurrentStep($other)
			$rows.push(New object:C1471(\
				"UUID"; $other.UUID; \
				"lotNumber"; $other.displayNumber; \
				"subSequence"; Choose:C955(Num:C11($other.subSequence)=0; ""; String:C10($other.subSequence)); \
				"device"; String:C10($other.device); \
				"ourCount"; $other.ourCount; \
				"dateCode"; String:C10($other.dateCode); \
				"currentStep"; ($step=Null:C1517) ? "(completed)" : (String:C10($step.order)+" - "+String:C10($step.description)); \
				"allowed"; $check.allowed; \
				"status"; Choose:C955($check.allowed; Choose:C955($check.warnings.length=0; "OK"; "Warning"); "Blocked"); \
				"message"; Choose:C955($check.allowed; $check.warnings.join("\r"); $check.message)\
				))
		End if 
	End for each 
	
Function checkMerge($mother : Variant; $child : Variant)->$result : Object
	// Blocking rules (allowed / message) and legacy warnings (warnings) for merging $child into $mother
	var $motherStep : cs:C1710.LotStepEntity
	var $childStep : cs:C1710.LotStepEntity
	var $devices : Collection
	var $conflicts : Collection
	var $bin : Object
	var $motherItems : Collection
	var $found : Collection
	var $snItem : Object
	
	$result:=New object:C1471("allowed"; False:C215; "message"; ""; "warnings"; New collection:C1472)
	
	If ($mother=Null:C1517) || ($child=Null:C1517)
		$result.message:="No lot to merge."
		return 
	End if 
	$motherStep:=cs:C1710.LotSplitService.me.resolveCurrentStep($mother)
	$childStep:=cs:C1710.LotSplitService.me.resolveCurrentStep($child)
	
	Case of 
		: ($child.UUID=$mother.UUID)
			$result.message:="A lot cannot be merged into itself."
		: (String:C10($child.UUID_Job)#String:C10($mother.UUID_Job))
			$result.message:="Only lots of the same job can be merged."
		: ($child.dateOut#!00-00-00!)
			$result.message:="Lot "+$child.displayNumber+" has already shipped."
		: (This:C1470.isMerged($child))
			$result.message:="Lot "+$child.displayNumber+" was already merged."
		: ($child.dateIn=!00-00-00!)
			$result.message:="Lot "+$child.displayNumber+" is not active yet (no date in)."
		: (Bool:C1537($child.onHold))
			$result.message:="Lot "+$child.displayNumber+" is on hold: release it first."
		: ($child.ourCount<=0)
			$result.message:="Lot "+$child.displayNumber+" has no quantity to merge."
		: ($childStep=Null:C1517)
			$result.message:="Lot "+$child.displayNumber+" has finished its traveler."
		: (Bool:C1537($child.serialization)#Bool:C1537($mother.serialization))
			$result.message:="A serialized lot and a non-serialized lot cannot be merged."
		Else 
			$result.allowed:=True:C214
	End case 
	If (Not:C34($result.allowed))
		return
	End if

	// both lots at the same step (SplitMerge_audit, Oct 2026: the only merge of the legacy history was
	// made at the same step, the day of the split). Merged at another step, the units would run steps
	// again on this lot, or the merged lot would get a punched-out step it never ran.
	If ($motherStep#Null:C1517)
		If (Int:C8($childStep.order)#Int:C8($motherStep.order))
			$result.allowed:=False:C215
			$result.message:="Lot "+$child.displayNumber+" is at step "+String:C10($childStep.order)+" and this lot at step "+String:C10($motherStep.order)+": lots are merged at the same step."
			return
		End if
	End if

	// bins: every bin holding parts in the merged lot's current step must exist in the receiving step
	If ($motherStep#Null:C1517) && ($childStep.bins#Null:C1517) && ($childStep.bins.items#Null:C1517)
		$motherItems:=(($motherStep.bins#Null:C1517) && ($motherStep.bins.items#Null:C1517)) ? $motherStep.bins.items : New collection:C1472
		For each ($bin; $childStep.bins.items)
			If (Num:C11($bin.quantity)#0) && ($motherItems.query("num = :1"; Num:C11($bin.num)).length=0)
				$result.allowed:=False:C215
				$result.message:="Incompatible bins: bin "+String:C10($bin.num)+" "+String:C10($bin.definition)+" of lot "+$child.displayNumber+" does not exist at the current step of this lot."
				return 
			End if 
		End for each 
	End if 
	
	// serial numbers: a unit cannot be active in both lots
	If (Bool:C1537($child.serialization))
		$conflicts:=New collection:C1472
		$motherItems:=(($mother.snTable#Null:C1517) && ($mother.snTable.items#Null:C1517)) ? $mother.snTable.items : New collection:C1472
		For each ($snItem; This:C1470._activeSn($child))
			$found:=$motherItems.query("id = :1"; $snItem.id)
			If ($found.length>0)
				If (Not:C34(Bool:C1537($found[0].split_out)))
					$conflicts.push(String:C10($snItem.id))
				End if 
			End if 
		End for each 
		If ($conflicts.length>0)
			$result.allowed:=False:C215
			$result.message:="Serial number(s) active in both lots: "+$conflicts.join(", ")
			return 
		End if 
	End if 
	
	// legacy warnings (the user decides)
	If (String:C10($child.device)#String:C10($mother.device))
		$result.warnings.push("Device differs: "+String:C10($child.device)+" (this lot: "+String:C10($mother.device)+")")
	End if 
	If (String:C10($child.process)#String:C10($mother.process))
		$result.warnings.push("Process differs: "+String:C10($child.process)+" (this lot: "+String:C10($mother.process)+")")
	End if 
	If ($motherStep#Null:C1517)
		If (String:C10($childStep.description)#String:C10($motherStep.description))
			$result.warnings.push("At another step: "+String:C10($childStep.order)+" "+String:C10($childStep.description)+" (this lot: "+String:C10($motherStep.order)+" "+String:C10($motherStep.description)+")")
		End if 
	End if 
	If (String:C10($child.currentOrNextArea)#String:C10($mother.currentOrNextArea))
		$result.warnings.push("Current / next area differs: "+String:C10($child.currentOrNextArea)+" (this lot: "+String:C10($mother.currentOrNextArea)+")")
	End if 
	$devices:=ds:C1482.Lot.query("UUID_Job = :1"; $mother.UUID_Job).distinct("device")
	If ($devices.length>1)
		$result.warnings.push("This job has several devices: "+$devices.join(", "))
	End if 
	
Function executeMerge($mother : Variant; $childUUID : Text)->$result : Object
	// Merges the whole lot $childUUID into $mother at $mother's current step.
	// Persistence contract (same as LotSplitService.executeSplit):
	// - the merged lot and every LotStep record are saved here
	// - the receiving lot ($mother, the panel's current item) is only changed in memory
	//   (ourCount, dateCode, snTable, comment, moreData): the panel save confirms it
	var $child : cs:C1710.LotEntity
	var $check : Object
	var $motherStep : cs:C1710.LotStepEntity
	var $childStep : cs:C1710.LotStepEntity
	var $step : cs:C1710.LotStepEntity
	var $res : Object
	var $qty : Integer
	var $by : Text
	var $jobNumber : Text
	var $bin : Object
	var $target : Collection
	var $moved : Collection
	var $snItem : Object
	var $copy : Object
	var $found : Collection
	var $codes : Collection
	var $code : Text
	var $stepModified : Boolean
	var $record : Object
	
	$result:=New object:C1471("success"; False:C215; "message"; ""; "child"; Null:C1517; "quantity"; 0; "movedSn"; New collection:C1472)
	
	$child:=ds:C1482.Lot.get($childUUID)
	$check:=This:C1470.checkMerge($mother; $child)
	If (Not:C34($check.allowed))
		$result.message:=$check.message
		return 
	End if 
	$motherStep:=cs:C1710.LotSplitService.me.resolveCurrentStep($mother)
	$childStep:=cs:C1710.LotSplitService.me.resolveCurrentStep($child)
	$qty:=$child.ourCount
	$by:=String:C10(cs:C1710.sfw_userManager.me.info.name)
	If ($by="")
		$by:=String:C10(cs:C1710.sfw_userManager.me.info.login)
	End if 
	$jobNumber:=($mother.job#Null:C1517) ? String:C10($mother.job.jobNumber) : ""
	
	// serial numbers leaving the merged lot
	$moved:=New collection:C1472
	If (Bool:C1537($child.serialization))
		For each ($snItem; This:C1470._activeSn($child))
			$copy:=OB Copy:C1225($snItem)
			$copy.split_out:=False:C215
			$copy.comments:=String:C10($copy.comments)+" Merge+ "
			$moved.push($copy)
		End for each 
	End if 
	
	// ---- the merged lot: closed, nothing retained ----
	$record:=New object:C1471("UUID"; $mother.UUID; "lotNumber"; $mother.displayNumber; "subSequence"; $mother.subSequence; "quantity"; $qty; "date"; String:C10(Current date:C33; ISO date:K1:8); "time"; String:C10(Current time:C178; HH MM:K7:2); "by"; $by)
	If ($child.moreData=Null:C1517)
		$child.moreData:=New object:C1471
	End if 
	$child.moreData.mergedInto:=$record
	$child.moreData:=$child.moreData
	$child.ourCount:=0
	$child.dateOut:=Current date:C33
	$child.location:="merged"
	$child.carrier:=""
	$child.trackingNumber:=""
	$child.comment:=This:C1470._appendLine(String:C10($child.comment); "Acquired by lot# "+$mother.displayNumber+" Job# "+$jobNumber+" By "+$by+" On "+String:C10(Current date:C33))
	If ($moved.length>0)
		For each ($snItem; $child.snTable.items)
			If ($moved.query("id = :1"; $snItem.id).length>0)
				$snItem.split_out:=True:C214
			End if 
		End for each 
		$child.snTable:=$child.snTable
	End if 
	$res:=$child.save()
	If (Not:C34($res.success))
		$result.message:="Lot "+$child.displayNumber+" could not be saved (is it open somewhere else?). Nothing was merged."
		return 
	End if 
	
	// its current step: punched out with nothing retained
	$childStep.qtyIn:=Choose:C955($childStep.qtyIn>0; $childStep.qtyIn; $qty)
	$childStep.qtyOut:=0
	$childStep.dateIn:=Choose:C955($childStep.dateIn=!00-00-00!; Current date:C33; $childStep.dateIn)
	$childStep.dateOut:=Current date:C33
	$childStep.timeOut:=Current time:C178
	$childStep.outOperator:=$by
	$childStep.comment1:=This:C1470._appendLine(String:C10($childStep.comment1); "Merged. Retained: 0. Acquired by lot# "+$mother.displayNumber)
	$res:=$childStep.save()
	If (Not:C34($res.success))
		$result.message:="Lot "+$child.displayNumber+" was closed but its current step could not be updated (record locked?)."
		return 
	End if 
	
	// ---- receiving lot's steps, from the current step onward ----
	If ($motherStep#Null:C1517)
		For each ($step; ds:C1482.LotStep.query("UUID_Lot = :1 AND order >= :2"; $mother.UUID; $motherStep.order).orderBy("order asc"))
			$stepModified:=False:C215
			If ($step.UUID=$motherStep.UUID)
				// quantity entering the step (only once the step is punched in, as for split)
				If ($step.qtyIn>0)
					$step.qtyIn:=$step.qtyIn+$qty
					$stepModified:=True:C214
				End if 
				// consolidation: the merged lot's bin quantities are added bin by bin
				If ($childStep.bins#Null:C1517) && ($childStep.bins.items#Null:C1517) && ($step.bins#Null:C1517) && ($step.bins.items#Null:C1517)
					For each ($bin; $childStep.bins.items)
						If (Num:C11($bin.quantity)#0)
							$target:=$step.bins.items.query("num = :1"; Num:C11($bin.num))
							$target[0].quantity:=Num:C11($target[0].quantity)+Num:C11($bin.quantity)
							$stepModified:=True:C214
						End if 
					End for each 
					$step.bins:=$step.bins
				End if 
				$step.comment1:=This:C1470._appendLine(String:C10($step.comment1); "Acquired lot# "+$child.displayNumber+" (qty "+String:C10($qty)+") on "+String:C10(Current date:C33)+" by "+$by)
				$stepModified:=True:C214
			End if 
			// serial numbers follow the lot on its SN steps (SNA / SNF)
			If ($moved.length>0) && (cs:C1710.ga_serialization.me.isSnStep($step)) && ($step.snTable#Null:C1517) && ($step.snTable.items#Null:C1517)
				For each ($snItem; $moved)
					If ($step.snTable.items.query("id = :1"; $snItem.id).length=0)
						$step.snTable.items.push(OB Copy:C1225($snItem))
					End if 
				End for each 
				$step.snTable.items:=$step.snTable.items.orderBy("id asc")
				$step.snTable:=$step.snTable
				$stepModified:=True:C214
			End if 
			If ($stepModified)
				$res:=$step.save()
				If (Not:C34($res.success))
					$result.message:="Lot "+$child.displayNumber+" was closed but step "+String:C10($step.order)+" of this lot could not be updated (record locked?). Check the quantities."
					return 
				End if 
			End if 
		End for each 
	End if 
	
	// ---- receiving lot: in memory, confirmed by the panel save ----
	$mother.ourCount:=$mother.ourCount+$qty
	$codes:=Split string:C1554(String:C10($mother.dateCode); ","; sk trim spaces:K86:2+sk ignore empty strings:K86:1)
	For each ($code; Split string:C1554(String:C10($child.dateCode); ","; sk trim spaces:K86:2+sk ignore empty strings:K86:1))
		If ($codes.indexOf($code)=-1)
			$codes.push($code)
		End if 
	End for each 
	$mother.dateCode:=$codes.join(",")
	$mother.comment:=This:C1470._appendLine(String:C10($mother.comment); "merged lot# "+$child.displayNumber+" (qty "+String:C10($qty)+") on "+String:C10(Current date:C33)+" by "+$by)
	If ($moved.length>0)
		If ($mother.snTable=Null:C1517)
			$mother.snTable:=New object:C1471("items"; New collection:C1472)
		End if 
		For each ($snItem; $moved)
			$found:=$mother.snTable.items.query("id = :1"; $snItem.id)
			If ($found.length>0)
				// a unit split out earlier comes back
				$found[0].split_out:=False:C215
				$found[0].pass:=$snItem.pass
				$found[0].comments:=$snItem.comments
			Else 
				$mother.snTable.items.push(OB Copy:C1225($snItem))
			End if 
		End for each 
		$mother.snTable.items:=$mother.snTable.items.orderBy("id asc")
		$mother.snTable:=$mother.snTable
	End if 
	If ($mother.moreData=Null:C1517)
		$mother.moreData:=New object:C1471
	End if 
	If ($mother.moreData.merges=Null:C1517)
		$mother.moreData.merges:=New collection:C1472
	End if 
	$mother.moreData.merges.push(New object:C1471("UUID"; $child.UUID; "lotNumber"; $child.displayNumber; "subSequence"; $child.subSequence; "quantity"; $qty; "sn"; $moved.extract("id"); "date"; $record.date; "time"; $record.time; "by"; $by; "step"; ($motherStep=Null:C1517) ? "" : (String:C10($motherStep.order)+" "+String:C10($motherStep.description))))
	$mother.moreData:=$mother.moreData
	
	$result.success:=True:C214
	$result.child:=$child
	$result.quantity:=$qty
	$result.movedSn:=$moved.extract("id")
	$result.warnings:=$check.warnings
	
Function _activeSn($lot : Variant)->$items : Collection
	// serial numbers still in $lot (not split out to a sublot)
	var $snItem : Object
	
	$items:=New collection:C1472
	If ($lot.snTable=Null:C1517) || ($lot.snTable.items=Null:C1517)
		return 
	End if 
	For each ($snItem; $lot.snTable.items)
		If (Not:C34(Bool:C1537($snItem.split_out)))
			$items.push($snItem)
		End if 
	End for each 
	
Function _appendLine($text : Text; $line : Text)->$result : Text
	$result:=Choose:C955($text=""; $line; $text+"\r"+$line)
