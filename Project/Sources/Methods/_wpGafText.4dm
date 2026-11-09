//%attributes = {}
// _wpGafText($doc; $x; $baseline; $width; $text; $style) -> a line of text on a GAF form, placed by
// its baseline as the PDF gives it (points from the top of the paper).
// $style: font (default "Times New Roman"), size (10), bold (False), align ("left" / "center" /
// "right"), and for a block of several lines: height (points) and lineHeight (points) - the
// first baseline then stays where $baseline says.
#DECLARE($doc : Object; $x : Real; $baseline : Real; $width : Real; $text : Text; $style : Object)->$box : Object

var $size : Real
var $lineHeight : Real
var $height : Real
var $top : Real

$size:=($style.size#Null) ? Num($style.size) : 10
$lineHeight:=($style.lineHeight#Null) ? Num($style.lineHeight) : ($size*1.15)
// the baseline of a line sits about 0.9 of the font size below the top of its text, plus half of
// the extra line height
$top:=$baseline-(0.9*$size)-(($lineHeight-($size*1.15))/2)
$height:=($style.height#Null) ? Num($style.height) : ($lineHeight+1)

$box:=_wpGafBox($doc; $x; $top; $width; $height)
WP SET TEXT($box; $text; wk append)
WP SET ATTRIBUTES($box; wk font family; ($style.font#Null) ? String($style.font) : "Times New Roman")
WP SET ATTRIBUTES($box; wk font size; $size)
WP SET ATTRIBUTES($box; wk font bold; Bool($style.bold) ? wk true : wk false)
WP SET ATTRIBUTES($box; wk text color; "#000000")
If ($style.lineHeight#Null)
	WP SET ATTRIBUTES($box; wk line height; String($lineHeight; "&xml")+"pt")
End if
Case of
	: (String($style.align)="center")
		WP SET ATTRIBUTES($box; wk text align; wk center)
	: (String($style.align)="right")
		WP SET ATTRIBUTES($box; wk text align; wk right)
End case
