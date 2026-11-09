//%attributes = {}
// _boVendorBlock($order) -> Text
// Legacy SubrBuyOrderAddr, which built the "Issued to:" block as:
//     VENDOR
//     Vendor_add1 / add2 / add3   (each only when not empty)
//     Vendor_ST   Vendor_ZIP      (three spaces between, when either is set)
//     Vendor_Country
// The new application keeps the vendor's address on [Supplier] rather than copied onto
// the order, so it is read from there; the order's own billing address is the fallback
// for imported orders where the supplier did not resolve.

#DECLARE($order : cs:C1710.BuyingOrderEntity)->$text : Text

var $lines : Collection
var $address : Object
var $detail : Object
var $cityLine : Text

$lines:=New collection:C1472()

If ($order.supplier#Null:C1517)
	If (String:C10($order.supplier.name)#"")
		$lines.push(String:C10($order.supplier.name))
	End if
End if

$address:=Null:C1517
If ($order.contactDetails#Null:C1517) && ($order.contactDetails.addresses#Null:C1517)
	$address:=$order.contactDetails.addresses.query("type = :1"; "billing").first()
End if

If ($address#Null:C1517) && ($address.detail#Null:C1517)
	$detail:=$address.detail
	If (String:C10($detail.street_1)#"")
		$lines.push(String:C10($detail.street_1))
	End if
	If (String:C10($detail.street_2)#"")
		$lines.push(String:C10($detail.street_2))
	End if
	If (String:C10($detail.city)#"")
		$lines.push(String:C10($detail.city))
	End if
	//---legacy printed state and zip on one line, three spaces apart
	$cityLine:=""
	If (String:C10($detail.state)#"") | (String:C10($detail.postcode)#"")
		$cityLine:=String:C10($detail.state)+"   "+String:C10($detail.postcode)
		$lines.push($cityLine)
	End if
	If (String:C10($detail.country)#"")
		$lines.push(String:C10($detail.country))
	End if
End if

$text:=$lines.join(Char:C90(Carriage return:K15:38))
