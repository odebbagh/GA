//%attributes = {}
// _wpGafRect($doc; $x; $top; $width; $height) : a black filled rectangle on a GAF form - the frame
// bars and the lines to write on, as the original PDF draws them (points from the top-left of the
// paper).
#DECLARE($doc : Object; $x : Real; $top : Real; $width : Real; $height : Real)

var $box : Object

$box:=_wpGafBox($doc; $x; $top; $width; $height)
WP SET ATTRIBUTES($box; wk background color; "#000000")
// the box keeps its height: the font of its empty paragraph only has to be small (1pt is the minimum)
WP SET ATTRIBUTES($box; wk font size; 1)
