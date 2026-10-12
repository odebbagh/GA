//%attributes = {}
// _diag_quoteSearch
// READ-ONLY. Why the yearCreation / monthCreation tags of the Quotes entry find the new quotes
// and not the imported ones. Nothing is saved. Writes Project/imports/quote_search_diag.txt.
//   - the search fields as the entry definition declares them (type 5 = integer)
//   - quotes per year from the stamp (getter) against ds.Quote.query("yearCreation = :1")
//   - quotes without a stamp, and the first imported ones with their stamp and dates
//   - quotes per month, the same comparison
//   - optional preliminary text: empty or a Write Pro document

var $lines; $years; $fields : Collection
var $byYear; $byMonth; $field : Object
var $quote : cs.QuoteEntity
var $year; $month; $nbQuery; $noStamp : Integer
var $key : Text

$lines:=New collection("Quote search diagnostic - "+String(Current date)+" "+String(Current time))
$lines.push("")

// ---------------------------------------------------------------- search fields
$fields:=ds.Quote.entryDefinition().searchfields
$lines.push("SEARCH FIELDS")
For each ($field; $fields)
	$lines.push("  "+JSON Stringify($field))
End for each
$lines.push("")

// ---------------------------------------------------------------- per year and month, from the stamp
$byYear:=New object
$byMonth:=New object
$noStamp:=0
For each ($quote; ds.Quote.all())
	If ($quote.stmpCreation=0)
		$noStamp+=1
	Else
		$key:=String($quote.yearCreation)
		$byYear[$key]:=Num($byYear[$key])+1
		$key:=String($quote.monthCreation)
		$byMonth[$key]:=Num($byMonth[$key])+1
	End if
End for each
$lines.push("QUOTES: "+String(ds.Quote.all().length)+", without a creation stamp: "+String($noStamp))
$lines.push("")

$lines.push("PER YEAR: getter count / query(\"yearCreation = :1\") count")
For each ($key; OB Keys($byYear).sort())
	$nbQuery:=ds.Quote.query("yearCreation = :1"; Num($key)).length
	$lines.push("  "+$key+": "+String($byYear[$key])+" / "+String($nbQuery)+(($nbQuery#$byYear[$key]) ? "   <-- differs" : ""))
End for each
$lines.push("")

$lines.push("PER MONTH: getter count / query(\"monthCreation = :1\") count")
For ($month; 1; 12)
	$key:=String($month)
	$nbQuery:=ds.Quote.query("monthCreation = :1"; $month).length
	$lines.push("  "+$key+": "+String(Num($byMonth[$key]))+" / "+String($nbQuery)+(($nbQuery#Num($byMonth[$key])) ? "   <-- differs" : ""))
End for
$lines.push("")

// ---------------------------------------------------------------- samples
$lines.push("SAMPLES: code, stmpCreation, dateCreation, yearCreation, monthCreation, preliminary text")
For each ($quote; ds.Quote.query("code in :1"; New collection("Q251"; "Q1000"; "Q2000"; "Q3040"; "Q3041"; "Q3042"; "Q3043")))
	$lines.push("  "+$quote.code+": "+String($quote.stmpCreation)+", "+String($quote.dateCreation)+", "+String($quote.yearCreation)+", "+String($quote.monthCreation)+", "+(($quote.optionalPreliminaryTxt_wr=Null) || OB Is empty($quote.optionalPreliminaryTxt_wr) ? "empty" : "document"))
End for each

Folder(fk database folder).folder("Project/imports").file("quote_search_diag.txt").setText($lines.join("\r\n"))
cs.sfw_dialog.me.info("Quote search diagnostic written to Project/imports/quote_search_diag.txt.\rSend it to Claude.")