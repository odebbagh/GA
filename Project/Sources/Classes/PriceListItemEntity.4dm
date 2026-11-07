Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.code+" - "+This:C1470.description

	// a new price: active, in US dollars, per unit, valid from today, for every customer
local Function loadAfterCreation()
	This:C1470.active:=True:C214
	This:C1470.currency:="USD"
	This:C1470.unit:="unit"
	This:C1470.UUID_StepProcess:="0"*32
	This:C1470.UUID_Customer:="0"*32
	This:C1470.stmpEffectiveFrom:=cs:C1710.sfw_stmp.me.build(Current date:C33; ?00:00:00?)
	This:C1470.flowPrices:=New object:C1471("rows"; New collection:C1472)

local Function beforeSave()
	This:C1470.normalize()

local Function beforeSaveCreation()
	This:C1470.normalize()

	// also called by _import_priceList, which saves without the sfw callbacks
Function normalize()
	This:C1470.code:=Uppercase:C13(cs:C1710.sfw_string.me.trimSpace(This:C1470.code))
	If (This:C1470.currency="")
		This:C1470.currency:="USD"
	End if
	If (This:C1470.unit="")
		This:C1470.unit:="unit"
	End if
	If (This:C1470.UUID_StepProcess="")
		This:C1470.UUID_StepProcess:="0"*32
	End if
	If (This:C1470.UUID_Customer="")
		This:C1470.UUID_Customer:="0"*32
	End if
	If (This:C1470.flowPrices=Null:C1517) || (Value type:C1509(This:C1470.flowPrices.rows)#Is collection:K8:32)
		This:C1470.flowPrices:=New object:C1471("rows"; New collection:C1472)
	End if

	//Mark:- Display
Function get processName()->$name : Text
	$name:=(This:C1470.stepProcess=Null:C1517) ? "" : This:C1470.stepProcess.name

	// blank: the general price, for every customer
Function get customerName()->$name : Text
	$name:=(This:C1470.customer=Null:C1517) ? "" : This:C1470.customer.name

Function get effectiveFrom()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpEffectiveFrom; True:C214)

Function set effectiveFrom($date : Date)
	This:C1470.stmpEffectiveFrom:=($date=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)

Function get effectiveTo()->$date : Date
	$date:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpEffectiveTo; True:C214)

Function set effectiveTo($date : Date)
	This:C1470.stmpEffectiveTo:=($date=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)

Function get effectiveFromText()->$text : Text
	$text:=(This:C1470.stmpEffectiveFrom=0) ? "" : String:C10(This:C1470.effectiveFrom)

Function get effectiveToText()->$text : Text
	$text:=(This:C1470.stmpEffectiveTo=0) ? "" : String:C10(This:C1470.effectiveTo)

	// "MIL 1.45 / SPACE 2.10", for the "Prices by flow" view
Function get flowPricesText()->$text : Text
	var $row : Object
	var $parts : Collection

	$parts:=New collection:C1472
	If (This:C1470.flowPrices#Null:C1517) && (Value type:C1509(This:C1470.flowPrices.rows)=Is collection:K8:32)
		For each ($row; This:C1470.flowPrices.rows)
			$parts.push(String:C10($row.flowCode)+" "+String:C10(Num:C11($row.unitPrice); "###,###,##0.00##"))
		End for each
	End if
	$text:=$parts.join(" / ")

	// valid today and active
Function get isCurrent()->$current : Boolean
	$current:=This:C1470.isValidOn(Current date:C33)

Function isValidOn($date : Date)->$valid : Boolean
	var $stmp : Integer
	$stmp:=cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
	$valid:=This:C1470.active && ((This:C1470.stmpEffectiveFrom=0) || (This:C1470.stmpEffectiveFrom<=$stmp)) && ((This:C1470.stmpEffectiveTo=0) || (This:C1470.stmpEffectiveTo>=$stmp))

	//Mark:- Prices
	// the row of flowPrices for $flowUUID, Null when the flow takes the base price
Function flowRow($flowUUID : Text)->$row : Object
	If (This:C1470.flowPrices#Null:C1517) && (Value type:C1509(This:C1470.flowPrices.rows)=Is collection:K8:32) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($flowUUID))
		$row:=This:C1470.flowPrices.rows.query("UUID_PriceFlow = :1"; $flowUUID).first()
	End if

	// {unitPrice; unitCost; flowCode; fromFlow}: the price of the flow, else the base one.
	// A flow row with no cost keeps the base cost.
Function priceFor($flowUUID : Text)->$price : Object
	var $row : Object

	$price:=New object:C1471("unitPrice"; This:C1470.unitPrice; "unitCost"; This:C1470.unitCost; "flowCode"; ""; "fromFlow"; False:C215)
	$row:=This:C1470.flowRow($flowUUID)
	If ($row#Null:C1517)
		$price.unitPrice:=Num:C11($row.unitPrice)
		If (Num:C11($row.unitCost)#0)
			$price.unitCost:=Num:C11($row.unitCost)
		End if
		$price.flowCode:=String:C10($row.flowCode)
		$price.fromFlow:=True:C214
	End if

	// the other active rows of the same item (process or code, customer) whose periods cross this one
Function overlaps()->$others : cs:C1710.PriceListItemSelection
	var $to : Integer

	$to:=(This:C1470.stmpEffectiveTo=0) ? MAXLONG:K35:2 : This:C1470.stmpEffectiveTo
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(This:C1470.UUID_StepProcess))
		$others:=ds:C1482.PriceListItem.query("active = :1 and code = :2 and UUID_StepProcess = :3"; True:C214; This:C1470.code; "0"*32)
	Else
		$others:=ds:C1482.PriceListItem.query("active = :1 and UUID_StepProcess = :2"; True:C214; This:C1470.UUID_StepProcess)
	End if
	$others:=$others.query("UUID_Customer = :1 and UUID # :2"; This:C1470.UUID_Customer; String:C10(This:C1470.UUID))
	$others:=$others.query("(stmpEffectiveTo = 0 or stmpEffectiveTo >= :1) and stmpEffectiveFrom <= :2"; This:C1470.stmpEffectiveFrom; $to)

	// the warnings shown on the panel and listed by _diag_priceList
Function get warnings()->$warnings : Collection
	var $row : Object

	$warnings:=New collection:C1472
	If (This:C1470.unitCost>0) && (This:C1470.unitPrice<This:C1470.unitCost)
		$warnings.push("The base price is below the cost.")
	End if
	If (This:C1470.flowPrices#Null:C1517) && (Value type:C1509(This:C1470.flowPrices.rows)=Is collection:K8:32)
		For each ($row; This:C1470.flowPrices.rows)
			If (Num:C11($row.unitCost)>0) && (Num:C11($row.unitPrice)<Num:C11($row.unitCost))
				$warnings.push("The "+String:C10($row.flowCode)+" price is below its cost.")
			End if
		End for each
	End if
	If (This:C1470.stmpEffectiveTo#0) && (This:C1470.stmpEffectiveTo<This:C1470.stmpEffectiveFrom)
		$warnings.push("The end date is before the start date.")
	End if
	If (This:C1470.active) && (This:C1470.overlaps().length>0)
		$warnings.push("Another active price of this item covers part of the same period.")
	End if
