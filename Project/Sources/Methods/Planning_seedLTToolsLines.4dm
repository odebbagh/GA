//%attributes = {}
// Adds inline toolsBlock to LT - Step and removes tools CRS lines from the Lot Traveller template.

var $i : Integer
var $indices : Collection
var $lineEntry : Object
var $lineItem : Object
var $message : Text
var $obj : Object
var $objects : Collection
var $okCount : Integer
var $res : Object
var $stepLine : cs:C1710.dfd_LineEntity
var $subCol : Text
var $tag : Object
var $tags : Collection
var $template : cs:C1710.dfd_TemplateEntity
var $templateName : Text
var $templateUpdated : Boolean
var $toolsHeaderLine : cs:C1710.dfd_LineEntity
var $toolsRowLine : cs:C1710.dfd_LineEntity

$templateName:="Lot Traveller"
$okCount:=0
$templateUpdated:=False:C215

$stepLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Step").first()
If ($stepLine=Null:C1517)
	ALERT:C41("LT - Step line not found.")
	return 
End if 

If ($stepLine.objectsForm=Null:C1517)
	$stepLine.objectsForm:=New object:C1471("objects"; New collection:C1472())
End if 
If ($stepLine.objectsForm.objects=Null:C1517)
	$stepLine.objectsForm.objects:=New collection:C1472()
End if 

$objects:=$stepLine.objectsForm.objects

For ($i; $objects.length-1; 0; -1)
	$obj:=$objects[$i]
	If ($obj.name="text_15")
		$objects.remove($i)
	Else 
		If ($obj.name="line_5")
			$objects.remove($i)
		Else 
			If ($obj.name="text_2") && ($obj.properties#Null:C1517) && (String:C10($obj.properties.text)="Tools *Cal Due Date:")
				$objects.remove($i)
			End if 
		End if 
	End if 
End for 

$indices:=$objects.indices("name = :1"; "toolsBlock")
If ($indices.length=0)
	$lineItem:=New object:C1471("name"; "toolsBlock"; "order"; 26; "properties"; New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 42; "left"; 279; "width"; 295; "height"; "auto"; "text"; "##this.toolsBlock##"; "visibility"; "##this.hasTools##"; "fontFamily"; "Helvetica"; "fontSize"; 9))
	$objects.push($lineItem)
Else 
	$objects[$indices[0]].properties:=New object:C1471("type"; "text"; "_origineType"; "text"; "top"; 42; "left"; 279; "width"; 295; "height"; "auto"; "text"; "##this.toolsBlock##"; "visibility"; "##this.hasTools##"; "fontFamily"; "Helvetica"; "fontSize"; 9)
End if 

$stepLine.calculs:=New object:C1471("rules"; New collection:C1472(\
New object:C1471("rule"; "line_1.bottom:=description.bottom+5"); \
New object:C1471("rule"; "line_2.bottom:=description.bottom+5"); \
New object:C1471("rule"; "line_3.bottom:=description.bottom+5"); \
New object:C1471("rule"; "line_4.bottom:=description.bottom+5")\
))

If ($stepLine.variableItems=Null:C1517)
	$stepLine.variableItems:=New object:C1471("tags"; New collection:C1472())
End if 
If ($stepLine.variableItems.tags=Null:C1517)
	$stepLine.variableItems.tags:=New collection:C1472()
End if 

$tags:=$stepLine.variableItems.tags
If ($tags.indices("tag = :1"; "this.toolsBlock").length=0)
	$tags.push(New object:C1471("tag"; "this.toolsBlock"; "objects"; New collection:C1472("toolsBlock")))
End if 
If ($tags.indices("tag = :1"; "this.hasTools").length=0)
	$tags.push(New object:C1471("tag"; "this.hasTools"; "objects"; New collection:C1472("toolsBlock")))
End if 

$res:=$stepLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$toolsHeaderLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Tools Header").first()
$toolsRowLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Tools").first()

$template:=ds:C1482.dfd_Template.query("name = :1"; $templateName).first()
If ($template#Null:C1517) && ($template.hierarchy#Null:C1517) && ($template.hierarchy.lines#Null:C1517)
	For ($i; $template.hierarchy.lines.length-1; 0; -1)
		$lineEntry:=$template.hierarchy.lines[$i]
		If ($lineEntry.typology="CRS")
			$subCol:=""
			If ($lineEntry.properties#Null:C1517)
				For each ($tag; $lineEntry.properties)
					If ($tag.kind="subcollectionSource")
						$subCol:=String:C10($tag.value)
					End if 
				End for each 
			End if 
			If ($toolsHeaderLine#Null:C1517) && ($lineEntry.UUID_entity=$toolsHeaderLine.UUID)
				$template.hierarchy.lines.remove($i)
			Else 
				If ($toolsRowLine#Null:C1517) && ($lineEntry.UUID_entity=$toolsRowLine.UUID)
					$template.hierarchy.lines.remove($i)
				Else 
					If ($subCol="toolsH") || ($subCol="tools")
						$template.hierarchy.lines.remove($i)
					End if 
				End if 
			End if 
		End if 
	End for 
	$res:=$template.save()
	If ($res.success)
		$templateUpdated:=True:C214
		$okCount:=$okCount+1
	End if 
End if 

$message:=String:C10($okCount)+" update(s) applied."
If ($templateUpdated)
	$message:=$message+"\rTools now render inline on LT - Step (below the qty grid)."
Else 
	$message:=$message+"\rLT - Step updated. Re-run if template tools CRS lines still need removal."
End if 

ALERT:C41($message)

Planning_seedLTStepLayout
