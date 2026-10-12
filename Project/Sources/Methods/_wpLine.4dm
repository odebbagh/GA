//%attributes = {}
// _wpLine($doc; $text; $size; $bold)
// Appends one paragraph of plain text. The building blocks below all go through this so
// the base style stays in one place.

#DECLARE($doc : Object; $text : Text; $size : Integer; $bold : Boolean)

var $range : Object

$range:=WP Text range:C1341($doc; wk end text; wk end text)
WP SET TEXT:C1574($range; $text+Char:C90(Carriage return:K15:38); wk append; wk include in range)

If ($size>0)
	WP SET ATTRIBUTES:C1342($range; wk font size; $size)
End if
WP SET ATTRIBUTES:C1342($range; wk font bold; $bold ? wk true : wk false)
