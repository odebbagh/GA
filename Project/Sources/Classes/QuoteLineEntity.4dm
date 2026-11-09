Class extends Entity


Function get amount()->$amount : Real
	// quantity x unit price, raised to the line's minimum lot charge when it is below it.
	// A few legacy lines keep a lower amount typed in the old app (a discount) in moreData.amount:
	// see _fix_quoteLineMinCharge; it is cleared as soon as the quantity, price or charge changes.
	// In the "block" mode of ga_quoteMinCharge the amount is not raised: the line is flagged instead
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.amount#Null:C1517)
		$amount:=Num:C11(This:C1470.moreData.amount)
	Else
		$amount:=This:C1470.unitPrice*This:C1470.quantity
		If (This:C1470.minLotCharge>$amount) && (cs:C1710.ga_quoteMinCharge.me.mode()="force")
			$amount:=This:C1470.minLotCharge
		End if
	End if

Function clearAmountOverride()
	// quantity, unit price or minimum lot charge changed: the legacy typed amount no longer applies
	var $moreData : Object
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.amount#Null:C1517)
		$moreData:=OB Copy:C1225(This:C1470.moreData)
		OB REMOVE:C1226($moreData; "amount")
		This:C1470.moreData:=$moreData
	End if

Function clearPriceFloorNote()
	// the price is back above its floor: the note of a price kept below it no longer applies
	var $moreData : Object
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.priceFloor#Null:C1517)
		$moreData:=OB Copy:C1225(This:C1470.moreData)
		OB REMOVE:C1226($moreData; "priceFloor")
		This:C1470.moreData:=$moreData
	End if

Function get meta()->$meta : Object
	// lb_quoteLines (panel_quote) metaSource: a unit price below its floor in red, in orange when it
	// was kept on purpose (see ga_quotePriceFloor). Information only: old prices are never blocked
	// Also red in the "block" mode of ga_quoteMinCharge when the line is under its minimum lot charge
	var $verdict : Object
	$verdict:=cs:C1710.ga_quotePriceFloor.me.check(This:C1470; 0)
	Case of
		: (cs:C1710.ga_quoteMinCharge.me.mode()="block") && (cs:C1710.ga_quoteMinCharge.me.isUnder(This:C1470))
			$meta:=New object:C1471("stroke"; "#C0392B")
		: ($verdict.kind#"floor") || (cs:C1710.ga_quotePriceFloor.me.mode()="off")
			$meta:=New object:C1471
		: (cs:C1710.ga_quotePriceFloor.me.isKept(This:C1470; $verdict))
			$meta:=New object:C1471("stroke"; "#D35400")
		Else
			$meta:=New object:C1471("stroke"; "#C0392B")
	End case

Function get minLotChargeSourceText()->$text : Text
	// panel_quote, next to the Min. lot charge field: where the minimum comes from (ga_quoteMinCharge)
	$text:=cs:C1710.ga_quoteMinCharge.me.sourceText(This:C1470)

Function get builtFromText()->$text : Text
	// panel_quote, under the description: what a line priced from steps was built from
	// (ga_quoteLinePricing), e.g. "Built from: Class S (modified) - 16 steps, flow CLASSS"; "" for a typed line
	var $build : Object
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.build#Null:C1517) && (Value type:C1509(This:C1470.moreData.build.steps)=Is collection:K8:32)
		$build:=This:C1470.moreData.build
		$text:="Built from: "+((String:C10($build.stepSetName)="") ? "steps ticked by hand" : $build.stepSetName+(Bool:C1537($build.stepSetModified) ? " (modified)" : ""))+\
			" - "+String:C10($build.steps.length)+" step"+(($build.steps.length>1) ? "s" : "")+\
			((String:C10($build.flowCode)="") ? "" : ", flow "+$build.flowCode)
	End if
