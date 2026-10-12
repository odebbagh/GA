//%attributes = {}
//%attributes = {}
// _wpAppendField($doc; $label; $key)
// Appends "Label: <formula>" and a carriage return to a Write Pro document.
// The formula is built from the key so the caller can drive it from a list.
// Inside a document with a data context, formulas reference This.

#DECLARE($doc : Object; $label : Text; $key : Text)

var $range : Object

$range:=WP Text range:C1341($doc; wk end text:K81:164; wk end text:K81:164)
WP SET TEXT:C1574($range; $label+": "; wk append:K81:179; wk include in range:K81:180)

If ($key#"")
	$range:=WP Text range:C1341($doc; wk end text:K81:164; wk end text:K81:164)
	WP Insert formula:C1703($range; Formula from string:C1601("This."+$key); wk include in range:K81:180)
End if 

$range:=WP Text range:C1341($doc; wk end text:K81:164; wk end text:K81:164)
WP SET TEXT:C1574($range; Char:C90(Carriage return:K15:38); wk append:K81:179; wk include in range:K81:180)