//%attributes = {}
// _wpField($doc; $label; $key)
// Appends "Label: {{key}}" and a carriage return. An empty label emits the placeholder
// on its own, which is what the address blocks want.
//
// NOT a Write Pro formula. WP Insert formula does not exist in this version - the token
// resolves to a different command entirely - so the values are plain {{key}} markers
// that _wpFill swaps for real text at print time, using WP Find all. That command IS
// used elsewhere in this application, which the formula route never was.

#DECLARE($doc : Object; $label : Text; $key : Text)

var $range : Object
var $text : Text

$text:=""
If ($label#"")
	$text:=$label+": "
End if
If ($key#"")
	$text:=$text+"{{"+$key+"}}"
End if

$range:=WP Text range($doc; wk end text; wk end text)
WP SET TEXT($range; $text+Char(Carriage return); wk append; wk include in range)