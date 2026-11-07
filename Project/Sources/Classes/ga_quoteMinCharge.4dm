// ga_quoteMinCharge
// The minimum lot charge of a quote line, filled from the Master Price List (PriceListItem.minLotCharge,
// the same for every flow) for the processes the line is built from (moreData.build.steps, see
// quote-lines-processes). Several processes: the highest of their minimums. For each process the
// customer's own price wins over the one for every customer.
// - moreData.minLotChargeSource: "priceList" (filled), "manual" (typed), "legacy" (imported or typed
//   before Oct 2026), "none". A line without the key and with a minimum counts as "legacy": existing
//   quotes are never recalculated (see _fix_quoteLineMinSource).
// - typing a minimum: raising it, or typing one where the price list gives none, is free; going below
//   the price list needs the PRICEOVERRIDE profile (or admin), as for ga_quotePriceFloor.
// - sfw_Setting "QuoteMinLotChargeMode", data.value: "force" (default: the amount is raised to the
//   minimum) or "block" (the amount stays quantity x unit price, the line is flagged and the quote
//   cannot be marked as sent while a line is under its minimum).

property _testMode : Text  // set by ga_demoCheck and for tests in the IDE; "" = the setting
property _mode : Text
property _modeRead : Integer  // Milliseconds of the last read: amount and meta are read per row

singleton Class constructor
	This:C1470._testMode:=""
	This:C1470._mode:=""
	This:C1470._modeRead:=0

