//%attributes = {}

/*
_wpGroupBox($doc; $caption; $left; $top; $width; $height; $captionWidth; $content) -> Object

Draws one 4D group box - a bordered rectangle with its caption sitting ON the top border
line, breaking it:

        +-- Issued to: ------------------+
        | ECR LABORATORY, INC            |
        | 916 COMMERCIAL STREET          |
        +--------------------------------+

Write Pro has no group box and no table can produce this, because a table caption is
always a row INSIDE the border. It is done with two anchored text boxes instead:

  1. the box itself - bordered, positioned absolutely, holding the content
  2. a small caption box laid OVER the top border, with a white background and no border
     of its own, which paints out the piece of line behind the caption text

Positions are in cm from the top-left of the page and follow the pattern proven in
panel_quote: WP New text box, then wk margin left / wk margin top to place it. Returns
the content box so the caller can style it further.

$captionWidth has to be wide enough for the caption text and no wider - it is the length
of border that gets painted out.
*/

#DECLARE($doc : Object; $caption : Text; $left : Real; $top : Real; $width : Real; \
	$height : Real; $captionWidth : Real; $content : Text)->$box : Object

var $captionBox : Object

//---the bordered rectangle
$box:=WP New text box($doc; 1)
WP SET ATTRIBUTES($box; wk margin left; String($left)+"cm")
WP SET ATTRIBUTES($box; wk margin top; String($top)+"cm")
WP SET ATTRIBUTES($box; wk width; String($width)+"cm")
WP SET ATTRIBUTES($box; wk height; String($height)+"cm")
WP SET ATTRIBUTES($box; wk border style; wk solid)
WP SET ATTRIBUTES($box; wk border width; "0.5pt")
WP SET ATTRIBUTES($box; wk border color; "#000000")
WP SET ATTRIBUTES($box; wk padding; "0.15cm")
WP SET ATTRIBUTES($box; wk font family; "Arial")
WP SET ATTRIBUTES($box; wk font size; 9)

If ($content#"")
	WP SET TEXT($box; $content; wk append)
End if

//---the caption, sitting on the top border line. 0.35cm in from the left corner so the
//   corner itself stays drawn, and lifted by 0.19cm so the text straddles the line.
If ($caption#"")
	$captionBox:=WP New text box($doc; 1)
	WP SET ATTRIBUTES($captionBox; wk margin left; String($left+0.35)+"cm")
	WP SET ATTRIBUTES($captionBox; wk margin top; String($top-0.19)+"cm")
	WP SET ATTRIBUTES($captionBox; wk width; String($captionWidth)+"cm")
	WP SET ATTRIBUTES($captionBox; wk height; "0.38cm")
	WP SET ATTRIBUTES($captionBox; wk border style; wk none)
	WP SET ATTRIBUTES($captionBox; wk background color; "#FFFFFF")
	WP SET ATTRIBUTES($captionBox; wk padding; "0cm")
	WP SET ATTRIBUTES($captionBox; wk font family; "Arial")
	WP SET ATTRIBUTES($captionBox; wk font size; 8)
	WP SET ATTRIBUTES($captionBox; wk font bold; True)
	WP SET TEXT($captionBox; $caption; wk append)
End if