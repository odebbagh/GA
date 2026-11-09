//%attributes = {}
// _wpGafBox($doc; $x; $top; $width; $height) -> an empty anchored text box on page 1, placed from
// the top-left corner of the paper, in points - the coordinates of the original GAF PDF
// (_ga_buildHoldFormTemplates). No border, no padding, transparent: the other _wpGaf* helpers
// dress it.
#DECLARE($doc : Object; $x : Real; $top : Real; $width : Real; $height : Real)->$box : Object

$box:=WP New text box($doc; 1)
WP SET ATTRIBUTES($box; wk anchor origin; wk paper box)
WP SET ATTRIBUTES($box; wk anchor horizontal align; wk left; wk anchor horizontal offset; String($x; "&xml")+"pt")
WP SET ATTRIBUTES($box; wk anchor vertical align; wk top; wk anchor vertical offset; String($top; "&xml")+"pt")
WP SET ATTRIBUTES($box; wk width; String($width; "&xml")+"pt"; wk height; String($height; "&xml")+"pt")
WP SET ATTRIBUTES($box; wk margin; "0pt"; wk padding; "0pt"; wk border style; wk none)
// transparent: a box laid over a line (a value on the line it fills) must not paint it out
WP SET ATTRIBUTES($box; wk background color; wk transparent)
