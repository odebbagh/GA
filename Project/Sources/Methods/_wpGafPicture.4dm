//%attributes = {}
// _wpGafPicture($doc; $resourcePath; $x; $top; $width; $height) : a picture of the Resources
// folder (the Golden Altos logo) placed on page 1 of a GAF form, in points from the top-left of
// the paper. Nothing when the file is missing: the form prints without it.
#DECLARE($doc : Object; $resourcePath : Text; $x : Real; $top : Real; $width : Real; $height : Real)

var $file : 4D:C1709.File
var $picture : Picture
var $element : Object

$file:=Folder(fk resources folder).file($resourcePath)
If (Not($file.exists))
	return
End if
READ PICTURE FILE($file.platformPath; $picture)
If (Picture size($picture)=0)
	return
End if

$element:=WP Add picture($doc; $picture)
WP SET ATTRIBUTES($element; wk anchor layout; wk in front of text)
WP SET ATTRIBUTES($element; wk anchor origin; wk paper box)
WP SET ATTRIBUTES($element; wk anchor horizontal align; wk left; wk anchor horizontal offset; String($x; "&xml")+"pt")
WP SET ATTRIBUTES($element; wk anchor vertical align; wk top; wk anchor vertical offset; String($top; "&xml")+"pt")
WP SET ATTRIBUTES($element; wk width; String($width; "&xml")+"pt"; wk height; String($height; "&xml")+"pt")
