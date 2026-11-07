// ga_pricing
// The lookups of the master price list (PriceListItem, PriceFlow), used by the quotes to fill the
// unit price, the minimum lot charge and the internal cost (the floor) of a line. Read-only.
// A context is {customerUUID; date (Date); flowUUID}: contextOf($quote) builds it from a quote.
// - a customer's own price beats the general one; the price valid on the context date is used
// - the flow changes the unit price (and cost), not the minimum lot charge
// - nothing found: 0, and the process is listed in "missing". Callers keep the manual entry.
// Quote lines keep the values they were given: a later change of the list does not move them.
singleton Class constructor


	// {customerUUID; date; flowUUID} of a quote: its customer, its creation date (today for a new
	// quote) and its flow (the default flow when it has none)
Function contextOf($quote : cs:C1710.QuoteEntity)->$context : Object
	var $flow : cs:C1710.PriceFlowEntity

	$context:=New object:C1471("customerUUID"; "0"*32; "date"; Current date:C33; "flowUUID"; "0"*32)
	If ($quote=Null:C1517)
		return
	End if
	$context.customerUUID:=$quote.UUID_Customer
	If ($quote.stmpCreation#0)
		$context.date:=cs:C1710.sfw_stmp.me.getDate($quote.stmpCreation)
	End if
	$flow:=This:C1470.priceFlowOf($quote)
	If ($flow#Null:C1517)
		$context.flowUUID:=$flow.UUID
	End if

	// the flow of the quote, else the default flow (Null when no flow is defined at all)
Function priceFlowOf($quote : cs:C1710.QuoteEntity)->$flow : cs:C1710.PriceFlowEntity
	If ($quote#Null:C1517) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($quote.UUID_PriceFlow))
		$flow:=$quote.priceFlow
	End if
	If ($flow=Null:C1517)
		$flow:=ds:C1482.PriceFlow.defaultFlow()
	End if

	// the price-list row of a process for the context: the customer's own row first, then the
	// general one; among several, the one that started last. Null when there is none.
Function findItem($processUUID : Text; $context : Object)->$item : cs:C1710.PriceListItemEntity
	var $items : cs:C1710.PriceListItemSelection
	var $customerUUID : Text

	$context:=This:C1470._context($context)
	$customerUUID:=String:C10($context.customerUUID)
	$items:=ds:C1482.PriceListItem.validOn($context.date; $processUUID; $customerUUID)
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($customerUUID)))
		$item:=$items.query("UUID_Customer = :1"; $customerUUID).orderBy("stmpEffectiveFrom desc").first()
	End if
	If ($item=Null:C1517)
		$item:=$items.query("UUID_Customer = :1"; "0"*32).orderBy("stmpEffectiveFrom desc").first()
	End if

	// the same for an item that is not a process (engineering hour, setup...), by its code
Function findByCode($code : Text; $context : Object)->$item : cs:C1710.PriceListItemEntity
	var $items : cs:C1710.PriceListItemSelection
	var $customerUUID : Text

	var $stmp : Integer

	$context:=This:C1470._context($context)
	$customerUUID:=String:C10($context.customerUUID)
	$stmp:=cs:C1710.sfw_stmp.me.build($context.date; ?00:00:00?)
	$items:=ds:C1482.PriceListItem.query("code = :1 and active = :2 and (stmpEffectiveFrom = 0 or stmpEffectiveFrom <= :3) and (stmpEffectiveTo = 0 or stmpEffectiveTo >= :3)"; Uppercase:C13(cs:C1710.sfw_string.me.trimSpace($code)); True:C214; $stmp)
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($customerUUID)))
		$item:=$items.query("UUID_Customer = :1"; $customerUUID).orderBy("stmpEffectiveFrom desc").first()
	End if
	If ($item=Null:C1517)
		$item:=$items.query("UUID_Customer = :1"; "0"*32).orderBy("stmpEffectiveFrom desc").first()
	End if

	// {unitPrice; unitCost; flowCode; fromFlow} of a row for a flow (the base price when the flow
	// has none of its own)
