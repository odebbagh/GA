//%attributes = {}
// Creates/updates Production Lot Traveller DFD lines and template.

var $headerAPLine : cs:C1710.dfd_LineEntity
var $headerFPLine : cs:C1710.dfd_LineEntity
var $lineRef : Object
var $message : Text
var $okCount : Integer
var $pageFooterLine : cs:C1710.dfd_LineEntity
var $res : Object
var $stepLine : cs:C1710.dfd_LineEntity
var $template : cs:C1710.dfd_TemplateEntity
var $templateName : Text

$templateName:="Production Lot Traveller"
$okCount:=0

$headerFPLine:=Planning_travPLTHeaderFP()
$res:=$headerFPLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$headerAPLine:=Planning_travPLTHeaderAP()
$res:=$headerAPLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$stepLine:=Planning_travPLTStep()
$res:=$stepLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$pageFooterLine:=Planning_travPLTPageFt()
$res:=$pageFooterLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$template:=ds:C1482.dfd_Template.query("name = :1"; $templateName).first()
If ($template=Null:C1517)
	$template:=ds:C1482.dfd_Template.new()
End if 

$template.name:=$templateName
$template.calculs:=New object:C1471("rules"; New collection:C1472())
$template.moreData:=New object:C1471("settings"; New object:C1471("format"; "A4"; "orientation"; "portrait"; "printPreview"; False:C215))
$template.hierarchy:=New object:C1471("lines"; New collection:C1472())

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $headerFPLine.UUID; "typology"; "EPP")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $headerAPLine.UUID; "typology"; "EPS")
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $stepLine.UUID; \
"typology"; "CR"; \
"properties"; New collection:C1472(New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"))\
)
$template.hierarchy.lines.push($lineRef)

$lineRef:=New object:C1471("kind"; "template_line"; "UUID_entity"; $pageFooterLine.UUID; "typology"; "PP")
$template.hierarchy.lines.push($lineRef)

$res:=$template.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$message:=String:C10($okCount)+" Production Lot Traveller record(s) created or updated."
$message:=$message+"\rTemplate: "+$templateName
$message:=$message+"\rRun Planning_printProdLotTrav from Planning to test."
ALERT:C41($message)
