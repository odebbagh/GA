//%attributes = {}

/*
_wpFitColumns($table; $weights; $borderColor)

Sizes a Write Pro table so that its OUTER width is the same as every other table sized
with it, whatever its number of columns. That is what makes the right edges of the
receipt line up.

Write Pro adds each cell's padding and borders ON TOP of the declared column width, so a
9-column table declared as wide as a 2-column one comes out wider. Here every cell gets the
same padding and the same 0.5pt border, and what they take is subtracted before the rest
is shared out between the columns by $weights (any numbers - only their proportions count).

$borderColor "#000000" draws the grid; "#FFFFFF" draws the same border invisibly, so a
table meant to look borderless keeps exactly the same geometry as the others.

Call it AFTER the rows are appended: the cell attributes are set on the rows that exist.

Widths are written with a "." decimal. String() follows the system locale, and a French
system writes "2,3cm", which Write Pro does not read as 2.3cm.
*/

#DECLARE($table : Object; $weights : Collection; $borderColor : Text)

var $outer; $padding; $border; $content; $sum : Real
var $i : Integer
var $column; $cells : Object

$outer:=18.8  // cm - every table on the page
$padding:=0.1  // cm, each side of each cell
$border:=0.5/72*2.54  // 0.5pt, in cm

$content:=$outer-($weights.length*2*$padding)-(($weights.length+1)*$border)
$sum:=$weights.sum()

For ($i; 0; $weights.length-1)
	$column:=WP Table get columns($table; $i+1)
	WP SET ATTRIBUTES($column; wk width; Replace string(String(Round($content*Num($weights[$i])/$sum; 3)); ","; ".")+"cm")
End for

//---the cells carry the padding and the grid; the table itself draws no extra frame.
//   WP Table get cells on the table alone returns every cell it has.
$cells:=WP Table get cells($table)
WP SET ATTRIBUTES($cells; wk padding; Replace string(String($padding); ","; ".")+"cm")
WP SET ATTRIBUTES($cells; wk border style; wk solid)
WP SET ATTRIBUTES($cells; wk border width; "0.5pt")
WP SET ATTRIBUTES($cells; wk border color; $borderColor)
WP SET ATTRIBUTES($table; wk border style; wk none)
