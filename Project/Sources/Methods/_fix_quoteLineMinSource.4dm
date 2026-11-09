//%attributes = {}
// _fix_quoteLineMinSource
// One-time marking of the existing quote lines for ga_quoteMinCharge (Oct 2026): where their minimum
// lot charge comes from. Nothing is recalculated and no amount changes:
// - a line with a minimum: moreData.minLotChargeSource "legacy" (kept as it is, never replaced by the
//   price list; "Reset minimum lot charge" in the quote does it by hand)
// - a line without one: "none" (the price list fills it when its quantity or unit price is entered)
// The report also lists the lines whose minimum differs from what the price list would give today,
// to review by hand. Asks first: "Report only" changes nothing and writes
// Project/imports/quote_min_lot_source.txt; "Apply" does the same and saves. Safe to run again:
// lines that already have a source are left alone.

var $apply : Boolean
var $eLine : cs:C1710.QuoteLineEntity
var $count; $default; $info; $moreData : Object
var $differ; $failed; $lines : Collection
var $source; $label : Text

$apply:=cs:C1710.sfw_dialog.me.confirm("Mark where the minimum lot charge of each existing quote line comes from?\r\r"+\
"No amount changes. Report only: writes Project/imports/quote_min_lot_source.txt and changes nothing.\r"+\
"Apply: does the same and saves the lines."; "Apply"; "Report only")

$count:=New object:C1471("lines"; 0; "already"; 0; "legacy"; 0; "none"; 0)
$differ:=New collection:C1472
$failed:=New collection:C1472
For each ($eLine; ds:C1482.QuoteLine.all())
	$count.lines+=1
	If ($eLine.moreData#Null:C1517) && (String:C10($eLine.moreData.minLotChargeSource)#"")
		$count.already+=1
	Else
		$source:=cs:C1710.ga_quoteMinCharge.me.sourceOf($eLine)  // "legacy" or "none"
		$count[$source]+=1
		$default:=cs:C1710.ga_quoteMinCharge.me.defaultFor($eLine)
		If ($default.source="priceList") && ($default.value#Num:C11($eLine.minLotCharge))  // only lines built from processes have one
			$label:=String:C10($eLine.quote.code)+" line "+String:C10($eLine.num)+": minimum "+String:C10($eLine.minLotCharge; "###,###,##0.00")+", price list "+String:C10($default.value; "###,###,##0.00")+" ("+$default.detail+")"
			$differ.push($label)
		End if
		If ($apply)
			$moreData:=($eLine.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($eLine.moreData)
			$moreData.minLotChargeSource:=$source
			$moreData.minLotChargeDefault:=$default.value
			$eLine.moreData:=$moreData
			$info:=$eLine.save()
			If (Not:C34($info.success))
				$failed.push(String:C10($eLine.quote.code)+" line "+String:C10($eLine.num)+" ("+String:C10($info.statusText)+")")
			End if
		End if
	End if
End for each

$lines:=New collection:C1472("Quote line minimum lot charge source - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Quote lines: "+String:C10($count.lines))
$lines.push("Already marked, left alone: "+String:C10($count.already))
$lines.push("With a minimum, marked \"legacy\" (kept): "+String:C10($count.legacy)+($apply ? "" : " (not saved)"))
$lines.push("Without a minimum, marked \"none\": "+String:C10($count.none)+($apply ? "" : " (not saved)"))
$lines.push("")
$lines.push("Minimum different from the price list today, not changed - to review ("+String:C10($differ.length)+"):")
For each ($label; $differ)
	$lines.push("  "+$label)
End for each
$lines.push("")
$lines.push("Save failed ("+String:C10($failed.length)+"): "+$failed.join(", "))

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("quote_min_lot_source.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info(String:C10($count.legacy)+" lines with a minimum kept as legacy, "+String:C10($count.none)+" without one"+($apply ? "" : " (nothing saved)")+".\r"+String:C10($differ.length)+" differ from the price list.\rDetails in Project/imports/quote_min_lot_source.txt")
