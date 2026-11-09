// ga_quoteLinePricing
// "Price from the price list..." on a quote line (panel_quote, Lines actions): the dialog
// Quote_pickSteps lists the steps (Step, Housekeeping) that have an operation process, with their
// price from the Master Price List for the quote's customer, flow and date (ga_pricing). The steps
// ticked set the line's unit price (the sum of their prices); the minimum lot charge and the floor
// then follow the same steps (ga_quoteMinCharge, ga_quotePriceFloor).
// The line keeps what it was built from in moreData.build {steps:[{UUID; process; description;
// price; priced}]; builtDescription; builtUnitPrice; flowCode; stepSet; stepSetName; stepSetModified;
// stmp} and the price snapshot in moreData.pricing; its other moreData keys are kept. Opened again,
// the dialog ticks the same steps: after a change of flow it reprices the line.
// Step sets (QuoteStepSet, "Standard step sets"): the "Step set" pop-up ticks the steps of a set in
// one click, in the set's order (the order of the description). When the set goes with another
// price flow than the quote's, the user may price with it: the quote takes that flow on Apply
// ($data.newFlowUUID, set by panel_quote._priceLineFromList).
// The same dialog without prices picks the steps of a set (panel_quoteStepSet): stepSetDialogData.
singleton Class constructor


	// the dialog's data: {rows; view; search; tickedOnly; headerText; totalText; stepSetNote; context;
	// quote; stepSet; stepSetModified; newFlowUUID; pricesHidden} - rows: [{UUID; selected; order;
	// description; process; code; price; minLotCharge; priced; meta}]
