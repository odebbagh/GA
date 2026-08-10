//%attributes = {}
// Address_toSingleLine
// Renders an sfw address object ({type; detail:{street_1; street_2; city; state;
// postcode; country; ...}}) as one readable line, skipping the empty parts.
// Used to display a full address inside a list box column.

#DECLARE($address : Object)->$text : Text

var $detail : Object
var $parts : Collection
var $cityLine : Collection
var $country : Text

$text:=""

If ($address=Null:C1517)
	return $text
End if

$detail:=$address.detail
If ($detail=Null:C1517)
	return $text
End if

$parts:=New collection:C1472()

If (String:C10($detail.service)#"")
	$parts.push(String:C10($detail.service))
End if
If (String:C10($detail.street_1)#"")
	$parts.push(String:C10($detail.street_1))
End if
If (String:C10($detail.street_2)#"")
	$parts.push(String:C10($detail.street_2))
End if

// city / state / postcode belong together on the same segment
$cityLine:=New collection:C1472()
If (String:C10($detail.city)#"")
	$cityLine.push(String:C10($detail.city))
End if
If (String:C10($detail.state)#"")
	$cityLine.push(String:C10($detail.state))
End if
If (String:C10($detail.postcode)#"")
	$cityLine.push(String:C10($detail.postcode))
End if
If ($cityLine.length>0)
	$parts.push($cityLine.join(" "))
End if

$country:=Uppercase:C13(String:C10($detail.country))
If ($country#"")
	$parts.push($country)
End if

$text:=$parts.join(", ")
