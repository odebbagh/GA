//%attributes = {}
// _boSizeReceiptColumns($table)
// The receipt's lot table, inserted by BOReceiving_printReceipt in place of Lots@. Sized
// by _wpFitColumns to the same outer width as every table in the BUY_RECEIPT template, so
// its right edge lines up with them - the fixed widths it had before totalled 19.5cm
// before Write Pro added padding and borders, and ran off the page.
//
// Columns: Part # | Stock # | Lot # | Qty | Original Qty | Date In | Currency | Unit Cost | Value

#DECLARE($table : Object)

var $rightAligned : Collection
var $i : Integer
var $column : Object

_wpFitColumns($table; New collection:C1472(2.3; 2.1; 2.3; 1.4; 1.8; 1.7; 1.3; 1.8; 2.2); "#000000")

$rightAligned:=New collection:C1472(False:C215; False:C215; False:C215; True:C214; True:C214; False:C215; False:C215; True:C214; True:C214)
For ($i; 1; $rightAligned.length)
	$column:=WP Table get columns:C1476($table; $i)
	WP SET ATTRIBUTES:C1342($column; wk text align; $rightAligned[$i-1] ? wk right : wk left)
End for

//---nine columns in 18.8cm: a point smaller than the rest of the page so the headers fit
WP SET ATTRIBUTES:C1342($table; wk font size; 8)