Function priceOf($item : cs:C1710.PriceListItemEntity; $flowUUID : Text)->$price : Object
	If ($item=Null:C1517)
		$price:=New object:C1471("unitPrice"; 0; "unitCost"; 0; "flowCode"; ""; "fromFlow"; False:C215)
	Else
		$price:=$item.priceFor($flowUUID)
	End if

	// The price of a quote line made of several processes - what the quote screens call:
	// {unitPrice: the sum of the processes' prices; unitCost: the sum of their costs;
	//  minLotCharge: the largest of their minimum lot charges (to be confirmed by the client);
	//  items: [{UUID; code; process; unitPrice; unitCost; minLotCharge; flowCode}];
	//  missing: [names of the processes with no price]; snapshot: to keep in QuoteLine.moreData.pricing}
Function lineFromProcesses($processUUIDs : Collection; $context : Object)->$line : Object
	var $processUUID : Text
	var $item : cs:C1710.PriceListItemEntity
	var $process : cs:C1710.StepProcessEntity
	var $price : Object

	$context:=This:C1470._context($context)
	$line:=New object:C1471("unitPrice"; 0; "unitCost"; 0; "minLotCharge"; 0; "items"; New collection:C1472; "missing"; New collection:C1472)
	If ($processUUIDs#Null:C1517)
		For each ($processUUID; $processUUIDs)
			$item:=This:C1470.findItem($processUUID; $context)
			If ($item=Null:C1517)
				$process:=ds:C1482.StepProcess.get($processUUID)
				$line.missing.push(($process=Null:C1517) ? $processUUID : $process.name)
			Else
				$price:=$item.priceFor(String:C10($context.flowUUID))
				$line.unitPrice+=$price.unitPrice
				$line.unitCost+=$price.unitCost
				If ($item.minLotCharge>$line.minLotCharge)
					$line.minLotCharge:=$item.minLotCharge
				End if
				$line.items.push(New object:C1471("UUID"; $item.UUID; "code"; $item.code; "process"; $item.processName; \
					"unitPrice"; $price.unitPrice; "unitCost"; $price.unitCost; "minLotCharge"; $item.minLotCharge; "flowCode"; $price.flowCode))
			End if
		End for each
	End if
	$line.snapshot:=New object:C1471("stmp"; cs:C1710.sfw_stmp.me.now(); "flowUUID"; String:C10($context.flowUUID); "date"; String:C10($context.date; ISO date:K1:8); \
		"items"; $line.items.copy(); "unitCost"; $line.unitCost; "missing"; $line.missing.copy())

	//Mark:- Steps (quote lines built from Step Templates, see quote-lines-processes)
	// A step is priced by its operation process (Step.stepProcess). Two steps of the same process
	// count twice.

	// the price of one step for a quote: {found; price; cost; minLotCharge; code; flowCode}
Function stepPrice($step : cs:C1710.StepEntity; $quote : cs:C1710.QuoteEntity)->$result : Object
	var $item : cs:C1710.PriceListItemEntity
	var $price; $context : Object

	$result:=New object:C1471("found"; False:C215; "price"; 0; "cost"; 0; "minLotCharge"; 0; "code"; ""; "flowCode"; "")
	If ($step=Null:C1517) || cs:C1710.sfw_string.me.isAnEmptyUUID($step.UUID_StepProcess)
		return
	End if
	$context:=This:C1470.contextOf($quote)
	$item:=This:C1470.findItem($step.UUID_StepProcess; $context)
	If ($item=Null:C1517)
		return
	End if
	$price:=$item.priceFor(String:C10($context.flowUUID))
	$result:=New object:C1471("found"; True:C214; "price"; $price.unitPrice; "cost"; $price.unitCost; "minLotCharge"; $item.minLotCharge; "code"; $item.code; "flowCode"; $price.flowCode)

	// lineFromProcesses for the steps of a line (Step UUIDs, in order); a step without a process
	// is listed in "missing"
Function lineFromSteps($stepUUIDs : Collection; $context : Object)->$line : Object
	var $stepUUID : Text
	var $step : cs:C1710.StepEntity
	var $processUUIDs; $noProcess : Collection

	$processUUIDs:=New collection:C1472
	$noProcess:=New collection:C1472
	If ($stepUUIDs#Null:C1517)
		For each ($stepUUID; $stepUUIDs)
			$step:=ds:C1482.Step.get($stepUUID)
			Case of
				: ($step=Null:C1517)
				: (cs:C1710.sfw_string.me.isAnEmptyUUID($step.UUID_StepProcess))
					$noProcess.push(String:C10($step.description)+" (no process)")
				Else
					$processUUIDs.push($step.UUID_StepProcess)
			End case
		End for each
	End if
	$line:=This:C1470.lineFromProcesses($processUUIDs; $context)
	$line.missing:=$line.missing.combine($noProcess)

	// the floor of a quote line: the internal cost of its steps for the quote's flow, per unit.
	// {value (0: no floor); source}. Lines typed by hand (no moreData.build.steps) have none.
	// Called by ga_quotePriceFloor.floorFor, once per row of the lines list: one query per step.
Function floorOfLine($line : cs:C1710.QuoteLineEntity)->$floor : Object
	var $priced : Object
	var $stepUUIDs : Collection

	$floor:=New object:C1471("value"; 0; "source"; "")
	If ($line=Null:C1517) || ($line.moreData=Null:C1517) || ($line.moreData.build=Null:C1517) || (Value type:C1509($line.moreData.build.steps)#Is collection:K8:32)
		return
	End if
	$stepUUIDs:=$line.moreData.build.steps.extract("UUID")
	If ($stepUUIDs.length=0)
		return
	End if
	$priced:=This:C1470.lineFromSteps($stepUUIDs; This:C1470.contextOf($line.quote))
	If ($priced.unitCost>0)
		$floor.value:=$priced.unitCost
		$floor.source:="price list cost: "+$priced.items.extract("code").join(" + ")+Choose:C955($priced.missing.length=0; ""; ", without "+$priced.missing.join(", "))
	End if

Function minLotCharge($processUUIDs : Collection; $context : Object)->$charge : Real
	$charge:=This:C1470.lineFromProcesses($processUUIDs; $context).minLotCharge

	// the internal cost of a line: the floor below which it is sold at a loss
Function floor($processUUIDs : Collection; $context : Object)->$floor : Real
	$floor:=This:C1470.lineFromProcesses($processUUIDs; $context).unitCost

	// a context with every attribute set: date (a Date, or an ISO text), today when missing;
	// no customer = the general prices; no flow = the default flow
Function _context($context : Object)->$full : Object
	var $flow : cs:C1710.PriceFlowEntity
	var $date : Date

	If ($context=Null:C1517)
		$context:=New object:C1471
	End if
	Case of
		: (Value type:C1509($context.date)=Is date:K8:7)
			$date:=$context.date
		: (Value type:C1509($context.date)=Is text:K8:3)
			$date:=_import_priceListDate($context.date)
	End case
	$full:=New object:C1471("date"; ($date=!00-00-00!) ? Current date:C33 : $date; "customerUUID"; "0"*32; "flowUUID"; "0"*32)
	If (Value type:C1509($context.customerUUID)=Is text:K8:3) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($context.customerUUID))
		$full.customerUUID:=$context.customerUUID
	End if
	If (Value type:C1509($context.flowUUID)=Is text:K8:3) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($context.flowUUID))
		$full.flowUUID:=$context.flowUUID
	Else
		$flow:=ds:C1482.PriceFlow.defaultFlow()
		If ($flow#Null:C1517)
			$full.flowUUID:=$flow.UUID
		End if
	End if
