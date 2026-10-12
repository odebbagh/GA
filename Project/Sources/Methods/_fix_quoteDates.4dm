//%attributes = {}
// _fix_quoteDates
// One-time repair: the quote import (__import_data_quote) left every legacy quote without a creation
// date (stmpCreation = 0), because Date("2019-07-17") gave !00-00-00!. So the date showed empty and
// the yearCreation / monthCreation tags never found them (_diag_quoteSearch, Oct 2026).
// Reads Qdate again from the data folder's DataJson/quotes.json and fills the quotes that have no
// date, or another date than the legacy one (a quote displayed in Modify mode got today's date from
// panel_quote and could be saved with it), matched by code. Asks first: "Report only" changes nothing and writes
// Project/imports/quote_dates_fix.txt; "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $file : 4D:C1709.File
var $dateByCode; $quote; $info : Object
var $lines; $notFound; $noDate; $failed; $wrongDate : Collection
var $legacy : Variant
var $eQuote : cs:C1710.QuoteEntity
var $date : Date
var $count; $byYear : Object
var $key : Text

$file:=Folder:C1567(fk data folder:K87:12).folder("DataJson").file("quotes.json")
If (Not:C34($file.exists))
	cs:C1710.sfw_dialog.me.alert("quotes.json is missing in the data folder's DataJson.\rNothing was changed.")
	return
End if

$apply:=cs:C1710.sfw_dialog.me.confirm("Fill the creation date of the imported quotes?\r\r"+\
"Report only: writes Project/imports/quote_dates_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the quotes."; "Apply"; "Report only")

// the legacy dates as stamps (0: no date), by quote code. Not Dates: an object may keep a Date as text
$dateByCode:=New object:C1471
For each ($quote; JSON Parse:C1218($file.getText()))
	$date:=ds:C1482.Quote.legacyDate($quote.Qdate)
	$dateByCode[String:C10($quote.QuoteNumber)]:=($date=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
End for each

$count:=New object:C1471("withoutDate"; 0; "filled"; 0)
$wrongDate:=New collection:C1472
$byYear:=New object:C1471
$notFound:=New collection:C1472
$noDate:=New collection:C1472
$failed:=New collection:C1472
For each ($eQuote; ds:C1482.Quote.all())
	$legacy:=$dateByCode[$eQuote.code]
	If ($eQuote.stmpCreation=0)
		$count.withoutDate+=1
	End if
	Case of
		: ($legacy=Null:C1517)  // created here, not imported
			If ($eQuote.stmpCreation=0)
				$notFound.push($eQuote.code)
			End if
		: ($legacy=0)
			If ($eQuote.stmpCreation=0)
				$noDate.push($eQuote.code)
			End if
		: ($eQuote.stmpCreation#0) && (cs:C1710.sfw_stmp.me.getDate($eQuote.stmpCreation)=cs:C1710.sfw_stmp.me.getDate($legacy))
			// already right
		Else
			If ($eQuote.stmpCreation#0)  // given today's date when displayed (panel_quote, before Oct 2026)
				$wrongDate.push($eQuote.code+": "+String:C10(cs:C1710.sfw_stmp.me.getDate($eQuote.stmpCreation))+" -> "+String:C10(cs:C1710.sfw_stmp.me.getDate($legacy)))
			End if
			$key:=String:C10(Year of:C25(cs:C1710.sfw_stmp.me.getDate($dateByCode[$eQuote.code])))
			$byYear[$key]:=Num:C11($byYear[$key])+1
			$count.filled+=1
			If ($apply)
				$eQuote.stmpCreation:=$dateByCode[$eQuote.code]
				$info:=$eQuote.save()
				If (Not:C34($info.success))
					$failed.push($eQuote.code+" ("+String:C10($info.statusText)+")")
				End if
			End if
	End case
End for each

$lines:=New collection:C1472("Quote dates fix - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Quotes without a date: "+String:C10($count.withoutDate))
$lines.push("Imported quotes with another date than the legacy one ("+String:C10($wrongDate.length)+"): "+$wrongDate.join(", "))
$lines.push("Dated from quotes.json (both): "+String:C10($count.filled)+($apply ? "" : " (not saved)"))
$lines.push("Per year:")
For each ($key; OB Keys:C1719($byYear).sort())
	$lines.push("  "+$key+": "+String:C10($byYear[$key]))
End for each
$lines.push("")
$lines.push("Not in quotes.json ("+String:C10($notFound.length)+"): "+$notFound.join(", "))
$lines.push("No Qdate in quotes.json ("+String:C10($noDate.length)+"): "+$noDate.join(", "))
$lines.push("Save failed ("+String:C10($failed.length)+"): "+$failed.join(", "))

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("quote_dates_fix.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info(String:C10($count.filled)+" of "+String:C10($count.withoutDate)+" quotes "+($apply ? "dated" : "can be dated")+".\rDetails in Project/imports/quote_dates_fix.txt")