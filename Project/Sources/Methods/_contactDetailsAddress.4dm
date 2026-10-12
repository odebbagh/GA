//%attributes = {}

// _contactDetailsAddress($contactDetails; $type) -> Text
// One structured address as printable lines - street_1, street_2, "city, state postcode"
// and country, each skipped when empty so there are no blank lines or stray commas.
//
// Types in use: "billing", "shipping", "remit", "main".
//
// NOTE this is for addresses that are genuinely structured. A free-text address that was
// only split into street_1/street_2 at import does NOT round-trip through here - see
// BuyingOrderEntity.shipToText, which reads the original text instead.

#DECLARE($contactDetails : Object; $type : Text)->$text : Text

var $address : Object
var $detail : Object
var $lines : Collection
var $cityLine : Text

$text:=""
If ($contactDetails=Null) || ($contactDetails.addresses=Null)
	return
End if

$address:=$contactDetails.addresses.query("type = :1"; $type).first()
If ($address=Null) || ($address.detail=Null)
	return
End if

$detail:=$address.detail
$lines:=New collection()

If (String($detail.street_1)#"")
	$lines.push(String($detail.street_1))
End if
If (String($detail.street_2)#"")
	$lines.push(String($detail.street_2))
End if

$cityLine:=String($detail.city)
If (String($detail.state)#"")
	$cityLine:=($cityLine="") ? String($detail.state) : $cityLine+", "+String($detail.state)
End if
If (String($detail.postcode)#"")
	$cityLine:=($cityLine="") ? String($detail.postcode) : $cityLine+" "+String($detail.postcode)
End if
If ($cityLine#"")
	$lines.push($cityLine)
End if

If (String($detail.country)#"")
	$lines.push(String($detail.country))
End if

$text:=$lines.join(Char(Carriage return))