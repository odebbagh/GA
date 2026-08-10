singleton Class constructor
	// Lot split / merge: Phase A gates, Phase B draft, Phase C+ validate/execute (later).
	This:C1470.STEP_TYPE_MOTHER_DOC:=511
	This:C1470.STEP_TYPE_CHILD_DOC:=512
	This:C1470.MIN_CHILD_COUNT:=2
	
Function canSplit($lot : Variant; $ctx : Object)->$result : Object
	var $inModification : Boolean
	var $lotSteps : cs:C1710.LotStepSelection
	var $openSteps : cs:C1710.LotStepSelection
	var $anchor : cs:C1710.LotStepEntity
	var $parentUUID : Text
	var $maxLotNumberLen : Integer
	var $reservedSuffixLen : Integer
	
	$result:=New object:C1471("allowed"; False:C215; "reasonCode"; "UNKNOWN"; "message"; ""; "anchorStep"; Null:C1517)
	
	If ($lot=Null:C1517)
		$result.reasonCode:="NO_LOT"
		$result.message:="No lot is selected."
		return 
	End if 
	
	$inModification:=True:C214
	If ($ctx#Null:C1517)
		If ($ctx.inModification#Null:C1517)
			$inModification:=Bool:C1537($ctx.inModification)
		End if 
	End if 
	If (Not:C34($inModification))
		$result.reasonCode:="NOT_IN_MODIFICATION"
		$result.message:="You must be in modification mode to split a lot."
		return 
	End if 
	
	If ($lot.dateIn=!00-00-00!)
		$result.reasonCode:="NOT_BORN"
		$result.message:="This lot is not active yet (no date in)."
		return 
	End if 
	
	If (Bool:C1537($lot.onHold))
		$result.reasonCode:="ON_HOLD"
		$result.message:="Cannot split a lot that is on hold."
		return 
	End if 
	
	If ($lot.dateOut#!00-00-00!)
		$result.reasonCode:="SHIPPED"
		$result.message:="Cannot split a lot that has already shipped (date out is set)."
		return 
	End if 
	
	$parentUUID:=String:C10($lot.UUID_LotParent)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($parentUUID)=False:C215)
		$result.reasonCode:="SUB_LOT"
		$result.message:="Cannot split a child lot. Open the parent lot to split."
		return 
	End if 
	
	$maxLotNumberLen:=255  // Lot.lotNumber catalog limiting_length
	$reservedSuffixLen:=24  // headroom for "-01" style suffixes and nested subSequence (see pln_splitLotBuildTargets)
	If (Length:C16(String:C10($lot.lotNumber))>($maxLotNumberLen-$reservedSuffixLen))
		$result.reasonCode:="LOT_NUMBER_TOO_LONG"
		$result.message:="Traveller # is too long to allocate child lot suffixes. Shorten the lot number before splitting."
		return 
	End if 
	
	$lotSteps:=$lot.steps
	If ($lotSteps.length=0)
		$result.reasonCode:="NO_STEPS"
		$result.message:="This lot has no traveler steps. Create steps before splitting."
		return 
	End if 
	
	$openSteps:=$lotSteps.query("dateOut = :1"; !00-00-00!)
	If ($openSteps.length=0)
		$result.reasonCode:="LOT_COMPLETED"
		$result.message:="You can't split a completed lot."
		return 
	End if 
	
	$anchor:=This:C1470.resolveSplitAnchorStep($lot)
	If ($anchor=Null:C1517)
		$result.reasonCode:="NO_ANCHOR_STEP"
		$result.message:="No completed traveler step was found. Create child lots from the job record instead."
		return 
	End if 
	
	If (Bool:C1537($anchor.sample))
		$result.reasonCode:="SAMPLE_STEP"
		$result.message:="Merge/Split is not allowed on a sample step."
		return 
	End if 
	
	If (cs:C1710.panel_planning.me.isLotStepPropertyEnabled($anchor; "Outside Of Count Rules"))
		$result.reasonCode:="OUTSIDE_COUNT_RULES"
		$result.message:="Merge/Split is not allowed when Outside Of Count Rules applies to the split step."
		return 
	End if 
	
	$result.allowed:=True:C214
	$result.reasonCode:="OK"
	$result.message:=""
	$result.anchorStep:=$anchor
	
Function resolveSplitAnchorStep($lot : Variant)->$anchor : cs:C1710.LotStepEntity
	// Last completed step by traveler order (highest "order" among steps with a punch-out date).

	$anchor:=ds:C1482.LotStep.query("UUID_Lot = :1 AND dateOut # :2"; $lot.UUID; !00-00-00!).orderBy("order desc").first()

Function resolveCurrentStep($lot : Variant)->$currentStep : cs:C1710.LotStepEntity
	// The step work is currently at: first step not punched out, by traveler order
	// (same rule as the green highlight in panel_planning.loadLotSteps).

	$currentStep:=ds:C1482.LotStep.query("UUID_Lot = :1 AND qtyOut = 0 AND dateOut = :2"; $lot.UUID; !00-00-00!).orderBy("order asc").first()

Function canSplitAtCurrentStep($lot : Variant; $ctx : Object)->$result : Object
	// Gates for the panel_planning "Split Lot" action: the child lot starts at the
	// mother's current step and takes part of the quantity with it.
	var $inModification : Boolean
	var $currentStep : cs:C1710.LotStepEntity
	var $availableQty : Integer

	$result:=New object:C1471("allowed"; False:C215; "reasonCode"; "UNKNOWN"; "message"; ""; "currentStep"; Null:C1517; "availableQty"; 0)

	If ($lot=Null:C1517)
		$result.reasonCode:="NO_LOT"
		$result.message:="No lot is selected."
		return
	End if

	$inModification:=True:C214
	If (($ctx#Null:C1517) && ($ctx.inModification#Null:C1517))
		$inModification:=Bool:C1537($ctx.inModification)
	End if
	If (Not:C34($inModification))
		$result.reasonCode:="NOT_IN_MODIFICATION"
		$result.message:="You must be in modification mode to split a lot."
		return
	End if

	If ($lot.dateIn=!00-00-00!)
		$result.reasonCode:="NOT_BORN"
		$result.message:="This lot is not active yet (no date in)."
		return
	End if

	If (Bool:C1537($lot.onHold))
		$result.reasonCode:="ON_HOLD"
		$result.message:="Cannot split a lot that is on hold."
		return
	End if

	If ($lot.dateOut#!00-00-00!)
		$result.reasonCode:="SHIPPED"
		$result.message:="Cannot split a lot that has already shipped (date out is set)."
		return
	End if

	If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($lot.UUID_LotParent))=False:C215)
		$result.reasonCode:="SUB_LOT"
		$result.message:="Cannot split a child lot. Open the mother lot to split."
		return
	End if

	If ($lot.steps.length=0)
		$result.reasonCode:="NO_STEPS"
		$result.message:="This lot has no traveler steps. Create steps before splitting."
		return
	End if

	$currentStep:=This:C1470.resolveCurrentStep($lot)
	If ($currentStep=Null:C1517)
		$result.reasonCode:="LOT_COMPLETED"
		$result.message:="You can't split a completed lot."
		return
	End if

	If (Bool:C1537($currentStep.sample))
		$result.reasonCode:="SAMPLE_STEP"
		$result.message:="Split is not allowed on a sample step."
		return
	End if

	If (cs:C1710.panel_planning.me.isLotStepPropertyEnabled($currentStep; "Outside Of Count Rules"))
		$result.reasonCode:="OUTSIDE_COUNT_RULES"
		$result.message:="Split is not allowed when Outside Of Count Rules applies to the current step."
		return
	End if

	$availableQty:=$currentStep.qtyIn
	If ($availableQty<=0)
		$availableQty:=$lot.ourCount
	End if
	If ($availableQty<2)
		$result.reasonCode:="NOT_ENOUGH_QTY"
		$result.message:="Not enough quantity to split: at least one item must stay in the mother lot."
		return
	End if

	$result.allowed:=True:C214
	$result.reasonCode:="OK"
	$result.message:=""
	$result.currentStep:=$currentStep
	$result.availableQty:=$availableQty

Function executeSplit($lot : Variant; $params : Object)->$result : Object
	// Creates ONE child lot taking $params.quantity items (and, for serialized
	// lots, the SN items whose ids are in $params.selectedSnIds) out of the
	// mother's current step.
	//
	// Persistence contract (same pattern as panel_planning SN generation):
	// - the child lot and every LotStep record (child's and mother's) are saved here
	// - the mother LOT entity is only mutated in memory (ourCount, snTable) —
	//   the caller activates the panel save button so the user confirms it
	var $currentStep : cs:C1710.LotStepEntity
	var $child : cs:C1710.LotEntity
	var $step : cs:C1710.LotStepEntity
	var $step_new : cs:C1710.LotStepEntity
	var $motherSteps : cs:C1710.LotStepSelection
	var $selectedIds : Collection
	var $items : Collection
	var $snItem : Object
	var $copy : Object
	var $bin : Object
	var $res : Object
	var $attributeName : Text
	var $qty : Integer
	var $nextSub : Integer
	var $sub : cs:C1710.LotEntity
	var $stepModified : Boolean

	$result:=New object:C1471("success"; False:C215; "message"; ""; "child"; Null:C1517)

	$qty:=Num:C11($params.quantity)
	$selectedIds:=($params.selectedSnIds#Null:C1517) ? $params.selectedSnIds : New collection:C1472()

	$currentStep:=This:C1470.resolveCurrentStep($lot)
	If ($currentStep=Null:C1517)
		$result.message:="No open traveler step was found."
		return
	End if

	// next sublot sequence under the same lot number: 1, 2, 3...
	$nextSub:=0
	For each ($sub; $lot.subLots)
		If ($sub.subSequence>$nextSub)
			$nextSub:=$sub.subSequence
		End if
	End for each
	$nextSub:=$nextSub+1

	// ---- child lot: copy every storage attribute from the mother ----
	$child:=ds:C1482.Lot.new()
	For each ($attributeName; ds:C1482.Lot)
		If (ds:C1482.Lot[$attributeName].kind="storage")
			Case of
				: ($attributeName="UUID")
					$child[$attributeName]:=Generate UUID:C1066
				: ($attributeName="UUID_LotParent")
					$child.UUID_LotParent:=$lot.UUID
				: ($attributeName="number")
					$child.number:=Sequence number:C244([Lot:118])
				: ($attributeName="subSequence")
					$child.subSequence:=$nextSub
				: ($attributeName="splitLevel")
					$child.splitLevel:=$lot.splitLevel+1
				: ($attributeName="ourCount")
					$child.ourCount:=$qty
				: ($attributeName="original")
					$child.original:=0
				: ($attributeName="snTable")
					// handled below (selected SNs only)
				Else
					$child[$attributeName]:=$lot[$attributeName]
			End case
		End if
	End for each

	// serialized lots: the child takes the selected SNs, the mother keeps them
	// flagged split_out (in memory - saved with the panel)
	If (($selectedIds.length>0) && ($lot.snTable#Null:C1517) && ($lot.snTable.items#Null:C1517))
		$items:=New collection:C1472()
		For each ($snItem; $lot.snTable.items)
			If ($selectedIds.indexOf($snItem.id)#-1)
				$copy:=OB Copy:C1225($snItem)
				$copy.split_out:=False:C215
				$items.push($copy)
				$snItem.split_out:=True:C214
			End if
		End for each
		$child.snTable:=New object:C1471("items"; $items)
		$lot.snTable:=$lot.snTable  // make sure the entity registers the touched attribute
	End if

	$res:=$child.save()
	If (Not:C34($res.success))
		$result.message:="The sublot could not be saved."
		return
	End if

	// ---- child steps: copy the mother's steps from the current step onward ----
	$motherSteps:=ds:C1482.LotStep.query("UUID_Lot = :1 AND order >= :2"; $lot.UUID; $currentStep.order).orderBy("order asc")

	For each ($step; $motherSteps)
		$step_new:=ds:C1482.LotStep.new()
		For each ($attributeName; ds:C1482.LotStep)
			If (ds:C1482.LotStep[$attributeName].kind="storage")
				Case of
					: ($attributeName="UUID")
						$step_new[$attributeName]:=Generate UUID:C1066
					: ($attributeName="UUID_Lot")
						$step_new.UUID_Lot:=$child.UUID
					Else
						$step_new[$attributeName]:=$step[$attributeName]
				End case
			End if
		End for each

		// the split quantity enters the child at its first step; rejects and bin
		// contents recorded on the mother's step stay with the mother
		If ($step.UUID=$currentStep.UUID)
			If ($step_new.qtyIn>0)
				$step_new.qtyIn:=$qty
			End if
			$step_new.rejects:=0
			$step_new.qtyRejects:=0
			If (($step_new.bins#Null:C1517) && ($step_new.bins.items#Null:C1517))
				$step_new.bins:=OB Copy:C1225($step.bins)
				For each ($bin; $step_new.bins.items)
					$bin["quantity"]:=0
				End for each
			End if
		End if

		// serialized lots: child steps only carry the selected SNs
		If (($selectedIds.length>0) && ($step.snTable#Null:C1517) && ($step.snTable.items#Null:C1517))
			$items:=New collection:C1472()
			For each ($snItem; OB Copy:C1225($step.snTable).items)
				If ($selectedIds.indexOf($snItem.id)#-1)
					$items.push($snItem)
				End if
			End for each
			$step_new.snTable:=New object:C1471("items"; $items)
		End if

		$res:=$step_new.save()
		If (Not:C34($res.success))
			$result.message:="A traveler step could not be copied to the sublot (record locked?)."
			return
		End if
	End for each

	// ---- mother: reduce the current step quantity and drop the moved SNs ----
	For each ($step; $motherSteps)
		$stepModified:=False:C215

		If (($step.UUID=$currentStep.UUID) && ($step.qtyIn>0))
			$step.qtyIn:=$step.qtyIn-$qty
			If ($step.qtyIn<0)
				$step.qtyIn:=0
			End if
			$stepModified:=True:C214
		End if

		If (($selectedIds.length>0) && ($step.snTable#Null:C1517) && ($step.snTable.items#Null:C1517))
			$items:=New collection:C1472()
			For each ($snItem; $step.snTable.items)
				If ($selectedIds.indexOf($snItem.id)=-1)
					$items.push($snItem)
				End if
			End for each
			$step.snTable:=New object:C1471("items"; $items)
			$stepModified:=True:C214
		End if

		If ($stepModified)
			$res:=$step.save()
			If (Not:C34($res.success))
				$result.message:="A mother lot step could not be updated (record locked?). The sublot was created - check the quantities."
				return
			End if
		End if
	End for each

	// mother count: in memory only, confirmed by the panel save
	$lot.ourCount:=$lot.ourCount-$qty

	$result.success:=True:C214
	$result.child:=$child
	
Function buildDraftFromLot($lot : Variant)->$draft : Object
	var $anchor : cs:C1710.LotStepEntity
	var $steps : cs:C1710.LotStepSelection
	var $highlightOrder : Integer
	var $step : cs:C1710.LotStepEntity
	var $row : Object
	
	$draft:=New object:C1471
	If ($lot=Null:C1517)
		return $draft
	End if 
	
	$anchor:=This:C1470.resolveSplitAnchorStep($lot)
	$highlightOrder:=($anchor#Null:C1517) ? $anchor.order : 0
	
	$draft.motherUUID:=$lot.UUID
	$draft.motherLotNumber:=String:C10($lot.lotNumber)
	$draft.motherSubSequence:=String:C10($lot.subSequence)
	$draft.motherOurCount:=$lot.ourCount
	$draft.motherSplitLevel:=$lot.splitLevel
	$draft.anchorStepUUID:=($anchor#Null:C1517) ? $anchor.UUID : ""
	$draft.anchorOrder:=$highlightOrder
	$draft.anchorDescription:=($anchor#Null:C1517) ? String:C10($anchor.description) : ""
	$draft.anchorQtyIn:=($anchor#Null:C1517) ? $anchor.qtyIn : 0
	$draft.anchorQtyOut:=($anchor#Null:C1517) ? $anchor.qtyOut : 0
	$draft.childCount:=This:C1470.MIN_CHILD_COUNT
	$draft.mode:="standard"
	$draft.serialization:=New collection:C1472
	$draft.steps:=New collection:C1472
	
	$steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; $lot.UUID).orderBy("order asc")
	For each ($step; $steps)
		$row:=New object:C1471
		$row.order:=$step.order
		$row.description:=$step.description
		$row.qtyOut:=$step.qtyOut
		$row.dateOut:=$step.dateOut
		$row.highlight:=($step.order=$highlightOrder)
		$draft.steps.push($row)
	End for each 
	
	This:C1470.rebuildSplitTargets($draft; True:C214)
	
Function rebuildSplitTargets($draft : Object; $applyDefaultQuantities : Boolean)
	var $count : Integer
	var $i : Integer
	var $row : Object
	var $baseLotNumber : Text
	var $parentSubSequence : Text
	var $nextSubSequence : Text
	var $savedQty : Collection
	var $target : Object
	var $totalQty : Integer
	var $baseQty : Integer
	var $remainder : Integer
	
	If ($draft=Null:C1517)
		return 
	End if 
	
	$count:=Num:C11($draft.childCount)
	If ($count<This:C1470.MIN_CHILD_COUNT)
		$count:=This:C1470.MIN_CHILD_COUNT
	End if 
	$draft.childCount:=$count
	
	$savedQty:=New collection:C1472
	If ($draft.targets#Null:C1517)
		For each ($target; $draft.targets)
			$savedQty.push(Num:C11($target.quantity))
		End for each 
	End if 
	
	$baseLotNumber:=String:C10($draft.motherLotNumber)
	$parentSubSequence:=String:C10($draft.motherSubSequence)
	$draft.targets:=New collection:C1472
	
	For ($i; 1; $count)
		$row:=New object:C1471
		$row.index:=$i
		$nextSubSequence:=Choose:C955(($i<10); "-0"+String:C10($i); "-"+String:C10($i))
		If ($parentSubSequence#"")
			$row.subSequence:=$parentSubSequence+$nextSubSequence
		Else 
			$row.subSequence:=$nextSubSequence
		End if 
		$row.lotName:=$baseLotNumber+$row.subSequence
		$row.lotNumber:=$row.lotName
		If ($i<=$savedQty.length)
			$row.quantity:=$savedQty[$i-1]
		Else 
			$row.quantity:=0
		End if 
		$draft.targets.push($row)
	End for 
	
	If ($applyDefaultQuantities)
		$totalQty:=0
		For each ($target; $draft.targets)
			$totalQty:=$totalQty+Num:C11($target.quantity)
		End for each 
		If ($totalQty=0)
			$totalQty:=Num:C11($draft.anchorQtyOut)
			If ($totalQty=0)
				$totalQty:=Num:C11($draft.motherOurCount)
			End if 
			If ($totalQty>0)
				$baseQty:=Int:C8($totalQty/$count)
				$remainder:=$totalQty-($baseQty*$count)
				For ($i; 0; $draft.targets.length-1)
					$draft.targets[$i].quantity:=$baseQty
					If ($i=($draft.targets.length-1))
						$draft.targets[$i].quantity:=$baseQty+$remainder
					End if 
				End for 
			End if 
		End if 
	End if 
	
	This:C1470.syncDraftLines($draft)
	
Function syncDraftLines($draft : Object)
	var $line : Object
	var $target : Object
	
	If ($draft=Null:C1517)
		return 
	End if 
	
	$draft.lines:=New collection:C1472
	For each ($target; $draft.targets)
		$line:=New object:C1471
		$line.index:=$target.index
		$line.quantity:=Num:C11($target.quantity)
		$line.qtyIn:=$line.quantity
		$line.qtyOut:=$line.quantity
		$draft.lines.push($line)
	End for each 
	
Function setDraftChildCount($draft : Object; $childCount : Integer)
	If ($draft=Null:C1517)
		return 
	End if 
	If (Num:C11($childCount)<This:C1470.MIN_CHILD_COUNT)
		$draft.childCount:=This:C1470.MIN_CHILD_COUNT
	Else 
		$draft.childCount:=Num:C11($childCount)
	End if 
	This:C1470.rebuildSplitTargets($draft; False:C215)
	
Function applyDraftToForm($draft : Object; $form : Object)
	If (($draft=Null:C1517) | ($form=Null:C1517))
		return 
	End if 
	
	$form.splitDraft:=$draft
	$form.splitTargets:=$draft.targets
	$form.splitLotSteps:=$draft.steps
	$form.splitLotCount:=$draft.childCount
	$form.splitLotCountDisplay:=String:C10($draft.childCount)
	$form.motherLotDisplay:=$draft.motherLotNumber
	$form.splitStepDisplay:=This:C1470.formatAnchorStepDisplay($draft)
	$form.splitReviewText:=This:C1470.formatDraftReview($draft)
	
Function formatAnchorStepDisplay($draft : Object)->$text : Text
	$text:=""
	If ($draft=Null:C1517)
		return 
	End if 
	$text:="Step "+String:C10($draft.anchorOrder)
	If (String:C10($draft.anchorDescription)#"")
		$text:=$text+" — "+String:C10($draft.anchorDescription)
	End if 
	
Function formatDraftReview($draft : Object)->$text : Text
	var $target : Object
	var $totalQty : Integer
	var $lines : Collection
	
	$text:=""
	If ($draft=Null:C1517)
		return 
	End if 
	
	$lines:=New collection:C1472
	$lines.push("Mother lot: "+String:C10($draft.motherLotNumber))
	$lines.push("Split at: "+This:C1470.formatAnchorStepDisplay($draft))
	$lines.push("Child lots: "+String:C10($draft.childCount))
	$lines.push("")
	
	$totalQty:=0
	For each ($target; $draft.targets)
		$totalQty:=$totalQty+Num:C11($target.quantity)
		$lines.push("  • "+String:C10($target.lotName)+" — qty "+String:C10($target.quantity))
	End for each 
	
	$lines.push("")
	$lines.push("Total quantity allocated: "+String:C10($totalQty))
	If (Num:C11($draft.anchorQtyOut)>0)
		$lines.push("(Anchor step qty out: "+String:C10($draft.anchorQtyOut)+")")
	End if 
	
	$text:=$lines.join("\n")
	