Function dialogData($quote : cs:C1710.QuoteEntity; $line : cs:C1710.QuoteLineEntity)->$data : Object
	var $ticked : Collection
	var $build : Object
	var $set : cs:C1710.QuoteStepSetEntity

	$ticked:=New collection:C1472
	If ($line#Null:C1517) && ($line.moreData#Null:C1517) && ($line.moreData.build#Null:C1517) && (Value type:C1509($line.moreData.build.steps)=Is collection:K8:32)
		$build:=$line.moreData.build
		$ticked:=$build.steps.extract("UUID")
	End if

	$data:=This:C1470._newData($ticked)
	$data.context:=cs:C1710.ga_pricing.me.contextOf($quote)
	$data.quote:=$quote
	// the set the line was built from, if it still exists
	If ($build#Null:C1517) && (String:C10($build.stepSet)#"")
		$set:=ds:C1482.QuoteStepSet.query("code = :1"; $build.stepSet).first()
		If ($set#Null:C1517)
			$data.stepSet:=This:C1470._setObject($set)
			$data.stepSetModified:=Bool:C1537($build.stepSetModified)
		End if
	End if
	This:C1470._priceRows($data)
	This:C1470._total($data)

	// the dialog without prices, for the steps of a standard step set ($UUIDs: the set's steps)
Function stepSetDialogData($UUIDs : Collection)->$data : Object
	$data:=This:C1470._newData($UUIDs)
	$data.pricesHidden:=True:C214
	$data.headerText:="Tick the steps of the set. The steps already in it keep their place, the new ones go at the end (Actions > Move step up / down to reorder them)."
	This:C1470._total($data)

	// every step with an operation process, ticked when in $ticked (in that order)
Function _newData($ticked : Collection)->$data : Object
	var $step : cs:C1710.StepEntity
	var $index : Integer

	$data:=New object:C1471("rows"; New collection:C1472; "search"; ""; "tickedOnly"; False:C215; "context"; Null:C1517; "quote"; Null:C1517; \
		"stepSet"; Null:C1517; "stepSetModified"; False:C215; "stepSetNote"; ""; "newFlowUUID"; ""; "pricesHidden"; False:C215)
	For each ($step; ds:C1482.Step.all())
		If (cs:C1710.sfw_string.me.isAnEmptyUUID($step.UUID_StepProcess))
			continue
		End if
		$index:=$ticked.indexOf($step.UUID)
		$data.rows.push(New object:C1471("UUID"; $step.UUID; "processUUID"; $step.UUID_StepProcess; "selected"; ($index#-1); "order"; ($index=-1) ? 999999 : $index; \
			"description"; $step.description; "process"; ($step.stepProcess=Null:C1517) ? "" : $step.stepProcess.name; \
			"code"; ""; "price"; 0; "minLotCharge"; 0; "priced"; False:C215; "meta"; New object:C1471))
	End for each
	$data.rows:=$data.rows.orderBy("selected desc, order asc, process asc, description asc")
	$data.view:=$data.rows

	// the prices of the rows for $data.context (customer, flow, date), and the header saying which
Function _priceRows($data : Object)
	var $prices; $price; $row : Object
	var $item : cs:C1710.PriceListItemEntity
	var $flow : cs:C1710.PriceFlowEntity
	var $processUUID : Text

	// one lookup per process, not per step
	$prices:=New object:C1471
	For each ($row; $data.rows)
		$processUUID:=$row.processUUID
		If ($prices[$processUUID]=Null:C1517)
			$item:=cs:C1710.ga_pricing.me.findItem($processUUID; $data.context)
			If ($item=Null:C1517)
				$prices[$processUUID]:=New object:C1471("priced"; False:C215; "price"; 0; "minLotCharge"; 0; "code"; "")
			Else
				$price:=$item.priceFor(String:C10($data.context.flowUUID))
				$prices[$processUUID]:=New object:C1471("priced"; True:C214; "price"; $price.unitPrice; "minLotCharge"; $item.minLotCharge; "code"; $item.code)
			End if
		End if
		$price:=$prices[$processUUID]
		$row.code:=$price.code
		$row.price:=$price.price
		$row.minLotCharge:=$price.minLotCharge
		$row.priced:=$price.priced
		$row.meta:=$price.priced ? New object:C1471 : New object:C1471("stroke"; "#A0A0A0")
	End for each

	$flow:=ds:C1482.PriceFlow.get(String:C10($data.context.flowUUID))
	$data.headerText:="Prices for "+(($data.quote=Null:C1517) || ($data.quote.customer=Null:C1517) ? "every customer" : $data.quote.customer.name)+\
		", flow "+(($flow=Null:C1517) ? "none" : $flow.code+" - "+$flow.name)+\
		(($data.newFlowUUID#"") ? " (the quote's flow on Apply)" : "")+", on "+String:C10($data.context.date)+\
		". Grey steps have no price in the Master Price List."

	// the form method and the object methods of Quote_pickSteps
Function dialogFormMethod()
	Case of
		: (Form event code:C388=On Load:K2:1)
			If (Bool:C1537(Form:C1466.pricesHidden))
				OBJECT SET VISIBLE:C603(*; "Column_code"; False:C215)
				OBJECT SET VISIBLE:C603(*; "Column_price"; False:C215)
				OBJECT SET VISIBLE:C603(*; "Column_min"; False:C215)
				OBJECT SET VISIBLE:C603(*; "label_stepSet"; False:C215)
				OBJECT SET VISIBLE:C603(*; "pup_stepSet"; False:C215)
				OBJECT SET TITLE:C194(*; "bOK"; "OK")
				SET WINDOW TITLE:C213("Steps of the set")
			End if
			This:C1470._total(Form:C1466)
			This:C1470._drawStepSet()
	End case

Function dialogSearch()
	// as the user types: the steps whose description, process or price code contain the text
	If (Form event code:C388=On After Keystroke:K2:26)
		Form:C1466.search:=Get edited text:C655
	End if
	This:C1470._filter(Form:C1466)

Function dialogTickedOnly()
	If (Form event code:C388=On Clicked:K2:4)
		This:C1470._filter(Form:C1466)
	End if

Function _filter($data : Object)
	var $rows : Collection
	$rows:=Bool:C1537($data.tickedOnly) ? $data.rows.query("selected = :1"; True:C214) : $data.rows
	If (String:C10($data.search)="")
		$data.view:=$rows
	Else
		$data.view:=$rows.query("description = :1 or process = :1 or code = :1"; "@"+$data.search+"@")
	End if

Function dialogList()
	If (Form event code:C388=On Data Change:K2:15) || (Form event code:C388=On Clicked:K2:4)
		This:C1470._total(Form:C1466)
		This:C1470._drawStepSet()
	End if

	// the "Step set" pop-up: Custom keeps the ticks as they are, a set ticks exactly its steps
Function dialogStepSet()
	var $menu; $choice : Text
	var $set : cs:C1710.QuoteStepSetEntity

	If (Form event code:C388#On Clicked:K2:4)
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Custom (tick the steps by hand)"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--custom")
	If (Form:C1466.stepSet=Null:C1517)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if
	APPEND MENU ITEM:C411($menu; "-")
	For each ($set; ds:C1482.QuoteStepSet.activeSets())
		APPEND MENU ITEM:C411($menu; $set.name+" ("+String:C10($set.stepCount)+" steps)"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $set.UUID)
		If (Form:C1466.stepSet#Null:C1517) && (Form:C1466.stepSet.UUID=$set.UUID)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choice="")
		: ($choice="--custom")
			Form:C1466.stepSet:=Null:C1517
			Form:C1466.stepSetNote:=""
			This:C1470._total(Form:C1466)
		Else
			This:C1470.applyStepSet(Form:C1466; ds:C1482.QuoteStepSet.get($choice))
	End case
	This:C1470._drawStepSet()

	// ticks exactly the steps of $set, in its order; the steps that cannot be listed (deleted, or
	// without process so without price) are named in stepSetNote. Offers the set's usual flow.
Function applyStepSet($data : Object; $set : cs:C1710.QuoteStepSetEntity)
	var $UUIDs; $notListed : Collection
	var $row : Object
	var $UUID : Text
	var $index : Integer
	var $step : cs:C1710.StepEntity
	var $flow; $setFlow : cs:C1710.PriceFlowEntity

	If ($set=Null:C1517)
		return
	End if
	$UUIDs:=$set.stepUUIDs
	For each ($row; $data.rows)
		$index:=$UUIDs.indexOf($row.UUID)
		$row.selected:=($index#-1)
		$row.order:=($index=-1) ? 999999 : $index
	End for each
	$data.stepSet:=This:C1470._setObject($set)
	$data.stepSetModified:=False:C215

	$notListed:=New collection:C1472
	For each ($UUID; $UUIDs)
		If ($data.rows.query("UUID = :1"; $UUID).length=0)
			$step:=ds:C1482.Step.get($UUID)
			$notListed.push(($step=Null:C1517) ? "(a deleted step)" : String:C10($step.description)+" (no process)")
		End if
	End for each
	$data.stepSetNote:=($notListed.length=0) ? "" : "Not in the list, so not on the line: "+$notListed.join(", ")

	// the set's usual flow, when the quote is priced with another one
	If ($data.context#Null:C1517) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($set.UUID_PriceFlow)) && ($set.UUID_PriceFlow#String:C10($data.context.flowUUID))
		$setFlow:=$set.priceFlow
		$flow:=ds:C1482.PriceFlow.get(String:C10($data.context.flowUUID))
		If ($setFlow#Null:C1517)
			If (cs:C1710.sfw_dialog.me.confirm("\""+$set.name+"\" usually goes with the flow "+$setFlow.code+" - "+$setFlow.name+\
				", and this quote is priced with "+(($flow=Null:C1517) ? "no flow" : $flow.code)+".\r\rPrice this line with "+$setFlow.code+\
				"? The quote then takes this flow when you click Apply (its other lines keep their prices)."; "Use "+$setFlow.code; "Keep "+(($flow=Null:C1517) ? "as is" : $flow.code)))
				$data.context.flowUUID:=$setFlow.UUID
				$data.newFlowUUID:=$setFlow.UUID
				This:C1470._priceRows($data)
			End if
		End if
	End if

	$data.rows:=$data.rows.orderBy("selected desc, order asc, process asc, description asc")
	This:C1470._filter($data)
	This:C1470._total($data)

Function _setObject($set : cs:C1710.QuoteStepSetEntity)->$object : Object
	$object:=New object:C1471("UUID"; $set.UUID; "code"; $set.code; "name"; $set.name; "UUIDs"; $set.stepUUIDs)

Function _drawStepSet()
	var $title : Text
	If (Form:C1466.stepSet=Null:C1517)
		$title:="Custom"
	Else
		$title:=Form:C1466.stepSet.name+(Bool:C1537(Form:C1466.stepSetModified) ? " (modified)" : "")
	End if
	OBJECT SET TITLE:C194(*; "pup_stepSet"; $title)

Function _total($data : Object)
	var $selected : Collection
	var $min : Real
	var $inSet : Integer

	$selected:=$data.rows.query("selected = :1"; True:C214)
	// a set whose ticks were changed by hand (its steps that are not listed don't count)
	If ($data.stepSet#Null:C1517)
		$inSet:=$data.rows.query("UUID in :1"; $data.stepSet.UUIDs).length
		$data.stepSetModified:=($selected.length#$inSet) || ($selected.query("UUID in :1"; $data.stepSet.UUIDs).length#$selected.length)
	End if
	If (Bool:C1537($data.pricesHidden))
		$data.totalText:=String:C10($selected.length)+" step(s) ticked"
		return
	End if
	$min:=($selected.length=0) ? 0 : $selected.max("minLotCharge")
	$data.totalText:=String:C10($selected.length)+" step(s) ticked - unit price "+String:C10($selected.sum("price"); "$###,###,##0.00##")+\
		" - minimum lot charge "+String:C10($min; "$###,###,##0.00")+Choose:C955($selected.query("priced = :1"; False:C215).length=0; ""; " - some ticked steps have no price")

	// The ticked steps onto the line (not saved: panel_quote saves it on its usual path), in the
	// order of the set or of the line (order), then as listed for the steps ticked by hand.
	// The description is replaced only when it is empty or still the one built last time.
Function applyToLine($line : cs:C1710.QuoteLineEntity; $data : Object)->$applied : Boolean
	var $selected; $steps : Collection
	var $row; $priced; $moreData : Object
	var $flow : cs:C1710.PriceFlowEntity
	var $built; $previousBuilt : Text
	var $index : Integer

	$selected:=$data.rows.query("selected = :1"; True:C214)
	If ($selected.length=0)
		return
	End if
	For each ($row; $selected)
		$index+=1
		$row.sortKey:=($row.order<999999) ? $row.order : 100000+$index
	End for each
	$selected:=$selected.orderBy("sortKey asc")
	$priced:=cs:C1710.ga_pricing.me.lineFromSteps($selected.extract("UUID"); $data.context)
	$flow:=ds:C1482.PriceFlow.get(String:C10($data.context.flowUUID))

	$steps:=New collection:C1472
	For each ($row; $selected)
		$steps.push(New object:C1471("UUID"; $row.UUID; "process"; $row.process; "description"; $row.description; "price"; $row.price; "priced"; $row.priced))
	End for each
	$built:=$selected.extract("description").join(", ")

	$moreData:=($line.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($line.moreData)
	$previousBuilt:=($moreData.build=Null:C1517) ? "" : String:C10($moreData.build.builtDescription)
	$moreData.build:=New object:C1471("steps"; $steps; "builtDescription"; $built; "builtUnitPrice"; $priced.unitPrice; \
		"flowCode"; ($flow=Null:C1517) ? "" : $flow.code; "stmp"; cs:C1710.sfw_stmp.me.now(); \
		"stepSet"; ($data.stepSet=Null:C1517) ? "" : $data.stepSet.code; \
		"stepSetName"; ($data.stepSet=Null:C1517) ? "" : $data.stepSet.name; \
		"stepSetModified"; Bool:C1537($data.stepSetModified))
	$moreData.pricing:=$priced.snapshot
	$line.moreData:=$moreData
	$line.unitPrice:=$priced.unitPrice
	If ($line.description="") || ($line.description=$previousBuilt)
		$line.description:=$built
	End if
	$applied:=True:C214
