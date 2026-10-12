//%attributes = {}
// _boStaffName($uuid : Text) -> Text
// A staff member's full name from their UUID, or "" when it does not resolve.
//
// Used where the name is reached through a FK rather than a relation attribute.
// [BuyingOrder] keeps a legacy text column called buyer AND has UUID_Buyer; the relation
// over that FK is now called staff, so the two no longer collide - but reading the FK
// stays the unambiguous route and works whatever the relation is called.

#DECLARE($uuid : Text)->$name : Text

var $staff : cs:C1710.StaffEntity

$name:=""
If (String:C10($uuid)="")
	return
End if
If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($uuid)))
	return
End if

$staff:=ds:C1482.Staff.query("UUID = :1"; String:C10($uuid)).first()
If ($staff#Null:C1517)
	$name:=String:C10($staff.fullName)
End if