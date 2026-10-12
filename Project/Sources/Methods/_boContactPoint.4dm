//%attributes = {}
// _boContactPoint($contact; $type) -> Text
// One communication off a [Contact], matching the "Fax:" and "Tel:" lines legacy printed
// from [BUY_ORDERS]Attention_Fax / Attention_Tel. contactDetails.communications is the
// {type; contact} collection the rest of this application uses.

#DECLARE($contact : Object; $type : Text)->$text : Text

var $entry : Object

$text:=""
If ($contact=Null:C1517) || ($contact.contactDetails=Null:C1517)
	return
End if
If ($contact.contactDetails.communications=Null:C1517)
	return
End if

$entry:=$contact.contactDetails.communications.query("type = :1"; $type).first()
If ($entry#Null:C1517)
	$text:=String:C10($entry.contact)
End if