Function mode()->$mode : Text
	var $eSetting : 4D:C1709.Entity

	If (This:C1470._testMode#"")
		return This:C1470._testMode
	End if
	If (This:C1470._mode#"") && (Abs:C99(Milliseconds:C459-This:C1470._modeRead)<5000)
		return This:C1470._mode
	End if
	$mode:="force"
	$eSetting:=ds:C1482.sfw_Setting.query("ident = :1"; "QuoteMinLotChargeMode").first()
	If ($eSetting#Null:C1517) && ($eSetting.data#Null:C1517)
		If (Lowercase:C14(String:C10($eSetting.data.value))="block")
			$mode:="block"
		End if
	End if
	This:C1470._mode:=$mode
	This:C1470._modeRead:=Milliseconds:C459

Function sourceOf($line : cs:C1710.QuoteLineEntity)->$source : Text
	If ($line.moreData#Null:C1517) && (String:C10($line.moreData.minLotChargeSource)#"")
		$source:=String:C10($line.moreData.minLotChargeSource)
	Else
		$source:=(Num:C11($line.minLotCharge)>0) ? "legacy" : "none"
	End if

Function defaultFor($line : cs:C1710.QuoteLineEntity)->$default : Object
	// -> {value; source ("priceList" or "none"); detail (the process and price that give it)}
	var $stepUUIDs : Collection
	var $process : cs:C1710.StepProcessEntity
	var $items : cs:C1710.PriceListItemSelection
	var $item : cs:C1710.PriceListItemEntity
	var $customerUUID : Text

	$default:=New object:C1471("value"; 0; "source"; "none"; "detail"; "")
	If ($line.moreData=Null:C1517) || ($line.moreData.build=Null:C1517) || ($line.moreData.build.steps=Null:C1517)
		return
	End if
	$stepUUIDs:=$line.moreData.build.steps.extract("UUID")
	If ($stepUUIDs.length=0)
		return
	End if
	$customerUUID:=($line.quote=Null:C1517) ? "" : $line.quote.UUID_Customer
	For each ($process; ds:C1482.Step.query("UUID in :1"; $stepUUIDs).stepProcess)
		$items:=ds:C1482.PriceListItem.validOn(Current date:C33; $process.UUID; $customerUUID)
		$item:=$items.query("UUID_Customer = :1"; $customerUUID).orderBy("minLotCharge desc").first()  // the customer's own price
		If ($item=Null:C1517)
			$item:=$items.orderBy("minLotCharge desc").first()  // two valid rows at once: the higher minimum
		End if
		If ($item#Null:C1517) && ($item.minLotCharge>$default.value)
			$default:=New object:C1471("value"; $item.minLotCharge; "source"; "priceList"; "detail"; $process.name+" ("+$item.code+")")
		End if
	End for each

Function applyDefault($line : cs:C1710.QuoteLineEntity)->$changed : Boolean
	// Fills the minimum from the price list, unless it was typed or imported. Not saved: the caller
	// saves the line. Called when a line's unit price or quantity is entered (panel_quote), which is
	// also the path of the lines built from processes.
	var $default : Object

	If (New collection:C1472("manual"; "legacy").indexOf(This:C1470.sourceOf($line))#-1)
		return
	End if
	$default:=This:C1470.defaultFor($line)
	$changed:=($line.minLotCharge#$default.value) || (This:C1470.sourceOf($line)#$default.source)
	If ($changed)
		$line.minLotCharge:=$default.value
		This:C1470._setSource($line; $default.source; $default.value)
	End if

Function resetToDefault($line : cs:C1710.QuoteLineEntity)
	// "Reset minimum lot charge" (panel_quote): back to the price list, or to none. Not saved
	var $default : Object
	var $old : Real

	$old:=$line.minLotCharge
	$default:=This:C1470.defaultFor($line)
	$line.minLotCharge:=$default.value
	This:C1470._setSource($line; $default.source; $default.value)
	$line.clearAmountOverride()
	If ($old#$default.value)
		This:C1470._event($line; $old; "Reset to "+Choose:C955($default.source="priceList"; "the price list ("+$default.detail+")"; "no minimum")+".")
	End if

Function confirmTyped($line : cs:C1710.QuoteLineEntity; $old : Real)->$keep : Boolean
	// Called by panel_quote when a minimum is typed, before the line is saved. False: the caller puts
	// the stored value back
	var $default : Object
	var $by : Text

	$keep:=True:C214
	If ($line.minLotCharge<0)
		cs:C1710.sfw_dialog.me.alert("The minimum lot charge cannot be negative: 0 means no minimum.")
		$keep:=False:C215
		return
	End if
	If ($line.minLotCharge=$old)
		return
	End if
	$default:=This:C1470.defaultFor($line)
	Case of
		: ($default.value>0) && ($line.minLotCharge=$default.value)
			This:C1470._setSource($line; "priceList"; $default.value)
			return
		: ($default.value>0) && ($line.minLotCharge<$default.value)
			If (Not:C34(cs:C1710.ga_quotePriceFloor.me.canOverride()))
				cs:C1710.sfw_dialog.me.alert("Line "+String:C10($line.num)+": the price list gives a minimum lot charge of "+This:C1470._money($default.value)+" ("+$default.detail+").\r\rOnly a Price override user can lower it.")
				$keep:=False:C215
				return
			End if
			$keep:=cs:C1710.sfw_dialog.me.confirm("Line "+String:C10($line.num)+": lower the minimum lot charge from the price list's "+This:C1470._money($default.value)+" ("+$default.detail+") to "+This:C1470._money($line.minLotCharge)+"?"; "Lower it"; "Change")
			If (Not:C34($keep))
				return
			End if
	End case
	This:C1470._setSource($line; "manual"; $default.value)
	$by:=String:C10(cs:C1710.sfw_userManager.me.info.name)
	This:C1470._event($line; $old; "Typed by "+$by+Choose:C955($default.value>0; " (price list: "+This:C1470._money($default.value)+")"; "")+".")

Function isUnder($line : cs:C1710.QuoteLineEntity)->$under : Boolean
	// quantity x unit price below the minimum (a legacy typed amount is left as it is)
	If ($line.moreData#Null:C1517) && ($line.moreData.amount#Null:C1517)
		return
	End if
	$under:=($line.minLotCharge>0) && (($line.quantity*$line.unitPrice)<($line.minLotCharge-0.005))

Function underText($line : cs:C1710.QuoteLineEntity)->$text : Text
	$text:="Line "+String:C10($line.num)+": "+String:C10($line.quantity)+" x "+This:C1470._money($line.unitPrice)+" = "+This:C1470._money($line.quantity*$line.unitPrice)+" is under the minimum lot charge "+This:C1470._money($line.minLotCharge)+"."

Function alertIfUnder($line : cs:C1710.QuoteLineEntity)
	// block mode: said when a quantity, unit price or minimum is entered (the line is still saved)
	If (This:C1470.mode()="block") && (This:C1470.isUnder($line))
		cs:C1710.sfw_dialog.me.alert(This:C1470.underText($line)+"\r\rRaise the quantity or the unit price: the quote cannot be marked as sent while a line is under its minimum.")
	End if

Function blockingLines($quote : cs:C1710.QuoteEntity)->$texts : Collection
	// block mode: the lines under their minimum ([] in force mode)
	var $line : cs:C1710.QuoteLineEntity

	$texts:=New collection:C1472
	If (This:C1470.mode()#"block")
		return
	End if
	For each ($line; $quote.lines.orderBy("num asc"))
		If (This:C1470.isUnder($line))
			$texts.push(This:C1470.underText($line))
		End if
	End for each

Function sourceText($line : cs:C1710.QuoteLineEntity)->$text : Text
	Case of
		: ($line=Null:C1517)
		: (This:C1470.sourceOf($line)="priceList")
			$text:="from the price list"
		: (This:C1470.sourceOf($line)="manual")
			$text:="typed"
		: (This:C1470.sourceOf($line)="legacy")
			$text:="kept as imported"
	End case

Function _setSource($line : cs:C1710.QuoteLineEntity; $source : Text; $default : Real)
	// other moreData keys (build, priceFloor, amount) are kept
	var $moreData : Object
	$moreData:=($line.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($line.moreData)
	$moreData.minLotChargeSource:=$source
	$moreData.minLotChargeDefault:=$default
	$line.moreData:=$moreData

Function _event($line : cs:C1710.QuoteLineEntity; $old : Real; $how : Text)
	cs:C1710.ga_events.me.addEvent("quote"; $line.UUID_Quote; "quoteMinLotCharge"; "Min. lot charge"; New collection:C1472(\
		"Line "+String:C10($line.num)+": "+This:C1470._money($old)+" -> "+This:C1470._money($line.minLotCharge)+"."; $how))

Function _money($value : Real)->$text : Text
	$text:=String:C10($value; "$###,###,##0.00")
