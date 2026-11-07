//%attributes = {}
// _fix_quoteLineMinCharge
// One-time repair for the "Min. lot charge" column of the quote lines (Oct 2026). Until then an amount
// typed over quantity x unit price (in the panel, or imported by __import_data_quote) was kept in
// moreData.amount. Now the amount is quantity x unit price, raised to QuoteLine.minLotCharge.
// - typed amount above quantity x unit price: moved into minLotCharge (same amount, now visible)
// - typed amount equal to it: the override is removed (no change of amount)
// - typed amount below it (a discount): left as it is and listed, to review by hand
// Asks first: "Report only" changes nothing and writes Project/imports/quote_min_charge_fix.txt;
// "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $eLine : cs:C1710.QuoteLineEntity
var $moreData; $info; $count : Object
var $typed; $product : Real
var $moved; $below; $failed; $lines : Collection
var $label : Text

$apply:=cs:C1710.sfw_dialog.me.confirm("Move the amounts typed on quote lines into the new Min. lot charge column?\r\r"+\
"Report only: writes Project/imports/quote_min_charge_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the lines."; "Apply"; "Report only")

$count:=New object:C1471("typed"; 0; "moved"; 0; "same"; 0)
$moved:=New collection:C1472
$below:=New collection:C1472
$failed:=New collection:C1472
For each ($eLine; ds:C1482.QuoteLine.all())
	If ($eLine.moreData#Null:C1517) && ($eLine.moreData.amount#Null:C1517)
		$count.typed+=1
		$typed:=Num:C11($eLine.moreData.amount)
		$product:=$eLine.quantity*$eLine.unitPrice
		$label:=String:C10($eLine.quote.code)+" line "+String:C10($eLine.num)+": "+String:C10($eLine.quantity)+" x "+String:C10($eLine.unitPrice; "###,###,##0.00")+" = "+String:C10($product; "###,###,##0.00")+", typed "+String:C10($typed; "###,###,##0.00")
		If ($typed<($product-0.005))
			$below.push($label)
		Else
			If ($typed>($product+0.005))
				$count.moved+=1
				$moved.push($label)
			Else
				$count.same+=1
			End if
			If ($apply)
				If ($typed>($product+0.005))
					$eLine.minLotCharge:=$typed
				End if
				$moreData:=OB Copy:C1225($eLine.moreData)
				OB REMOVE:C1226($moreData; "amount")
				$eLine.moreData:=$moreData
				$info:=$eLine.save()
				If (Not:C34($info.success))
					$failed.push($label+" ("+String:C10($info.statusText)+")")
				End if
			End if
		End if
	End if
End for each

$lines:=New collection:C1472("Quote line minimum lot charge fix - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Lines with a typed amount: "+String:C10($count.typed))
$lines.push("Typed amount equal to quantity x unit price, override removed: "+String:C10($count.same)+($apply ? "" : " (not saved)"))
$lines.push("")
$lines.push("Moved into Min. lot charge ("+String:C10($moved.length)+")"+($apply ? "" : " (not saved)")+":")
For each ($label; $moved)
	$lines.push("  "+$label)
End for each
$lines.push("")
$lines.push("Below quantity x unit price, kept as typed - to review ("+String:C10($below.length)+"):")
For each ($label; $below)
	$lines.push("  "+$label)
End for each
$lines.push("")
$lines.push("Save failed ("+String:C10($failed.length)+"): "+$failed.join(", "))

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("quote_min_charge_fix.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info(String:C10($count.moved)+" lines "+($apply ? "moved" : "to move")+" into Min. lot charge, "+String:C10($below.length)+" to review.\rDetails in Project/imports/quote_min_charge_fix.txt")
