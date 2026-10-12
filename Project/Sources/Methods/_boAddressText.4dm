//%attributes = {}
// _boAddressText($order : BuyingOrderEntity; $type : Text) -> Text
// One address off the order's contactDetails, as printable lines.
//
// _import_buyOrders stores them as {type; detail{street_1, street_2, city, state,
// postcode, country}} under contactDetails.addresses, with type being billing, shipping
// or remit. Empty parts are skipped rather than leaving blank lines or stray commas.

#DECLARE($order : cs:C1710.BuyingOrderEntity; $type : Text)->$text : Text

var $address : Object
var $detail : Object
var $lines : Collection
var $cityLine : Text

$text:=""
If ($order=Null:C1517) || ($order.contactDetails=Null:C1517) || ($order.contactDetails.addresses=Null:C1517)
	return
End if

$address:=$order.contactDetails.addresses.query("type = :1"; $type).first()
If ($address=Null:C1517) || ($address.detail=Null:C1517)
	return
End if

$detail:=$address.detail
$lines:=New collection:C1472()

If (String:C10($detail.street_1)#"")
	$lines.push(String:C10($detail.street_1))
End if
If (String:C10($detail.street_2)#"")
	$lines.push(String:C10($detail.street_2))
End if

$cityLine:=String:C10($detail.city)
If (String:C10($detail.state)#"")
	$cityLine:=($cityLine="") ? String:C10($detail.state) : $cityLine+", "+String:C10($detail.state)
End if
If (String:C10($detail.postcode)#"")
	$cityLine:=($cityLine="") ? String:C10($detail.postcode) : $cityLine+" "+String:C10($detail.postcode)
End if
If ($cityLine#"")
	$lines.push($cityLine)
End if

If (String:C10($detail.country)#"")
	$lines.push(String:C10($detail.country))
End if

$text:=$lines.join(Char:C90(Carriage return:K15:38))