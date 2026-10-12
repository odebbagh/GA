//%attributes = {}
// _ga_usdText ($amount) -> "$1,234.56"
// An amount as US dollars whatever the Windows region: String($x; "###,##0.00") follows the
// system separators and gave "$00,00" on a French Windows. Used by the amount getters of
// LeadEntity (list column) and QuoteEntity (Total).
#DECLARE($amount : Real)->$text : Text

var $cents; $dollars; $rest : Real  // Real: in cents an Integer overflows past $21M
var $digits : Text

$cents:=Round:C94(Abs:C99($amount)*100; 0)
$dollars:=Int:C8($cents/100)
$rest:=$cents-($dollars*100)

// thousands separators from the right
$digits:=String:C10($dollars)
$text:=""
While (Length:C16($digits)>3)
	$text:=","+Substring:C12($digits; Length:C16($digits)-2)+$text
	$digits:=Substring:C12($digits; 1; Length:C16($digits)-3)
End while
$text:=(($amount<0) ? "-" : "")+"$"+$digits+$text+"."+String:C10($rest; "00")