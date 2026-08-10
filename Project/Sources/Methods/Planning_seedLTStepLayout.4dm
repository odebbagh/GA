//%attributes = {}
// Fixes LT - Step borders and wires step/page table closing into the Lot Traveller template.

var $blockEnd : Integer
var $footerCrsIdx : Integer
var $footerLine : cs:C1710.dfd_LineEntity
var $hasFooterCrs : Boolean
var $hasPageCloseRp : Boolean
var $i : Integer
var $indices : Collection
var $insertAt : Integer
var $lineEntry : Object
var $lineRef : Object
var $message : Text
var $misplacedFooterCrs : Object
var $misplacedFooterCrsIdx : Integer
var $misplacedRp : Object
var $misplacedRpIdx : Integer
var $objects : Collection
var $okCount : Integer
var $res : Object
var $rpIdx : Integer
var $stepLine : cs:C1710.dfd_LineEntity
var $template : cs:C1710.dfd_TemplateEntity
var $templateLines : Collection
var $templateName : Text

$templateName:="Lot Traveller"
$okCount:=0

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

// Step row: side borders follow description; bottom border is on LT - Step Footer only.
$objects:=$stepLine.objectsForm.objects
For ($i; $objects.length-1; 0; -1)
	If ($objects[$i].name="line_5")
		$objects.remove($i)
	End if 
End for 

$stepLine.calculs:=New object:C1471("rules"; New collection:C1472(\
New object:C1471("rule"; "line_1.bottom:=description.bottom+5"); \
New object:C1471("rule"; "line_2.bottom:=description.bottom+5"); \
New object:C1471("rule"; "line_3.bottom:=description.bottom+5"); \
New object:C1471("rule"; "line_4.bottom:=description.bottom+5")\
))

$res:=$stepLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$footerLine:=Planning_travLTStepFooterLine()
$res:=$footerLine.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$template:=ds:C1482.dfd_Template.query("name = :1"; $templateName).first()
If ($template=Null:C1517)
	ALERT:C41(String:C10($okCount)+" step line saved.\rTemplate not found: "+$templateName)
	return 
End if 

If ($template.hierarchy=Null:C1517)
	$template.hierarchy:=New object:C1471("lines"; New collection:C1472())
End if 
If ($template.hierarchy.lines=Null:C1517)
	$template.hierarchy.lines:=New collection:C1472()
End if 

$templateLines:=$template.hierarchy.lines
$hasFooterCrs:=False:C215
$hasPageCloseRp:=False:C215
$rpIdx:=-1
$footerCrsIdx:=-1
$misplacedRpIdx:=-1
$misplacedFooterCrsIdx:=-1
$misplacedRp:=Null:C1517
$misplacedFooterCrs:=Null:C1517

For ($i; 0; $templateLines.length-1)
	$lineEntry:=$templateLines[$i]
	If (String:C10($lineEntry.UUID_entity)=String:C10($footerLine.UUID))
		If ($lineEntry.typology="CRS")
			$hasFooterCrs:=True:C214
			$footerCrsIdx:=$i
		End if 
		If ($lineEntry.typology="RP")
			$hasPageCloseRp:=True:C214
			$rpIdx:=$i
		End if 
	End if 
End for 

$blockEnd:=Planning_travLTStepsBlockEnd($templateLines; String:C10($stepLine.UUID); String:C10($footerLine.UUID))
If ($blockEnd=-1)
	ALERT:C41(String:C10($okCount)+" step line saved.\rLT - Step CR not found in template.")
	return 
End if 

// Footer CRS / RP must be last in the step block — never between Step CR and binning/DT.
If ($hasFooterCrs) && ($footerCrsIdx>=0) && ($footerCrsIdx<($blockEnd-1))
	$misplacedFooterCrsIdx:=$footerCrsIdx
	$misplacedFooterCrs:=$templateLines[$footerCrsIdx]
	$templateLines.remove($footerCrsIdx)
	If ($misplacedFooterCrsIdx<$blockEnd)
		$blockEnd:=$blockEnd-1
	End if 
	If ($rpIdx>$misplacedFooterCrsIdx)
		$rpIdx:=$rpIdx-1
	End if 
	$hasFooterCrs:=False:C215
End if 

If ($hasPageCloseRp) && ($rpIdx>=0) && ($rpIdx<($blockEnd-1))
	$misplacedRpIdx:=$rpIdx
	$misplacedRp:=$templateLines[$rpIdx]
	$templateLines.remove($rpIdx)
	If ($misplacedRpIdx<$blockEnd)
		$blockEnd:=$blockEnd-1
	End if 
	$hasPageCloseRp:=False:C215
End if 

If (Not:C34($hasFooterCrs))
	$blockEnd:=Planning_travLTStepsBlockEnd($templateLines; String:C10($stepLine.UUID); String:C10($footerLine.UUID))
	$insertAt:=$blockEnd
	If ($misplacedFooterCrs#Null:C1517)
		$lineRef:=$misplacedFooterCrs
	Else 
		$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $footerLine.UUID; \
"typology"; "CRS"; \
"properties"; New collection:C1472(\
New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"); \
New object:C1471("name"; "groupWithMain"; "kind"; "groupWithMain"; "value"; "true")\
)\
)
	End if 
	$templateLines.insert($insertAt; $lineRef)
	$okCount:=$okCount+1
End if 

If (Not:C34($hasPageCloseRp))
	$blockEnd:=Planning_travLTStepsBlockEnd($templateLines; String:C10($stepLine.UUID); String:C10($footerLine.UUID))
	If ($misplacedRp#Null:C1517)
		$lineRef:=$misplacedRp
	Else 
		$lineRef:=New object:C1471(\
"kind"; "template_line"; \
"UUID_entity"; $footerLine.UUID; \
"typology"; "RP"; \
"properties"; New collection:C1472(\
New object:C1471("name"; "source collection"; "kind"; "collectionSource"; "value"; "steps"); \
New object:C1471("name"; "afficher en fin"; "kind"; "displayAtEnd"; "value"; "true")\
)\
)
	End if 
	$templateLines.insert($blockEnd; $lineRef)
	$okCount:=$okCount+1
End if 

$template.hierarchy.lines:=$templateLines
$res:=$template.save()
If ($res.success)
	$okCount:=$okCount+1
End if 

$message:=String:C10($okCount)+" layout update(s) applied."
$message:=$message+"\r- Step side borders only (no mid-row horizontal on LT - Step)"
$message:=$message+"\r- Step footer is horizontal bottom border only"
$message:=$message+"\r- Footer CRS/RP moved after binning and data-table sublines"
ALERT:C41($message)
