//%attributes = {}

// _contactDetailsValue($contactDetails; $type) -> Text
// One communication value out of a contactDetails object, which across this application
// is {communications:[{type; contact}]}. Shared by ContactEntity and StaffEntity so the
// two do not drift apart; neither table stores communications any differently.
//
// Types in use: "phone", "fax", "mail".

#DECLARE($contactDetails : Object; $type : Text)->$value : Text

var $entry : Object

$value:=""
If ($contactDetails=Null) || ($contactDetails.communications=Null)
	return
End if

$entry:=$contactDetails.communications.query("type = :1"; $type).first()
If ($entry#Null)
	$value:=String($entry.contact)
End if