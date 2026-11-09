//%attributes = {}
// _boBuyerContact($uuid) -> Text
// Legacy object method Field11 overwrote [BUY_ORDERS]BuyersCode at print time with the
// buyer's contact details, one per line:
//     Tel: ...
//     Fax: ...
//     Email: ...
// each only when the employee record had it. Same thing, off [Staff].

#DECLARE($uuid : Text)->$text : Text

var $staff : cs:C1710.StaffEntity
var $lines : Collection
var $value : Text

$text:=""
If (String:C10($uuid)="") || (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($uuid)))
	return
End if

$staff:=ds:C1482.Staff.query("UUID = :1"; String:C10($uuid)).first()
If ($staff=Null:C1517) || ($staff.contactDetails=Null:C1517) || ($staff.contactDetails.communications=Null:C1517)
	return
End if

$lines:=New collection:C1472()

$value:=_boContactPoint($staff; "phone")
If ($value#"")
	$lines.push("Tel: "+$value)
End if
$value:=_boContactPoint($staff; "fax")
If ($value#"")
	$lines.push("Fax: "+$value)
End if
$value:=_boContactPoint($staff; "mail")
If ($value#"")
	$lines.push("Email: "+$value)
End if

$text:=$lines.join(Char:C90(Carriage return:K15:38))
