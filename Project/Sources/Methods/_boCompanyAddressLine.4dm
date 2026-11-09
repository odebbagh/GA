//%attributes = {}
// _boCompanyAddressLine($order; $which) -> Text
// Legacy printed YOUR OWN address in the "Bill to" box from the interprocess variables
// <>GBilladd1 and <>GBilladd2, set from Housekeeping at startup. Here it comes from the
// division's [DivisionInfo] remit address, which is the same idea held per division -
// legacy switched the letterhead by division too (SetResetDivisionForLogo).
// Returns "" when there is no DivisionInfo, so the box simply prints empty.

#DECLARE($order : cs:C1710.BuyingOrderEntity; $which : Integer)->$text : Text

var $info : Object
var $address : Object
var $detail : Object

$text:=""
If ($order=Null:C1517) || (String:C10($order.UUID_Division)="")
	return
End if

$info:=ds:C1482.DivisionInfo.query("UUID_Division = :1"; String:C10($order.UUID_Division)).first()
If ($info=Null:C1517) || ($info.contactDetails=Null:C1517) || ($info.contactDetails.addresses=Null:C1517)
	return
End if

$address:=$info.contactDetails.addresses.query("type = :1"; "remit").first()
If ($address=Null:C1517) || ($address.detail=Null:C1517)
	return
End if

$detail:=$address.detail
Case of
	: ($which=1)
		$text:=String:C10($detail.street_1)
	Else
		$text:=String:C10($detail.city)
		If (String:C10($detail.state)#"")
			$text:=$text+", "+String:C10($detail.state)
		End if
		If (String:C10($detail.postcode)#"")
			$text:=$text+" "+String:C10($detail.postcode)
		End if
End case
