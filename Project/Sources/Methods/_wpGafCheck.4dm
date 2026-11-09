//%attributes = {}
// _wpGafCheck($doc; $x; $top; $width; $height; $token) : a tick box of a GAF form, as the PDF draws
// it (points from the top-left of the paper). It holds {{$token}}, which LotHoldForm_printBox
// makes "X" or empty at print time.
#DECLARE($doc : Object; $x : Real; $top : Real; $width : Real; $height : Real; $token : Text)

var $box : Object

$box:=_wpGafBox($doc; $x; $top; $width; $height)
WP SET ATTRIBUTES($box; wk border style; wk solid; wk border width; "0.72pt"; wk border color; "#000000")
WP SET TEXT($box; "{{"+$token+"}}"; wk append)
WP SET ATTRIBUTES($box; wk font family; "Arial"; wk font size; 8; wk font bold; wk true; wk text color; "#000000")
WP SET ATTRIBUTES($box; wk text align; wk center; wk padding top; "1pt")
