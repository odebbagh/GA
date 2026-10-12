//%attributes = {}
// _wpFill($doc; $context)
// Replaces every {{key}} placeholder in a Write Pro document with the matching value
// from $context.
//
// WP Find all takes the search options as a REQUIRED third parameter, and an optional
// fourth that is the replacement - so one call per key does find-and-replace across the
// whole document. That is how Forms/Form1 uses it.
//
// Values are converted by type, so the caller can put dates and numbers in the context
// without formatting each one by hand.
//
// A key with no placeholder is simply skipped, and a placeholder with no key is left
// visible - deliberately: an unreplaced {{something}} on the page is a far clearer
// fault than a silent blank.

#DECLARE($doc : Object; $context : Object)

var $keys : Collection
var $key : Text
var $value : Text
var $options : Integer
var $ranges : Collection
var $targets : Collection
var $target : Object
var $textBox : Object

If ($doc=Null) | ($context=Null)
	return
End if

//---keep character style so a replacement inherits the formatting of the marker it
//   lands in, rather than resetting to the document default
$options:=wk case insensitive+wk keep character style

//---The body AND every anchored text box, searched separately.
//
//   The group boxes at the top of the buy order are anchored text boxes, and their
//   placeholders do not necessarily live in the document body that WP Find all walks.
//   Rather than depend on whether it descends into anchored elements, each box is
//   searched in its own right. Searching a box that the body pass already covered costs
//   nothing - the placeholder is gone, so the second pass finds nothing.
$targets:=New collection($doc)
For each ($textBox; WP Get elements($doc; wk type text box))
	$targets.push($textBox)
End for each

$keys:=OB Keys($context)

For each ($key; $keys)
	
	Case of
		: (Value type($context[$key])=Is text)
			$value:=$context[$key]
		: (Value type($context[$key])=Is date)
			$value:=($context[$key]=!00-00-00!) ? "" : String($context[$key]; System date short)
		: (Value type($context[$key])=Is boolean)
			$value:=$context[$key] ? "X" : ""
		Else
			$value:=String($context[$key])
	End case
	
	For each ($target; $targets)
		$ranges:=WP Find all($target; "{{"+$key+"}}"; $options; $value)
	End for each
	
End for each