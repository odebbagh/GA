//%attributes = {}
// _wpRule($doc)
// A horizontal rule, drawn as a paragraph carrying only a bottom border - the legacy
// form used Line objects, which Write Pro has no equivalent for.

#DECLARE($doc : Object)

var $range : Object

$range:=WP Text range:C1341($doc; wk end text; wk end text)
WP SET TEXT:C1574($range; Char:C90(Carriage return:K15:38); wk append; wk include in range)
WP SET ATTRIBUTES:C1342($range; wk border style bottom; wk solid)
WP SET ATTRIBUTES:C1342($range; wk border width bottom; "0.5pt")
