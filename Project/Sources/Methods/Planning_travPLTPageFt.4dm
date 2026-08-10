//%attributes = {}
// PLT - Page Footer
#DECLARE()->$line : cs:C1710.dfd_LineEntity

var $lineItem : Object
var $objects : Collection
var $tags : Collection

$line:=ds:C1482.dfd_Line.query("name = :1"; "PLT - Page Footer").first()
If ($line=Null:C1517)
	$line:=ds:C1482.dfd_Line.new()
End if 

$line.name:="PLT - Page Footer"
$line.calculs:=New object:C1471("rules"; New collection:C1472())
$line.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"))
$line.objectsForm:=New object:C1471("objects"; New collection:C1472())
$objects:=$line.objectsForm.objects
$tags:=New collection:C1472()

$lineItem:=New object:C1471("name"; "text_footer"; "order"; 1; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 0; "left"; 0; "width"; 574; "height"; 12; "text"; "Form: PTS1 GAF# 1492 Rev. 08  Job# ##jobNumber##  Lot # ##lotNumber##                    Page: #!page!#"; "fontFamily"; "Helvetica"; "fontSize"; 7; "textAlign"; "right"))
$objects.push($lineItem)
$tags.push(New object:C1471("tag"; "jobNumber"; "objects"; New collection:C1472("text_footer")))
$tags.push(New object:C1471("tag"; "lotNumber"; "objects"; New collection:C1472("text_footer")))

$line.variableItems:=New object:C1471("tags"; $tags)

return $line
