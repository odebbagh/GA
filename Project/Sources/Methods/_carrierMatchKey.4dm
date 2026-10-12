//%attributes = {}
// _carrierMatchKey($name : Text) -> Text
// Folds a carrier name down to a comparison key, so the many spellings the legacy
// application used all land on the same [CustomerCarrier] row.
//
//   "Fed-Ex Priority Overnight" )
//   "fedex Priority Overnight"  ) -> "fedexpriorityovernight"
//   "FedEx  Priority Overnight" )
//
//   "fedex Std Overnight" -> "fedexstandardovernight" -> same row as "FedEx Standard Overnight"
//   "ups"                 -> "ups"                    -> same row as "UPS"
//
// Used by _import_customerCarriers to seed the table, and by _import_buyOrders and
// _import_customers to resolve a legacy shipVia / carrier name to that table. All three
// must fold the same way, which is why this lives in one place.

#DECLARE($name : Text)->$key : Text

var $work : Text

$key:=""
$work:=Lowercase:C14(String:C10($name))

If ($work="")
	return
End if

//brand spelt three ways in the source data
$work:=Replace string:C233($work; "fed-ex"; "fedex")
$work:=Replace string:C233($work; "fed ex"; "fedex")

//abbreviations, matched as whole words: pad so the first and last word match too
$work:=" "+$work+" "
$work:=Replace string:C233($work; " std "; " standard ")
$work:=Replace string:C233($work; " acct "; " account ")
$work:=Replace string:C233($work; " intl "; " international ")

//everything that is not a letter or a digit is noise for matching purposes
$key:=""
var $i : Integer
var $char : Text
For ($i; 1; Length:C16($work))
	$char:=Substring:C12($work; $i; 1)
	If (Position:C15($char; "abcdefghijklmnopqrstuvwxyz0123456789")>0)
		$key:=$key+$char
	End if
End for
