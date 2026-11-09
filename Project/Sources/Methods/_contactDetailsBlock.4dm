//%attributes = {}

// _contactDetailsBlock($contactDetails) -> Text
// Telephone, fax and email as printable lines:
//     Tel: ...
//     Fax: ...
//     Email: ...
// Each appears only when the record has it, so there are no empty labels. This is what
// legacy object method Field11 wrote over [BUY_ORDERS]BuyersCode at print time.

#DECLARE($contactDetails : Object)->$text : Text

var $lines : Collection
var $value : Text

$lines:=New collection()

$value:=_contactDetailsValue($contactDetails; "phone")
If ($value#"")
	$lines.push("Tel: "+$value)
End if
$value:=_contactDetailsValue($contactDetails; "fax")
If ($value#"")
	$lines.push("Fax: "+$value)
End if
$value:=_contactDetailsValue($contactDetails; "mail")
If ($value#"")
	$lines.push("Email: "+$value)
End if

$text:=$lines.join(Char(Carriage return))