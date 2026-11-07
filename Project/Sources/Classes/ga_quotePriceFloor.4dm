// ga_quotePriceFloor
// Quote line unit price below a floor set by accounting (a dropped zero, or a price under cost).
// Checked when a person types a unit price or a quantity in panel_quote (confirmLine), never on
// open, save, revision or import: imported legacy prices are never blocked.
// - sfw_Setting "QuotePriceFloorMode", data.value: "warn" (default), "block" or "off"
// - block: only the PRICEOVERRIDE profile (or admin) keeps the price, or a holder signs in the
//   Util_Authorizer window. A kept price is noted in moreData.priceFloor and in the quote history.
// - no floor for the line: a typo check only (warn, never block), new price under a fifth of the old.
// floorFor is the one place that knows where floors come from (the Master Price List, later;
// until then only the test floors described there).

property _testFloor : Real  // set by ga_demoCheck and for tests in the IDE; 0 = no test floor

singleton Class constructor
	This:C1470._testFloor:=0

Function mode()->$mode : Text
	var $eSetting : 4D:C1709.Entity

	$mode:="warn"
	$eSetting:=ds:C1482.sfw_Setting.query("ident = :1"; "QuotePriceFloorMode").first()
	If ($eSetting#Null:C1517) && ($eSetting.data#Null:C1517)
		If (New collection:C1472("warn"; "block"; "off").indexOf(Lowercase:C14(String:C10($eSetting.data.value)))#-1)
			$mode:=Lowercase:C14(String:C10($eSetting.data.value))
		End if
	End if

Function floorFor($line : cs:C1710.QuoteLineEntity)->$floor : Object
	// -> {value; source}; value 0 = no floor for this line.
	// The Master Price List: the internal cost of the line's steps for the quote's flow
	// (ga_pricing.floorOfLine). Lines typed by hand, or whose processes have no cost, have none.
	// Also a test floor: _testFloor (this process only, ga_demoCheck), and when the price list gives
	// none, the sfw_Setting "QuotePriceFloorDemo" (one floor for every line, to show the check in
	// the panel; delete the setting after the demo).
	var $eSetting : 4D:C1709.Entity

	$floor:=New object:C1471("value"; 0; "source"; "")
	If (This:C1470._testFloor>0)
		$floor:=New object:C1471("value"; This:C1470._testFloor; "source"; "test floor")
		return
	End if
	$floor:=cs:C1710.ga_pricing.me.floorOfLine($line)
	If ($floor.value>0)
		return
	End if
	$eSetting:=ds:C1482.sfw_Setting.query("ident = :1"; "QuotePriceFloorDemo").first()
	If ($eSetting#Null:C1517) && ($eSetting.data#Null:C1517) && (Num:C11($eSetting.data.value)>0)
		$floor:=New object:C1471("value"; Num:C11($eSetting.data.value); "source"; "demo floor")
	End if

Function check($line : cs:C1710.QuoteLineEntity; $previousPrice : Real)->$verdict : Object
	// No UI. -> {ok; kind ("floor", "typo" or ""); floor; source; reason}
	var $floor : Object
	var $price : Real

	$verdict:=New object:C1471("ok"; True:C214; "kind"; ""; "floor"; 0; "source"; ""; "reason"; "")
	$price:=Num:C11($line.unitPrice)
	If ($price<=0)  // not priced yet: a new line starts at 0
		return
	End if
	$floor:=This:C1470.floorFor($line)
	$verdict.floor:=Num:C11($floor.value)
	$verdict.source:=String:C10($floor.source)
	Case of
		: ($verdict.floor>0)
			If ($price<$verdict.floor)
				$verdict.ok:=False:C215
				$verdict.kind:="floor"
				$verdict.reason:="Line "+String:C10($line.num)+": the unit price "+This:C1470._money($price)+" is below the floor "+This:C1470._money($verdict.floor)+Choose:C955($verdict.source=""; ""; " ("+$verdict.source+")")+"."
			End if
		: ($previousPrice>0) && ($price<($previousPrice/5))
			$verdict.ok:=False:C215
			$verdict.kind:="typo"
			$verdict.reason:="Line "+String:C10($line.num)+": the unit price "+This:C1470._money($price)+" is less than a fifth of the previous price "+This:C1470._money($previousPrice)+". A missing zero?"
	End case

Function isKept($line : cs:C1710.QuoteLineEntity; $verdict : Object)->$kept : Boolean
	// this same price was already kept below this same floor (a quantity changed, or the field re-entered)
	var $note : Object

	If ($line.moreData=Null:C1517) || ($line.moreData.priceFloor=Null:C1517)
		return
	End if
	$note:=$line.moreData.priceFloor
	$kept:=(Num:C11($note.price)=Num:C11($line.unitPrice)) && (Num:C11($note.floor)=Num:C11($verdict.floor))

Function canOverride()->$can : Boolean
	var $profiles : Collection
	var $profile : Variant

	$profiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	If ($profiles=Null:C1517)
		return
	End if
	For each ($profile; $profiles)
		If (Value type:C1509($profile)=Is text:K8:3)
			If (New collection:C1472("PRICEOVERRIDE"; "ADMIN").indexOf(Uppercase:C13($profile))#-1)
				$can:=True:C214
			End if
		End if
	End for each

Function confirmLine($line : cs:C1710.QuoteLineEntity; $previousPrice : Real)->$keep : Boolean
	// Called by panel_quote when a unit price or quantity is typed, before the line is saved.
	// True: save the line (moreData.priceFloor set when a price is kept below). False: the caller
	// puts the stored values back.
	var $verdict; $approval : Object
	var $mode; $approver : Text

	$keep:=True:C214
	$mode:=This:C1470.mode()
	If ($mode="off")
		return
	End if
	$verdict:=This:C1470.check($line; $previousPrice)
	If ($verdict.ok)
		$line.clearPriceFloorNote()
		return
	End if
	If (This:C1470.isKept($line; $verdict))
		return
	End if

	$approver:=""
	Case of
		: ($verdict.kind="typo") || ($mode="warn")
			$keep:=cs:C1710.sfw_dialog.me.confirm($verdict.reason+"\r\rKeep this price?"; "Keep price"; "Change")
		: (This:C1470.canOverride())
			$keep:=cs:C1710.sfw_dialog.me.confirm($verdict.reason+"\r\rKeep this price below the floor?"; "Keep (override)"; "Change")
		Else
			$keep:=cs:C1710.sfw_dialog.me.confirm($verdict.reason+"\r\rOnly a Price override user can keep it."; "Ask approval"; "Change")
			If ($keep)
				$approval:=cs:C1710.Util_Authorizer.me.requestApproval(New object:C1471(\
					"profiles"; New collection:C1472("PRICEOVERRIDE"; "ADMIN"); \
					"profileLabel"; "Price override"; \
					"requirePassword"; True:C214; \
					"title"; "Price below floor"))
				// cancelled: nothing to say. Failed: Util_Authorizer already said why
				$keep:=Bool:C1537($approval.success)
				If ($keep)
					$approver:=String:C10($approval.staff.fullName)
				End if
			End if
	End case

	If ($keep)
		This:C1470._note($line; $verdict; $mode; $approver)
	End if

Function _note($line : cs:C1710.QuoteLineEntity; $verdict : Object; $mode : Text; $approver : Text)
	// moreData.priceFloor (saved with the line by the caller) and a line in the quote history
	var $moreData : Object
	var $by : Text

	$by:=String:C10(cs:C1710.sfw_userManager.me.info.name)
	$moreData:=($line.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($line.moreData)
	$moreData.priceFloor:=New object:C1471(\
		"price"; Num:C11($line.unitPrice); \
		"floor"; $verdict.floor; \
		"kind"; $verdict.kind; \
		"source"; $verdict.source; \
		"mode"; $mode; \
		"by"; $by; \
		"approvedBy"; $approver; \
		"stmp"; cs:C1710.sfw_stmp.me.now())
	$line.moreData:=$moreData

	cs:C1710.ga_events.me.addEvent("quote"; $line.UUID_Quote; "quotePriceBelowFloor"; "Price below floor"; New collection:C1472(\
		$verdict.reason; \
		"Kept by "+$by+Choose:C955($approver=""; ""; ", approved by "+$approver)+"."))

Function _money($value : Real)->$text : Text
	$text:=String:C10($value; "$###,###,##0.00")

