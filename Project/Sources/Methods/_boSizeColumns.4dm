//%attributes = {}
// _boSizeColumns($table; $showPartNumber)
// The legacy PL_SetWidths pixel widths, converted at 96dpi (1px = 0.0265cm).
//
//   part-number layout : 35 150 65 40 45 60 40 64 46
//   order-date layout  : 33 155 36 45 60 45 64 55 55
//
// Money, quantity and date columns print right-aligned, as PL_SetFormat implied.

#DECLARE($table : Object; $showPartNumber : Boolean)

//---the same tight, predictable padding the template's own tables use, so nine columns
//   of padding cannot push the line table past the right margin
WP SET ATTRIBUTES:C1342($table; wk padding; "0.08cm")

var $widths : Collection
var $rightAligned : Collection
var $i : Integer
var $column : Object

If ($showPartNumber)
	$widths:=New collection:C1472("0.93cm"; "3.97cm"; "1.72cm"; "1.06cm"; "1.19cm"; "1.59cm"; "1.06cm"; "1.69cm"; "1.22cm")
	$rightAligned:=New collection:C1472(False:C215; False:C215; False:C215; False:C215; True:C214; True:C214; True:C214; True:C214; True:C214)
Else
	$widths:=New collection:C1472("0.87cm"; "4.10cm"; "0.95cm"; "1.19cm"; "1.59cm"; "1.19cm"; "1.69cm"; "1.46cm"; "1.46cm")
	$rightAligned:=New collection:C1472(False:C215; False:C215; False:C215; True:C214; True:C214; True:C214; True:C214; True:C214; True:C214)
End if

For ($i; 1; $widths.length)
	$column:=WP Table get columns:C1476($table; $i)
	WP SET ATTRIBUTES:C1342($column; wk width; $widths[$i-1])
	WP SET ATTRIBUTES:C1342($column; wk text align; $rightAligned[$i-1] ? wk right : wk left)
End for